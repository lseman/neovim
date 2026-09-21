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

do
  local saved_name, saved_bg = require("config.themes").load_saved_theme()
  if saved_bg then vim.o.background = saved_bg end
  local applied = saved_name or "ayu-mirage"
  if not pcall(vim.cmd.colorscheme, applied) then
    applied = "ayu-mirage"
    pcall(vim.cmd.colorscheme, applied)
  end
  -- Some colorschemes (e.g. every ayu-* variant) set vim.g.colors_name to a
  -- shared/generic value, so colors_name alone can't identify which named
  -- variant is active. Track the exact applied name ourselves.
  vim.g.current_theme = applied
end

