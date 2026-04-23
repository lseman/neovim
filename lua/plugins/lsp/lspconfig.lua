return {
    {
        "neovim/nvim-lspconfig",
        version = "*",
        dependencies = {
            { "williamboman/mason.nvim", lazy = true, opts = { ui = { border = "rounded" } } },
            {
                "williamboman/mason-lspconfig.nvim",
                opts = {
                    ensure_installed = { "basedpyright", "ruff", "clangd", "vhdl_ls" },
                    automatic_enable = true,
                },
            },
            "nvim-telescope/telescope.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
            "p00f/clangd_extensions.nvim",
            "Civitasv/cmake-tools.nvim",
            {
                "SmiteshP/nvim-navbuddy",
                dependencies = { "SmiteshP/nvim-navic", "MunifTanjim/nui.nvim" },
                opts = { lsp = { auto_attach = true } },
            },
        },

        config = function()
            local integrations = require("config.integrations")
            local ok, blink = pcall(require, "blink.cmp")
            local capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

            local function diagnostic_jump(count)
                return function()
                    vim.diagnostic.jump({ count = count, float = false })
                end
            end

            local function lsp_picker(snacks_name, telescope_name, fallback, opts)
                return function()
                    if not integrations.open_picker(snacks_name, telescope_name, opts, fallback) then
                        vim.notify("No LSP picker backend available", vim.log.levels.WARN)
                    end
                end
            end

            local on_attach = function(client, bufnr)
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
                end

                map("n", "gd", lsp_picker("lsp_definitions", "lsp_definitions", vim.lsp.buf.definition), "Definition")
                map("n", "gr", lsp_picker("lsp_references", "lsp_references", vim.lsp.buf.references), "References")
                map("n", "gI", lsp_picker("lsp_implementations", "lsp_implementations", vim.lsp.buf.implementation), "Implementation")
                map("n", "K", vim.lsp.buf.hover, "Hover")
                map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                map("n", "<leader>sh", vim.lsp.buf.signature_help, "Signature Help")
                map("n", "<leader>ds", lsp_picker("lsp_symbols", "lsp_document_symbols", vim.lsp.buf.document_symbol), "Doc Symbols")
                map("n", "<leader>ws", lsp_picker("lsp_workspace_symbols", "lsp_workspace_symbols", function()
                    vim.lsp.buf.workspace_symbol(vim.fn.input("Workspace Symbols: "))
                end), "WS Symbols")
                map("n", "<leader>fd", lsp_picker("diagnostics", "diagnostics", vim.diagnostic.setloclist), "Diagnostics")
                map("n", "<leader>dl", vim.diagnostic.open_float, "Line diag")
                map("n", "[d", diagnostic_jump(-1), "Prev diag")
                map("n", "]d", diagnostic_jump(1), "Next diag")
                map("n", "<leader>nb", require("nvim-navbuddy").open, "NavBuddy")

                if client.supports_method("textDocument/inlayHint") then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end

            vim.keymap.set("n", "<leader>uh", function()
                local enabled = vim.lsp.inlay_hint.is_enabled({
                    bufnr = 0
                })
                vim.lsp.inlay_hint.enable(not enabled, {
                    bufnr = 0
                })
            end, { desc = "Toggle Inlay Hints" })

            local ok_clangd, clangd_extensions = pcall(require, "clangd_extensions")
            if ok_clangd then clangd_extensions.setup({}) end

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
                    offsetEncoding = { "utf-16" }
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

            vim.lsp.enable({ "vhdl_ls" })

            require("cmake-tools").setup({
                cmake_build_directory = "build",
                cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
            })
        end,
    },
}
