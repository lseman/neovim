return {
    {
        "echasnovski/mini.map",
        version = false,
    event = "User FilePost",

        keys = {
            {
                "<leader>um",
                function()
                    require("mini.map").toggle()
                end,
                desc = "Toggle Mini Map",
            },
            {
                "<leader>uM",
                function()
                    require("mini.map").refresh()
                end,
                desc = "Refresh Mini Map",
            },
        },

        opts = {
            auto_enable = false,

            -- Leave integrations and encode empty here — we'll fill them in config
            integrations = {},
            symbols = {
                scroll_line = "▶",
                scroll_view = "┃",
            },
            window = {
                side = "right",
                focusable = false,
                width = 12,
                winblend = 30,
                zindex = 10,
                show_integration_count = true,
            },
        },

        config = function(_, opts)
            local map = require "mini.map"

            local integrations = {}
            local gen = map.gen_integration
            if gen then
                table.insert(integrations, gen.builtin_search())
                table.insert(integrations, gen.gitsigns())
                table.insert(integrations, gen.diagnostic())
            end
            opts.integrations = integrations

            map.setup(opts)
        end,
    },
}
