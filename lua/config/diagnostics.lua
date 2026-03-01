local M = {}

local diagnostics_enabled = true
local popup_delay = 250
local popup_timer = nil

vim.diagnostic.config({
    virtual_text = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "●",
            [vim.diagnostic.severity.WARN] = "●",
            [vim.diagnostic.severity.INFO] = "●",
            [vim.diagnostic.severity.HINT] = "●"
        }
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "if_many",
        header = "",
        prefix = " ",
        max_width = 100
    }
})

local function show_diagnostics_popup()
    if not diagnostics_enabled then
        return
    end

    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diagnostics = vim.diagnostic.get(0, {
        lnum = line
    })
    if #diagnostics == 0 then
        return
    end

    vim.diagnostic.open_float(nil, {
        scope = "cursor",
        close_events = {"BufLeave", "CursorMoved", "InsertEnter", "FocusLost"}
    })
end

local function show_diagnostics_debounced()
    if popup_timer then
        popup_timer:stop()
        popup_timer:close()
        popup_timer = nil
    end

    popup_timer = vim.uv.new_timer()
    popup_timer:start(popup_delay, 0, vim.schedule_wrap(function()
        show_diagnostics_popup()
        if popup_timer then
            popup_timer:stop()
            popup_timer:close()
            popup_timer = nil
        end
    end))
end

local group = vim.api.nvim_create_augroup("DiagnosticsPopup", {
    clear = true
})

vim.api.nvim_create_autocmd("CursorHold", {
    group = group,
    callback = show_diagnostics_debounced,
    desc = "Show diagnostics popup on cursor hold"
})

vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
        if popup_timer then
            popup_timer:stop()
            popup_timer:close()
            popup_timer = nil
        end
    end,
    desc = "Cancel diagnostics popup timer on insert"
})

vim.api.nvim_create_user_command("DiagnosticDelay", function(opts)
    local new_delay = tonumber(opts.args)
    if not new_delay or new_delay < 10 then
        vim.notify("Invalid delay value. Use a number >= 10.", vim.log.levels.ERROR)
        return
    end
    popup_delay = new_delay
    vim.opt.updatetime = new_delay
    vim.notify(string.format("Diagnostic popup delay set to %dms", new_delay), vim.log.levels.INFO)
end, {
    nargs = 1,
    desc = "Set diagnostic popup delay in milliseconds"
})

M.show_popup = show_diagnostics_popup
M.toggle = function()
    diagnostics_enabled = not diagnostics_enabled
    if diagnostics_enabled then
        vim.diagnostic.enable()
        vim.notify("Diagnostics enabled", vim.log.levels.INFO)
    else
        vim.diagnostic.disable()
        vim.notify("Diagnostics disabled", vim.log.levels.INFO)
    end
end
M.status = function()
    return diagnostics_enabled
end
M.set_delay = function(delay)
    if type(delay) == "number" and delay >= 10 then
        popup_delay = delay
        vim.opt.updatetime = delay
    end
end

return M
