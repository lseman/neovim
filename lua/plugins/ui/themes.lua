local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h:h")

return {
    name = "theme-picker",
    dir = root .. "/local/theme-picker",
    lazy = false,
    priority = 1100,
    dependencies = { { import = "plugins.ui.ayu" } },
    keys = {
        { "<leader>T", function() require("theme_picker").toggle() end, desc = "Theme Picker" },
        { "<leader>uC", function() require("theme_picker").toggle() end, desc = "Colorschemes" },
    },
    config = function()
        require("theme_picker").setup()
    end,
}
