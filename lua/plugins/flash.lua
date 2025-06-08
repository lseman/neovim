return {
  "folke/flash.nvim",
  event = "VeryLazy",

  config = function()
    local flash = require("flash")

    flash.setup({
      labels = "abcdefghijklmnopqrstuvwxyz",

      modes = {
        search = {
          enabled = true,
          highlight = { backdrop = true },
          jump = {
            history = true,
            register = true,
          },
        },
        char = {
          enabled = true,
          keys = { "f", "F", "t", "T" },
        },
        treesitter = {
          enabled = true,
          labels = "abcdefghijklmnopqrstuvwxyz",
        },
      },
    })
  end,

  keys = function()
    local flash = require("flash")

    return {
      -- Character and motion jumping
      {
        "s",
        mode = { "n", "x", "o" },
        function() flash.jump() end,
        desc = "Flash Jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function() flash.treesitter() end,
        desc = "Flash Treesitter Jump",
      },

      -- Text object remote motion
      {
        "r",
        mode = "o",
        function() flash.remote() end,
        desc = "Remote Flash Jump",
      },
      {
        "R",
        mode = { "o", "x" },
        function() flash.treesitter_search() end,
        desc = "Treesitter Search",
      },

      -- Toggle in command-line mode
      {
        "<C-s>",
        mode = "c",
        function() flash.toggle() end,
        desc = "Toggle Flash Search",
      },
    }
  end,
}
