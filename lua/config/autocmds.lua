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
local file_post_group = group "NvFilePost"
if not vim.g.config_file_post then
    autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
        group = file_post_group,
        callback = function(args)
            if args.event == "UIEnter" then vim.g.ui_entered = true end
            local file = vim.api.nvim_buf_get_name(args.buf)
            if file == "" or vim.bo[args.buf].buftype ~= "" or not vim.g.ui_entered then return end
            vim.g.config_file_post = true
            vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
            vim.api.nvim_del_augroup_by_name "NvFilePost"
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(args.buf) then return end
                vim.api.nvim_buf_call(args.buf, function()
                    vim.api.nvim_exec_autocmds("FileType", { buffer = args.buf, modeline = false })
                end)
            end)
        end,
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
        (vim.hl.hl_op or vim.hl.on_yank)({
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
        -- Trailing double spaces encode hard line breaks in Markdown/Quarto.
        if vim.bo[bufnr].filetype == "markdown" or vim.bo[bufnr].filetype == "quarto" then
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

-- Prose filetypes: enable wrap, linebreak, and spell
autocmd("FileType", {
    group = group "ProseOptions",
    pattern = { "markdown", "quarto", "tex", "text", "gitcommit" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
    end,
    desc = "Enable wrapping, linebreaks, and spell check for prose filetypes"
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

-- Inspect displayed content, including notebooks converted through BufReadCmd.
autocmd({ "BufReadPost", "FileType" }, {
    group = group "LargeFile",
    callback = function(args)
        if vim.bo[args.buf].buftype ~= "" or not require("config.buffer").is_large(args.buf) then return end
        vim.b[args.buf].large_file = true
        vim.bo[args.buf].undofile = false
        vim.treesitter.stop(args.buf)
        for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
            vim.wo[win].foldmethod = "manual"
        end
    end,
    desc = "Disable expensive features for large buffers",
})

local function update_folds(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) or require("config.buffer").is_large(bufnr) then return end
    local has_lsp = #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/foldingRange" }) > 0
    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        vim.wo[win].foldexpr = has_lsp and "v:lua.vim.lsp.foldexpr()" or "v:lua.vim.treesitter.foldexpr()"
        vim.wo[win].foldtext = has_lsp and "v:lua.vim.lsp.foldtext()" or "foldtext()"
    end
end

autocmd({ "LspAttach", "LspDetach", "BufWinEnter" }, {
    group = group "ConfigFolding",
    callback = function(args)
        -- LspDetach fires before the client has been removed from the buffer.
        vim.schedule(function() update_folds(args.buf) end)
    end,
    desc = "Select native LSP or Tree-sitter folds for each buffer window",
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
