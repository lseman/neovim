-- lua/config/keymaps.lua
-- Simplified – no custom nmap/imap/vmap helpers
-- All mappings use vim.keymap.set directly
local map = vim.keymap.set
local default_opts = {
    noremap = true,
    silent = true
}

-- ── 1. Core ─────────────────────────────────────────────────────────────

-- Save
map({"n", "v", "i"}, "<C-s>", "<cmd>update<CR>", vim.tbl_extend("force", default_opts, {
    desc = "Save file"
}))

-- Quit with confirmation
local function smart_quit()
    if vim.bo.modified then
        local choice = vim.fn.confirm("Save changes before quitting?", "&Yes\n&No\n&Cancel", 1)
        if choice == 1 then
            vim.cmd("silent! wqa")
        elseif choice == 2 then
            vim.cmd("silent! qa!")
        end
    else
        vim.cmd("silent! qa")
    end
end

map({"n", "v", "i"}, "<C-q>", function()
    local mode = vim.api.nvim_get_mode().mode
    if mode:find("i") then
        vim.cmd("stopinsert")
    end
    if mode:find("[vV]") then
        vim.cmd("normal! <Esc>")
    end
    vim.schedule(smart_quit)
end, vim.tbl_extend("force", default_opts, {
    desc = "Quit (confirm if modified)"
}))

-- Undo / Redo
map("n", "<C-z>", "u", default_opts)
map("n", "<C-y>", "<C-r>", default_opts)
map("i", "<C-z>", "<C-o>u", default_opts)
map("i", "<C-y>", "<C-o><C-r>", default_opts)

-- ── 2. Navigation ───────────────────────────────────────────────────────

map("n", "<C-h>", "<C-w>h", default_opts)
map("n", "<C-j>", "<C-w>j", default_opts)
map("n", "<C-k>", "<C-w>k", default_opts)
map("n", "<C-l>", "<C-w>l", default_opts)

map("n", "<C-Up>", "<cmd>resize +2<CR>", default_opts)
map("n", "<C-Down>", "<cmd>resize -2<CR>", default_opts)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", default_opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", default_opts)

-- ── Smart arrows in insert mode (still included) ───────────────────────

local function smart_left()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return col == 0 and "<Up><End>" or "<Left>"
end

local function smart_right()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    return cursor[2] >= #line and "<Down><Home>" or "<Right>"
end

map("i", "<Left>", smart_left, {
    expr = true,
    noremap = true,
    desc = "Smart left – jump to previous line if at start"
})
map("i", "<Right>", smart_right, {
    expr = true,
    noremap = true,
    desc = "Smart right – jump to next line if at end"
})

-- ── 3. Buffers & Tabs ──────────────────────────────────────────────────

map("n", "<C-]>", "<cmd>bnext<CR>", default_opts)
map("n", "<C-[>", "<cmd>bprevious<CR>", default_opts)

-- Buffer 1–9
for i = 1, 9 do
    map("n", "<C-" .. i .. ">", function()
        local bufs = vim.fn.getbufinfo({
            buflisted = 1
        })
        if i <= #bufs then
            vim.cmd("buffer " .. bufs[i].bufnr)
        else
            vim.notify("No buffer #" .. i, vim.log.levels.WARN)
        end
    end, {
        noremap = true,
        silent = true,
        desc = "Buffer " .. i
    })
end

map("n", "<leader>tn", "<cmd>tabnew<CR>", default_opts)
map("n", "<leader>tc", "<cmd>tabclose<CR>", default_opts)
map("n", "<leader>to", "<cmd>tabonly<CR>", default_opts)

-- ── 4. Text & Clipboard ────────────────────────────────────────────────

map("v", "<C-c>", '"+y', default_opts)
map("n", "<C-v>", '"+p', default_opts)
map("n", "<C-S-v>", '"+P', default_opts)
map("i", "<C-v>", "<C-r>+", default_opts)
map("v", "<C-v>", '"_dP', default_opts)

map({"n", "v", "i"}, "<C-a>", "<Esc>ggVG", vim.tbl_extend("force", default_opts, {
    desc = "Select all"
}))

map("v", "<Tab>", ">gv", default_opts)
map("v", "<S-Tab>", "<gv", default_opts)

-- ── 5. Search / Telescope ──────────────────────────────────────────────

local builtin = require("telescope.builtin")

map("n", ";", function()
    local include = {"lua", "py", "ts", "tsx", "js", "jsx", "html", "css", "json", "md", "ipynb", "vhd", "Makefile"}
    local exclude = {".git", "node_modules", ".venv", "__pycache__", ".mypy_cache", ".idea", ".vscode", ".cache"}

    local cmd = {"fd", "--type", "f", "--hidden", "--no-ignore", "--no-ignore-parent"}
    for _, ext in ipairs(include) do
        vim.list_extend(cmd, {"--extension", ext})
    end
    for _, dir in ipairs(exclude) do
        vim.list_extend(cmd, {"--exclude", dir})
    end

    builtin.find_files({
        find_command = cmd,
        hidden = true
    })
end, vim.tbl_extend("force", default_opts, {
    desc = "Find files (filtered)"
}))

map("n", ".", builtin.live_grep, default_opts)
map("n", ",", builtin.buffers, default_opts)

map("n", "\\", function()
    require("telescope").extensions.file_browser.file_browser({
        path = "%:p:h",
        select_buffer = true
    })
end, vim.tbl_extend("force", default_opts, {
    desc = "File browser (current dir)"
}))

map("n", "<leader>ff", builtin.find_files, default_opts)
map("n", "<leader>fg", builtin.git_files, default_opts)
map("n", "<leader>fw", builtin.grep_string, default_opts)
map("n", "<leader>sh", builtin.help_tags, default_opts)

map({"n", "i"}, "<C-f>", function()
    if vim.fn.mode() == "i" then
        vim.cmd("normal! <Esc>")
    end
    builtin.current_buffer_fuzzy_find({
        layout_strategy = "vertical",
        layout_config = {
            width = 0.65,
            height = 0.7,
            prompt_position = "top",
            preview_height = 0.45
        },
        sorting_strategy = "ascending"
    })
end, vim.tbl_extend("force", default_opts, {
    desc = "Fuzzy find in current buffer"
}))

-- ── 6. Plugins & Utilities ─────────────────────────────────────────────

map("n", "<C-e>", function()
    require("nvim-tree.api").tree.toggle({
        find_file = true
    })
end, vim.tbl_extend("force", default_opts, {
    desc = "Toggle NvimTree"
}))

map("n", "<C-b>", function()
    require("nabla").popup({
        border = "single"
    })
end, vim.tbl_extend("force", default_opts, {
    desc = "Nabla popup"
}))

map("n", "<C-h>", function()
    require("config.custom").find_and_replace()
end, vim.tbl_extend("force", default_opts, {
    desc = "Find and Replace"
}))

map("n", "<F5>", function()
    local ft = vim.bo.filetype
    local build_cmd = ({
        cpp = "make -j$(nproc)",
        rust = "cargo build",
        go = "go build",
        typescript = "npm run build",
        javascript = "npm run build"
    })[ft]

    if build_cmd then
        vim.cmd("write")
        vim.cmd("split | terminal " .. build_cmd)
        vim.cmd("startinsert")
    else
        vim.notify("No build command for " .. ft, vim.log.levels.WARN)
    end
end, vim.tbl_extend("force", default_opts, {
    desc = "Smart build"
}))

-- Copilot / completion Tab
vim.g.copilot_no_tab_map = true
map("i", "<Tab>", function()
    local suggestion = require("copilot.suggestion")
    if suggestion.is_visible() then
        suggestion.accept()
        return ""
    elseif vim.fn.pumvisible() == 1 then
        return "<C-n>"
    else
        return "<Tab>"
    end
end, {
    expr = true,
    noremap = true,
    silent = false,
    desc = "Copilot accept / next completion / tab"
})
