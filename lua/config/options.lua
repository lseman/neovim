-- Set leader key before plugins
vim.g.mapleader = " "

-- Disable netrw (for nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ============================
-- Editor Option Groups
-- ============================

local ui_options = {
    number = true,
    relativenumber = false,
    showmatch = true,
    termguicolors = true,
    showbreak = "↳ ",
    breakindent = true,
    wrap = true,
    mouse = "a",
    updatetime = 250,
    timeoutlen = 300,
}

local search_options = {
    ignorecase = true,
    smartcase = true,
    hlsearch = true,
    incsearch = true,
}

local indent_options = {
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,
    autoindent = true,
    smartindent = true,
    shiftround = true,
}

local completion_options = {
    wildmode = "longest,list,full",
    pumheight = 10,
    completeopt = "menu,menuone,noselect",
}

local file_options = {
    backup = false,
    swapfile = false,
    undofile = true,
    writebackup = false,
}

local performance_options = {
    lazyredraw = false,
    hidden = true,
    history = 100,
    synmaxcol = 240,
}

-- ============================
-- Apply All Options
-- ============================

local function apply_options(opts)
    for key, value in pairs(opts) do
        vim.opt[key] = value
    end
end

for _, opts in ipairs({
    ui_options,
    search_options,
    indent_options,
    completion_options,
    file_options,
    performance_options,
}) do
    apply_options(opts)
end

-- ============================
-- Highlight Groups
-- ============================

local highlights = {
    Comment = { italic = true },
    Function = { italic = true },
    Type = { italic = true },
    ["@keyword"] = { italic = true },
    ["@variable"] = { bold = false },
    ["@property"] = { italic = false },
    ["@parameter"] = { italic = true },
}

for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
end

-- ============================
-- Autocommands
-- ============================

local augroup = vim.api.nvim_create_augroup("CustomSettings", { clear = true })

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- Return to last edit position on reopen
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    pattern = "*",
    callback = function()
        local last_pos = vim.fn.line("'")
        if last_pos > 0 and last_pos <= vim.fn.line("$") then
            vim.fn.setpos(".", vim.fn.getpos("'"))
        end
    end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 200,
        })
    end,
})