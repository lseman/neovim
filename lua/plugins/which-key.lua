return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = function(ctx)
            return ctx.mapping and 120 or 600
        end,
        win = {
            border = "rounded",
            no_overlap = true,
            padding = {1, 2},
            title = true,
            title_pos = "center",
            zindex = 1000,
            wo = {
                winblend = 10
            }
        },
        layout = {
            width = {
                min = 20,
                max = 50
            },
            height = {
                min = 6,
                max = 25
            },
            spacing = 5,
            align = "center"
        },
        sort = {"local", "order", "group", "alphanum", "case", "mod"},
        icons = {
            breadcrumb = "» ",
            separator = "➜ ",
            group = "+ ",
            ellipsis = "…",
            mappings = true,
            -- rules = false,   -- or remove this line entirely (defaults to using built-ins safely)
            colors = true
        },
        show_help = true,
        show_keys = true,
        disable = {
            filetypes = {"TelescopePrompt", "neo-tree", "lazy", "alpha", "dashboard"}
        },
        plugins = {
            marks = true,
            registers = true,
            spelling = {
                enabled = true,
                suggestions = 20
            },
            presets = {
                operators = true,
                motions = true,
                text_objects = true,
                windows = true,
                nav = true,
                z = true,
                g = true
            }
        },
        replace = {
            ["<leader>"] = "SPC",
            ["<space>"] = "SPC",
            ["<cr>"] = "RET",
            ["<tab>"] = "TAB",
            ["<C-"] = "Ctrl+",
            ["<A-"] = "Alt+"
        }
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

        wk.add { -- Leader groups
        {
            "<leader>b",
            group = "󰓩 buffers"
        }, {
            "<leader>c",
            group = "󰘦 code / lsp"
        }, {
            "<leader>d",
            group = "󰃤 debug"
        }, {
            "<leader>f",
            group = "󰈞 find"
        }, {
            "<leader>g",
            group = "󰊢 git"
        }, {
            "<leader>h",
            group = "󰞇 harpoon / help"
        }, {
            "<leader>l",
            group = "󰗊 lazy / lsp"
        }, {
            "<leader>n",
            group = "󰙅 nvim-tree"
        }, {
            "<leader>p",
            group = "󰏖 plugins"
        }, {
            "<leader>q",
            group = "󰗼 quit / session"
        }, {
            "<leader>r",
            group = "󰑕 refactor / replace"
        }, {
            "<leader>s",
            group = "󰛔 search / session"
        }, {
            "<leader>t",
            group = "󰙅 toggle / test / terminal"
        }, {
            "<leader>u",
            group = "󰔃 ui / ux"
        }, {
            "<leader>w",
            group = "󰖲 windows"
        }, {
            "<leader>x",
            group = "󰒅 diagnostics / trouble"
        }, {
            "]",
            group = "next"
        }, {
            "[",
            group = "prev"
        }, {
            "g",
            group = "goto"
        }, {
            "z",
            group = "fold / center"
        }, {
            "<leader>",
            group = "leader",
            mode = "v"
        }}

        wk.add { -- File / Buffer
        {
            "<leader>e",
            desc = "File Explorer"
        }, {
            "<leader>w",
            "<cmd>update<cr>",
            desc = "Save"
        }, {
            "<leader>W",
            "<cmd>wa<cr>",
            desc = "Save All"
        }, {
            "<leader>q",
            "<cmd>confirm q<cr>",
            desc = "Quit"
        }, {
            "<leader>Q",
            "<cmd>confirm qa<cr>",
            desc = "Quit All"
        }, -- Utility
        {
            "<leader>/",
            function()
                require("Comment.api").toggle.linewise.current()
            end,
            desc = "Comment Line",
            mode = "n"
        }, {
            "<leader>/",
            function()
                require("Comment.api").toggle.linewise(vim.fn.visualmode())
            end,
            desc = "Comment",
            mode = "v"
        }, {
            "<leader>h",
            "<cmd>nohlsearch<cr>",
            desc = "Clear Highlights"
        }, -- Snacks / Picker
        {
            "<leader>ff",
            desc = "Find Files"
        }, {
            "<leader>fg",
            desc = "Live Grep"
        }, {
            "<leader>fb",
            desc = "Find Buffers"
        }, {
            "<leader>fh",
            desc = "Help Tags"
        }, -- LSP
        {
            "<leader>ca",
            vim.lsp.buf.code_action,
            desc = "Code Action",
            mode = {"n", "v"}
        }, {
            "<leader>rn",
            vim.lsp.buf.rename,
            desc = "Rename Symbol"
        }, {
            "<leader>gd",
            vim.lsp.buf.definition,
            desc = "Goto Definition"
        }, {
            "<leader>gr",
            vim.lsp.buf.references,
            desc = "References"
        }, {
            "<leader>gi",
            vim.lsp.buf.implementation,
            desc = "Implementation"
        }, {
            "<leader>gt",
            vim.lsp.buf.type_definition,
            desc = "Type Definition"
        }, -- Trouble
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Trouble Diagnostics"
        }, {
            "<leader>xl",
            "<cmd>Trouble loclist toggle<cr>",
            desc = "Location List"
        }}
    end
}
