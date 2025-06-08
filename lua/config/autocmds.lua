-- Utility functions
local create_group = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Terminal and cursor settings
autocmd("ExitPre", {
    group = create_group("Exit", { clear = true }),
    command = "set guicursor=a:ver90",
    desc = "Set cursor back to beam when leaving Neovim"
})

-- Diagnostic float
autocmd("CursorHold", {
    group = create_group("DiagnosticFloat", { clear = true }),
    callback = function()
        if #vim.diagnostic.get() > 0 then
            vim.diagnostic.open_float({
                focusable = false,
                close_events = {"BufLeave", "CursorMoved", "InsertEnter", "FocusLost"},
                border = "rounded",
                source = "always",
                prefix = " ",
                scope = "cursor"
            })
        end
    end,
    desc = "Show diagnostics float on cursor hold"
})

-- Kitty terminal configuration
local kitty = {
    set_spacing = function(padding, margin)
        if vim.fn.executable("kitty") == 1 then
            vim.system(string.format("kitty @ set-spacing padding=%d margin=%d", padding, margin))
        end
    end
}

local kitty_group = create_group("KittyConfig", { clear = true })
autocmd("VimEnter", {
    group = kitty_group,
    callback = function() kitty.set_spacing(0, 0) end,
    desc = "Remove Kitty padding/margin on enter"
})

autocmd("VimLeavePre", {
    group = kitty_group,
    callback = function() kitty.set_spacing(20, 10) end,
    desc = "Restore Kitty padding/margin on leave"
})

-- CMake formatting
local function format_cmake()
    if vim.fn.executable("cmake-format") ~= 1 then
        vim.notify("cmake-format not found", vim.log.levels.WARN)
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    vim.cmd("write")
    vim.fn.jobstart({"cmake-format", "-i", filename}, {
        on_exit = function(_, code)
            if code == 0 then
                vim.cmd("edit!")
                vim.schedule(function()
                    pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
                end)
                vim.notify("CMake formatting complete", vim.log.levels.INFO)
            else
                vim.notify("cmake-format failed", vim.log.levels.ERROR)
            end
        end
    })
end

autocmd("BufWritePost", {
    group = create_group("CMakeFormat", { clear = true }),
    pattern = "CMakeLists.txt",
    callback = format_cmake,
    desc = "Format CMakeLists.txt on save"
})

-- Additional commands
local function restore_cursor()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
end

-- Standard editor behavior
autocmd("TextYankPost", {
    group = create_group("HighlightYank", { clear = true }),
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 200
        })
    end,
    desc = "Highlight yanked text"
})

autocmd("BufReadPost", {
    group = create_group("RestoreCursor", { clear = true }),
    callback = restore_cursor,
    desc = "Restore cursor position"
})

autocmd({"FocusGained", "TermClose", "TermLeave"}, {
    group = create_group("CheckTime", { clear = true }),
    command = "checktime",
    desc = "Check if file changed externally"
})

autocmd("VimResized", {
    group = create_group("AutoResize", { clear = true }),
    command = "wincmd =",
    desc = "Auto-resize windows"
})