-- Run: nvim --headless -u NONE -i NONE -l tests/lazy-specs.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
assert(vim.fn.isdirectory(lazy_path) == 1, "Install lazy.nvim before running this test")
vim.opt.rtp:prepend(lazy_path)
local config = require "lazy.core.config"
config.options = vim.deepcopy(config.defaults)
local specs
-- Capture the real config's setup options, then pass its entire spec tree to
-- Lazy's real parser. No downloads, plugin initialization, or lockfile writes.
package.loaded.lazy = {
    setup = function(opts) specs = opts.spec end,
}
dofile(root .. "/lua/config/lazy.lua")
local spec = require("lazy.core.plugin").Spec.new(specs, { pkg = false })
local errors = {}
for _, notification in ipairs(spec.notifs) do
    if notification.level >= vim.log.levels.ERROR then
        table.insert(errors, notification.msg)
    end
end
assert(#errors == 0, table.concat(errors, "\n"))
assert(spec.plugins["nvim-lspconfig"], "LSP plugin was not registered")
assert(type(require "plugins.lsp.interactive-rename") == "function")
assert(type(require("plugins.lsp.signature").setup) == "function")
print("PASS: complete Lazy spec tree parses; both LSP helpers remain loadable")
