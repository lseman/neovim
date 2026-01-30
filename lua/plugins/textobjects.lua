return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",  -- important: master is frozen/archived
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },

  opts = {
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        include_surrounding_whitespace = false,  -- keep your preference

        keymaps = {
          -- Functions, calls, classes
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["aF"] = "@call.outer",
          ["iF"] = "@call.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",

          -- Control flow
          ["ao"] = "@conditional.outer",  -- 'o' for "one/conditional"
          ["io"] = "@conditional.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",

          -- Blocks & statements
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["as"] = "@statement.outer",  -- added: useful for lines/exprs

          -- Parameters / arguments
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",

          -- Comments
          ["a/"] = "@comment.outer",
          -- ["i/"] = "@comment.inner",  -- often not very useful; comment out if unused
        },
      },

      move = {
        enable = true,
        set_jumps = true,  -- jumplist

        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.outer",
          ["]l"] = "@loop.outer",
          ["]o"] = "@conditional.outer",  -- updated
          ["]s"] = "@statement.outer",    -- added
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]A"] = "@parameter.outer",
          ["]L"] = "@loop.outer",
          ["]O"] = "@conditional.outer",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.outer",
          ["[l"] = "@loop.outer",
          ["[o"] = "@conditional.outer",
          ["[s"] = "@statement.outer",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[A"] = "@parameter.outer",
          ["[L"] = "@loop.outer",
          ["[O"] = "@conditional.outer",
        },
      },

      swap = {
        enable = true,
        swap_next = {
          ["<leader>sp"] = "@parameter.inner",  -- better: parameter swap
          ["<leader>sf"] = "@function.outer",   -- function swap (where supported)
        },
        swap_previous = {
          ["<leader>sP"] = "@parameter.inner",
          ["<leader>sF"] = "@function.outer",
        },
      },

      lsp_interop = {
        enable = true,  -- recommended: peek LSP defs via textobject
        border = "rounded",
        floating_preview_opts = {},
        peek_definition_code = {
          ["<leader>df"] = "@function.outer",
          ["<leader>dF"] = "@class.outer",  -- capital for outer
        },
      },
    },
  },

  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}