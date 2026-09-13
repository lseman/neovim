-- Run: nvim --headless -u NONE -i NONE -l tests/cheatsheet.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
local api = vim.api
local cheatsheet = require "config.cheatsheet"
local source = api.nvim_get_current_buf()
vim.keymap.set("n", "z1", function() end, { buffer = source, desc = "Fixture first action" })
vim.keymap.set("n", "z2", function() end, { buffer = source, desc = "Fixture second action" })
cheatsheet.open()
local win, buf = api.nvim_get_current_win(), api.nvim_get_current_buf()
assert(not vim.bo[buf].modifiable, "cheatsheet must stay read-only")
local ns = api.nvim_create_namespace "cheatsheet"
local marks = api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })
assert(vim.inspect(marks):find("Fixture"), "source buffer mappings must appear")
assert(vim.inspect(marks):find("First action", 1, true), "mapping actions must appear")
vim.o.columns = 120
api.nvim_exec_autocmds("VimResized", {})
assert(api.nvim_win_get_width(win) == 116, "float follows terminal resize")
assert(not vim.bo[buf].modifiable)
api.nvim_win_close(win, true)
assert(not api.nvim_buf_is_valid(buf), "closing wipes scratch buffer")
cheatsheet.render(buf, win, source) -- late callbacks safely do nothing
cheatsheet.open()
win, buf = api.nvim_get_current_win(), api.nvim_get_current_buf()
assert(not vim.bo[buf].modifiable, "reopen is read-only")
api.nvim_win_close(win, true)
api.nvim_exec_autocmds("VimResized", {})

local collect = cheatsheet.collect_mappings
cheatsheet.collect_mappings = function() return {} end
cheatsheet.open()
win, buf = api.nvim_get_current_win(), api.nvim_get_current_buf()
assert(api.nvim_get_current_line() == "No mappings found.", "empty state renders")
assert(not vim.bo[buf].modifiable, "empty state remains read-only")
api.nvim_exec_autocmds("VimResized", {})
assert(not vim.bo[buf].modifiable)
api.nvim_win_close(win, true)
cheatsheet.collect_mappings = collect

vim.o.columns = 30
vim.o.lines = 15
cheatsheet.open()
win, buf = api.nvim_get_current_win(), api.nvim_get_current_buf()
assert(not vim.bo[buf].modifiable, "narrow layout renders")
api.nvim_win_close(win, true)
print("PASS: source mappings, read-only render, resize, close/reopen, empty state, narrow terminal")
