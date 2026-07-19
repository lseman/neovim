return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    event = "VeryLazy",

    config = function()
        local harpoon = require "harpoon"
        local map = vim.keymap.set
        local opts = { noremap = true, silent = true }

        -- Keep a single Harpoon list per working directory.
        harpoon:setup({
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
                key = function()
                    return vim.uv.cwd()
                end,
            },
        })

        local function current_list()
            return harpoon:list()
        end

        -- ── Your preferred shortcuts ────────────────────────────────────────────
        local function add_current_file()
            local list = current_list()
            list:add()
            vim.notify(("Added file to Harpoon (%d items)"):format(list:length()), vim.log.levels.INFO)
        end

        local function remove_current_file()
            current_list():remove()
            vim.notify("Removed current file from Harpoon", vim.log.levels.INFO)
        end

        local function compact_list(list)
            local items = {}

            for i = 1, list:length() do
                if list.items[i] then
                    table.insert(items, list.items[i])
                end
            end

            list.items = items
            list._length = #items
        end

        local function open_list()
            local list = current_list()
            compact_list(list)
            harpoon.ui:toggle_quick_menu(list)
        end

        map("n", "<F2>", add_current_file, vim.tbl_extend("force", opts, { desc = "Harpoon: Add file" }))
        map("n", "<F3>", remove_current_file, vim.tbl_extend("force", opts, { desc = "Harpoon: Remove current" }))
        map("n", "<F4>", open_list, vim.tbl_extend("force", opts, { desc = "Harpoon: List" }))
        map("n", "<leader>ha", add_current_file, vim.tbl_extend("force", opts, { desc = "Harpoon: Add file" }))

        -- ── Additional useful mappings (grouped under <leader>h) ────────────────
        map("n", "<leader>hm", open_list, vim.tbl_extend("force", opts, { desc = "Harpoon: List" }))

        -- Quick jumps to slots 1–4
        -- map("n", "<C-h>", function() list:select(1) end, vim.tbl_extend("force", opts, { desc = "Harpoon → 1" }))
        -- map("n", "<C-j>", function() list:select(2) end, vim.tbl_extend("force", opts, { desc = "Harpoon → 2" }))
        -- map("n", "<C-k>", function() list:select(3) end, vim.tbl_extend("force", opts, { desc = "Harpoon → 3" }))
        -- map("n", "<C-l>", function() list:select(4) end, vim.tbl_extend("force", opts, { desc = "Harpoon → 4" }))

        -- Cycle through marks
        map("n", "<C-S-P>", function()
            current_list():prev({ ui_nav_wrap = true })
        end, vim.tbl_extend("force", opts, { desc = "Harpoon: Previous" }))
        map("n", "<C-S-N>", function()
            current_list():next({ ui_nav_wrap = true })
        end, vim.tbl_extend("force", opts, { desc = "Harpoon: Next" }))

        -- Remove / Clear
        map("n", "<leader>hd", remove_current_file, vim.tbl_extend("force", opts, { desc = "Harpoon: Remove current" }))

        map("n", "<leader>hc", function()
            current_list():clear()
            vim.notify("Harpoon list cleared", vim.log.levels.WARN)
        end, vim.tbl_extend("force", opts, { desc = "Harpoon: Clear all" }))
    end,
}
