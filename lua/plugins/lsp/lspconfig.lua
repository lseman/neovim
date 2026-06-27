return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    version = "*",
    dependencies = {
      { "williamboman/mason.nvim", lazy = true, opts = { ui = { border = "rounded" } } },
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = { "basedpyright", "ruff", "clangd", "lua_ls", "vhdl_ls", "biome" },
          automatic_enable = true,
        },
      },
      "p00f/clangd_extensions.nvim",
      "Civitasv/cmake-tools.nvim",
    },

    config = function()
      local ok, blink = pcall(require, "blink.cmp")
      local capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

      local function diagnostic_jump(count)
        return function()
          vim.diagnostic.jump({ count = count, float = false })
        end
      end

      local function lsp_picker(snacks_name, opts)
        return function()
          Snacks.picker[snacks_name](opts or {})
        end
      end

      local on_attach = function(client, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        map("n", "gd", lsp_picker "lsp_definitions", "Definition")
        map("n", "gr", lsp_picker "lsp_references", "References")
        map("n", "gI", lsp_picker "lsp_implementations", "Implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>sh", vim.lsp.buf.signature_help, "Signature Help")
        map("n", "<leader>ds", lsp_picker "lsp_symbols", "Doc Symbols")
        map("n", "<leader>ws", lsp_picker "lsp_workspace_symbols", "WS Symbols")
        map("n", "<leader>dl", vim.diagnostic.open_float, "Line diag")
        map("n", "[d", diagnostic_jump(-1), "Prev diag")
        map("n", "]d", diagnostic_jump(1), "Next diag")

        if client:supports_method("textDocument/inlayHint", bufnr) then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end

      vim.keymap.set("n", "<leader>uh", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({
          bufnr = 0,
        })
        vim.lsp.inlay_hint.enable(not enabled, {
          bufnr = 0,
        })
      end, { desc = "Toggle Inlay Hints" })

      local ok_clangd, clangd_extensions = pcall(require, "clangd_extensions")
      if ok_clangd then
        clangd_extensions.setup({})
      end

      vim.lsp.config("*", { capabilities = capabilities, on_attach = on_attach })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              diagnosticSeverityOverrides = {
                reportUnusedImport = "none",
                reportUnusedVariable = "none",
                reportUnusedExpression = "none",
                reportDuplicateImport = "none",
                reportMissingImports = "warning",
              },
              autoImportCompletions = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      vim.lsp.config("clangd", {
        capabilities = vim.tbl_deep_extend("force", capabilities, {
          offsetEncoding = { "utf-16" },
        }),
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

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      })

      vim.lsp.enable({ "basedpyright", "ruff", "clangd", "lua_ls", "vhdl_ls", "biome" })

      require("cmake-tools").setup({
        cmake_build_directory = "build",
        cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      })
    end,
  },
}
