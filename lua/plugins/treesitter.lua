return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      opts = {
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
      },
    },
    -- Recommended replacement for built-in autotag
    { "windwp/nvim-ts-autotag", opts = {} },
  },

  opts = {
    ensure_installed = {
      -- Core / always needed
      "c", "cpp", "lua", "vim", "vimdoc", "query",
      -- Docs & markup
      "markdown", "markdown_inline",
      -- Web / frontend
      "javascript", "typescript", "tsx", "html", "css",
      -- Scripting & data
      "bash", "regex", "json", "yaml", "toml",
      -- Build / config
      "cmake", "make", "dockerfile",
      "git_config", "git_rebase", "gitcommit", "gitignore",
      -- Optional popular additions (uncomment as needed)
      -- "rust", "go", "python", "java", "php", "ruby", "sql",
    },

    sync_install = false,
    auto_install = true,
    ignore_install = {},

    highlight = {
      enable = true,
      disable = function(lang, buf)
        -- Large file protection (good!)
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > 200 * 1024 then  -- raised a bit
          return true
        end

        -- UI / special buffers
        local ft = vim.bo[buf].filetype
        local excluded = { "TelescopePrompt", "neo-tree", "lazy", "mason", "alpha", "dashboard" }
        if vim.tbl_contains(excluded, ft) then
          return true
        end

        return false
      end,
      additional_vim_regex_highlighting = false,
    },

    indent = { enable = true },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = "<C-s>",
        node_decremental = "<BS>",
      },
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
          ["]o"] = "@conditional.outer",  -- added
        },
        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
      },

      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["as"] = { query = "@scope", query_group = "locals", desc = "Select scope" },
          ["am"] = "@comment.outer",
          ["aC"] = "@call.outer",
          ["iC"] = "@call.inner",
          ["ao"] = "@conditional.outer",  -- added
          ["io"] = "@conditional.inner",
        },
        selection_modes = {
          ["@parameter.outer"] = "v",
          ["@function.outer"] = "V",
          ["@class.outer"] = "<C-v>",
        },
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
        floating_preview_opts = {},
        peek_definition_code = {
          ["<leader>df"] = "@function.outer",
          ["<leader>dF"] = "@class.outer",
        },
      },
    },
  },

  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)

    -- Custom highlight links (if still needed; upstream improved a lot)
    vim.api.nvim_set_hl(0, "TSFunctionCall", { link = "Function" })
    vim.api.nvim_set_hl(0, "TSConstructor", { link = "Constructor" })  -- or link to Type/Structure

    -- Folding (opt-in per buffer or keep global)
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldenable = false   -- unfold by default

    -- Optional: register extra filetypes if needed
    -- vim.treesitter.language.register("typescript", "typescript.tsx")
  end,
}