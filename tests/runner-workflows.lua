-- Run: nvim --headless -u NONE -i NONE -l tests/runner-workflows.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
local api = vim.api
local runner = require "config.runner"
runner.setup({ shell = "/bin/sh", auto_save = false, notify = false, clear_terminal = false })
runner.run_code([[value = "$HOME $(printf wrong) `printf wrong` 'quoted'"
print(value)]])
local result = vim.system({ "/bin/sh", "-c", runner.state.last_command }, { text = true }):wait()
assert(result.code == 0, result.stderr)
assert(result.stdout == "$HOME $(printf wrong) `printf wrong` 'quoted'\n", result.stdout)
local buf, job = runner.state.terminal_buf, runner.state.terminal_job
runner.toggle_terminal()
runner.toggle_terminal()
assert(runner.state.terminal_buf == buf and runner.state.terminal_job == job, "hidden terminal must reuse shell")
vim.fn.jobstop(job)
assert(vim.wait(1000, function() return runner.state.terminal_job == nil end))
runner.run_code("print('restarted')")
assert(runner.state.terminal_job ~= job and api.nvim_buf_is_valid(runner.state.terminal_buf))
runner.close_terminal()
runner.close_terminal()
api.nvim_buf_set_lines(0, 0, -1, false, { "value = 42", "print(value)" })
api.nvim_buf_set_mark(0, "<", 1, 0, {})
api.nvim_buf_set_mark(0, ">", 2, #"print(value)" - 1, {})
runner.run_selection()
result = vim.system({ "/bin/sh", "-c", runner.state.last_command }, { text = true }):wait()
assert(result.code == 0 and result.stdout == "42\n", result.stderr)
runner.close_terminal()

local temp = vim.fn.tempname() .. " project ' $literal"
vim.fn.mkdir(temp, "p")
local path = temp .. "/script ' $literal.py"
vim.fn.writefile({ "print('file ok')" }, path)
runner.run_file(path)
result = vim.system({ "/bin/sh", "-c", runner.state.last_command }, { text = true }):wait()
assert(result.code == 0 and result.stdout == "file ok\n", result.stderr)
runner.close_terminal()

-- Returning to existing buffers must restore their project's environment.
package.loaded["config.env"] = { notify_loaded = function() end }
require "config.workflows"
local buffers = {}
for _, name in ipairs({ "a", "b" }) do
    local project = temp .. "/" .. name
    vim.fn.mkdir(project .. "/.venv/bin", "p")
    vim.fn.writefile({ "#!/bin/sh", "echo Python-test" }, project .. "/.venv/bin/python")
    vim.fn.setfperm(project .. "/.venv/bin/python", "rwx------")
    local b = api.nvim_create_buf(true, false)
    api.nvim_buf_set_name(b, project .. "/main.py")
    api.nvim_set_current_buf(b)
    assert(vim.env.VIRTUAL_ENV == project .. "/.venv")
    buffers[name] = b
end
api.nvim_set_current_buf(buffers.a)
assert(vim.env.VIRTUAL_ENV == temp .. "/a/.venv")
assert(not vim.env.PATH:find(temp .. "/b/.venv/bin", 1, true), "old environment must leave PATH")
local opts = require("plugins.lsp.conform").opts
local b = api.nvim_get_current_buf()
vim.b[b].large_file = true
assert(opts.format_on_save(b) == nil)
vim.b[b].large_file = false
api.nvim_buf_set_lines(b, 0, -1, false, { string.rep("x", 1024 * 1024) })
assert(opts.format_on_save(b) == nil, "single-line large files must skip formatting")
api.nvim_buf_set_lines(b, 0, -1, false, { "print('small')" })
assert(opts.format_on_save(b) ~= nil)
vim.fn.delete(temp, "rf")
print("PASS: runner quoting, terminal reuse/restart, project environment switching, large-file formatting")
