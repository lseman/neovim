-- lua/config/custom.lua - Buffer find/replace with a two-field live preview
local M = {}

local NS = vim.api.nvim_create_namespace("buf_replace")

local Config = {
  literal = true,
  ignorecase = true,
  confirm = true,
  word = false,

  max_height_frac = 0.82,
  max_width_frac = 0.82,
  min_width = 64,

  preview_context = 1,
  debounce_ms = 60,
  winblend = 0,
  title = " BufReplace ",
}

function M.setup(opts)
  Config = vim.tbl_deep_extend("force", Config, opts or {})
end

local function escape_vim_literal(text)
  return vim.fn.escape(text, [[\.^$*~[]/]])
end

local function replacement_for_substitute(text)
  return (text or ""):gsub([[\]], [[\\]]):gsub("&", [[\&]])
end

local function build_search_pattern(text, opts)
  if text == "" then
    return ""
  end

  local case = opts.ignorecase and [[\c]] or [[\C]]
  if opts.literal then
    local body = escape_vim_literal(text)
    if opts.word then
      body = [[\<]] .. body .. [[\>]]
    end
    return case .. [[\V]] .. body
  end

  local body = text
  if opts.word then
    body = [[<]] .. body .. [[>]]
  end
  return case .. [[\v]] .. body
end

local function compile_pattern(text, opts)
  local pattern = build_search_pattern(text, opts)
  local ok, regex = pcall(vim.regex, pattern)
  if not ok then
    return nil, pattern
  end
  return regex, pattern
end

local function substitute_line(line, search_text, replace_text, opts)
  local pattern = build_search_pattern(search_text, opts)
  local replace = replacement_for_substitute(replace_text)
  local ok, replaced = pcall(vim.fn.substitute, line, pattern, replace, "g")
  return ok and replaced or line
end

local function literal_occurrences(line, needle, opts)
  local out = {}
  if needle == "" then
    return out
  end

  local hay = opts.ignorecase and line:lower() or line
  local target = opts.ignorecase and needle:lower() or needle
  local start = 1

  local function is_keyword_char(char)
    return char ~= "" and char:match("[%w_]") ~= nil
  end

  local function is_whole_word(s, e)
    if not opts.word then
      return true
    end
    return not is_keyword_char(line:sub(s - 1, s - 1)) and not is_keyword_char(line:sub(e + 1, e + 1))
  end

  while true do
    local s, e = hay:find(target, start, true)
    if not s then
      break
    end

    if is_whole_word(s, e) then
      table.insert(out, { s = s - 1, e = e })
    end
    start = e + 1
  end

  return out
end

local function regex_occurrences(line, regex)
  local out = {}
  if not regex then
    return out
  end

  local start = 0
  local limit = #line
  while start <= limit do
    local s, e = regex:match_str(line:sub(start + 1))
    if not s then
      break
    end

    local from = start + s
    local to = start + e
    table.insert(out, { s = from, e = to })

    start = to
    if from == to then
      start = start + 1
    end
  end

  return out
end

local function find_occurrences(line, search_text, opts, regex)
  if opts.literal then
    return literal_occurrences(line, search_text, opts)
  end
  return regex_occurrences(line, regex)
end

local function add_mark(marks, row, start_col, end_col, group)
  if start_col and end_col and end_col > start_col then
    table.insert(marks, {
      row = row,
      start_col = start_col,
      end_col = end_col,
      group = group,
    })
  end
end

local function add_line(lines, text, marks, line_group)
  table.insert(lines, text)
  local row = #lines - 1
  if line_group and text ~= "" then
    add_mark(marks, row, 0, #text, line_group)
  end
  return row
end

local function mode_label(opts)
  return ("%s  %s  %s  %s"):format(
    opts.literal and "literal" or "regex",
    opts.ignorecase and "ignore case" or "match case",
    opts.word and "whole word" or "partial",
    opts.confirm and "confirm" or "apply all"
  )
end

local function render_preview(bufnr, search_text, replace_text, opts)
  local lines = {}
  local marks = {}

  if search_text == "" then
    add_line(lines, "Type in Find, then Replace. Preview updates live.", marks, "Title")
    add_line(lines, "", marks)
    add_line(lines, "Tab switches fields. Enter in Replace applies. Esc closes.", marks, "Comment")
    add_line(lines, "Alt-r regex, Alt-c case, Alt-w word, Alt-a confirm.", marks, "Comment")
    return { lines = lines, marks = marks }
  end

  local regex, pattern = compile_pattern(search_text, opts)
  if not opts.literal and not regex then
    add_line(lines, "Invalid regex", marks, "ErrorMsg")
    add_line(lines, pattern, marks, "Comment")
    return { lines = lines, marks = marks }
  end

  local source = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local changes = {}
  local match_count = 0

  for lnum, line in ipairs(source) do
    local occ = find_occurrences(line, search_text, opts, regex)
    if #occ > 0 then
      local replaced = substitute_line(line, search_text, replace_text, opts)
      match_count = match_count + #occ
      if replaced ~= line then
        table.insert(changes, {
          lnum = lnum,
          old = line,
          new = replaced,
          occ = occ,
        })
      end
    end
  end

  add_line(lines, ("Find: %s"):format(search_text), marks, "Title")
  add_line(lines, ("Replace: %s"):format(replace_text or ""), marks, "Title")
  add_line(lines, ("Matches: %d   Lines changed: %d   %s"):format(match_count, #changes, mode_label(opts)), marks, "Comment")
  add_line(lines, string.rep("-", 72), marks, "Comment")
  add_line(lines, "", marks)

  if #changes == 0 then
    add_line(lines, match_count == 0 and "No matches found." or "Matches found, but replacement would not change text.", marks, "Comment")
    return { lines = lines, marks = marks }
  end

  local ctx = math.max(0, Config.preview_context or 0)
  local printed_until = 0

  for _, change in ipairs(changes) do
    local from = math.max(1, change.lnum - ctx)
    local to = math.min(#source, change.lnum + ctx)

    if from > printed_until + 1 then
      add_line(lines, "...", marks, "Comment")
    end

    for lnum = math.max(printed_until + 1, from), to do
      if lnum == change.lnum then
        local old_prefix = ("- %4d | "):format(lnum)
        local old_row = add_line(lines, old_prefix .. change.old, marks, "DiffDelete")
        add_mark(marks, old_row, 0, #old_prefix, "LineNr")

        for _, occ in ipairs(change.occ) do
          add_mark(marks, old_row, #old_prefix + occ.s, #old_prefix + occ.e, "Search")
        end

        local new_prefix = ("+ %4d | "):format(lnum)
        local new_row = add_line(lines, new_prefix .. change.new, marks, "DiffAdd")
        add_mark(marks, new_row, 0, #new_prefix, "LineNr")
        add_line(lines, "", marks)
      else
        add_line(lines, ("  %4d | %s"):format(lnum, source[lnum]), marks, "Comment")
      end
    end

    printed_until = to
  end

  return { lines = lines, marks = marks }
end

local function set_preview(buf, rendered)
  vim.bo[buf].readonly = false
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, rendered.lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true

  vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
  for _, mark in ipairs(rendered.marks) do
    pcall(vim.api.nvim_buf_set_extmark, buf, NS, mark.row, mark.start_col, {
      end_col = mark.end_col,
      hl_group = mark.group,
      priority = 200,
    })
  end
end

local function make_prompt_buf(prompt)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "prompt"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "bufreplace"
  vim.fn.prompt_setprompt(buf, prompt)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
  return buf
end

local function make_preview_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  vim.bo[buf].filetype = "bufreplace"
  return buf
end

local function open_windows()
  local total_height = math.max(14, math.floor(vim.o.lines * Config.max_height_frac))
  local total_width = math.max(Config.min_width, math.floor(vim.o.columns * Config.max_width_frac))
  total_width = math.min(total_width, vim.o.columns - 4)
  total_height = math.min(total_height, vim.o.lines - 4)

  local row = math.max(0, math.floor((vim.o.lines - total_height) / 2))
  local col = math.max(0, math.floor((vim.o.columns - total_width) / 2))
  local preview_height = math.max(6, total_height - 6)

  local find_buf = make_prompt_buf("Find: ")
  local replace_buf = make_prompt_buf("Replace: ")
  local preview_buf = make_preview_buf()

  local find_win = vim.api.nvim_open_win(find_buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = total_width,
    height = 1,
    style = "minimal",
    border = "rounded",
    title = Config.title .. " Find ",
    title_pos = "center",
  })

  local replace_win = vim.api.nvim_open_win(replace_buf, false, {
    relative = "editor",
    row = row + 3,
    col = col,
    width = total_width,
    height = 1,
    style = "minimal",
    border = "rounded",
    title = Config.title .. " Replace ",
    title_pos = "center",
  })

  local preview_win = vim.api.nvim_open_win(preview_buf, false, {
    relative = "editor",
    row = row + 6,
    col = col,
    width = total_width,
    height = preview_height,
    style = "minimal",
    border = "rounded",
    title = Config.title .. " Preview ",
    title_pos = "center",
  })

  for _, win in ipairs({ find_win, replace_win, preview_win }) do
    vim.api.nvim_set_option_value("winblend", Config.winblend or 0, { win = win })
  end

  return {
    find_buf = find_buf,
    find_win = find_win,
    replace_buf = replace_buf,
    replace_win = replace_win,
    preview_buf = preview_buf,
    preview_win = preview_win,
  }
end

local function close_windows(ws)
  for _, key in ipairs({ "find_win", "replace_win", "preview_win" }) do
    local win = ws and ws[key]
    if win and vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
end

local function prompt_text(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return ""
  end
  local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
  local prompt = vim.fn.prompt_getprompt(buf)
  if prompt ~= "" and line:sub(1, #prompt) == prompt then
    return line:sub(#prompt + 1)
  end
  return line
end

local function build_substitute_cmd(search_text, replace_text, opts)
  local flags = opts.confirm and "gc" or "g"
  local pattern = build_search_pattern(search_text, opts)
  local replacement = replacement_for_substitute(replace_text):gsub("/", [[\/]])
  return ("%%s/%s/%s/%s"):format(pattern, replacement, flags)
end

local function apply_replace(bufnr, ws, state)
  if state.search == "" then
    vim.notify("Find text is empty", vim.log.levels.WARN)
    return
  end

  close_windows(ws)
  if ws.source_win and vim.api.nvim_win_is_valid(ws.source_win) then
    vim.api.nvim_set_current_win(ws.source_win)
  end
  vim.api.nvim_set_current_buf(bufnr)
  vim.cmd(build_substitute_cmd(state.search, state.replace, state.opts))
end

local function wire_panel(bufnr, ws, state)
  local timer = vim.uv and vim.uv.new_timer() or nil

  local function refresh_titles()
    vim.api.nvim_win_set_config(ws.find_win, {
      title = Config.title .. " Find [" .. mode_label(state.opts) .. "] ",
    })
    vim.api.nvim_win_set_config(ws.replace_win, {
      title = Config.title .. " Replace ",
    })
  end

  local function refresh_preview()
    if not vim.api.nvim_buf_is_valid(ws.preview_buf) then
      return
    end
    refresh_titles()
    set_preview(ws.preview_buf, render_preview(bufnr, state.search, state.replace, state.opts))
  end

  local function schedule_preview()
    state.search = prompt_text(ws.find_buf)
    state.replace = prompt_text(ws.replace_buf)

    if not timer then
      vim.defer_fn(refresh_preview, Config.debounce_ms or 60)
      return
    end

    timer:stop()
    timer:start(Config.debounce_ms or 60, 0, function()
      vim.schedule(refresh_preview)
    end)
  end

  local function focus(win)
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_current_win(win)
      vim.cmd("startinsert!")
    end
  end

  local function toggle(field)
    state.opts[field] = not state.opts[field]
    schedule_preview()
  end

  local function set_keymaps(buf, other_win)
    local opts = { buffer = buf, nowait = true, noremap = true, silent = true }
    vim.keymap.set({ "i", "n" }, "<Esc>", function()
      close_windows(ws)
    end, opts)
    vim.keymap.set("i", "<Tab>", function()
      focus(other_win)
    end, opts)
    vim.keymap.set("i", "<S-Tab>", function()
      focus(other_win)
    end, opts)
    vim.keymap.set("i", "<M-r>", function()
      toggle("literal")
    end, opts)
    vim.keymap.set("i", "<M-c>", function()
      toggle("ignorecase")
    end, opts)
    vim.keymap.set("i", "<M-w>", function()
      toggle("word")
    end, opts)
    vim.keymap.set("i", "<M-a>", function()
      toggle("confirm")
    end, opts)
  end

  set_keymaps(ws.find_buf, ws.replace_win)
  set_keymaps(ws.replace_buf, ws.find_win)

  vim.keymap.set("i", "<CR>", function()
    focus(ws.replace_win)
  end, { buffer = ws.find_buf, nowait = true, noremap = true, silent = true })
  vim.keymap.set("i", "<CR>", function()
    state.search = prompt_text(ws.find_buf)
    state.replace = prompt_text(ws.replace_buf)
    apply_replace(bufnr, ws, state)
  end, { buffer = ws.replace_buf, nowait = true, noremap = true, silent = true })

  for _, buf in ipairs({ ws.find_buf, ws.replace_buf }) do
    vim.api.nvim_buf_attach(buf, false, {
      on_lines = schedule_preview,
      on_detach = function()
        if timer then
          pcall(timer.stop, timer)
          pcall(timer.close, timer)
        end
      end,
    })
  end

  local augroup = vim.api.nvim_create_augroup(("BufReplace_%d_%d"):format(bufnr, vim.fn.getpid()), { clear = true })
  vim.api.nvim_create_autocmd({ "BufWipeout", "BufHidden" }, {
    group = augroup,
    buffer = bufnr,
    once = true,
    callback = function()
      close_windows(ws)
    end,
  })

  refresh_preview()
  focus(ws.find_win)
end

function M.find_and_replace()
  local bufnr = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()
  if vim.bo[bufnr].buftype ~= "" then
    vim.notify("Find and replace is available for normal file buffers", vim.log.levels.WARN)
    return
  end

  local state = {
    search = "",
    replace = "",
    opts = {
      literal = Config.literal,
      ignorecase = Config.ignorecase,
      word = Config.word,
      confirm = Config.confirm,
    },
  }

  local ws = open_windows()
  ws.source_win = source_win
  wire_panel(bufnr, ws, state)
end

return M
