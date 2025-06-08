return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    local telescope = require("telescope")
    local map = vim.keymap.set

    -- Correct setup call
    harpoon.setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        key = function()
          return vim.loop.cwd() .. vim.api.nvim_buf_get_name(0)
        end,
      },
    })

    -- Define the Harpoon list object
    local list = harpoon:list()

    -- Telescope integration
    local function toggle_telescope(harpoon_list)
      local ok, pickers = pcall(require, "telescope.pickers")
      if not ok then return end

      local items = harpoon_list.items or {}
      if #items == 0 then
        vim.notify("Harpoon list is empty", vim.log.levels.INFO)
        return
      end

      local file_paths = vim.tbl_map(function(item) return item.value end, items)
      pickers.new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({ results = file_paths }),
        previewer = require("telescope.config").values.file_previewer({}),
        sorter = require("telescope.config").values.generic_sorter({}),
      }):find()
    end

    -- Keymaps
    map("n", "<F2>", function() list:add() end, { desc = "Harpoon: Add file" })
    map("n", "<F3>", function() toggle_telescope(list) end, { desc = "Harpoon: Telescope UI" })
    map("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(list) end, { desc = "Harpoon: Toggle Menu" })

    -- Navigation
    map("n", "<C-h>", function() list:select(1) end, { desc = "Harpoon: Jump to 1" })
    map("n", "<C-j>", function() list:select(2) end, { desc = "Harpoon: Jump to 2" })
    map("n", "<C-k>", function() list:select(3) end, { desc = "Harpoon: Jump to 3" })
    map("n", "<C-l>", function() list:select(4) end, { desc = "Harpoon: Jump to 4" })

    -- Cycle
    map("n", "<C-S-P>", function() list:prev() end, { desc = "Harpoon: Previous mark" })
    map("n", "<C-S-N>", function() list:next() end, { desc = "Harpoon: Next mark" })

    -- Remove/Clear
    map("n", "<leader>hd", function()
      list:remove()
      vim.notify("Removed current file from Harpoon", vim.log.levels.INFO)
    end, { desc = "Harpoon: Remove file" })

    map("n", "<leader>hc", function()
      list:clear()
      vim.notify("Cleared all Harpoon marks", vim.log.levels.WARN)
    end, { desc = "Harpoon: Clear all" })

    -- Safe load for telescope extension
    pcall(telescope.load_extension, "harpoon")
  end,
}
