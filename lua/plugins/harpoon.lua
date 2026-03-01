return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },

  event = "VeryLazy",

  config = function()
    local harpoon = require("harpoon")
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Setup with per-project persistence
    harpoon:setup({
      settings = {
        save_on_toggle    = true,
        sync_on_ui_close  = true,
        key = function()
          -- Makes the list unique per working directory + open file
          return vim.loop.cwd() .. vim.api.nvim_buf_get_name(0)
        end,
      },
    })

    local list = harpoon:list()

    -- ── Your preferred shortcuts ────────────────────────────────────────────
    map("n", "<F2>", function() list:add() end, vim.tbl_extend("force", opts, { desc = "Harpoon: Add file" }))
    map("n", "<F3>", function()
      require("telescope").extensions.harpoon.marks()
    end, vim.tbl_extend("force", opts, { desc = "Harpoon: Telescope UI" }))

    -- ── Additional useful mappings (grouped under <leader>h) ────────────────
    map("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(list) end,
      vim.tbl_extend("force", opts, { desc = "Harpoon: Quick Menu" }))

    -- Quick jumps to slots 1–4
    -- map("n", "<C-h>", function() list:select(1) end, vim.tbl_extend("force", opts, { desc = "Harpoon → 1" }))
    -- map("n", "<C-j>", function() list:select(2) end, vim.tbl_extend("force", opts, { desc = "Harpoon → 2" }))
    -- map("n", "<C-k>", function() list:select(3) end, vim.tbl_extend("force", opts, { desc = "Harpoon → 3" }))
    -- map("n", "<C-l>", function() list:select(4) end, vim.tbl_extend("force", opts, { desc = "Harpoon → 4" }))

    -- Cycle through marks
    map("n", "<C-S-P>", function() list:prev({ ui_nav_wrap = true }) end,
      vim.tbl_extend("force", opts, { desc = "Harpoon: Previous" }))
    map("n", "<C-S-N>", function() list:next({ ui_nav_wrap = true }) end,
      vim.tbl_extend("force", opts, { desc = "Harpoon: Next" }))

    -- Remove / Clear
    map("n", "<leader>hd", function()
      list:remove()
      vim.notify("Removed current file from Harpoon", vim.log.levels.INFO)
    end, vim.tbl_extend("force", opts, { desc = "Harpoon: Remove current" }))

    map("n", "<leader>hc", function()
      list:clear()
      vim.notify("Harpoon list cleared", vim.log.levels.WARN)
    end, vim.tbl_extend("force", opts, { desc = "Harpoon: Clear all" }))

    -- Load telescope extension (safe)
    pcall(require("telescope").load_extension, "harpoon")
  end,
}