-- lua/config/keymaps.lua
--[[
    Neovim Keymaps Configuration
    Organization:
    1. Core Editor Functions (save, quit, undo, redo)
    2. Navigation and Window Management
    3. Buffer and Tab Management
    4. Text Manipulation
    5. Search and Telescope Integration
    6. File Explorer and Project Management
    7. Custom Functions and Utilities
    8. Plugin-Specific Mappings
--]]

-- Initialize global table for functions
G = G or {}

-- Utility function for creating keymaps
    local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.noremap = opts.noremap ~= false
        opts.silent = opts.silent ~= false
        vim.keymap.set(mode, lhs, rhs, opts)
    end
    

--[[ 1. Core Editor Functions ]]--

-- Save operations
vim.keymap.set("n", "<C-s>", ":silent! update<CR>", {
    noremap = true,
    silent = true,
    desc = "Save"
})
vim.keymap.set("v", "<C-s>", "<C-C>:silent! update<CR>", {
    noremap = true,
    silent = true,
    desc = "Save"
})
vim.keymap.set("i", "<C-s>", "<Esc>:silent! update<CR>gi", {
    noremap = true,
    silent = true,
    desc = "Save"
})

-- Quit and buffer close operations
local function confirm_quit()
    if vim.bo.modified then
        local choice = vim.fn.confirm("Save changes?", "&Yes\n&No\n&Cancel", 2)
        if choice == 1 then
            vim.cmd("silent! wqa")
        elseif choice == 2 then
            vim.cmd("silent! qa!")
        end
    else
        vim.cmd("silent! qa")
    end
    
    -- If that fails, force exit
    vim.schedule(function()
        os.exit(0)
    end)
end

-- Map for normal mode
vim.keymap.set("n", "<C-q>", confirm_quit, {
    noremap = true,
    silent = true,
    desc = "Quit with confirmation"
})

-- Map for visual mode
vim.keymap.set("v", "<C-q>", function()
    -- First exit visual mode, then run confirm_quit
    vim.cmd("normal! <Esc>")
    confirm_quit()
end, {
    noremap = true,
    silent = true,
    desc = "Quit with confirmation"
})

-- Map for insert mode
vim.keymap.set("i", "<C-q>", function()
    -- First exit insert mode, then run confirm_quit
    vim.cmd("stopinsert")
    confirm_quit()
end, {
    noremap = true,
    silent = true,
    desc = "Quit with confirmation"
})
-- Undo/Redo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.config/nvim/undo")

vim.keymap.set("n", "<C-z>", "u", { noremap = true, silent = true, desc = "Undo" })
vim.keymap.set("i", "<C-z>", "<C-O>u", { noremap = true, silent = true, desc = "Undo" })
vim.keymap.set("v", "<C-z>", "u", { noremap = true, silent = true, desc = "Undo" })
vim.keymap.set("n", "<C-y>", "<C-R>", { noremap = true, silent = true, desc = "Redo" })
vim.keymap.set("i", "<C-y>", "<C-O><C-R>", { noremap = true, silent = true, desc = "Redo" })
vim.keymap.set("v", "<C-y>", "<C-R>", { noremap = true, silent = true, desc = "Redo" })

--[[ 2. Navigation and Window Management ]]--

-- Smart arrow key navigation
local function smart_left_arrow_insert()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up><End>", true, true, true), "n", true)
        return ""
    else
        return vim.api.nvim_replace_termcodes("<Left>", true, true, true)
    end
end

local function smart_right_arrow_insert()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    if col >= #line then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down><Home>", true, true, true), "n", true)
        return ""
    else
        return vim.api.nvim_replace_termcodes("<Right>", true, true, true)
    end
end

-- Arrow key mappings
vim.api.nvim_set_keymap("i", "<Left>", "", { expr = true, noremap = true, callback = smart_left_arrow_insert })
vim.api.nvim_set_keymap("i", "<Right>", "", { expr = true, noremap = true, callback = smart_right_arrow_insert })


-- -- Smooth scrolling with Neoscroll
-- neoscroll = require("neoscroll")
-- local scroll_mappings = {
--     ["<C-e>"] = function() neoscroll.ctrl_u({ duration = 250 }) end,
--     ["<C-d>"] = function() neoscroll.ctrl_d({ duration = 250 }) end
-- }

-- for key, func in pairs(scroll_mappings) do
--     vim.keymap.set({"n", "v", "x"}, key, func)
-- end

--[[ 3. Buffer and Tab Management ]]--

-- Tab management
local tab_mappings = {
    ["n|<leader>tn"] = "tabnew",
    ["n|<leader>tc"] = "tabclose",
    ["n|<leader>to"] = "tabonly",
    ["n|<leader>tnext"] = "tabnext",
    ["n|<leader>tprev"] = "tabprevious",
    ["n|<C-n>"] = "tabnew",
    ["i|<C-n>"] = "<Esc>:tabnew<CR>"
}

for mapping, cmd in pairs(tab_mappings) do
    local mode, key = mapping:match("([^|]+)|(.+)")
    vim.api.nvim_set_keymap(mode, key, ":" .. cmd .. "<CR>", {
        noremap = true,
        silent = true
    })
end

-- Buffer navigation with BufferLine
local modes = {'n', 'i', 'v'}
local buffer_mappings = {
    ['<C-K>'] = 'bn',
    ['<C-J>'] = 'bp'
}

for _, mode in ipairs(modes) do
    for key, cmd in pairs(buffer_mappings) do
        local prefix = mode == 'n' and '' or '<Esc>'
        vim.keymap.set(mode, key, prefix .. '<cmd>' .. cmd .. '<CR>', {
            noremap = true,
            silent = true
        })
    end
end

--[[ 4. Text Manipulation ]]--

-- Clipboard operations
vim.keymap.set("v", "<C-x>", '"+x', { noremap = true, silent = true, desc = "Cut to clipboard" })
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true, desc = "Copy to clipboard" })
vim.keymap.set("v", "<C-v>", '"_d"+P', { noremap = true, silent = true, desc = "Paste from clipboard" })
vim.keymap.set("n", "<C-v>", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
vim.keymap.set("i", "<C-v>", "<C-R>+", { noremap = true, silent = true, desc = "Paste from clipboard" })

-- Selection operations
vim.keymap.set("n", "<C-A>", "ggVG", { noremap = true, silent = true, desc = "Select all" })
vim.keymap.set("i", "<C-A>", "<Esc>ggVG", { noremap = true, silent = true, desc = "Select all" })
vim.keymap.set("v", "<C-A>", "ggVG", { noremap = true, silent = true, desc = "Select all" })

-- Indentation
vim.api.nvim_set_keymap("v", "<Tab>", ">gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-Tab>", "<gv", { noremap = true, silent = true })

--[[ 5. Search and Telescope Integration ]]--
-- Telescope custom find_files using fd
local builtin = require("telescope.builtin")

vim.keymap.set("n", ";", function()
  local excludes = {
    ".git", ".vscode", "node_modules", ".mypy_cache", "__pycache__",
    ".venv", ".pytest_cache", ".cache", ".idea", ".DS_Store",
    "Thumbs.db", ".gitignore", ".env", "package-lock.json",
    "yarn.lock", "pnpm-lock.yaml", "flash-attention"
  }

  local fd_args = { "fd", "--type", "f", "--hidden", "--no-ignore", "--no-ignore-parent" }
  for _, pattern in ipairs(excludes) do
    table.insert(fd_args, "--exclude")
    table.insert(fd_args, pattern)
  end

  builtin.find_files({
    hidden = true,
    no_ignore = true,
    no_ignore_parent = true,
    find_command = fd_args,
  })
end, { desc = "Telescope find_files with fd + clean excludes" })

vim.keymap.set("n", ".", builtin.live_grep, {})
vim.keymap.set("n", ",", builtin.buffers, {})
vim.keymap.set("n", "\\", builtin.treesitter, {})

local telescope_mappings = {
    ["<leader>gf"] = "git_files",
    ["<leader>sf"] = "find_files",
    ["<leader>sh"] = "help_tags",
    ["<leader>sw"] = "grep_string",
    ["<leader>sg"] = "live_grep",
    ["<leader>sd"] = "diagnostics",
    ["<leader>sr"] = "resume"
}

for key, cmd in pairs(telescope_mappings) do
    vim.api.nvim_set_keymap("n", key, ":Telescope " .. cmd .. "<CR>", {
        noremap = true,
        silent = true
    })
end

-- Enhanced buffer search
vim.keymap.set({"n", "i"}, "<C-f>", function()
    if vim.fn.mode() == 'i' then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    end

    require('telescope.builtin').current_buffer_fuzzy_find({
        layout_strategy = 'vertical',
        layout_config = {
            width = 0.6,
            height = 0.6,
            prompt_position = "top",
            preview_height = 0.4
        },
        sorting_strategy = "ascending",
        prompt_title = "Search in Current Buffer",
        previewer = true,
        initial_mode = "insert",
        path_display = {"truncate"},
        results_title = false
    })
end, { desc = "Search in current buffer" })

--[[ 7. Custom Functions and Utilities ]]--

-- Build commands
vim.api.nvim_create_user_command("BR", function()
    vim.cmd("split | terminal cd build && make -j32 && ./dsn")
end, {})


-- Find and replace
vim.keymap.set('n', '<C-h>', function()
    require('config.custom').find_and_replace()
end, {
    noremap = true,
    silent = true,
    desc = "Find and Replace"
})

--[[ 8. Plugin-Specific Mappings ]]--

-- Enhanced build system
local function smart_build()
    local build_commands = {
        cpp = "make -j$(nproc)",
        rust = "cargo build",
        go = "go build",
        typescript = "npm run build",
        javascript = "npm run build"
    }

    local filetype = vim.bo.filetype
    local cmd = build_commands[filetype]

    if cmd then
        vim.cmd('write')
        vim.cmd('split')
        vim.cmd('terminal ' .. cmd)
        vim.cmd('startinsert')
    else
        vim.notify("No build command defined for filetype: " .. filetype, vim.log.levels.WARN)
    end
end

map('n', '<F5>', smart_build, { desc = "Smart build" })


local function accept_copilot_or_tab()
  local suggestion = require("copilot.suggestion")
  if suggestion.is_visible() then
    suggestion.accept()
    return ""
  elseif vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes("<C-n>", true, true, true)
  else
    return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
  end
end


G.accept_copilot_or_tab = accept_copilot_or_tab
vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.G.accept_copilot_or_tab()", {
    expr = true,
    silent = true
})

-- Switch to specific buffer using Ctrl + Number
for i = 1, 9 do
    vim.keymap.set('n', '<C-' .. i .. '>', function()
        -- Get a list of all listed buffers
        local buflist = vim.fn.getbufinfo({ buflisted = 1 })
        -- Check if the requested buffer exists
        if i <= #buflist then
            vim.cmd('buffer ' .. buflist[i].bufnr)
        else
            vim.notify("Buffer " .. i .. " does not exist", vim.log.levels.WARN)
        end
    end, {
        noremap = true,
        silent = true,
        desc = "Switch to buffer " .. i
    })
end

vim.keymap.set("n", "<C-b>", function()
  require("nabla").popup({ border = "single" }) -- or "double", "rounded"
end, { desc = "Nabla popup" })

vim.keymap.set("n", "<leader>fr", require("config.custom").find_and_replace, {
    noremap = true,
    silent = true,
    desc = "Find and Replace"
})

-- Replace <C-e> to open nvim-tree
vim.keymap.set("n", "<C-e>", function()
  require("nvim-tree.api").tree.toggle()
end, {
  noremap = true,
  silent = true,
  desc = "Toggle NvimTree"
})
