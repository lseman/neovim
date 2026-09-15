-- Utility functions
local create_group = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local function group(name)
    return create_group(name, {
        clear = true
    })
end

-- ============================================================
-- User FilePost: fires after UIEnter + real file buffer.
-- All plugins subscribe to this instead of scattered events.
-- ============================================================
autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
    group = group "NvFilePost",
    callback = function(args)
        local file = vim.api.nvim_buf_get_name(args.buf)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

        if not vim.g.ui_entered and args.event == "UIEnter" then
            vim.g.ui_entered = true
        end

        if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
            vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
            vim.api.nvim_del_augroup_by_name "NvFilePost"

            vim.schedule(function()
                vim.api.nvim_exec_autocmds("FileType", {})

                if vim.g.editorconfig then
                    local ok, ec = pcall(require, "editorconfig")
                    if ok then ec.config(args.buf) end
                end
            end)
        end
    end,
})

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

-- LSP folding: switch to LSP foldexpr/foldtext when server supports textDocument/foldingRange
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/foldingRange") then
            vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
            vim.wo.foldtext = "v:lua.vim.lsp.foldtext()"
        end
    end,
})

-- LSP inline completion: enable when server supports textDocument/inlineCompletion
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/inlineCompletion") then
            vim.lsp.inline_completion.enable()
        end
    end,
})
-- ============================================================
-- TSInstallAll: install all Treesitter parsers from ensure_installed list
-- ============================================================
vim.api.nvim_create_user_command("TSInstallAll", function()
    local spec = require("lazy.core.config").plugins["nvim-treesitter"]
    local opts = type(spec.opts) == "table" and spec.opts or {}
    local langs = opts.ensure_installed or {}
    if #langs == 0 then
        vim.notify("No Treesitter parsers in ensure_installed", vim.log.levels.WARN)
        return
    end
    require("nvim-treesitter").install(langs)
end, { desc = "Install all Treesitter parsers" })
