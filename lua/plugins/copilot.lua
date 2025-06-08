return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      -- 🧠 Inline suggestions
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },

      -- 📋 Side panel for browsing suggestions
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

      -- 🚫 Disable Copilot for non-coding filetypes
      filetypes = vim.tbl_deep_extend("force", {
        ["*"] = true, -- default: enabled
      }, {
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
        [""] = false, -- unnamed buffers
      }),

      -- ⚙️ Runtime environment
      copilot_node_command = "node", -- ensure >= Node 18.x
      server_opts_overrides = {},
    })
  end,
}
