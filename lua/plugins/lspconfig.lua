return {
  -- Core LSP + bridge to native config
  { "neovim/nvim-lspconfig", version = "*" }, -- still recommended in 0.11+

  -- Optional but strongly recommended: auto-install servers
  {
    "williamboman/mason.nvim",
    lazy = true,
    opts = { ui = { border = "rounded" } },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "basedpyright",
        "ruff",
        "clangd",
        "vhdl_ls",
        -- "cmake",          -- uncomment if you want cmake-language-server
      },
      automatic_installation = true,
    },
  },

  -- Your other dependencies
  "hrsh7th/cmp-nvim-lsp",
  "nvim-telescope/telescope.nvim",
  "nvim-telescope/telescope-fzf-native.nvim",
  "p00f/clangd_extensions.nvim",
  "Civitasv/cmake-tools.nvim",

  -- Navbuddy stack
  {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
      "numToStr/Comment.nvim", -- optional
    },
    opts = {
      lsp = { auto_attach = true },
    },
  },

  config = function()
    local lspconfig = require("lspconfig")

    -- Global capabilities (do once)
    local capabilities = vim.tbl_deep_extend(
      "force",
      vim.lsp.protocol.make_client_capabilities(),
      require("cmp_nvim_lsp").default_capabilities()
    )
    capabilities.offsetEncoding = { "utf-16" } -- most common safe choice

    -- ── Centralized on_attach ───────────────────────────────────────
    local on_attach = function(client, bufnr)
      -- You can add client-specific logic here if needed
      -- e.g. if client.name == "basedpyright" then ... end

      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
      end

      -- Clear any conflicting <F2> (optional safety)
      pcall(vim.keymap.del, "n", "<F2>", { buffer = bufnr })

      map("n", "gd", "<cmd>Telescope lsp_definitions<CR>",  "Definition")
      map("n", "gr", "<cmd>Telescope lsp_references<CR>",   "References")
      map("n", "gI", "<cmd>Telescope lsp_implementations<CR>", "Implementation")
      map("n", "K",  vim.lsp.buf.hover,                     "Hover")
      map("n", "<leader>rn", vim.lsp.buf.rename,            "Rename")
      map("n", "<F2>", vim.lsp.buf.code_action,             "Code Action")
      map("n", "<leader>sh", vim.lsp.buf.signature_help,    "Signature Help")
      map("n", "<leader>fm", vim.lsp.buf.format,            "Format (LSP)")
      map("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>",  "Doc Symbols")
      map("n", "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<CR>", "WS Symbols")
      map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", "Diagnostics")

      -- Diagnostic navigation
      map("n", "<leader>dl", vim.diagnostic.open_float, "Line diag")
      map("n", "[d",         vim.diagnostic.goto_prev,  "Prev diag")
      map("n", "]d",         vim.diagnostic.goto_next,  "Next diag")

      -- NavBuddy
      map("n", "<leader>nb", require("nvim-navbuddy").open, "NavBuddy")

      -- Optional: only enable inlay hints for clients that support them well
      if client.supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end

    -- ── Telescope setup ─────────────────────────────────────────────
    require("telescope").setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
      pickers = {
        lsp_definitions     = { theme = "dropdown" },
        lsp_references      = { theme = "dropdown" },
        lsp_implementations = { theme = "dropdown" },
        lsp_type_definitions= { theme = "dropdown" },
      },
    })
    pcall(require("telescope").load_extension, "fzf")

    -- ── Servers ─────────────────────────────────────────────────────
    -- Let mason-lspconfig handle most of them automatically
    require("mason-lspconfig").setup_handlers({
      -- default handler
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })
      end,

      -- basedpyright (custom settings)
      ["basedpyright"] = function()
        lspconfig.basedpyright.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard",          -- or "strict"
                diagnosticSeverityOverrides = {
                  reportUnusedImport     = "none",
                  reportUnusedVariable   = "none",
                  reportUnusedExpression = "none",
                  reportDuplicateImport  = "none",
                  reportMissingImports   = "warning",
                },
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        })
      end,

      -- clangd (with extensions)
      ["clangd"] = function()
        lspconfig.clangd.setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)                   -- your common keymaps
            require("clangd_extensions").setup({})     -- inlay hints, etc
          end,
          cmd = {
            "clangd",
            "--background-index",
            "--header-insertion=iwyu",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--all-scopes-completion",
            "--completion-style=detailed",
          },
        })
      end,
    })

    -- If you really don't want mason for vhdl_ls, you can still do:
    -- lspconfig.vhdl_ls.setup({ capabilities = capabilities, on_attach = on_attach })

    -- ── Extra tools ─────────────────────────────────────────────────
    require("cmake-tools").setup({
      cmake_build_directory = "build",
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      -- …
    })

    -- Conform (formatting fallback / ruff)
    require("conform").setup({
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format" },
      },
      notify_on_error = false,
    })

    -- Optional extra Conform keymap
    vim.keymap.set("n", "<leader>cf", function()
      require("conform").format({ async = false, lsp_fallback = true })
    end, { desc = "Format (Conform)" })
  end,
}