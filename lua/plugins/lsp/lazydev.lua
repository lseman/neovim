return {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
        library = {
            { path = "snacks.nvim", words = { "Snacks" } },
            { path = "lazy.nvim", words = { "LazyVim", "Lazy" } },
            { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
    },
    dependencies = {
        { "Bilal2453/luvit-meta", lazy = true },
    },
}
