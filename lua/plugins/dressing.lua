return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  config = function()
    local telescope_themes = require("telescope.themes")

    require("dressing").setup({
      input = {
        enabled = true,
        default_prompt = "❯ ",
        prompt_align = "left",
        insert_only = true,
        border = "rounded",
        relative = "cursor",
        prefer_width = 40,
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },
        win_options = {
          winblend = 0,
          wrap = false,
          list = true,
          listchars = "precedes:…,extends:…",
          sidescrolloff = 3,
          cursorline = true,
          cursorlineopt = "both",
        },
        mappings = {
          n = {
            ["<Esc>"] = "Close",
            ["<CR>"]  = "Confirm",
            ["<C-p>"] = "HistoryPrev",
            ["<C-n>"] = "HistoryNext",
          },
          i = {
            ["<C-c>"] = "Close",
            ["<CR>"]  = "Confirm",
            ["<Up>"]  = "HistoryPrev",
            ["<Down>"] = "HistoryNext",
            ["<C-p>"] = "HistoryPrev",
            ["<C-n>"] = "HistoryNext",
            ["<C-u>"] = "DeleteLine",
            ["<C-w>"] = "DeleteWord",
            ["<C-h>"] = "DeleteCharacter",
          },
        },
        override = function(conf)
          conf.win_options = conf.win_options or {}
          conf.win_options.winhighlight =
            "NormalFloat:Normal,FloatBorder:FloatBorder,FloatTitle:Title"
          return conf
        end,
      },

      select = {
        enabled = true,
        backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
        trim_prompt = true,

        telescope = telescope_themes.get_dropdown({
          layout_config = { anchor = "N", width = 0.8, height = 0.8 },
        }),

        fzf = {
          window = {
            width = 0.5,
            height = 0.4,
            border = "rounded",
          },
        },

        nui = {
          position = "50%",
          relative = "editor",
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winblend = 0,
            winhighlight = "NormalFloat:Normal,FloatBorder:FloatBorder",
          },
          max_width = 80,
          max_height = 40,
          min_width = 40,
          min_height = 10,
        },

        builtin = {
          show_numbers = true,
          border = "rounded",
          relative = "editor",
          max_width = { 140, 0.8 },
          min_width = { 40, 0.2 },
          max_height = 0.9,
          min_height = { 10, 0.2 },
          win_options = {
            cursorline = true,
            cursorlineopt = "both",
            signcolumn = "no",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          },
          mappings = {
            ["<Esc>"]  = "Close",
            ["<C-c>"]  = "Close",
            ["<CR>"]   = "Confirm",
            ["<C-p>"]  = "SelectPrev",
            ["<C-n>"]  = "SelectNext",
            ["<C-u>"]  = "ScrollUp",
            ["<C-d>"]  = "ScrollDown",
          },
        },
      },
    })
  end,
}
