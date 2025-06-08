return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "nvim-telescope/telescope.nvim",
    "nvim-telescope/telescope-fzf-native.nvim",
    "p00f/clangd_extensions.nvim",
    "Civitasv/cmake-tools.nvim",
    "barreiroleo/ltex_extra.nvim", -- Optional: grammar/language tool
  },

  config = function()
    local lspconfig = require("lspconfig")
    local telescope = require("telescope")

    -- ========================
    -- Capabilities
    -- ========================
    local capabilities = require("cmp_nvim_lsp").default_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    )
    capabilities.offsetEncoding = { "utf-16", "utf-8" }

    -- ========================
    -- Telescope Setup
    -- ========================
    telescope.setup({
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
        lsp_definitions       = { theme = "dropdown" },
        lsp_references        = { theme = "dropdown" },
        lsp_implementations   = { theme = "dropdown" },
        lsp_type_definitions  = { theme = "dropdown" },
      },
    })
    pcall(telescope.load_extension, "fzf")

    -- ========================
    -- LSP Keymaps
    -- ========================
    local function setup_lsp_keymaps(_, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
          buffer = bufnr,
          noremap = true,
          silent = true,
          desc = desc,
        })
      end

      map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Goto Definition")
      map("n", "gr", "<cmd>Telescope lsp_references<CR>", "Find References")
      map("n", "gI", "<cmd>Telescope lsp_implementations<CR>", "Goto Implementation")
      map("n", "K", vim.lsp.buf.hover, "Hover Info")
      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
      map("n", "<F1>", vim.lsp.buf.code_action, "Code Action")
      map("n", "<leader>sh", vim.lsp.buf.signature_help, "Signature Help")
      map("n", "<leader>fm", vim.lsp.buf.format, "Format Code")
      map("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>", "Document Symbols")
      map("n", "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<CR>", "Workspace Symbols")
      map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", "Show Diagnostics")
    end

    -- ========================
    -- LSP Servers
    -- ========================

    -- Pyright
    lspconfig.pyright.setup({
      on_attach = setup_lsp_keymaps,
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic", -- "strict" is also available
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
    })

    -- Optional: Ruff LSP (commented)
    -- lspconfig.ruff_lsp.setup({
    --   on_attach = setup_lsp_keymaps,
    --   capabilities = capabilities,
    --   init_options = {
    --     settings = { args = {} },
    --   },
    -- })

    -- Clangd (via clangd_extensions)
    local clangd_cmd = {
      "clangd",
      "--background-index=false",
      "--header-insertion=iwyu",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
      "--all-scopes-completion",
      "--completion-style=detailed",
    }

    require("clangd_extensions").setup({
      server = {
        cmd = clangd_cmd,
        capabilities = capabilities,
        on_attach = setup_lsp_keymaps,
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      },
    })

    -- ========================
    -- CMake Tools Setup
    -- ========================
    require("cmake-tools").setup({
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_build_options = {},
      cmake_console_size = 10,
      cmake_show_console = "always",
      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
      },
    })

    -- ========================
    -- Global Inlay Hints
    -- ========================
    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true)
    end
  end,
}
