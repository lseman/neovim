return {
    "stevearc/conform.nvim",
    event = {"BufWritePre"},
    cmd = {"ConformInfo"},

    keys = {{
        "<leader>fm",
        function()
            require("conform").format({
                async = true,
                lsp_fallback = true,
                timeout_ms = 2500
            })
        end,
        desc = "Format buffer (Conform)"
    }},

    init = function()
        -- Global toggle for format-on-save
        vim.g.disable_autoformat = false

        vim.api.nvim_create_user_command("FormatDisable", function(args)
            if args.bang then
                vim.b.disable_autoformat = true
                vim.notify("Format-on-save disabled (buffer-local)", vim.log.levels.INFO)
            else
                vim.g.disable_autoformat = true
                vim.notify("Format-on-save disabled (global)", vim.log.levels.INFO)
            end
        end, {
            desc = "Disable autoformat-on-save",
            bang = true
        })

        vim.api.nvim_create_user_command("FormatEnable", function(args)
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
            vim.notify("Format-on-save enabled", vim.log.levels.INFO)
        end, {
            desc = "Enable autoformat-on-save"
        })
    end,

    opts = {
        -- Format on save (main logic here)
        format_on_save = function(bufnr)
            -- Respect global/buffer toggle
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
            end

            local ft = vim.bo[bufnr].filetype

            -- Skip very large files, vendor dirs, etc.
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname:match("/node_modules/") or fname:match("/%.git/") or fname:match("/%.venv/") or
                fname:match("/site%-packages/") or vim.api.nvim_buf_line_count(bufnr) > 20000 then
                return
            end

            -- Filetypes to never autoformat
            local no_auto = {
                sql = true,
                terraform = true
            }
            if no_auto[ft] then
                return
            end

            -- Python: synchronous + no LSP fallback (ruff handles everything)
            if ft == "python" then
                return {
                    timeout_ms = 1500,
                    lsp_fallback = false,
                    async = false
                }
            end

            -- Most other filetypes: fast + LSP fallback ok
            return {
                timeout_ms = 800,
                lsp_fallback = true,
                async = false
            }
        end,

        -- Default fallback behavior
        default_format_opts = {
            lsp_format = "fallback"
        },

        format_after_save = {
            lsp_fallback = true,
            timeout_ms = 1200
        },

        -- Which formatters per filetype (order = execution order)
        formatters_by_ft = {
            lua = {"stylua"},

            -- Python: fix imports first → then format
            python = {"ruff_fix", "ruff_format"},

            -- Web stack: prefer biome when config exists, then prettier*
            javascript = {"biome", "prettierd", "prettier"},
            typescript = {"biome", "prettierd", "prettier"},
            javascriptreact = {"biome", "prettierd", "prettier"},
            typescriptreact = {"biome", "prettierd", "prettier"},
            json = {"biome", "prettierd", "prettier"},
            jsonc = {"biome", "prettierd", "prettier"},

            yaml = {"prettierd", "prettier"},
            html = {"prettierd", "prettier"},
            css = {"prettierd", "prettier"},
            scss = {"prettierd", "prettier"},
            markdown = {"prettierd", "prettier"},

            cpp = {"clang-format"},
            c = {"clang-format"},
            java = {"google-java-format"},

            go = {"goimports", "gofmt"}
            -- go = { "gofumpt", "goimports", "gofmt" }, -- if you prefer gofumpt
        },

        -- Formatter customizations
        formatters = {
            stylua = {
                prepend_args = {"--indent-type", "Spaces", "--indent-width", "2"}
            },
            ruff_fix = {
                prepend_args = {"--select", "I", "--fix"} -- only organize imports
            },

            ruff_format = {
                -- inherits Black defaults; respects pyproject.toml
            },

            biome = {
                condition = function(ctx)
                    return vim.fn.executable("biome") == 1 and (vim.fs.find({"biome.json", "biome.jsonc"}, {
                        upward = true,
                        path = ctx.filename
                    })[1] ~= nil)
                end
            },

            prettierd = {
                condition = function(ctx)
                    return vim.fn.executable("prettierd") == 1
                end
            },

            prettier = {
                condition = function(ctx)
                    return vim.fn.executable("prettier") == 1 and vim.fn.executable("prettierd") ~= 1 and
                               not vim.fs.find({"biome.json"}, {
                            upward = true,
                            path = ctx.filename
                        })[1]
                end
            },

            clang_format = {
                prepend_args = {"--style", "{BasedOnStyle: Google, IndentWidth: 4}"}
            },

            ["google-java-format"] = {
                -- no special args needed
            },

            goimports = {},
            gofmt = {}
        },

        -- Logging & error feedback
        notify_on_error = true,
        log_level = vim.log.levels.WARN
    },

    config = function(_, opts)
        require("conform").setup(opts)

        -- Optional: visual mode range formatting
        vim.api.nvim_create_user_command("FormatRange", function()
            local start = vim.fn.getpos("'<")[2]
            local end_ = vim.fn.getpos("'>")[2]
            require("conform").format({
                async = true,
                lsp_fallback = true,
                range = {
                    start = {start, 0},
                    ["end"] = {end_, 0}
                }
            })
        end, {
            range = true,
            desc = "Format selected range"
        })
    end
}
