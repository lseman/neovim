-- Utility functions
local create_group = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local function group(name)
    return create_group(name, {
        clear = true
    })
end

-- Terminal and cursor settings
autocmd("ExitPre", {
    group = group("Exit"),
    command = "set guicursor=a:ver90",
    desc = "Set cursor back to beam when leaving Neovim"
})

-- Kitty terminal configuration
local kitty = {
    set_spacing = function(padding, margin)
        if vim.fn.executable("kitty") == 1 and vim.env.KITTY_PID then
            vim.system({"kitty", "@", "set-spacing", string.format("padding=%d", padding),
                        string.format("margin=%d", margin)}, {
                text = true
            })
        end
    end
}

local kitty_group = group("KittyConfig")
autocmd("VimEnter", {
    group = kitty_group,
    callback = function()
        kitty.set_spacing(0, 0)
    end,
    desc = "Remove Kitty padding/margin on enter"
})

autocmd("VimLeavePre", {
    group = kitty_group,
    callback = function()
        kitty.set_spacing(20, 10)
    end,
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
    group = group("CMakeFormat"),
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
    group = group("HighlightYank"),
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 200
        })
    end,
    desc = "Highlight yanked text"
})

autocmd("BufWritePre", {
    group = group("TrimTrailingWhitespace"),
    pattern = "*",
    callback = function(args)
        local bufnr = args.buf
        if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable or vim.bo[bufnr].binary then
            return
        end

        local view = vim.fn.winsaveview()
        local search = vim.fn.getreg("/")
        local search_type = vim.fn.getregtype("/")

        vim.cmd([[keeppatterns silent! %s/\s\+$//e]])

        vim.fn.setreg("/", search, search_type)
        vim.fn.winrestview(view)
    end,
    desc = "Trim trailing whitespace on save"
})

autocmd("FileType", {
    group = group("FormatOptions"),
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({"c", "r", "o"})
    end,
    desc = "Do not continue comments on new lines"
})

autocmd("BufReadPost", {
    group = group("RestoreCursor"),
    callback = restore_cursor,
    desc = "Restore cursor position"
})

autocmd({"FocusGained", "TermClose", "TermLeave"}, {
    group = group("CheckTime"),
    command = "checktime",
    desc = "Check if file changed externally"
})

autocmd("VimResized", {
    group = group("AutoResize"),
    command = "wincmd =",
    desc = "Auto-resize windows"
})
