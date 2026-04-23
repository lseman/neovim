if vim.loader then
    vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Pin the Neovim Python host to the system python3 so remote plugins
-- (e.g. molten-nvim) always find pynvim, regardless of project venvs.
do
    local candidates = {vim.fn.exepath("python3"), "/usr/bin/python3", "/usr/local/bin/python3"}
    for _, p in ipairs(candidates) do
        if p ~= "" and vim.fn.executable(p) == 1 then
            vim.g.python3_host_prog = p
            break
        end
    end
end

local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")
if not vim.uv.fs_stat(lazypath) then
    local result = vim.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath
    }):wait()
    if result.code ~= 0 then
        vim.api.nvim_echo({{"Failed to clone lazy.nvim:\n", "ErrorMsg"}, {result.stderr, "WarningMsg"}}, true, {})
        return
    end
end
vim.opt.rtp:prepend(lazypath)

local function safe_require(name)
    local ok, err = pcall(require, name)
    if not ok then
        vim.notify("Failed to load " .. name .. ":\n" .. tostring(err), vim.log.levels.ERROR)
    end
end

local modules = {"config.options", "config.lazy", "config.autocmds", "config.diagnostics", "config.highlight",
                 "config.keymaps", "config.keymap_cheatsheet"}

for _, mod in ipairs(modules) do
    safe_require(mod)
end

pcall(vim.cmd.colorscheme, "ayu-mirage")
vim.g.skip_ts_context_commentstring_module = true
