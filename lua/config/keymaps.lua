-- lua/config/keymaps.lua
-- Simplified – no custom nmap/imap/vmap helpers
-- All mappings use vim.keymap.set directly
local map = vim.keymap.set
local integrations = require("config.integrations")
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

-- map("n", "<C-h>", "<C-w>h", default_opts)
-- map("n", "<C-j>", "<C-w>j", default_opts)
-- map("n", "<C-k>", "<C-w>k", default_opts)
-- map("n", "<C-l>", "<C-w>l", default_opts)

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

-- ── 5. Search / Picker (Snacks-first, Telescope fallback) ─────────────────

map("n", ";", integrations.picker("files", "find_files"), vim.tbl_extend("force", default_opts, {
    desc = "Find files"
}))

map("n", ".", integrations.picker("grep", "live_grep"), vim.tbl_extend("force", default_opts, {
    desc = "Live grep"
}))

map("n", ",", integrations.picker("buffers", "buffers"), vim.tbl_extend("force", default_opts, {
    desc = "Buffers"
}))

map("n", "\\", function()
    if not integrations.toggle_explorer() then
        vim.notify("No explorer backend available", vim.log.levels.WARN)
    end
end, vim.tbl_extend("force", default_opts, {
    desc = "File explorer"
}))

map("n", "<C-e>", function()
    if not integrations.toggle_explorer() then
        vim.notify("No explorer backend available", vim.log.levels.WARN)
    end
end, vim.tbl_extend("force", default_opts, {
    desc = "Toggle Explorer"
}))

map("n", "<C-f>", function()
    if not integrations.open_current_buffer_picker() then
        vim.notify("No in-buffer finder available", vim.log.levels.WARN)
    end
end, vim.tbl_extend("force", default_opts, {
    desc = "Fuzzy find in current buffer"
}))

-- ── 6. Plugins & Utilities ─────────────────────────────────────────────

map("n", "<C-b>", function()
    local ok, nabla = pcall(require, "nabla")
    if not ok then
        vim.notify("nabla is not available", vim.log.levels.WARN)
        return
    end

    nabla.popup({
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

map("n", "<F7>", function()
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

-- Copilot / completion Tab (after blink.cmp is loaded)
vim.g.copilot_no_tab_map = true

map("i", "<Tab>", function()
    local ok, suggestion = pcall(require, "copilot.suggestion")
    if ok and suggestion and suggestion.is_visible() then
        suggestion.accept()
        return ""
    end

    -- Fallback to blink.cmp behavior or next completion
    if vim.fn.pumvisible() == 1 then
        return "<C-n>"
    end

    return "<Tab>"
end, {
    expr = true,
    noremap = true,
    silent = true,
    desc = "Copilot accept / next completion / tab"
})

-- Add this to your keymaps.lua (e.g. in section 6. Plugins & Utilities)
map("n", "<leader>rr", function()
    vim.cmd("source " .. vim.fn.fnameescape(vim.env.MYVIMRC))
    vim.notify("Core config reloaded", vim.log.levels.INFO)
end, {
    desc = "Reload init.lua"
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", {
    desc = "Open parent directory"
})
