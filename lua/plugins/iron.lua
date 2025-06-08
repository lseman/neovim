-- plugins/iron.lua
return {
  "Vigemus/iron.nvim",
  event = "VeryLazy",

  config = function()
    local iron = require("iron.core")
    local view = require("iron.view")

    iron.setup({
      config = {
        --- Auto-open and reset behavior
        open_repl = true,
        scratch_repl = true,

        --- REPL definitions per filetype
        repl_definition = {
          python = {
            command = { "ipython", "--no-autoindent" },
          },
          -- Add more: lua = { command = { "lua" } },
        },

        --- Window layout for REPL
        repl_open_cmd = view.split.vertical.botright(0.4),
      },

      keymaps = {
        send_motion   = "<leader>sc",
        visual_send   = "<leader>sc",
        send_file     = "<leader>sf",
        send_line     = "<leader>sl",
        send_mark     = "<leader>sm",
        mark_motion   = "<leader>mc",
        mark_visual   = "<leader>mc",
        remove_mark   = "<leader>md",
        cr            = "<leader>s<CR>",
        interrupt     = "<leader>s<Space>",
        exit          = "<leader>sq",
        clear         = "<leader>cl",
      },

      highlight = {
        italic = true,
      },

      ignore_blank_lines = true,
    })
  end,
}
