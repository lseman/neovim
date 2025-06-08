return {
  "GCBallesteros/jupytext.nvim",
  config = function()
    require("jupytext").setup({
      style = "hydrogen", -- or "percent" or "sphinx" (default is "percent")
      output_extension = "py", -- or "jl", "r", etc., based on kernel
      force_ft = "python", -- Filetype to use for Jupytext buffers
      -- Add other options here if you need more customization
    })
  end,
}
