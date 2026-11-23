-- Run: nvim --headless -u NONE -i NONE -l tests/editor-regressions.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
local api = vim.api
require "config.autocmds"

for _, ft in ipairs({ "markdown", "quarto", "lua" }) do
    vim.bo.filetype = ft
    api.nvim_buf_set_lines(0, 0, -1, false, { "line  ", "next" })
    api.nvim_exec_autocmds("BufWritePre", { buffer = 0 })
    assert(api.nvim_buf_get_lines(0, 0, 1, false)[1] == (ft == "lua" and "line" or "line  "))
end

local temp = vim.fn.tempname()
vim.fn.mkdir(temp .. "/project/src", "p")
vim.fn.mkdir(temp .. "/other", "p")
local cwd = vim.fn.getcwd()
vim.cmd.cd(temp .. "/other")
local opts = require("plugins.lsp.conform").opts
for _, name in ipairs({ "biome.json", "biome.jsonc" }) do
    vim.fn.writefile({ "{}" }, temp .. "/project/" .. name)
    assert(opts.formatters.biome.condition({}, { filename = temp .. "/project/src/file.ts" }))
    assert(not opts.formatters.biome.condition({}, { filename = temp .. "/other/file.ts" }))
    vim.fn.delete(temp .. "/project/" .. name)
end
vim.cmd.cd(cwd)
vim.fn.delete(temp, "rf")

-- Exercise formatter selection through the installed Conform implementation.
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/conform.nvim")
local conform = require "conform"
local available = { biome = true, prettierd = true, prettier = true }
conform.setup(opts)
conform.get_formatter_info = function(name)
    return { name = name, available = available[name] == true }
end
local web = opts.formatters_by_ft.typescript
for _, expected in ipairs({ "biome", "prettierd", "prettier" }) do
    local selected = conform.resolve_formatters(web, 0, false, web.stop_after_first)
    assert(#selected == 1 and selected[1].name == expected)
    available[expected] = false
end
available.ruff_fix, available.ruff_format = true, true
assert(#conform.resolve_formatters(opts.formatters_by_ft.python, 0, false, false) == 2)

-- Explicit ranges must not depend on stale visual-selection marks.
require("plugins.lsp.conform").config(nil, opts)
local real_format = conform.format
local formatted
conform.format = function(options) formatted = options end
api.nvim_buf_set_lines(0, 0, -1, false, { "first", "second", "last 😀", "outside" })
api.nvim_buf_set_mark(0, "<", 1, 0, {})
api.nvim_buf_set_mark(0, ">", 1, 0, {})
vim.cmd "2,3FormatRange"
assert(vim.deep_equal(formatted.range, { start = { 2, 0 }, ["end"] = { 3, #"last 😀" } }))
vim.cmd "1,1FormatRange"
assert(vim.deep_equal(formatted.range, { start = { 1, 0 }, ["end"] = { 1, #"first" } }))
conform.format = real_format

local installed, parsed = {}, 0
package.loaded["nvim-treesitter"] = {
    setup = function() end,
    install = function(langs) installed[#installed + 1] = langs end,
}
vim.treesitter.start = function() end
vim.treesitter.get_parser = function()
    return { parse = function() parsed = parsed + 1 end }
end
local spec = require "plugins.editor.treesitter"
package.loaded["lazy.core.config"] = { plugins = { ["nvim-treesitter"] = spec } }
spec.config(spec, spec.opts)
vim.cmd.TSInstallAll()
assert(#installed == 2 and #installed[1] > 0 and vim.deep_equal(installed[1], installed[2]))

local timers = {}
local new_timer = vim.uv.new_timer
vim.uv.new_timer = function()
    local timer = { closed = false }
    function timer:start(_, _, callback) self.callback = callback end
    function timer:stop() end
    function timer:is_closing() return self.closed end
    function timer:close() assert(not self.closed); self.closed = true end
    timers[#timers + 1] = timer
    return timer
end
local buf = api.nvim_create_buf(true, false)
api.nvim_set_current_buf(buf)
vim.bo.filetype = "markdown"
api.nvim_exec_autocmds("FileType", { buffer = buf })
local function edit() api.nvim_exec_autocmds("TextChanged", { buffer = buf }) end
edit()
timers[1].callback() -- callback is queued but not yet executed
edit()
vim.wait(10)
assert(timers[1].closed and parsed == 0, "stale callbacks must not parse")
timers[2].callback()
vim.wait(10)
assert(timers[2].closed and parsed == 1, "completed timers must close")
api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep("x", 201 * 1024) })
edit()
timers[3].callback()
vim.wait(10)
assert(timers[3].closed and parsed == 1, "large buffers must skip forced parsing")
edit()
timers[4].callback()
api.nvim_buf_delete(buf, { force = true })
vim.wait(10)
assert(timers[4].closed and parsed == 1, "deleted buffers must cancel queued parsing")
vim.uv.new_timer = new_timer
print("PASS: prose whitespace, formatter roots/fallbacks, parser install command, timer cleanup/races/size guard")
