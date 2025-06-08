return {
  "SmiteshP/nvim-navbuddy",
  event = "LspAttach",
  dependencies = {
    "SmiteshP/nvim-navic",
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    local navbuddy = require("nvim-navbuddy")
    local actions = require("nvim-navbuddy.actions")

    -- ── Setup Navbuddy ─────────────────────────────────────
    navbuddy.setup({
      window = {
        border = "rounded",
        size = "75%",
        position = "50%",
        sections = {
          left = { size = "25%" },
          mid  = { size = "35%" },
          right = { size = "40%" },
        },
      },

      node_markers = {
        enabled = true,
        icons = {
          leaf = "  ",
          leaf_selected = " ",
          branch = " ",
        },
      },

      lsp = {
        auto_attach = true,
        preference = nil,
      },

      icons = {
        File = "󰈔 ", Module = "󰆧 ", Namespace = "󰌗 ", Package = "󰏗 ",
        Class = "󰠱 ", Method = "󰊕 ", Property = "󰜢 ", Field = "󰇽 ",
        Constructor = " ", Enum = "󰕘 ", Interface = "󰕘 ", Function = "󰊕 ",
        Variable = "󰀫 ", Constant = "󰏿 ", String = "󰀬 ", Number = "󰎠 ",
        Boolean = "󰨙 ", Array = "󰅪 ", Object = "󰅩 ", Key = "󰌋 ",
        Null = "󰟢 ", EnumMember = " ", Struct = "󰙅 ", Event = "󰉁 ",
        Operator = "󰆕 ", TypeParameter = "󰊄 ", Component = "󰡀 ",
        Fragment = "󰅴 ",
      },

      mappings = {
        -- Close
        ["<esc>"] = actions.close(), ["q"] = actions.close(), ["<C-c>"] = actions.close(),

        -- Movement
        ["h"] = actions.parent(), ["<Left>"] = actions.parent(),
        ["l"] = actions.children(), ["<Right>"] = actions.children(),
        ["k"] = actions.previous_sibling(), ["<Up>"] = actions.previous_sibling(),
        ["j"] = actions.next_sibling(), ["<Down>"] = actions.next_sibling(),

        -- Select
        ["<CR>"] = actions.select(), ["o"] = actions.select(), ["<2-LeftMouse>"] = actions.select(),
        ["<S-CR>"] = actions.select(),

        -- Visual
        ["v"] = actions.visual_name(), ["V"] = actions.visual_scope(), ["<C-v>"] = actions.visual_name(),

        -- Navigation
        ["0"] = actions.root(), ["s"] = actions.toggle_preview(),

        -- Help
        ["?"] = actions.help(),
      },
    })

    -- ── Keybindings ────────────────────────────────────────
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    local function open_navbuddy()
      require("nvim-navbuddy").open()
    end

    map("n", "<leader>nb", open_navbuddy, vim.tbl_extend("force", opts, { desc = "Open Navbuddy" }))
    map("n", "<C-b>",     open_navbuddy, vim.tbl_extend("force", opts, { desc = "Open Navbuddy (Ctrl-B)" }))
    map("n", "<leader>ns", open_navbuddy, vim.tbl_extend("force", opts, { desc = "Navigate Symbols" }))

  end,
}
