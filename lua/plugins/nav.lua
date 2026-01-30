return {
  "SmiteshP/nvim-navbuddy",
  event = "LspAttach",
  dependencies = {
    "SmiteshP/nvim-navic",
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
  },

  opts = {
    window = {
      border = "rounded",
      size = { height = "60%", width = "80%" },  -- slightly smaller & responsive
      position = "50%",
      sections = {
        left = { size = "25%" },
        mid = { size = "35%" },
        right = { size = "40%" },
      },
      preview = {
        enabled = true,
        border = "rounded",
        size = { height = "60%", width = "50%" },
      },
    },

    node_markers = {
      enabled = true,
      icons = {
        leaf = "  ",
        leaf_selected = "➜ ",
        branch = "▸ ",
      },
    },

    icons = {
      File          = "󰈙 ",
      Module        = " ",
      Namespace     = "󰌗 ",
      Package       = " ",
      Class         = "󰠱 ",
      Method        = "󰊕 ",
      Property      = " ",
      Field         = " ",
      Constructor   = " ",
      Enum          = "󰖽 ",
      Interface     = " ",
      Function      = "󰊕 ",
      Variable      = "󰀫 ",
      Constant      = "󰏿 ",
      String        = "󰉿 ",
      Number        = "󰎠 ",
      Boolean       = "󰨙 ",
      Array         = "󰅪 ",
      Object        = "󰅩 ",
      Key           = "󰌋 ",
      Null          = "󰟢 ",
      EnumMember    = " ",
      Struct        = "󰙅 ",
      Event         = " ",
      Operator      = "󰆕 ",
      TypeParameter = "󰊄 ",
      Component     = "󰡀 ",
      Fragment      = "󰅴 ",
      FolderClosed  = " ",
      FolderOpen    = " ",
    },

    use_default_mappings = false,  -- important: avoid conflicts

    mappings = {
      ["<esc>"] = require("nvim-navbuddy.actions").close(),
      ["q"]     = require("nvim-navbuddy.actions").close(),
      ["<C-c>"] = require("nvim-navbuddy.actions").close(),

      ["h"]     = require("nvim-navbuddy.actions").parent(),
      ["<Left>"] = require("nvim-navbuddy.actions").parent(),
      ["l"]     = require("nvim-navbuddy.actions").children(),
      ["<Right>"] = require("nvim-navbuddy.actions").children(),

      ["k"]     = require("nvim-navbuddy.actions").previous_sibling(),
      ["<Up>"]  = require("nvim-navbuddy.actions").previous_sibling(),
      ["j"]     = require("nvim-navbuddy.actions").next_sibling(),
      ["<Down>"] = require("nvim-navbuddy.actions").next_sibling(),

      ["<CR>"]  = require("nvim-navbuddy.actions").select(),
      ["o"]     = require("nvim-navbuddy.actions").select(),
      ["<2-LeftMouse>"] = require("nvim-navbuddy.actions").select(),

      ["v"]     = require("nvim-navbuddy.actions").visual_name(),
      ["V"]     = require("nvim-navbuddy.actions").visual_scope(),
      ["<C-v>"] = require("nvim-navbuddy.actions").visual_name(),

      ["s"]     = require("nvim-navbuddy.actions").toggle_preview(),
      ["?"]     = require("nvim-navbuddy.actions").help(),
      ["0"]     = require("nvim-navbuddy.actions").root(),
    },

    lsp = {
      auto_attach = true,
      preference = nil,  -- or { "tsserver", "pyright", ... } if you want priority
    },

    reorient = true,  -- auto-scroll to current symbol
  },

  config = function(_, opts)
    require("nvim-navbuddy").setup(opts)

    -- Buffer-local keymap only when LSP is attached
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("NavbuddyKeymaps", { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.supports_method("textDocument/documentSymbol") then
          vim.keymap.set("n", "<leader>nb", function()
            require("nvim-navbuddy").open()
          end, { buffer = bufnr, desc = "Open Navbuddy" })

          vim.keymap.set("n", "<C-b>", function()
            require("nvim-navbuddy").open()
          end, { buffer = bufnr, desc = "Navbuddy (Ctrl+B)" })
        end
      end,
    })
  end,
}