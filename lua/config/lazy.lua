require("lazy").setup({
    spec = {{
        import = "plugins"
    }},
    defaults = {
        lazy = true,
        version = false
    },
    install = {
        colorscheme = {"ayu", "habamax"}
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
