return {
  {
    "jbyuki/nabla.nvim",
    keys = {
      {
        "<C-b>",
        function()
          require("nabla").popup()
        end,
        desc = "Show LaTeX popup",
      },
    },
    config = function()
      require("nabla").setup({})
    end,
  },
}
