require("lazy").setup({
    spec = {{
        import = "plugins.ui"
    }, {
        import = "plugins.editor"
    }, {
        import = "plugins.navigation"
    }, {
        -- Import the explicit spec list without scanning its helper modules.
        name = "plugins.lsp",
        import = function()
            return require "plugins.lsp"
        end
    }, {
        import = "plugins.git"
    }, {
        import = "plugins.notebooks"
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
