-- Run: nvim --headless -u NONE -i NONE -l tests/dashboard.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/snacks.nvim")
require "snacks"
local config = require "config.dashboard"
vim.o.laststatus = 0
vim.o.showtabline = 0
vim.o.columns = 120
vim.o.lines = 36
vim.api.nvim_win_set_width(0, 120)
vim.api.nvim_win_set_height(0, 35)
vim.v.oldfiles = {}
local win = vim.api.nvim_open_win(0, true, { relative = "editor", row = 0, col = 0, width = 120, height = 35 })
local d = Snacks.dashboard(vim.tbl_extend("force", config, { win = win }))
assert(#d.panes == 2, "wide dashboard uses two columns")
local lines = vim.api.nvim_buf_get_lines(d.buf, 0, -1, false)
local text = table.concat(lines, "\n")
assert(text:find("N E O V I M", 1, true))
assert(text:find("CONTINUE WORKING", 1, true))
assert(text:find("Your next file starts the list.", 1, true))
assert(not text:find("██", 1, true), "no ASCII banner")
for _, line in ipairs(lines) do
    assert(vim.fn.strdisplaywidth(line) <= 120, "wide layout fits")
end
local keys = {}
for _, item in ipairs(d.items) do
    if item.key then
        assert(not keys[item.key], "duplicate shortcut " .. item.key)
        keys[item.key] = true
    end
end
for _, key in ipairs({ "f", "n", "g", "r", "p", "c", "k", "l", "h", "q" }) do
    assert(keys[key], "missing action " .. key)
end
local fixture = vim.fn.tempname()
vim.fn.mkdir(fixture .. "/.git", "p")
vim.fn.writefile({ "dashboard fixture" }, fixture .. "/example.lua")
vim.v.oldfiles = { fixture .. "/example.lua" }
d:update()
local populated = table.concat(vim.api.nvim_buf_get_lines(d.buf, 0, -1, false), "\n")
assert(populated:find("example.lua", 1, true), "recent file appears")
local autokeys = {}
for _, item in ipairs(d.items) do
    if item.autokey then
        assert(item.key:match("%d"), "recent items use digits")
        assert(not autokeys[item.key], "automatic shortcuts are unique")
        autokeys[item.key] = true
    end
end
assert(vim.tbl_count(autokeys) >= 1)
vim.fn.delete(fixture, "rf")
vim.o.columns = 42
vim.o.lines = 24
vim.api.nvim_win_set_config(win, { width = 42, height = 23 })
d:update()
assert(#d.panes == 1, "narrow dashboard uses one column")
for _, line in ipairs(vim.api.nvim_buf_get_lines(d.buf, 0, -1, false)) do
    assert(vim.fn.strdisplaywidth(line) <= 42, "narrow layout fits")
end
assert(#d.lines <= 23, "compact actions fit in short window")
print("PASS: real Snacks render, two-column/compact layouts, empty states, unique shortcuts")
