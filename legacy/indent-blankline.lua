return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    enabled = false,
    event = {"BufReadPost", "BufNewFile"},

    opts = {
        indent = {
            char = "▏", -- thin vertical line
            tab_char = "▏",
            highlight = {"IblIndent"}
        },

        scope = {
            enabled = true,
            show_start = true,
            show_end = true,
            show_exact_scope = true, -- cleaner: only exact scope
            highlight = {"IblScope"}
        },

        exclude = {
            filetypes = {"help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "notify", "toggleterm",
                         "lazyterm", "TelescopePrompt", "TelescopeResults", "WhichKey", "noice", "oil", "qf", "terminal"},
            buftypes = {"terminal", "nofile", "quickfix", "prompt"}
        }
    },

    config = function(_, opts)
        local ibl = require("ibl")
        local hooks = require("ibl.hooks")

        vim.keymap.set("n", "<leader>ti", function()
            if ibl.is_enabled() then
                ibl.disable()
                vim.notify("Indent guides → disabled", vim.log.levels.INFO)
            else
                ibl.enable()
                vim.notify("Indent guides → enabled", vim.log.levels.INFO)
            end
        end, {
            desc = "Toggle indent guides"
        })

        -- Theme-friendly highlight groups: neutral indent, emphasized current scope only.
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "IblIndent", {
                link = "NonText",
                default = true
            })
            vim.api.nvim_set_hl(0, "IblScope", {
                link = "CursorLineNr",
                default = true,
                nocombine = true
            })
        end)

        -- Optional: use scope highlight also in the gutter (cleaner in some themes)
        -- hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_gutter)

        ibl.setup(opts)
    end
}
