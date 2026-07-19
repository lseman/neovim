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
    group = group "Exit",
    command = "set guicursor=a:ver90",
    desc = "Set cursor back to beam when leaving Neovim"
})

-- Kitty terminal configuration
local kitty = {
    set_spacing = function(padding, margin)
        if vim.fn.executable "kitty" == 1 and vim.env.KITTY_PID then
            vim.system({"kitty", "@", "set-spacing", string.format("padding=%d", padding),
                        string.format("margin=%d", margin)}, {
                text = true
            })
        end
    end
}

local kitty_group = group "KittyConfig"
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
    group = group "HighlightYank",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 200
        })
    end,
    desc = "Highlight yanked text"
})

autocmd("BufWritePre", {
    group = group "TrimTrailingWhitespace",
    pattern = "*",
    callback = function(args)
        local bufnr = args.buf
        if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable or vim.bo[bufnr].binary then
            return
        end

        local view = vim.fn.winsaveview()
        local search = vim.fn.getreg "/"
        local search_type = vim.fn.getregtype "/"

        vim.cmd [[keeppatterns silent! %s/\s\+$//e]]

        vim.fn.setreg("/", search, search_type)
        vim.fn.winrestview(view)
    end,
    desc = "Trim trailing whitespace on save"
})

autocmd("FileType", {
    group = group "FormatOptions",
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({"c", "r", "o"})
    end,
    desc = "Do not continue comments on new lines"
})

autocmd("BufReadPost", {
    group = group "RestoreCursor",
    callback = restore_cursor,
    desc = "Restore cursor position"
})

autocmd({"FocusGained", "TermClose", "TermLeave"}, {
    group = group "CheckTime",
    command = "checktime",
    desc = "Check if file changed externally"
})

autocmd("VimResized", {
    group = group "AutoResize",
    command = "wincmd =",
    desc = "Auto-resize windows"
})

-- Large file guard: disable expensive features for files > 1MB
autocmd("BufReadPre", {
    group = group "LargeFile",
    callback = function(args)
        local ok, stat = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
        if not ok or not stat or stat.size < 1024 * 1024 then
            return
        end
        vim.b[args.buf].large_file = true
        vim.opt_local.swapfile = false
        vim.opt_local.undofile = false
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.syntax = "off"
        vim.cmd "syntax off"
        vim.api.nvim_create_autocmd("BufReadPost", {
            buffer = args.buf,
            once = true,
            callback = function()
                vim.treesitter.stop(args.buf)
            end
        })
    end,
    desc = "Disable expensive features for large files"
})

-- nvim-ufo setup

-- nvim-ufo: attach new file buffers (skip dashboard/nofile/special/terminal)
autocmd("BufWinEnter", {
    group = group "Ufo",
    pattern = "*",
    callback = function(args)
        local buftype = vim.api.nvim_buf_get_option(args.buf, "buftype")
        local ft = vim.api.nvim_buf_get_option(args.buf, "filetype")
        local name = vim.api.nvim_buf_get_name(args.buf)
        -- Skip nofile, terminal, dashboard, yazi, and buffers without a file path
        if buftype == "nofile" or buftype == "terminal" or ft == "dashboard" or ft == "snacks_dashboard" or name == "" or
            name:match "^%w+://" then
            return
        end
        vim.b[args.buf].ufo = true
    end,
    desc = "Enable nvim-ufo for file buffers"
})
