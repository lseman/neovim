return {
  {
    "echasnovski/mini.map",
    version = false,
    event = "VeryLazy",

    keys = {
      {
        "<Leader>mm",
        function() require("mini.map").toggle() end,
        desc = "Toggle Mini Map",
      },
      {
        "<Leader>mr",
        function() require("mini.map").refresh() end,
        desc = "Refresh Mini Map",
      },
    },

    config = function()
      local mini_map = require("mini.map")

      -- Safely generate integrations
      local integrations = {}
      local ok, gen = pcall(mini_map.gen_integration)
      if ok and gen then
        table.insert(integrations, gen.builtin_search())
        table.insert(integrations, gen.gitsigns())
        table.insert(integrations, gen.diagnostic())
      end

      mini_map.setup({
        auto_enable = false,

        integrations = integrations,

        symbols = {
          encode = mini_map.gen_encode_symbols.dot("4x2"),
          scroll_line = "▶",    -- Indicates cursor line
          scroll_view = "┃",    -- Indicates visible viewport
        },

        window = {
          side = "right",
          focusable = false,
          width = 12,
          winblend = 30,
          zindex = 10,
          show_integration_count = true,
        },
      })
    end,
  },
}
