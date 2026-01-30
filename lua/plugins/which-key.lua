return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = function(ctx)
      return ctx.mapping and 200 or 600   -- faster for known mappings
    end,
    win = {
      border = "rounded",
      no_overlap = true,
      padding = { 1, 2 },
      title = true,
      title_pos = "center",
      zindex = 1000,
      wo = {
        winblend = 10,
      },
    },
    layout = {
      width = { min = 20, max = 50 },
      height = { min = 6, max = 25 },
      spacing = 4,
      align = "left",
    },
    sort = { "case", "local", "order", "group", "alphanum", "mod" },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
      ellipsis = "…",
      mappings = true,
      rules = false,
    },
    show_help = true,
    show_keys = true,
    disable = {
      filetypes = { "TelescopePrompt", "neo-tree", "lazy" },
    },
    -- Automatically label many popular plugins
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = true, suggestions = 20 },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    -- Replace <leader> etc in display
    replace = {
      ["<leader>"] = "SPC",
      ["<space>"] = "SPC",
      ["<cr>"] = "RET",
      ["<tab>"] = "TAB",
      ["<C-"] = "Ctrl+",
    },
  },

  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- ── Main <leader> groups ───────────────────────────────────────
    wk.add({
      -- Core
      { "<leader>b", group = "󰓩 Buffers" },
      { "<leader>c", group = "󰘦 Code / LSP" },
      { "<leader>d", group = "󰃤 Debug" },
      { "<leader>f", group = "󰈞 Find / Telescope" },
      { "<leader>g", group = "󰊢 Git" },
      { "<leader>l", group = "󰗊 LSP" },
      { "<leader>p", group = "󰏖 Plugins / Lazy" },
      { "<leader>q", group = "󰗼 Quit / Session" },
      { "<leader>r", group = "󰑕 Replace / Refactor" },
      { "<leader>s", group = "󰛔 Search" },
      { "<leader>t", group = "󰙅 Toggle / Terminal" },
      { "<leader>u", group = "󰔃 UI / UX" },
      { "<leader>w", group = "󰖲 Windows" },
      { "<leader>x", group = "󰒅 Diagnostics / Trouble" },

      -- Navigation / motion groups
      { "]", group = "Next" },
      { "[", group = "Prev" },
      { "g",  group = "Goto" },
      { "z",  group = "Fold / Zentering" },

      -- Visual mode root
      { "<leader>", group = "Leader", mode = "v" },
    })

    -- ── Example concrete mappings (replace with your real ones) ─────
    wk.add({
      -- File / Buffer
      { "<leader>e", "<cmd>NvimTreeToggle<CR>",      desc = "File Explorer" },
      { "<leader>w", "<cmd>update<CR>",              desc = "Save" },
      { "<leader>W", "<cmd>wa<CR>",                  desc = "Save All" },
      { "<leader>q", "<cmd>confirm q<CR>",           desc = "Quit" },
      { "<leader>Q", "<cmd>confirm qa<CR>",          desc = "Quit All" },

      -- Common actions
      { "<leader>/", function() require("Comment.api").toggle.linewise.current() end, desc = "Comment Line", mode = "n" },
      { "<leader>/", function() require("Comment.api").toggle.linewise(vim.fn.visualmode()) end, desc = "Comment", mode = "v" },
      { "<leader>h", "<cmd>nohlsearch<CR>",          desc = "Clear Search Highlights" },

      -- Telescope / Find (examples)
      { "<leader>ff", "<cmd>Telescope find_files<CR>",   desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",    desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",      desc = "Buffers" },

      -- LSP (examples – adjust to your actual keys)
      { "<leader>ca", vim.lsp.buf.code_action,           desc = "Code Action", mode = { "n", "v" } },
      { "<leader>rn", vim.lsp.buf.rename,                desc = "Rename" },
      { "<leader>gd", vim.lsp.buf.definition,            desc = "Goto Definition" },
    })
  end,
}