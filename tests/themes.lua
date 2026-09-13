-- Run: nvim --headless -u NONE -i NONE -l tests/themes.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
local api = vim.api
local picker = require "config.themes"
local origin = api.nvim_get_current_win()
local original_completion = vim.fn.getcompletion
vim.fn.getcompletion = function(_, kind)
    assert(kind == "color")
    return { "desert", "evening", "slate" }
end
vim.cmd.colorscheme "slate"
local background = vim.o.background
local function windows()
    local input = api.nvim_get_current_win()
    for _, win in ipairs(api.nvim_list_wins()) do
        if win ~= input and win ~= origin then return input, win end
    end
    error("Missing preview window")
end
local function key(buf, mode, lhs)
    for _, map in ipairs(api.nvim_buf_get_keymap(buf, mode)) do
        if map.lhs == lhs then return map.callback() end
    end
    error("Missing key " .. lhs)
end
picker.open()
local input, preview = windows()
local input_buf, preview_buf = api.nvim_win_get_buf(input), api.nvim_win_get_buf(preview)
assert(api.nvim_buf_line_count(preview_buf) == 3)
assert(api.nvim_win_get_cursor(preview)[1] == 3, "actual active theme selected")
assert(api.nvim_win_get_cursor(input)[1] == 1, "input cursor stays on one line")
assert(not vim.bo[preview_buf].modifiable)
assert(vim.g.colors_name == "slate" and vim.o.background == background, "preview restores current theme")
local ns = api.nvim_create_namespace "ThemePicker"
assert(#api.nvim_buf_get_extmarks(preview_buf, ns, 0, -1, {}) == 3)
picker.open()
assert(#api.nvim_list_wins() == 3, "repeated open does not leak windows")
local function filter(text)
    api.nvim_buf_set_lines(input_buf, 0, -1, false, { text })
    api.nvim_exec_autocmds("TextChangedI", { buffer = input_buf })
end
filter("des")
assert(api.nvim_buf_line_count(preview_buf) == 1)
filter("[")
assert(api.nvim_buf_get_lines(preview_buf, 0, 1, false)[1]:find("No matching themes", 1, true))
assert(#api.nvim_buf_get_extmarks(preview_buf, ns, 0, -1, {}) == 0, "no stale preview marks")
key(input_buf, "i", "<CR>")
assert(api.nvim_win_is_valid(input), "empty selection is harmless")
filter("")
key(input_buf, "i", "<Down>")
assert(api.nvim_win_get_cursor(preview)[1] == 2)
assert(api.nvim_win_get_cursor(input)[1] == 1)
key(input_buf, "i", "<CR>")
assert(vim.g.colors_name == "evening", "selected theme applied")
assert(#api.nvim_list_wins() == 1 and not api.nvim_buf_is_valid(input_buf))
picker.close()
picker.toggle()
input, preview = windows()
api.nvim_set_current_win(preview)
assert(api.nvim_win_is_valid(input), "switching within picker keeps it open")
api.nvim_set_current_win(origin)
assert(#api.nvim_list_wins() == 1, "leaving picker closes both windows")
picker.open()
input, preview = windows()
api.nvim_win_close(input, true)
assert(#api.nvim_list_wins() == 1, "closing search window also closes preview")
vim.fn.getcompletion = original_completion
picker.open()
input, preview = windows()
assert(api.nvim_buf_line_count(api.nvim_win_get_buf(preview)) > 1, "real colorscheme discovery works")
picker.toggle()
assert(#api.nvim_list_wins() == 1)
print("PASS: discovery, previews, active theme, literal filtering, navigation, selection, close/reopen, window cleanup")
