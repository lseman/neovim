return {
  'nvim-tree/nvim-web-devicons',
  lazy = true,
  config = function()
    require('nvim-web-devicons').setup({
      color_icons = true,
      default = true, -- fallback icon when not found
      strict = true,  -- only override if matching name/extension

      -- Override specific filetypes (by name)
      override = {
        zsh = { icon = "", color = "#428850", name = "Zsh" },
        lua = { icon = "", color = "#51a0cf", name = "Lua" },
        -- Use "" to disable icons if desired, but it's more explicit to remove the icon key
      },

      -- Override by exact filename
      override_by_filename = {
        [".gitignore"] = { icon = "", color = "#f1502f", name = "Gitignore" },
      },

      -- Override by extension
      override_by_extension = {
        log = { icon = "", color = "#81e043", name = "Log" },
      },
    })
  end,
}
