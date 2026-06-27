return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  keys = {
    {
      "<leader>hr",
      function()
        require("kulala").run()
      end,
      desc = "HTTP request",
    },
    {
      "<leader>ha",
      function()
        require("kulala").run_all()
      end,
      desc = "HTTP run all",
    },
    {
      "<leader>hR",
      function()
        require("kulala").scratchpad()
      end,
      desc = "HTTP scratchpad",
    },
  },
  opts = {
    global_keymaps = false,
    ui = {
      display_mode = "split",
    },
  },
}
