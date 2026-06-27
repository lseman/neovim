return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    {
      "<leader>sr",
      function()
        require("grug-far").open()
      end,
      desc = "Search and replace",
    },
    {
      "<C-h>",
      function()
        require("grug-far").open({
          prefills = {
            paths = vim.fn.expand "%",
          },
        })
      end,
      desc = "Search and replace current file",
    },
    {
      "<leader>rw",
      function()
        require("grug-far").open({
          prefills = {
            search = vim.fn.expand "<cword>",
          },
        })
      end,
      desc = "Replace word",
    },
    {
      "<leader>rF",
      function()
        require("grug-far").open({
          transient = true,
        })
      end,
      desc = "Search and replace scratch",
    },
    {
      "<leader>sr",
      function()
        require("grug-far").with_visual_selection()
      end,
      mode = "v",
      desc = "Search and replace selection",
    },
  },
  opts = {
    startInInsertMode = false,
    transient = false,
    maxSearchCharsInTitles = 40,
    engines = {
      ripgrep = {
        path = "rg",
      },
    },
    windowCreationCommand = "botright split",
  },
}
