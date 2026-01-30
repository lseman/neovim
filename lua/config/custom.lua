-- lua/buf_replace/init.lua
local M = {}

-- Lazy telescope deps
local function T()
  return {
    actions = require('telescope.actions'),
    state   = require('telescope.actions.state'),
    pickers = require('telescope.pickers'),
    finders = require('telescope.finders'),
    conf    = require('telescope.config').values,
  }
end

-- ── Config (can be overridden via M.setup) ─────────────────────────────────
local Config = {
  literal = true,      -- default: literal search (escape all magic)
  ignorecase = true,   -- default: case-insensitive
  confirm = true,      -- pass `c` flag to :substitute
  word = false,        -- regex word-boundaries when regex mode
  max_height_frac = 0.8,
  max_width_frac  = 0.8,
}

function M.setup(opts)
  Config = vim.tbl_deep_extend("force", Config, opts or {})
end

-- ── Utils ─────────────────────────────────────────────────────────────────
local function build_search_pattern(q, o)
  o = o or {}
  local literal = o.literal
  local ignorecase = o.ignorecase
  local word = o.word

  if q == "" then return "" end

  if literal then
    -- Very nomagic + escaped
    local esc = vim.fn.escape(q, [[\.^$*~[]/]])
    local prefix = ignorecase and [[\V\c]] or [[\V\C]]
    -- \V makes everything literal; we still need to escape the delimiter and backslashes
    return prefix .. esc
  else
    -- Regex mode; add word boundaries if asked
    local body = q
    if word then
      body = [[\b]] .. body .. [[\b]]
    end
    local prefix = ignorecase and [[\v\c]] or [[\v\C]]
    return prefix .. body
  end
end

local function compile_regex(q, o)
  -- For scanning line-by-line with vim.regex; only used when not literal.
  local pat = build_search_pattern(q, o)
  local ok, rx = pcall(vim.regex, pat)
  if not ok then return nil end
  return rx
end

-- Return all matches as { lnum=int, text=string }
local function get_all_matches(bufnr, query, opts)
  local matches = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  if query == "" then
    return matches
  end

  if opts.literal then
    -- Fast literal scan
    local needle = query
    if opts.ignorecase then
      needle = needle:lower()
    end
    for i, line in ipairs(lines) do
      local hay = opts.ignorecase and line:lower() or line
      if hay:find(needle, 1, true) then
        table.insert(matches, { lnum = i, text = line })
      end
    end
  else
    -- Regex scan via vim.regex
    local rx = compile_regex(query, opts)
    if not rx then return matches end
    for i, line in ipairs(lines) do
      local s, e = rx:match_str(line)
      if s ~= nil and e ~= nil then
        table.insert(matches, { lnum = i, text = line })
      end
    end
  end
  return matches
end

-- Render preview lines for replacements
local function render_preview_lines(bufnr, search_text, replace_text, opts)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local out = {}
  table.insert(out, ("Previewing replacements for: %q"):format(search_text))
  table.insert(out, string.rep("-", 40))
  table.insert(out, "")

  local found_any = false
  local pat = build_search_pattern(search_text, opts)

  local function gsub_safe(line)
    -- Use vim.fn.substitute to respect magic flags in `pat`
    -- Need to escape replacement ampersands and backslashes for :substitute semantics
    local repl = (replace_text or ""):gsub([[\]], [[\\]]):gsub("&", [[\&]])
    local ok, res = pcall(function()
      return vim.fn.substitute(line, pat, repl, "g")
    end)
    return ok and res or line
  end

  for i, line in ipairs(lines) do
    local new_line = line
    local matched = false
    if opts.literal then
      local needle = search_text
      local hay = line
      if opts.ignorecase then
        needle = needle:lower()
        hay = hay:lower()
      end
      if needle ~= "" then
        matched = hay:find(needle, 1, true) ~= nil
      end
      if matched then
        new_line = gsub_safe(line)
      end
    else
      local rx = compile_regex(search_text, opts)
      if rx then
        local s, e = rx:match_str(line)
        matched = (s ~= nil and e ~= nil)
        if matched then
          new_line = gsub_safe(line)
        end
      end
    end

    if matched then
      found_any = true
      table.insert(out, ("Line %d:"):format(i))
      table.insert(out, "Original: " .. line)
      table.insert(out, "Replace:  " .. new_line)
      table.insert(out, "")
    end
  end

  if not found_any then
    table.insert(out, "No matches found")
  end

  return out
end

local function open_windows(height, width, row, col)
  local preview_buf = vim.api.nvim_create_buf(false, true)
  -- safer buf opts
  pcall(vim.api.nvim_buf_set_option, preview_buf, 'buftype', 'nofile')
  pcall(vim.api.nvim_buf_set_option, preview_buf, 'bufhidden', 'wipe')
  pcall(vim.api.nvim_buf_set_option, preview_buf, 'swapfile', false)
  pcall(vim.api.nvim_buf_set_option, preview_buf, 'modifiable', false)
  pcall(vim.api.nvim_buf_set_option, preview_buf, 'readonly', true)

  local preview_win = vim.api.nvim_open_win(preview_buf, false, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height - 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Preview ',
    title_pos = 'center',
  })

  local replace_buf = vim.api.nvim_create_buf(false, true)
  pcall(vim.api.nvim_buf_set_option, replace_buf, 'buftype', 'prompt')
  pcall(vim.api.nvim_buf_set_option, replace_buf, 'bufhidden', 'wipe')

  local replace_win = vim.api.nvim_open_win(replace_buf, true, {
    relative = 'editor',
    row = row + height - 1,
    col = col,
    width = width,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    title = ' Replace ',
    title_pos = 'center',
  })

  return {
    preview_buf = preview_buf,
    preview_win = preview_win,
    replace_buf = replace_buf,
    replace_win = replace_win,
  }
end

local function close_windows(ws)
  if ws.replace_win and vim.api.nvim_win_is_valid(ws.replace_win) then
    pcall(vim.api.nvim_win_close, ws.replace_win, true)
  end
  if ws.preview_win and vim.api.nvim_win_is_valid(ws.preview_win) then
    pcall(vim.api.nvim_win_close, ws.preview_win, true)
  end
end

local function update_preview(bufnr, ws, search_text, replace_text, opts)
  if not (vim.api.nvim_buf_is_valid(ws.preview_buf)) then return end
  local content = render_preview_lines(bufnr, search_text, replace_text, opts)
  pcall(vim.api.nvim_buf_set_option, ws.preview_buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(ws.preview_buf, 0, -1, false, content)
  pcall(vim.api.nvim_buf_set_option, ws.preview_buf, 'modifiable', false)
end

-- Set up the prompt buffer that drives live preview and apply
local function setup_replace_prompt(bufnr, ws, search_text, opts)
  local replace_text = ""

  vim.fn.prompt_setprompt(ws.replace_buf, ('Replace with%s: '):format(opts.literal and " (literal)" or " (regex)"))
  vim.api.nvim_buf_set_lines(ws.replace_buf, 0, -1, false, { "" })

  -- live preview
  vim.api.nvim_buf_attach(ws.replace_buf, false, {
    on_lines = function()
      local line = vim.api.nvim_buf_get_lines(ws.replace_buf, 0, 1, false)[1] or ""
      -- strip prompt if needed (prompt buftype usually doesn’t include it in the line)
      if line ~= replace_text then
        replace_text = line
        update_preview(bufnr, ws, search_text, replace_text, opts)
      end
    end,
    on_detach = function()
      close_windows(ws)
    end,
  })

  -- Apply on <CR>
  vim.fn.prompt_setcallback(ws.replace_buf, function(text)
    close_windows(ws)
    if text and text ~= "" then
      local flags = "g"
      if Config.confirm then flags = flags .. "c" end
      local pat = build_search_pattern(search_text, opts)
      -- Escape slash in replacement for :substitute
      local repl = (text:gsub([[\]], [[\\]]):gsub("&", [[\&]]))
      local cmd = ("%%s/%s/%s/%s"):format(pat, repl:gsub("/", [[\/]]), flags)
      vim.cmd(cmd)
    end
  end)

  -- Mappings inside prompt to toggle modes on the fly
  local function refresh_prompt_title()
    vim.fn.prompt_setprompt(ws.replace_buf,
      ('Replace with%s%s%s: '):format(
        opts.literal and " (literal)" or " (regex)",
        opts.ignorecase and " +ic" or " +Cs",
        (not opts.literal and opts.word) and " +word" or ""
      )
    )
  end

  local map_opts = { buffer = ws.replace_buf, nowait = true }
  vim.keymap.set("i", "<Esc>", function() close_windows(ws) end, map_opts)
  vim.keymap.set("i", "<C-l>", function()
    opts.literal = not opts.literal
    update_preview(bufnr, ws, search_text, replace_text, opts)
    refresh_prompt_title()
  end, map_opts)
  vim.keymap.set("i", "<C-i>", function()
    opts.ignorecase = not opts.ignorecase
    update_preview(bufnr, ws, search_text, replace_text, opts)
    refresh_prompt_title()
  end, map_opts)
  vim.keymap.set("i", "<C-w>", function()
    if not opts.literal then
      opts.word = not opts.word
      update_preview(bufnr, ws, search_text, replace_text, opts)
      refresh_prompt_title()
    end
  end, map_opts)

  update_preview(bufnr, ws, search_text, "", opts)
  vim.cmd("startinsert!")
end

-- ── Public entry: Telescope-driven find → live preview replace ────────────
function M.find_and_replace()
  local bufnr = vim.api.nvim_get_current_buf()
  local ts = T()

  local opts = {
    literal = Config.literal,
    ignorecase = Config.ignorecase,
    word = Config.word,
  }

  local function open_preview_flow(search_text)
    if not search_text or search_text == "" then return end

    -- Precompute matches to size the window nicely
    local matches = get_all_matches(bufnr, search_text, opts)
    local height = math.min(#matches + 4, math.floor(vim.o.lines * Config.max_height_frac))
    height = math.max(height, 8)
    local width  = math.floor(vim.o.columns * Config.max_width_frac)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local ws = open_windows(height, width, row, col)

    -- autoclose if user switches buffer
    local aug = vim.api.nvim_create_augroup("BufReplacePreview", { clear = true })
    vim.api.nvim_create_autocmd({ "BufLeave", "BufHidden", "BufWipeout" }, {
      group = aug,
      buffer = bufnr,
      once = true,
      callback = function()
        close_windows(ws)
      end,
    })

    setup_replace_prompt(bufnr, ws, search_text, vim.deepcopy(opts))
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local results = {}
  for i, line in ipairs(lines) do
    if line ~= "" then
      table.insert(results, { lnum = i, text = line })
    end
  end

  ts.pickers
    .new({}, {
      prompt_title = "Find text (Enter to select)",
      layout_strategy = 'vertical',
      layout_config = {
        width = 0.8,
        height = 0.8,
        prompt_position = "top",
      },
      finder = ts.finders.new_table {
        results = results,
        entry_maker = function(entry)
          return {
            value = entry,
            ordinal = entry.text,
            display = string.format("Line %d: %s", entry.lnum, entry.text),
            lnum = entry.lnum,
            text = entry.text
          }
        end
      },
      sorter = ts.conf.generic_sorter({}),
      previewer = ts.conf.grep_previewer({}),
      attach_mappings = function(prompt_bufnr, map)
        -- Enter: take whatever is typed in prompt as the search
        map('i', '<CR>', function()
          local search_text = ts.state.get_current_line()
          ts.actions.close(prompt_bufnr)
          open_preview_flow(search_text)
        end)
        -- Toggles directly from the prompt
        map('i', '<C-l>', function()
          opts.literal = not opts.literal
        end)
        map('i', '<C-i>', function()
          opts.ignorecase = not opts.ignorecase
        end)
        map('i', '<C-w>', function()
          if not opts.literal then
            opts.word = not opts.word
          end
        end)
        return true
      end,
    })
    :find()
end

return M
