return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },

  opts = {
    indent = {
      char = "▏",                          -- thin vertical line
      tab_char = "▏",
      -- Rainbow indent lines
      highlight = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
        "IndentBlanklineIndent3",
        "IndentBlanklineIndent4",
        "IndentBlanklineIndent5",
        "IndentBlanklineIndent6",
        "IndentBlanklineIndent7",
      },
    },

    scope = {
      enabled = true,
      show_start = true,
      show_end = true,
      show_exact_scope = true,            -- cleaner: only exact scope
      -- Rainbow scope indicators
      highlight = {
        "IndentBlanklineScope1",
        "IndentBlanklineScope2",
        "IndentBlanklineScope3",
        "IndentBlanklineScope4",
        "IndentBlanklineScope5",
        "IndentBlanklineScope6",
        "IndentBlanklineScope7",
      },
    },

    exclude = {
      filetypes = {
        "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason",
        "notify", "toggleterm", "lazyterm", "TelescopePrompt", "TelescopeResults",
        "WhichKey", "noice", "oil", "qf", "terminal",
      },
      buftypes = { "terminal", "nofile", "quickfix", "prompt" },
    },
  },

  config = function(_, opts)
    local ibl = require("ibl")
    local hooks = require("ibl.hooks")

    -- Define soft rainbow colors (adjust to your theme if needed)
    local indent_colors = {
      "#E06C75", -- red
      "#E5C07B", -- yellow
      "#61AFEF", -- blue
      "#D19A66", -- orange
      "#98C379", -- green
      "#C678DD", -- purple
      "#56B6C2", -- cyan
    }

    -- Slightly brighter for scope (current context stands out)
    local scope_colors = {
      "#f38ba8",
      "#fab387",
      "#f9e2af",
      "#a6e3a1",
      "#89b4fa",
      "#cba6f7",
      "#94e2d5",
    }

    -- Register the highlight groups once on colorscheme change or startup
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      for i, color in ipairs(indent_colors) do
        vim.api.nvim_set_hl(0, "IndentBlanklineIndent" .. i, { fg = color })
      end

      for i, color in ipairs(scope_colors) do
        vim.api.nvim_set_hl(0, "IndentBlanklineScope" .. i, {
          fg = color,
          nocombine = true,  -- prevent blending issues
        })
      end
    end)

    -- Optional: use scope highlight also in the gutter (cleaner in some themes)
    -- hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_gutter)

    ibl.setup(opts)
  end,
}