vim.g.snacks_animate = false  -- ← disables ALL snacks animations globally

return {
  "folke/snacks.nvim",
  priority = 1000,   -- load early (good for dashboard/ui replacements)
  lazy = false,      -- or event = "VeryLazy" if you prefer lazy-loading

  ---@type snacks.Config
  opts = {
    -- === Core toggles (enable what you want) ===
    bigfile     = { enabled = true },     -- auto-detect huge files + better performance
    dashboard   = { enabled = true },     -- nice startup screen (customizable)
    explorer    = { enabled = true },     -- built-in file explorer (oil.nvim style)
    indent      = { enabled = true },     -- modern indent guides (replaces indent-blankline)
    input       = { enabled = true },     -- better vim.ui.input (replaces dressing input)
    picker      = { enabled = true },     -- the star: modern fuzzy finder
    quickfile   = { enabled = true },     -- fast :edit last file on startup
    scroll      = { enabled = false },    -- smooth scrolling (try it if you like)
    statuscolumn= { enabled = true },     -- nicer folds/signs/statuscolumn
    words       = { enabled = true },     -- auto show references/definitions on cursor hold

    -- === Notifier (replaces nvim-notify in many cases) ===
    notifier    = {
      enabled = true,
      timeout = 3000,
      style = "compact",   -- or "fancy"
    },

    -- === Zen mode (distraction free) ===
    zen         = { enabled = true },

    -- === Picker is the big one — highly recommended ===
    picker = {
      sources = {
        -- Customize layouts per source if needed
        files = {
          -- layout = { preset = "vertical" },
        },
      },
      -- Default layout for most pickers
      layout = {
        preset = "default",   -- try: "vertical", "select", "ivy", "telescope"
        -- preview = true,    -- most sources support preview
      },
    },

    -- === Explorer config (if enabled above) ===
    explorer = {
      -- git = { enabled = true },
      -- diagnostics = { enabled = true },
    },
  },

  keys = {
    -- === Quick access to picker modes (very useful) ===
    { "<leader>ff", function() Snacks.picker.files() end,              desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.grep() end,               desc = "Grep (project)" },
    { "<leader>fb", function() Snacks.picker.buffers() end,            desc = "Buffers" },
    { "<leader>fr", function() Snacks.picker.recent() end,             desc = "Recent Files" },
    { "<leader>fs", function() Snacks.picker.lsp_symbols() end,        desc = "Document Symbols" },
    { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols" },
    { "<leader>fd", function() Snacks.picker.diagnostics() end,        desc = "Diagnostics" },
    { "<leader>fh", function() Snacks.picker.help() end,               desc = "Help Pages" },
    { "<leader>fk", function() Snacks.picker.keymaps() end,            desc = "Keymaps" },
    { "<leader>fn", function() Snacks.picker.notifications() end,      desc = "Notifications" },

    -- Explorer toggle
    { "<leader>e",  function() Snacks.explorer() end,                  desc = "File Explorer" },

    -- Zen mode
    { "<leader>z",  function() Snacks.zen() end,                       desc = "Zen Mode" },

    -- Other nice ones
    { "<leader>gb", function() Snacks.gitbrowse() end,                 desc = "Git Browse (line/repo)" },
  },

  init = function()
    -- Optional: use snacks as default vim.ui provider (like dressing)
    vim.ui.select = function(...)
      return require("snacks").picker.select(...)
    end
    -- vim.ui.input = ... (snacks handles it via input.enable)
  end,
}