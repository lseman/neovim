-- Replaced by folke/ts-comments.nvim — treesitter-native, zero config
return {{
    "JoosepAlviste/nvim-ts-context-commentstring",
    enabled = false
}, {
    "numToStr/Comment.nvim",
    enabled = false
}, {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
        require("ts-comments").setup(opts)

        -- Keep familiar <leader>/ toggle (delegates to gc/gcc under the hood)
        vim.keymap.set("n", "<leader>/", "gcc", {
            remap = true,
            silent = true,
            desc = "Comment: toggle line"
        })
        vim.keymap.set("x", "<leader>/", "gc", {
            remap = true,
            silent = true,
            desc = "Comment: toggle selection"
        })
    end
}}
