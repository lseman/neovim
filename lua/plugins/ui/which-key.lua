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
            padding = { 1, 2 },
            title = true,
            title_pos = "center",
            zindex = 1000,
            wo = {
                winblend = 10,
            },
        },
        layout = {
            width = {
                min = 20,
                max = 50,
            },
            height = {
                min = 6,
                max = 25,
            },
            spacing = 5,
            align = "center",
        },
        sort = { "local", "order", "group", "alphanum", "case", "mod" },
        icons = {
            breadcrumb = "» ",
            separator = "➜ ",
            group = "+ ",
            ellipsis = "…",
            mappings = true,
            colors = true,
        },
        show_help = true,
        show_keys = true,
        disable = {
            filetypes = { "snacks_picker_list", "lazy", "alpha", "dashboard" },
        },
        plugins = {
            marks = true,
            registers = true,
            spelling = {
                enabled = true,
                suggestions = 20,
            },
            presets = {
                operators = true,
                motions = true,
                text_objects = true,
                windows = true,
                nav = true,
                z = true,
                g = true,
            },
        },
        replace = {
            ["<leader>"] = "SPC",
            ["<space>"] = "SPC",
            ["<cr>"] = "RET",
            ["<tab>"] = "TAB",
            ["<C-"] = "Ctrl+",
            ["<A-"] = "Alt+",
        },
    },
    config = function(_, opts)
        local wk = require "which-key"
        wk.setup(opts)

        wk.add({ -- Leader groups
            {
                "<leader>c",
                group = "󰘦 code / lsp",
            },
            {
                "<leader>d",
                group = "󰃤 debug",
            },
            {
                "<leader>f",
                group = "󰈞 find",
            },
            {
                "<leader>g",
                group = "󰊢 git",
            },
            {
                "<leader>h",
                group = "󰞇 harpoon / help",
            },
            {
                "<leader>k",
                group = "󰌠 kulala",
            },
            {
                "<leader>kr",
                function()
                    require("kulala").run()
                end,
                desc = "HTTP request",
            },
            {
                "<leader>ka",
                function()
                    require("kulala").run_all()
                end,
                desc = "HTTP run all",
            },
            {
                "<leader>kR",
                function()
                    require("kulala").scratchpad()
                end,
                desc = "HTTP scratchpad",
            },
            {
                "<leader>l",
                group = "󰗊 lazy / tools",
            },
            {
                "<leader>n",
                group = "󰎟 notifications",
            },
            {
                "<leader>p",
                group = "󰏖 plugins",
            },
            {
                "<leader>q",
                group = "󰗼 quit / session",
            },
            {
                "<leader>r",
                group = "󰑕 refactor / replace",
            },
            {
                "<leader>s",
                group = "󰛔 search / session",
            },
            {
                "<leader>t",
                group = "󰙅 toggle / test / terminal",
            },
            {
                "<leader>u",
                group = "󰔃 ui / toggles",
            },
            {
                "<leader>w",
                group = "󰖲 workspace / write",
            },
            {
                "<leader>x",
                group = "󰒅 diagnostics / lists",
            },
            {
                "]",
                group = "next",
            },
            {
                "[",
                group = "prev",
            },
            {
                "g",
                group = "goto",
            },
            {
                "z",
                group = "fold / center",
            },
            {
                "<leader>",
                group = "leader",
                mode = "v",
            },
        })

        wk.add({ -- File / Buffer
            {
                "<leader>e",
                desc = "File Explorer",
            },
            {
                "<leader>ww",
                "<cmd>update<cr>",
                desc = "Save",
            },
            {
                "<leader>wW",
                "<cmd>wa<cr>",
                desc = "Save All",
            },
            {
                "<leader>qq",
                "<cmd>confirm q<cr>",
                desc = "Quit",
            },
            {
                "<leader>qQ",
                "<cmd>confirm qa<cr>",
                desc = "Quit All",
            }, -- Utility
            {
                "<leader>/",
                desc = "Comment Line",
                mode = "n",
            },
            {
                "<leader>/",
                desc = "Comment",
                mode = "v",
            },
            {
                "<leader>u/",
                "<cmd>nohlsearch<cr>",
                desc = "Clear Search Highlight",
            }, -- Snacks / Picker
            {
                "<leader>ff",
                desc = "Find Files",
            },
            {
                "<leader>fc",
                desc = "Config Files",
            },
            {
                "<leader>fg",
                desc = "Live Grep",
            },
            {
                "<leader>fG",
                desc = "Git Files",
            },
            {
                "<leader>fb",
                desc = "Find Buffers",
            },
            {
                "<leader>fp",
                desc = "Projects",
            },
            {
                "<leader>fh",
                desc = "Help Tags",
            },
            {
                "<leader>fr",
                desc = "Recent Files",
            },
            {
                "<leader>fK",
                desc = "Write Keymap Cheatsheet",
            },
            {
                "<leader>fW",
                desc = "Write Cheatsheet to Disk",
            },
            {
                "<leader>fk",
                desc = "Keymaps",
            },

            {
                "<leader>sB",
                desc = "Grep Open Buffers",
            },
            {
                '<leader>s"',
                desc = "Registers",
            },
            {
                "<leader>s/",
                desc = "Search History",
            },
            {
                "<leader>sc",
                desc = "Command History",
            },
            {
                "<leader>sC",
                desc = "Commands",
            },
            {
                "<leader>sD",
                desc = "Buffer Diagnostics",
            },
            {
                "<leader>sj",
                desc = "Jumps",
            },
            {
                "<leader>sl",
                desc = "Location List",
            },
            {
                "<leader>sm",
                desc = "Marks",
            },
            {
                "<leader>sp",
                desc = "Plugin Spec Search",
            },
            {
                "<leader>sq",
                desc = "Quickfix List",
            },
            {
                "<leader>sR",
                desc = "Resume Picker",
            },
            {
                "<leader>sr",
                desc = "Search and Replace",
            },
            {
                "<leader>rF",
                desc = "Search and Replace Scratch",
            },
            {
                "<leader>rw",
                desc = "Replace Word",
            },
            {
                "<leader>rm",
                desc = "SSH Mount Remote FS",
            },
            {
                "<leader>rs",
                desc = "SSH Connect to Host",
            },
            {
                "<leader>uC",
                desc = "Colorschemes",
            },

            {
                "<leader>gk",
                desc = "Git Branches",
            },
            {
                "<leader>gl",
                desc = "Git Log",
            },
            {
                "<leader>gL",
                desc = "Git Log Line",
            },
            {
                "<leader>gf",
                desc = "Git Log File",
            },
            {
                "<leader>lp",
                desc = "Toggle LSP Progress HUD",
            },
            {
                "<leader>lh",
                desc = "Fidget History",
            },
            {
                "<leader>lH",
                desc = "Clear Fidget History",
            },
            {
                "<leader>lc",
                desc = "Clear Active Progress",
            },
            {
                "<leader>cR",
                desc = "Rename File",
            }, -- LSP
            {
                "<leader>ca",
                vim.lsp.buf.code_action,
                desc = "Code Action",
                mode = { "n", "v" },
            },
            {
                "<leader>rn",
                vim.lsp.buf.rename,
                desc = "Rename Symbol",
            },
            {
                "<leader>sh",
                desc = "Signature Help",
            },
            {
                "<leader>ds",
                desc = "Document Symbols",
            },
            {
                "<leader>ws",
                desc = "Workspace Symbols",
            },
            {
                "<leader>dl",
                desc = "Line Diagnostics",
            },
            {
                "<leader>fm",
                desc = "Format Buffer",
            },
            {
                "<leader>uh",
                desc = "Toggle Inlay Hints",
            }, -- Trouble
            {
                "<leader>xx",
                desc = "Diagnostics List",
            },
            {
                "<leader>xL",
                desc = "Location List",
            },
        })
    end,
}
