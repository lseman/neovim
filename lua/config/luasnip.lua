local config = {
  vscode = {
    exclude = vim.g.vscode_snippets_exclude or {},
    paths = vim.g.vscode_snippets_path or ""
  },
  snipmate = {
    paths = vim.g.snipmate_snippets_path or ""
  },
  lua = {
    paths = vim.g.lua_snippets_path or ""
  }
}

local function init_loader(name)
  local ok, loader = pcall(require, "luasnip.loaders." .. name)
  return ok and loader or nil
end

local loaders = {
  { name = "from_vscode", config = config.vscode },
  { name = "from_snipmate", config = config.snipmate },
  { name = "from_lua", config = config.lua },
}

for _, entry in ipairs(loaders) do
  local loader = init_loader(entry.name)
  if loader then
    pcall(loader.lazy_load)
    if entry.config.paths ~= "" or #entry.config.exclude > 0 then
      pcall(loader.lazy_load, {
        paths = entry.config.paths ~= "" and entry.config.paths or nil,
        exclude = entry.config.exclude,
      })
    end
  end
end

vim.api.nvim_create_autocmd("InsertLeave", {
  group = vim.api.nvim_create_augroup("LuaSnipCleanup", { clear = true }),
  desc = "Clean up LuaSnip snippet nodes when leaving insert mode",
  callback = function()
    local ok, ls = pcall(require, "luasnip")
    if not ok then return end
    local buf = vim.api.nvim_get_current_buf()
    if ls.session.current_nodes[buf] and not ls.session.jump_active then
      ls.unlink_current()
    end
  end,
})
