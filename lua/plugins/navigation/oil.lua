return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  cmd = "Oil",
  keys = { {
    "-",
    "<cmd>Oil<CR>",
    desc = "Open parent directory",
  } },
  opts = {
    -- Don't rely on lazy default keymaps; define our preferred mappings
    use_default_keymaps = false,

    -- Window and view settings
    float = {
      border = "rounded",
      padding = 2,
      max_width = 120,
      max_height = 40,
    },

    view_options = {
      show_hidden = true,
    },

    win_options = {
      number = true,
      relativenumber = false,
    },

    -- Recommended keymaps (customize as desired)
    keymaps = {
      ["<CR>"] = "actions.select",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-v>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["-"] = "actions.parent",
      -- ["g?"] = "actions.toggle_help",
      ["q"] = "actions.close",
    },
  },
  -- Optional dependencies
  dependencies = { {
    "nvim-mini/mini.icons",
    opts = {},
  } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
}
