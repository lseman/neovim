-- Load category manifests explicitly; never scan their helper modules.
local categories = { "ui", "editor", "navigation", "lsp", "git", "notebooks" }
local specs = {}
for _, category in ipairs(categories) do
    local module = "plugins." .. category
    specs[#specs + 1] = {
        name = module,
        import = function()
            return require(module)
        end,
    }
end

require("lazy").setup({
    spec = specs,
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
