-- Native Neovim 0.12 diagnostics configuration
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = {
        current_line = true, -- shows diagnostics for the current line on CursorHold
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚",
            [vim.diagnostic.severity.WARN] = "󰀪",
            [vim.diagnostic.severity.INFO] = "󰋽",
            [vim.diagnostic.severity.HINT] = "󰌶",
        },
    },
    underline = {
        severity = {
            min = vim.diagnostic.severity.WARN,
        },
    },
    severity_sort = true,
    update_in_insert = false,
})

return {
    toggle = function()
        local enabled = vim.diagnostic.is_enabled()
        vim.diagnostic.enable(not enabled)
        vim.notify(enabled and "Diagnostics disabled" or "Diagnostics enabled", vim.log.levels.INFO)
    end,
    status = function()
        return vim.diagnostic.is_enabled()
    end,
}
