local M = {}

function M.reload()
    -- Plugin managers, terminals, providers, and environment subscriptions own
    -- live state. Reapply editor configuration without unloading those modules.
    for _, name in ipairs({
        "config.options", "config.autocmds", "config.diagnostics",
        "config.highlight", "config.keymaps", "config.cheatsheet",
    }) do
        package.loaded[name] = nil
        require(name)
    end
    require("config.workflows").setup()
    vim.notify("Editor configuration reloaded. Restart Neovim to apply plugin changes.", vim.log.levels.INFO)
end

return M
