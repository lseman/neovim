local M = {}

-- Native 0.12 diagnostics: virtual_lines.current_line provides IDE-like
-- inline diagnostic display on the current line, updating automatically
-- on CursorHold. No custom timer or autocmd machinery needed.
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = {
        current_line = true,
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
})

-- DiagnosticDelay command sets updatetime, which drives native CursorHold.
vim.api.nvim_create_user_command("DiagnosticDelay", function(opts)
    local new_delay = tonumber(opts.args)
    if not new_delay or new_delay < 10 then
        vim.notify("Invalid delay value. Use a number >= 10.", vim.log.levels.ERROR)
        return
    end
    vim.opt.updatetime = new_delay
    vim.notify(string.format("Diagnostic popup delay set to %dms", new_delay), vim.log.levels.INFO)
end, {
    nargs = 1,
    desc = "Set diagnostic popup delay in milliseconds (via updatetime)",
})

M.toggle = function()
    local enabled = vim.diagnostic.is_enabled({ bufnr = 0 })
    vim.diagnostic.enable(not enabled, { bufnr = 0 })
    vim.notify(enabled and "Diagnostics disabled" or "Diagnostics enabled", vim.log.levels.INFO)
end

M.status = function()
    return vim.diagnostic.is_enabled({ bufnr = 0 })
end

return M
