return {
  "Shatur/neovim-ayu",
  config = function()
    require("ayu").setup({
      mirage = true, -- Matches startup colorscheme `ayu-mirage`.
      terminal = true, -- Set to `false` to let terminal manage its own colors.
      overrides = {}, -- A dictionary of group names, each associated with a dictionary of parameters (`bg`, `fg`, `sp` and `style`) and colors in hex.
    })
  end,
}
