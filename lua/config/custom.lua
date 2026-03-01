-- lua/buf_replace/init.lua
local M = {}

-- Lazy telescope deps
local function T()
  return {
    actions = require("telescope.actions"),
    state = require("telescope.actions.state"),
    pickers = require("telescope.pickers"),
    finders = require("telescope.finders"),
    conf = require("telescope.config").values,
  }
end

-- ── Config (can be overridden via M.setup) ─────────────────────────────────
local Config = {
  literal = true,
  ignorecase = true,
  confirm = true,
  word = false,

  max_height_frac = 0.82,
  max_width_frac = 0.82,

  -- UI polish
  preview_context = 0,        -- show N context lines around changed lines
  debounce_ms = 60,           -- live preview debounce
  winblend = 0,               -- set e.g. 10 for slight transparency
  title = " BufReplace ",
}

function M.setup(opts)
  Config = vim.tbl_deep_extend("force", Config, opts or {})
end

-- ── Utils ─────────────────────────────────────────────────────────────────

local NS = vim.api.nvim_create_namespace("buf_replace")

local function esc_lua_pattern(s)
  return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

local function escape_vim_literal(q)
  -- used inside \V very-nomagic; still escape delimiter-ish and backslashes
  return vim.fn.escape(q, [[\.^$*~[]/]])
end

local function build_search_pattern(q, o)
  o = o or {}
  local literal = o.literal
  local ignorecase = o.ignorecase
  local word = o.word
  if q == "" then return "" end

  if literal then
    local esc = escape_vim_literal(q)
    local prefix = ignorecase and [[\V\c]] or [[\V\C]]
    return prefix .. esc
  else
    local body = q
    if word then
      body = [[\b]] .. body .. [[\b]]
    end
    local prefix = ignorecase and [[\v\c]] or [[\v\C]]
    return prefix .. body
  end
end

local function compile_regex(q, o)
  local pat = build_search_pattern(q, o)
  local ok, rx = pcall(vim.regex, pat)
  if not ok then return nil end
  return rx
end

local function find_all_occurrences_literal(line, needle, ignorecase)
  local out = {}
  if needle == "" then return out end

  local hay = line
  local ndl = needle
  if ignorecase then
    hay = hay:lower()
    ndl = ndl:lower()
  end

  local start = 1
  while true do
    local s, e = hay:find(ndl, start, true)
    if not s then break end
    table.insert(out, { s = s, e = e })
    start = e + 1
  end
  return out
end

local function gsub_safe(line, search_text, replace_text, opts)
  local pat = build_search_pattern(search_text, opts)
  local repl = (replace_text or ""):gsub([[\]], [[\\]]):gsub("&", [[\&]])
  local ok, res = pcall(function()
    return vim.fn.substitute(line, pat, repl, "g")
  end)
  return ok and res or line
end

local function line_matches(line, search_text, opts, rx_cache)
  if search_text == "" then return false end
  if opts.literal then
    local needle = search_text
    local hay = line
    if opts.ignorecase then
      needle = needle:lower()
      hay = hay:lower()
    end
    return hay:find(needle, 1, true) ~= nil
  else
    local rx = rx_cache or compile_regex(search_text, opts)
    if not rx then return false end
    local s, e = rx:match_str(line)
    return (s ~= nil and e ~= nil)
  end
end

local function buf_set_lines(buf, lines)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function clear_extmarks(buf)
  pcall(vim.api.nvim_buf_clear_namespace, buf, NS, 0, -1)
end

-- Add highlight ranges to a specific line in preview buffer
local function add_hl(buf, lnum0, col_start, col_end, hl_group)
  if col_start < 0 or col_end <= col_start then return end
  pcall(vim.api.nvim_buf_set_extmark, buf, NS, lnum0, col_start, {
    end_col = col_end,
    hl_group = hl_group,
    priority = 200,
  })
end

local function add_virt(buf, lnum0, text, hl_group)
  pcall(vim.api.nvim_buf_set_extmark, buf, NS, lnum0, 0, {
    virt_text = { { text, hl_group } },
    virt_text_pos = "eol",
    priority = 150,
  })
end

-- Build a pretty diff-like preview, with highlights
local function render_preview(bufnr, search_text, replace_text, opts)
  local src = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local lines = {}
  local marks = {} -- { kind="hl"/"virt", ... }

  local rx = (not opts.literal) and compile_regex(search_text, opts) or nil

  local changed_lines = 0
  local match_count = 0

  -- Pre-scan which lines will change
  local will_change = {}
  for i, line in ipairs(src) do
    if line_matches(line, search_text, opts, rx) then
      local new_line = gsub_safe(line, search_text, replace_text, opts)
      if new_line ~= line then
        will_change[i] = { old = line, new = new_line }
        changed_lines = changed_lines + 1
        if opts.literal then
          match_count = match_count + #find_all_occurrences_literal(line, search_text, opts.ignorecase)
        else
          -- For regex, we count "at least one per line" (exact counting requires iterative matching)
          match_count = match_count + 1
        end
      end
    end
  end

  -- Header
  table.insert(lines, ("Find: %q"):format(search_text))
  table.insert(lines, ("Replace: %q"):format(replace_text or ""))
  table.insert(lines, ("Matches: %d   Lines changed: %d   Mode: %s%s%s"):format(
    match_count,
    changed_lines,
    opts.literal and "literal" or "regex",
    opts.ignorecase and " +ic" or " +Cs",
    (not opts.literal and opts.word) and " +word" or ""
  ))
  table.insert(lines, string.rep("─", 60))
  table.insert(lines, "") -- spacer

  if changed_lines == 0 then
    table.insert(lines, "No changes would be made.")
    return { lines = lines, marks = marks }
  end

  local ctx = math.max(0, Config.preview_context or 0)

  local function push_context(i)
    table.insert(lines, ("  %4d │ %s"):format(i, src[i]))
    local row0 = #lines - 1
    table.insert(marks, { kind = "hl", row0 = row0, c0 = 0, c1 = 0, group = "Comment" })
  end

  local function highlight_literal(preview_row0, prefix_len, old_line)
    local occ = find_all_occurrences_literal(old_line, search_text, opts.ignorecase)
    for _, r in ipairs(occ) do
      add_hl(preview_buf, preview_row0, prefix_len + (r.s - 1), prefix_len + r.e, "Search")
    end
  end

  local function highlight_literal_new(preview_row0, prefix_len, new_line)
    local occ = find_all_occurrences_literal(new_line, replace_text or "", false)
    for _, r in ipairs(occ) do
      add_hl(preview_buf, preview_row0, prefix_len + (r.s - 1), prefix_len + r.e, "IncSearch")
    end
  end

  -- We need preview_buf to add marks; we will set it later in update_preview().
  -- So we store mark intents now and apply them in update_preview().
  local preview_buf = nil
  local function store_hl(row0, c0, c1, group)
    table.insert(marks, { kind = "hl", row0 = row0, c0 = c0, c1 = c1, group = group })
  end
  local function store_virt(row0, text, group)
    table.insert(marks, { kind = "virt", row0 = row0, text = text, group = group })
  end

  local last_printed = 0
  for i = 1, #src do
    if will_change[i] then
      local from = math.max(1, i - ctx)
      local to = math.min(#src, i + ctx)

      if from > last_printed + 1 then
        table.insert(lines, "  …")
        store_hl(#lines - 1, 0, 0, "Comment")
      end

      for j = math.max(last_printed + 1, from), to do
        if j == i then
          table.insert(lines, ("Line %d"):format(i))
          store_hl(#lines - 1, 0, 0, "Title")

          -- diff style
          local oldp = ("- %4d │ "):format(i)
          local newp = ("+ %4d │ "):format(i)

          table.insert(lines, oldp .. will_change[i].old)
          local old_row0 = #lines - 1
          store_hl(old_row0, 0, #oldp, "LineNr")
          store_hl(old_row0, 0, 1, "DiffDelete")
          store_hl(old_row0, #oldp, #oldp + #will_change[i].old, "DiffDelete")

          table.insert(lines, newp .. will_change[i].new)
          local new_row0 = #lines - 1
          store_hl(new_row0, 0, #newp, "LineNr")
          store_hl(new_row0, 0, 1, "DiffAdd")
          store_hl(new_row0, #newp, #newp + #will_change[i].new, "DiffAdd")

          -- highlight matches on old line
          if opts.literal then
            local occ = find_all_occurrences_literal(will_change[i].old, search_text, opts.ignorecase)
            for _, r in ipairs(occ) do
              store_hl(old_row0, #oldp + (r.s - 1), #oldp + r.e, "Search")
            end
          else
            -- best-effort: highlight first match
            local s, e = rx and rx:match_str(will_change[i].old) or nil, nil
            if rx then
              s, e = rx:match_str(will_change[i].old)
              if s and e then
                store_hl(old_row0, #oldp + s, #oldp + e, "Search")
              end
            end
          end

          -- nice right-side hint
          store_virt(new_row0, "  <CR> apply  |  <Esc> close  |  Ctrl+L literal/regex  Ctrl+I ic  Ctrl+W word", "Comment")

          table.insert(lines, "") -- spacer
        else
          -- context line
          table.insert(lines, ("  %4d │ %s"):format(j, src[j]))
          local row0 = #lines - 1
          store_hl(row0, 0, 0, "Comment")
        end
      end

      last_printed = to
    end
  end

  return { lines = lines, marks = marks }
end

-- ── Floating windows ──────────────────────────────────────────────────────

local function open_windows(height, width, row, col)
  local preview_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[preview_buf].buftype = "nofile"
  vim.bo[preview_buf].bufhidden = "wipe"
  vim.bo[preview_buf].swapfile = false
  vim.bo[preview_buf].modifiable = false
  vim.bo[preview_buf].readonly = true
  vim.bo[preview_buf].filetype = "bufreplace"

  local preview_win = vim.api.nvim_open_win(preview_buf, false, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height - 3,
    style = "minimal",
    border = "rounded",
    title = Config.title .. " Preview ",
    title_pos = "center",
  })
  vim.api.nvim_set_option_value("winblend", Config.winblend or 0, { win = preview_win })

  local replace_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[replace_buf].buftype = "prompt"
  vim.bo[replace_buf].bufhidden = "wipe"

  local replace_win = vim.api.nvim_open_win(replace_buf, true, {
    relative = "editor",
    row = row + (height - 2),
    col = col,
    width = width,
    height = 2,
    style = "minimal",
    border = "rounded",
    title = Config.title .. " Replace ",
    title_pos = "center",
  })
  vim.api.nvim_set_option_value("winblend", Config.winblend or 0, { win = replace_win })

  return {
    preview_buf = preview_buf,
    preview_win = preview_win,
    replace_buf = replace_buf,
    replace_win = replace_win,
  }
end

local function close_windows(ws)
  if ws and ws.replace_win and vim.api.nvim_win_is_valid(ws.replace_win) then
    pcall(vim.api.nvim_win_close, ws.replace_win, true)
  end
  if ws and ws.preview_win and vim.api.nvim_win_is_valid(ws.preview_win) then
    pcall(vim.api.nvim_win_close, ws.preview_win, true)
  end
end

local function update_preview(bufnr, ws, search_text, replace_text, opts)
  if not ws or not vim.api.nvim_buf_is_valid(ws.preview_buf) then return end
  clear_extmarks(ws.preview_buf)

  local rendered = render_preview(bufnr, search_text, replace_text, opts)
  buf_set_lines(ws.preview_buf, rendered.lines)

  -- Apply extmark intents
  for _, m in ipairs(rendered.marks or {}) do
    if m.kind == "hl" then
      add_hl(ws.preview_buf, m.row0, m.c0 or 0, m.c1 or (m.c0 or 0), m.group or "Comment")
    elseif m.kind == "virt" then
      add_virt(ws.preview_buf, m.row0, m.text or "", m.group or "Comment")
    end
  end
end

-- Build :%s command safely
local function build_substitute_cmd(search_text, replace_text, opts)
  local flags = "g"
  if Config.confirm then flags = flags .. "c" end

  local pat = build_search_pattern(search_text, opts)

  -- Substitute "replacement" needs escaping for \ and &
  local repl = (replace_text or ""):gsub([[\]], [[\\]]):gsub("&", [[\&]])
  -- And escape delimiter '/'
  repl = repl:gsub("/", [[\/]])

  return ("%%s/%s/%s/%s"):format(pat, repl, flags)
end

-- ── Prompt driver ─────────────────────────────────────────────────────────

local function setup_replace_prompt(bufnr, ws, search_text, opts)
  local replace_text = ""

  local function refresh_prompt()
    vim.fn.prompt_setprompt(ws.replace_buf,
      ("Replace with (%s%s%s): "):format(
        opts.literal and "literal" or "regex",
        opts.ignorecase and " +ic" or " +Cs",
        (not opts.literal and opts.word) and " +word" or ""
      )
    )
  end

  refresh_prompt()
  vim.api.nvim_buf_set_lines(ws.replace_buf, 0, -1, false, { "" })

  -- Debounced live preview
  local timer = vim.uv and vim.uv.new_timer() or nil
  local function schedule_preview()
    if not timer then
      vim.defer_fn(function()
        if ws and vim.api.nvim_buf_is_valid(ws.preview_buf) then
          update_preview(bufnr, ws, search_text, replace_text, opts)
        end
      end, Config.debounce_ms or 60)
      return
    end

    timer:stop()
    timer:start(Config.debounce_ms or 60, 0, function()
      vim.schedule(function()
        if ws and vim.api.nvim_buf_is_valid(ws.preview_buf) then
          update_preview(bufnr, ws, search_text, replace_text, opts)
        end
      end)
    end)
  end

  vim.api.nvim_buf_attach(ws.replace_buf, false, {
    on_lines = function()
      if not ws or not vim.api.nvim_buf_is_valid(ws.replace_buf) then return end
      local line = vim.api.nvim_buf_get_lines(ws.replace_buf, 0, 1, false)[1] or ""
      if line ~= replace_text then
        replace_text = line
        schedule_preview()
      end
    end,
    on_detach = function()
      if timer then pcall(timer.stop, timer) end
      close_windows(ws)
    end,
  })

  -- Apply on <CR>
  vim.fn.prompt_setcallback(ws.replace_buf, function(text)
    close_windows(ws)
    if not text then return end
    local cmd = build_substitute_cmd(search_text, text, opts)
    -- run in original buffer context
    vim.api.nvim_set_current_buf(bufnr)
    vim.cmd(cmd)
  end)

  -- Mappings inside prompt
  local map_opts = { buffer = ws.replace_buf, nowait = true, noremap = true }
  vim.keymap.set("i", "<Esc>", function() close_windows(ws) end, map_opts)

  vim.keymap.set("i", "<C-l>", function()
    opts.literal = not opts.literal
    if opts.literal then opts.word = false end
    refresh_prompt()
    update_preview(bufnr, ws, search_text, replace_text, opts)
  end, map_opts)

  vim.keymap.set("i", "<C-i>", function()
    opts.ignorecase = not opts.ignorecase
    refresh_prompt()
    update_preview(bufnr, ws, search_text, replace_text, opts)
  end, map_opts)

  vim.keymap.set("i", "<C-w>", function()
    if not opts.literal then
      opts.word = not opts.word
      refresh_prompt()
      update_preview(bufnr, ws, search_text, replace_text, opts)
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

    local height = math.floor(vim.o.lines * (Config.max_height_frac or 0.82))
    height = math.max(height, 10)

    local width = math.floor(vim.o.columns * (Config.max_width_frac or 0.82))
    width = math.max(width, 60)

    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local ws = open_windows(height, width, row, col)

    -- per-instance augroup (no global clear)
    local aug = vim.api.nvim_create_augroup(("BufReplacePreview_%d_%d"):format(bufnr, vim.fn.getpid()), { clear = true })
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

  -- Feed telescope with non-empty lines (same as you had, but nicer display)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local results = {}
  for i, line in ipairs(lines) do
    if line ~= "" then
      table.insert(results, { lnum = i, text = line })
    end
  end

  ts.pickers
    .new({}, {
      prompt_title = "Find (type pattern, <CR> to replace)",
      layout_strategy = "vertical",
      layout_config = {
        width = 0.8,
        height = 0.8,
        prompt_position = "top",
      },
      finder = ts.finders.new_table({
        results = results,
        entry_maker = function(entry)
          return {
            value = entry,
            ordinal = entry.text,
            display = (" %4d │ %s"):format(entry.lnum, entry.text),
            lnum = entry.lnum,
            text = entry.text,
          }
        end,
      }),
      sorter = ts.conf.generic_sorter({}),
      previewer = ts.conf.grep_previewer({}),
      attach_mappings = function(prompt_bufnr, map)
        map("i", "<CR>", function()
          -- Use what the user typed (pattern), not the full selected line.
          local search_text = ts.state.get_current_line()
          ts.actions.close(prompt_bufnr)
          vim.schedule(function()
            open_preview_flow(search_text)
          end)
        end)

        -- toggles while searching
        map("i", "<C-l>", function() opts.literal = not opts.literal; if opts.literal then opts.word = false end end)
        map("i", "<C-i>", function() opts.ignorecase = not opts.ignorecase end)
        map("i", "<C-w>", function() if not opts.literal then opts.word = not opts.word end end)

        return true
      end,
    })
    :find()
end

return M
