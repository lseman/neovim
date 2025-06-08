-- ~/.config/nvim/lua/lsp/patch.lua
local M = {}

M.patch_start_client = function()
  if vim.lsp._patched_start_client then return end
  vim.lsp._patched_start_client = true

  vim.lsp.start_client = function(config)
    return vim.lsp.start({ name = config.name or "legacy", cmd = config.cmd, root_dir = config.root_dir, config = config })
  end
end

return M
