return {
    "SmiteshP/nvim-navbuddy",
    event = "LspAttach",
    dependencies = {"SmiteshP/nvim-navic", "MunifTanjim/nui.nvim", "neovim/nvim-lspconfig"},

    opts = {
        window = {
            border = "rounded", -- "single", "double", "shadow", "none" also possible
            size = {
                height = 0.60,
                width = 0.82
            }, -- relative to screen — feels more modern/responsive
            position = "50%", -- center
            sections = {
                left = {
                    size = "25%"
                },
                mid = {
                    size = "38%"
                },
                right = {
                    size = "37%"
                }
            },
            preview = {
                enabled = true,
                border = "rounded",
                size = {
                    height = 0.65,
                    width = 0.55
                }
            }
        },

        node_markers = {
            enabled = true,
            icons = {
                leaf = "  ",
                leaf_selected = "➜ ",
                branch = "▸ "
            }
        },

        icons = {
            File = "󰈙 ",
            Module = " ",
            Namespace = "󰌗 ",
            Package = " ",
            Class = "󰠱 ",
            Method = "ƒ ", -- slightly more distinguishable than duplicated 󰊕
            Property = " ",
            Field = " ",
            Constructor = " ",
            Enum = "󰖽 ",
            Interface = " ",
            Function = "󰊕 ",
            Variable = "󰀫 ",
            Constant = "󰏿 ",
            String = "󰉿 ",
            Number = "󰎠 ",
            Boolean = "󰨙 ",
            Array = "󰅪 ",
            Object = "󰅩 ",
            Key = "󰌋 ",
            Null = "󰟢 ",
            EnumMember = " ",
            Struct = "󰙅 ",
            Event = " ",
            Operator = "󰆕 ",
            TypeParameter = "󰊄 ",
            Component = "󰡀 ",
            Fragment = "󰅴 ",
            FolderClosed = " ",
            FolderOpen = " "
        },

        use_default_mappings = false,

        mappings = {
            ["<esc>"] = require("nvim-navbuddy.actions").close(),
            ["q"] = require("nvim-navbuddy.actions").close(),
            ["<C-c>"] = require("nvim-navbuddy.actions").close(),

            ["h"] = require("nvim-navbuddy.actions").parent(),
            ["<Left>"] = require("nvim-navbuddy.actions").parent(),
            ["l"] = require("nvim-navbuddy.actions").children(),
            ["<Right>"] = require("nvim-navbuddy.actions").children(),

            ["k"] = require("nvim-navbuddy.actions").previous_sibling(),
            ["<Up>"] = require("nvim-navbuddy.actions").previous_sibling(),
            ["j"] = require("nvim-navbuddy.actions").next_sibling(),
            ["<Down>"] = require("nvim-navbuddy.actions").next_sibling(),

            ["<CR>"] = require("nvim-navbuddy.actions").select(),
            ["o"] = require("nvim-navbuddy.actions").select(),
            ["<2-LeftMouse>"] = require("nvim-navbuddy.actions").select(),

            -- Extra useful bindings
            ["<C-y>"] = require("nvim-navbuddy.actions").yank_name(),
            ["s"] = require("nvim-navbuddy.actions").toggle_preview(),

            ["v"] = require("nvim-navbuddy.actions").visual_name(),
            ["V"] = require("nvim-navbuddy.actions").visual_scope(),
            ["?"] = require("nvim-navbuddy.actions").help(),
            ["0"] = require("nvim-navbuddy.actions").root()
        },

        lsp = {
            auto_attach = true,
            preference = nil -- example: { "tsserver", "pyright", "gopls" }
        },

        reorient = true, -- keep current symbol visible / centered
        highlight = true -- use LSP highlight groups when possible

        -- Optional: override some highlight groups (very useful with many themes)
        -- You can also link them to your colorscheme groups
        -- Example:
        -- highlight = {
        --   NavbuddyName        = { fg = "#89b4fa", bg = "NONE" },
        --   NavbuddyScope       = { fg = "#f38ba8", bg = "NONE", bold = true },
        --   NavbuddyCursor      = { link = "Cursor" },
        -- },
    },

    config = function(_, opts)
        require("nvim-navbuddy").setup(opts)

        -- Buffer-local keymaps — only created when LSP supports documentSymbol
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("NavbuddyKeymaps", {
                clear = true
            }),
            callback = function(args)
                local bufnr = args.buf
                local client = vim.lsp.get_client_by_id(args.data.client_id)

                -- Only add keymaps if the client supports document symbols
                if client and client:supports_method("textDocument/documentSymbol") then
                    vim.keymap.set("n", "<leader>nb", function()
                        require("nvim-navbuddy").open()
                    end, {
                        buffer = bufnr,
                        desc = "Navbuddy: Open"
                    })

                    vim.keymap.set("n", "<C-b>", function()
                        require("nvim-navbuddy").open()
                    end, {
                        buffer = bufnr,
                        desc = "Navbuddy (Ctrl+B)"
                    })
                end
            end
        })
    end
}
