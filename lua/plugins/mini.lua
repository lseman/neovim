return {
  {
    "echasnovski/mini.map",
    version = false,
    event = "VeryLazy",

    keys = {
      { "<leader>mm", function() require("mini.map").toggle() end, desc = "Toggle Mini Map" },
      { "<leader>mr", function() require("mini.map").refresh() end, desc = "Refresh Mini Map" },
    },

    opts = {
      auto_enable = false,

      -- Leave integrations and encode empty here — we'll fill them in config
      integrations = {},
      symbols = {
        scroll_line = "▶",
        scroll_view = "┃",
      },
      window = {
        side = "right",
        focusable = false,
        width = 12,
        winblend = 30,
        zindex = 10,
        show_integration_count = true,
      },
    },

    config = function(_, opts)
      local map = require("mini.map")

      -- Safe generation of integrations
      local integrations = {}
      local ok, gen = pcall(map.gen_integration)
      if ok and gen then
        table.insert(integrations, gen.builtin_search())
        table.insert(integrations, gen.gitsigns())
        table.insert(integrations, gen.diagnostic())
        -- table.insert(integrations, gen.wrap())  -- optional: shows wrapped lines
      end
      opts.integrations = integrations

      -- Generate encoding symbols **now** that we have required the module
      -- opts.symbols.encode = map.gen_encode_symbols.square("4x2")  -- or .dot("4x2")

      -- Optional: nicer symbols (popular in 2025+ configs)
      -- opts.symbols.scroll_line = "━"
      -- opts.symbols.scroll_view = "▌"

      map.setup(opts)
    end,
  },
}