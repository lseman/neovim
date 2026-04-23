require("lazy").setup({
    spec = {{
        import = "plugins.ui"
    }, {
        import = "plugins.editor"
    }, {
        import = "plugins.navigation"
    }, {
        import = "plugins.lsp"
    }, {
        import = "plugins.git"
    }, {
        import = "plugins.notebooks"
    }, {
        import = "plugins.terminal"
    }, {
        import = "plugins.misc"
    }, {
        import = "plugins"
    }},
    defaults = {
        lazy = true,
        version = false
    },
    install = {
        missing = true,
        colorscheme = {"ayu", "habamax"}
    },
    ui = {
        border = "rounded"
    },
    checker = {
        enabled = true,
        notify = false
    },
    change_detection = {
        enabled = true,
        notify = false
    },
    performance = {
        rtp = {
            disabled_plugins = {"gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin"}
        }
    }
})
