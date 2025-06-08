return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      config = function()
        xpcall(function()
          require("ts_context_commentstring").setup({
            enable_autocmd = false,
            languages = {
              javascript = {
                __default = "// %s",
                jsx_element = "{/* %s */}",
                jsx_fragment = "{/* %s */}",
                jsx_attribute = "// %s",
                comment = "// %s",
              },
              typescript = { __default = "// %s" },
              tsx = {
                __default = "// %s",
                jsx_element = "{/* %s */}",
                jsx_fragment = "{/* %s */}",
                jsx_attribute = "// %s",
              },
            },
          })
        end, function(err)
          vim.notify("Failed to load ts-context-commentstring: " .. tostring(err), vim.log.levels.WARN)
        end)
      end,
    },
  },
  opts = {
    ensure_installed = {
      "c", "cpp", "lua", "vim", "vimdoc", "query",
      "markdown", "markdown_inline", "latex",
      "python", "javascript", "typescript", "html", "css", "bash", "regex", "json", "yaml", "toml",
      "cmake", "make", "dockerfile",
      "git_config", "git_rebase", "gitcommit", "gitignore",
    },
    sync_install = false,
    auto_install = true,
    ignore_install = {},

    highlight = {
      enable = true,
      disable = function(lang, buf)
        local ok, stats = pcall(function()
          return vim.loop.fs_stat(vim.api.nvim_buf_get_name(buf))
        end)
        if ok and stats and stats.size > 100 * 1024 then
          return true
        end

        local ok2, ft = pcall(function()
          return vim.bo[buf].filetype
        end)
        if ok2 then
          local disabled = { "TelescopePrompt", "NvimTree" }
          if vim.tbl_contains(disabled, ft) then return true end
        end
        return false
      end,
      additional_vim_regex_highlighting = false,
      custom_captures = {
        ["function.call"] = "TSFunctionCall",
        ["constructor"] = "TSConstructor",
      },
    },

    -- incremental_selection = {
    --   enable = true,
    --   keymaps = {
    --     init_selection = "gnn",
    --     node_incremental = "grn",
    --     node_decremental = "grm",
    --     scope_incremental = "grc",
    --   },
    -- },

    indent = {
      enable = true,
      -- disable = { "yaml", "python" },
    },

    autotag = {
      enable = true,
      filetypes = { "html", "xml", "javascript", "typescript", "jsx", "tsx", "markdown" },
    },

    textobjects = {
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.inner",
          ["]l"] = "@loop.outer",
          ["]s"] = "@statement.outer",
          ["]z"] = "@fold",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]A"] = "@parameter.inner",
          ["]L"] = "@loop.outer",
          ["]S"] = "@statement.outer",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.inner",
          ["[l"] = "@loop.outer",
          ["[s"] = "@statement.outer",
          ["[z"] = "@fold",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[A"] = "@parameter.inner",
          ["[L"] = "@loop.outer",
          ["[S"] = "@statement.outer",
        },
      },

      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["as"] = { query = "@scope", query_group = "locals", desc = "Select scope" },
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["am"] = "@comment.outer",
          ["aC"] = "@call.outer",
          ["iC"] = "@call.inner",
        },
        selection_modes = {
          ["@parameter.outer"] = "v",
          ["@function.outer"] = "V",
          ["@class.outer"] = "<c-v>",
          ["@scope.outer"] = "V",
        },
        include_surrounding_whitespace = false,
      },

      swap = {
        enable = true,
        swap_next = {
          ["<leader>a]"] = "@parameter.inner",
          ["<leader>f]"] = "@function.outer",
        },
        swap_previous = {
          ["<leader>a["] = "@parameter.inner",
          ["<leader>f["] = "@function.outer",
        },
      },

      lsp_interop = {
        enable = true,
        border = "rounded",
        peek_definition_code = {
          ["<leader>df"] = "@function.outer",
          ["<leader>dF"] = "@class.outer",
        },
      },
    },

    playground = {
      enable = true,
      disable = {},
      updatetime = 25,
      persist_queries = true,
      keybindings = {
        toggle_query_editor = "o",
        toggle_hl_groups = "i",
        toggle_injected_languages = "t",
        toggle_anonymous_nodes = "a",
        toggle_language_display = "I",
        focus_language = "f",
        unfocus_language = "F",
        update = "R",
        goto_node = "<cr>",
        show_help = "?",
      },
    },
  },
  config = function(_, opts)
    local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
    if not ok then
      vim.notify("nvim-treesitter.configs failed to load", vim.log.levels.ERROR)
      return
    end

    local ok2, parser_config = pcall(require, "nvim-treesitter.parsers")
    if ok2 and parser_config.get_parser_configs then
      local cfg = parser_config.get_parser_configs()
      if cfg.tsx then
        cfg.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
      end
    end

    ts_configs.setup(opts)

    vim.cmd([[
      highlight default link TSFunctionCall Function
      highlight default link TSConstructor Constructor
    ]])

    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldenable = false
  end,
}
