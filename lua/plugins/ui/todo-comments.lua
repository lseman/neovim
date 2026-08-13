return {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        signs = true,
        highlight = {
            keyword = "default",
            bg = true,
            line = true,
        },
        search = {
            command = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
            },
        },
    },
    keys = {
        { "<leader>st", function() require("todo-comments").todo() end, desc = "Todo Quickfix" },
        { "<leader>sT", function() require("todo-comments").todo({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme Quickfix" },
    },
}
