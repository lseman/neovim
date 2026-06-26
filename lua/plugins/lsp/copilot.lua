return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = false,  -- handled by <Tab> in keymaps.lua
          accept_word = "<M-w>",
          accept_line = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },

      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          accept = "<CR>",
          jump_prev = "[[",
          jump_next = "]]",
          refresh = "gr",
          open = "<M-CR>",
        },
        layout = {
          position = "bottom", -- top | left | right
          ratio = 0.4,
        },
      },

      filetypes = {
        ["*"] = true,
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["TelescopePrompt"] = false,
        ["dap-repl"] = false,
        [""] = false,
      },

      copilot_node_command = "node",
      server_opts_overrides = {},
    })
  end,
}
