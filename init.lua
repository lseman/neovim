if vim.loader then
    vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local result = vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
                                  "--branch=stable", lazypath})
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({{"Failed to clone lazy.nvim:\n", "ErrorMsg"}, {result, "WarningMsg"}}, true, {})
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
                 "config.keymaps", "config.custom", "config.workflows"}

for _, mod in ipairs(modules) do
    safe_require(mod)
end

pcall(vim.cmd, "colorscheme ayu-mirage")
vim.g.skip_ts_context_commentstring_module = true
