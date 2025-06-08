-- ~/.config/nvim/lua/lsp/patch.lua
local M = {}

M.patch_client_request = function()
  local lsp = vim.lsp
  if lsp._patched_request then return end
  lsp._patched_request = true

  local original_request = vim.lsp.client.request

  --- Patch all requests to inject `position_encoding_kind` if needed
  vim.lsp.client.request = function(self, method, params, ...)
    if type(params) == "table" and not params.position_encoding_kind then
      if self and self.offset_encoding then
        params.position_encoding_kind = self.offset_encoding
      else
        params.position_encoding_kind = "utf-16"
      end
    end
    return original_request(self, method, params, ...)
  end
end

return M
