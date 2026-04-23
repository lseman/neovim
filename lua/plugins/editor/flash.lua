return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {                       -- ← prefer `opts =` over `config = function() require("flash").setup()`
    labels = "asdfghjklqwertyuiopzxcvbnm",   -- home-row biased (very popular choice)
    search = {
      multi_window = true,       -- ← very useful in practice (default anyway)
      forward = true,
      wrap = true,
      mode = "fuzzy",            -- ← "exact", "fuzzy", "search" — fuzzy feels more forgiving
    },
    jump = {
      history = true,
      register = true,           -- ← yank/put integration — very powerful
      nohlsearch = true,         -- ← clean up search highlight (most users want this)
    },
    highlight = {
      backdrop = true,           -- nice visual feedback
      matches = { search = { hl = { backdrop = true } } },
    },
    modes = {
      char = {
        enabled = true,
        keys = { "f", "F", "t", "T" },
        -- You can also do: multi_line = false  if you hate multi-line fFtT
        jump_labels = true,      -- ← shows labels even for fFtT (very nice upgrade)
      },
      search = {
        enabled = true,
      },
      treesitter = {
        enabled = true,
      },
    },
  },
  keys = {
    -- Core jump (most used)
    {
      "s",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
      desc = "Flash Jump",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function() require("flash").treesitter() end,
      desc = "Flash Treesitter",
    },

    -- Remote / textobject enhancements
    {
      "r",
      mode = "o",
      function() require("flash").remote() end,
      desc = "Remote Flash",
    },
    {
      "R",
      mode = { "o", "x" },
      function() require("flash").treesitter_search() end,
      desc = "Treesitter Search",
    },

    -- Very useful when you want to toggle flash mid-search
    {
      "<c-s>",
      mode = "c",
      function() require("flash").toggle() end,
      desc = "Toggle Flash (cmdline)",
    },

    -- Bonus mappings many people add (pick what you like)
    -- { "gl", mode = { "n", "x", "o" }, function() require("flash").jump({
    --     search = { forward = false, wrap = false, multi_window = false },
    --   }) end, desc = "Flash backward" },
  },
}