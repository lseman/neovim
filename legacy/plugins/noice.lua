return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {"MunifTanjim/nui.nvim"},

    opts = {
        -- Snacks.notifier owns vim.notify — don't let noice shadow it
        notify = { enabled = false },

        lsp = {
            -- Better hover/signature rendering via markdown
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
            },
            -- Show LSP progress in a compact fidget-style widget
            progress = { enabled = true },
            hover = { enabled = true },
            signature = { enabled = true },
        },

        presets = {
            bottom_search = true,        -- classic / at the bottom
            command_palette = true,      -- : floats at top-center
            long_message_to_split = true, -- long messages → split instead of popup
            inc_rename = false,          -- set true if/when inc-rename.nvim is added
        },

        -- Route boring/noisy messages away from the cmdline
        routes = {
            -- Hide "written" / "N lines" write confirmations
            {
                filter = { event = "msg_show", find = "written" },
                opts = { skip = true },
            },
            -- Hide search count noise ("[1/23]")
            {
                filter = { event = "msg_show", find = "^[/?]" },
                opts = { skip = true },
            },
        },

        views = {
            cmdline_popup = {
                border = { style = "rounded" },
                position = { row = "40%", col = "50%" },
                size = { width = 60, height = "auto" },
            },
            popupmenu = {
                border = { style = "rounded" },
                position = { row = "50%", col = "50%" },
                size = { width = 60, height = 10 },
            },
        },
    },

    keys = {
        { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Dismiss noice messages" },
        { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice message history" },
        { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end,
          mode = "c", desc = "Redirect cmdline to split" },
    },
}
