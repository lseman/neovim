-- lua/config/diagnostics.lua
-- Enhanced diagnostics configuration with popup-only display

-- ============================================================================
-- Core Diagnostic Configuration
-- ============================================================================

vim.diagnostic.config({
    virtual_text = false,     -- Disable inline diagnostics
    signs = false,           -- Disable signs in the gutter (will be configured separately)
    underline = false,       -- Disable underlining
    update_in_insert = false,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = " ",
        max_width = 80,
        max_height = 15,
        wrap = true,
        suffix = "",
        format = function(diagnostic)
            -- Custom formatting for better readability
            local code = diagnostic.code and string.format(" [%s]", diagnostic.code) or ""
            local source = diagnostic.source and string.format(" (%s)", diagnostic.source) or ""
            return string.format("%s%s%s", diagnostic.message, code, source)
        end,
    }
})

-- ============================================================================
-- LSP Handler Configuration (Fixed deprecated API)
-- ============================================================================

-- Note: vim.lsp.diagnostic.on_publish_diagnostics is deprecated
-- Using the modern approach instead
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        signs = false,
        underline = false,
        update_in_insert = false,
    }
)

-- ============================================================================
-- Enhanced Popup Functions
-- ============================================================================

local popup_timer = nil
local popup_delay = 300  -- milliseconds

-- Enhanced diagnostics popup with better positioning and content
local function show_diagnostics_popup()
    -- Cancel any existing timer
    if popup_timer then
        vim.loop.timer_stop(popup_timer)
        popup_timer = nil
    end
    
    -- Get diagnostics for current position
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    
    -- Only show popup if there are diagnostics
    if #diagnostics == 0 then
        return
    end
    
    vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = {"BufLeave", "CursorMoved", "InsertEnter", "FocusLost"},
        border = "rounded",
        source = "always",
        prefix = function(diagnostic, i, total)
            -- Custom prefix with severity icons
            local icons = {
                [vim.diagnostic.severity.ERROR] = " ",
                [vim.diagnostic.severity.WARN] = " ",
                [vim.diagnostic.severity.INFO] = " ",
                [vim.diagnostic.severity.HINT] = " "
            }
            local icon = icons[diagnostic.severity] or " "
            return string.format("%s ", icon)
        end,
        suffix = "",
        severity_sort = true,
        style = "minimal",
        max_width = 80,
        max_height = 15,
        wrap = true,
    })
end

-- Debounced version to prevent popup spam
local function show_diagnostics_debounced()
    -- Cancel existing timer
    if popup_timer then
        vim.loop.timer_stop(popup_timer)
    end
    
    -- Create new timer
    popup_timer = vim.loop.new_timer()
    popup_timer:start(popup_delay, 0, vim.schedule_wrap(function()
        show_diagnostics_popup()
        popup_timer = nil
    end))
end

-- ============================================================================
-- Auto Commands for Popup Management
-- ============================================================================

local diagnostics_group = vim.api.nvim_create_augroup("DiagnosticsPopup", { clear = true })

-- Show diagnostics on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
    group = diagnostics_group,
    callback = show_diagnostics_debounced,
    desc = "Show diagnostics popup on cursor hold"
})

-- Hide popup when cursor moves
vim.api.nvim_create_autocmd("CursorMoved", {
    group = diagnostics_group,
    callback = function()
        -- Close any existing diagnostic floats
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
                local buf = vim.api.nvim_win_get_buf(win)
                local buf_name = vim.api.nvim_buf_get_name(buf)
                if buf_name:match("diagnostic") then
                    vim.api.nvim_win_close(win, false)
                end
            end
        end
        
        -- Cancel pending timer
        if popup_timer then
            vim.loop.timer_stop(popup_timer)
            popup_timer = nil
        end
    end,
    desc = "Hide diagnostics popup on cursor move"
})

-- ============================================================================
-- Visual Configuration and Highlights
-- ============================================================================

-- Set up diagnostic highlights with better colors
local function setup_diagnostic_highlights()
    local highlights = {
        -- Diagnostic severity colors
        DiagnosticError = { fg = "#FF6B6B", bold = true },
        DiagnosticWarn = { fg = "#FFD93D", bold = true },
        DiagnosticInfo = { fg = "#6BCF7F", bold = true },
        DiagnosticHint = { fg = "#4D9DFF", bold = true },
        
        -- Float window styling
        NormalFloat = { bg = "none" },
        FloatBorder = { fg = "#FFFFFF", bg = "none" },
        
        -- Diagnostic float specific
        DiagnosticFloatingError = { fg = "#FF6B6B", bg = "none" },
        DiagnosticFloatingWarn = { fg = "#FFD93D", bg = "none" },
        DiagnosticFloatingInfo = { fg = "#6BCF7F", bg = "none" },
        DiagnosticFloatingHint = { fg = "#4D9DFF", bg = "none" },
    }
    
    for group, opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

-- Apply highlights
setup_diagnostic_highlights()

-- ============================================================================
-- Sign Configuration (Optional - keeping disabled as per your preference)
-- ============================================================================

-- Configure diagnostic signs (currently disabled but available)
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '●',
            [vim.diagnostic.severity.WARN] = '●',
            [vim.diagnostic.severity.INFO] = '●',
            [vim.diagnostic.severity.HINT] = '●'
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
            [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
        }
    }
})

-- ============================================================================
-- Configuration Options
-- ============================================================================

-- Adjust popup delay (you can modify this value)
vim.opt.updatetime = popup_delay

-- Create a command to adjust popup delay dynamically
vim.api.nvim_create_user_command('DiagnosticDelay', function(opts)
    local new_delay = tonumber(opts.args)
    if new_delay and new_delay > 0 then
        popup_delay = new_delay
        vim.opt.updatetime = new_delay
        vim.notify(string.format('Diagnostic popup delay set to %dms', new_delay), vim.log.levels.INFO)
    else
        vim.notify('Invalid delay value. Use a positive number.', vim.log.levels.ERROR)
    end
end, {
    nargs = 1,
    desc = 'Set diagnostic popup delay in milliseconds'
})

-- ============================================================================
-- Module Export (for use in other configs)
-- ============================================================================

-- Export functions for use in other parts of config
local M = {}

M.show_popup = show_diagnostics_popup
M.toggle = function()
    if diagnostics_enabled then
        vim.diagnostic.disable()
        diagnostics_enabled = false
    else
        vim.diagnostic.enable()
        diagnostics_enabled = true
    end
end
M.status = diagnostic_status
M.set_delay = function(delay)
    popup_delay = delay
    vim.opt.updatetime = delay
end

return M