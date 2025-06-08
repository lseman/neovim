return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local wk = require("which-key")
    
    wk.setup({
      preset = "modern", -- Use modern preset for better defaults
      
      win = {
        border = "rounded", -- More modern look
        padding = { 1, 2 }, -- Simplified padding [top/bottom, left/right]
        title = true,
        title_pos = "center",
        zindex = 1000,
        -- Add some styling
        wo = {
          winblend = 10, -- Slight transparency
        },
      },
      
      layout = {
        width = { min = 20, max = 50 },
        height = { min = 4, max = 25 },
        spacing = 3,
        align = "left",
      },
      
      -- Enhanced filtering and sorting
      sort = { "local", "order", "group", "alphanum", "mod" },
      expand = 1, -- Expand groups when <= 1
      
      -- Better replacement rules for cleaner display
      replace = {
        ["<space>"] = "SPC",
        ["<cr>"] = "RET",
        ["<tab>"] = "TAB",
      },
      
      -- Icon configuration
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
        ellipsis = "…",
        -- Set to false to disable all mapping icons (both keys and groups)
        mappings = true,
        -- Additional customizations
        rules = false, -- Disable default icon rules to avoid conflicts
      },
      
      -- Key display options
      keys = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
      },
      
      -- Disable for certain modes/operators
      disable = {
        buftypes = {},
        filetypes = {},
      },
      
      -- Debugging options (can be removed in production)
      debug = false,
      
      -- Triggers
      triggers = {
        { "<auto>", mode = "nxsot" },
      },
    })

    -- Define key group labels for better organization
    wk.add({
      -- Leader key groups
      { "<leader>b", group = "󰓩 Buffers" },
      { "<leader>c", group = "󰘦 Code" },
      { "<leader>d", group = "󰃤 Debug" },
      { "<leader>f", group = "󰈞 Find" },
      { "<leader>g", group = "󰊢 Git" },
      { "<leader>l", group = "󰗊 LSP" },
      { "<leader>n", group = "󰎄 Navigation" },
      { "<leader>p", group = "󰏖 Package Manager" },
      { "<leader>q", group = "󰗼 Quit/Session" },
      { "<leader>r", group = "󰑕 Replace" },
      { "<leader>s", group = "󰛔 Search" },
      { "<leader>t", group = "󰙅 Toggle/Terminal" },
      { "<leader>u", group = "󰔃 UI" },
      { "<leader>w", group = "󰖲 Windows" },
      { "<leader>x", group = "󰒅 Trouble/Diagnostics" },
      
      -- Bracket-based groups (commonly used)
      { "]", group = "Next" },
      { "[", group = "Prev" },
      
      -- Visual mode groups
      { "<leader>", group = "Leader", mode = "v" },
      { "g", group = "Go to", mode = { "n", "v" } },
      
      -- Common single-key actions with descriptions
      { "z", group = "Fold" },
      { "g", group = "Go to" },
      
      -- Plugin-specific groups (uncomment as needed)
      -- { "<leader>gh", group = "󰊢 GitHub" }, -- for GitHub CLI or similar
      -- { "<leader>m", group = "󰍉 Markdown" }, -- for markdown tools
      -- { "<leader>v", group = "󰦨 Vimspector" }, -- for debugging
    })

    -- Optional: Add some common keymaps with descriptions
    -- These serve as examples - adjust to your actual keymaps
    wk.add({
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
      { "<leader>w", "<cmd>w!<cr>", desc = "Save" },
      { "<leader>q", "<cmd>confirm q<cr>", desc = "Quit" },
      { "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<cr>", desc = "Comment" },
      { "<leader>h", "<cmd>nohlsearch<cr>", desc = "Clear Highlights" },
    }, { mode = "n" })

    -- Visual mode mappings
    wk.add({
      { "<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", desc = "Comment" },
    }, { mode = "v" })
  end,
}