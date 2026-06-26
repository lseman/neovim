return {
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
}
