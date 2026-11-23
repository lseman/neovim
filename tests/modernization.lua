-- Run: nvim --headless -u NONE -i NONE -l tests/modernization.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
vim.g.mapleader = " "
local api = vim.api
local environment = require "config.environment"
local inherited_env, inherited_path = vim.env.VIRTUAL_ENV, vim.env.PATH
local temp = vim.fn.tempname()
vim.fn.mkdir(temp .. "/project/.venv/bin", "p")
vim.fn.mkdir(temp .. "/outside", "p")
vim.fn.writefile({ "#!/bin/sh", "echo Python-test" }, temp .. "/project/.venv/bin/python")
vim.fn.setfperm(temp .. "/project/.venv/bin/python", "rwx------")
package.loaded["config.env"] = { notify_loaded = function() end }
assert(environment.activate_for_dir(temp .. "/project"))
assert(vim.env.VIRTUAL_ENV == temp .. "/project/.venv")
assert(not environment.activate_for_dir(temp .. "/outside"))
assert(vim.env.VIRTUAL_ENV == inherited_env and vim.env.PATH == inherited_path, "restore inherited environment")
assert(environment.activate_for_dir(temp .. "/project"))
vim.env.PATH = temp .. "/new-tools:" .. vim.env.PATH
environment.activate_for_dir(temp .. "/outside")
assert(vim.env.PATH == temp .. "/new-tools:" .. inherited_path, "retain tools added during activation")
vim.env.PATH = inherited_path

-- Live state and subscriptions survive repeated reloads; autocommands do not multiply.
require "config.workflows"
local runner = require "config.runner"
runner.state.last_command = "preserved"
local calls = 0
environment.on_activated(function() calls = calls + 1 end)
require("config.reload").reload()
local function groups()
    local result = {}
    for _, name in ipairs({ "ConfigWorkflows", "PerBufferVenvDetect", "PythonRunner", "ConfigFolding", "HighlightYank" }) do
        result[name] = #api.nvim_get_autocmds({ group = name })
    end
    return result
end
local counts = groups()
require("config.reload").reload()
assert(vim.deep_equal(counts, groups()), "reload must not duplicate callbacks")
assert(require("config.runner") == runner and runner.state.last_command == "preserved")
assert(environment.activate_for_dir(temp .. "/project"))
vim.wait(20)
assert(calls == 1, "environment subscription survives reload")
environment.activate_for_dir(temp .. "/outside")

-- FormatEnable! changes only the buffer override; global enable leaves it alone.
local spec = require "plugins.lsp.conform"
spec.init()
vim.cmd "FormatDisable!"
vim.cmd "FormatDisable"
vim.cmd "FormatEnable!"
assert(vim.g.disable_autoformat and not vim.b.disable_autoformat)
vim.cmd "FormatDisable!"
vim.cmd "FormatEnable"
assert(not vim.g.disable_autoformat and vim.b.disable_autoformat)
vim.cmd "FormatEnable!"

-- FilePost runs once for a real buffer and stays fired across editor reloads.
local fired = 0
api.nvim_create_autocmd("User", { pattern = "FilePost", callback = function() fired = fired + 1 end })
api.nvim_buf_set_name(0, temp .. "/outside/test.py")
api.nvim_exec_autocmds("UIEnter", {})
vim.wait(20)
assert(fired == 1)
require("config.reload").reload()
api.nvim_exec_autocmds("BufReadPost", { buffer = 0 })
vim.wait(20)
assert(fired == 1)
-- Folding follows the buffer's capabilities in every window, including detach.
local source, first_win = api.nvim_get_current_buf(), api.nvim_get_current_win()
vim.cmd "vnew"
local other_win = api.nvim_get_current_win()
local get_clients = vim.lsp.get_clients
vim.lsp.get_clients = function(opts) return opts.bufnr == source and { { id = 123 } } or {} end
api.nvim_exec_autocmds("BufWinEnter", { buffer = source })
vim.wait(20)
assert(vim.wo[first_win].foldexpr == "v:lua.vim.lsp.foldexpr()")
assert(vim.wo[other_win].foldexpr == "v:lua.vim.treesitter.foldexpr()")
vim.lsp.get_clients = function() return {} end
api.nvim_exec_autocmds("LspDetach", { buffer = source, data = { client_id = 123 } })
vim.wait(20)
assert(vim.wo[first_win].foldexpr == "v:lua.vim.treesitter.foldexpr()")
vim.lsp.get_clients = get_clients
api.nvim_win_close(other_win, true)

-- A large notebook on disk may display a tiny converted text buffer.
vim.fn.writefile({ string.rep("x", 1024 * 1024) }, temp .. "/outside/converted.ipynb")
api.nvim_buf_set_name(source, temp .. "/outside/converted.ipynb")
api.nvim_buf_set_lines(source, 0, -1, false, { "# Small converted notebook" })
api.nvim_exec_autocmds("BufReadPost", { buffer = source })
assert(not vim.b[source].large_file)
api.nvim_buf_set_lines(source, 0, -1, false, { string.rep("x", 1024 * 1024) })
api.nvim_exec_autocmds("BufReadPost", { buffer = source })
assert(vim.b[source].large_file and vim.wo.foldmethod == "manual")
vim.fn.delete(temp, "rf")
print("PASS: environment restoration, stateful reloads, format toggles, FilePost lifecycle")
