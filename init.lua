-- Disable Neovim's built-in directory buffer to avoid conflicts with oil.nvim
vim.g.loaded_nvim_dir_plugin = 1

if vim.loader then
  vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require "config.providers"
if not require("config.bootstrap").setup() then
    return
end

local function safe_require(name)
  local ok, err = pcall(require, name)
  if not ok then
    vim.notify("Failed to load " .. name .. ":\n" .. tostring(err), vim.log.levels.ERROR)
  end
end

local modules = {
  "config.options",
  "config.lazy",
  "config.autocmds",
  "config.diagnostics",
  "config.highlight",
  "config.keymaps",
  "config.cheatsheet",
  "config.workflows",
}

for _, mod in ipairs(modules) do
  safe_require(mod)
end

