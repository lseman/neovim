return {
  -- ts-context-commentstring first (loaded early as dep)
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,   -- disable CursorHold → we trigger only on comment
    },
    config = true,  -- calls .setup(opts) automatically
  },

  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },

    opts = {
      padding = true,
      sticky = true,
      ignore = "^%s*$",

      toggler = { line = "gcc", block = "gbc" },
      opleader = { line = "gc", block = "gb" },
      extra = { above = "gcO", below = "gco", eol = "gcA" },

      mappings = { basic = true, extra = true, extended = false },
      -- NO pre_hook here!
    },

    config = function(_, opts)
      -- Now safe to require (dependency is loaded)
      local ts_integration = require("ts_context_commentstring.integrations.comment_nvim")
      opts.pre_hook = ts_integration.create_pre_hook()

      require("Comment").setup(opts)

      local api = require("Comment.api")
      local keymap = vim.keymap.set
      local km_opts = { noremap = true, silent = true }

      -- Your leader mappings
      keymap("n", "<leader>/", api.toggle.linewise.current, vim.tbl_extend("force", km_opts, { desc = "Comment: toggle current line" }))
      keymap("x", "<leader>/", function() api.toggle.linewise(vim.fn.visualmode()) end, vim.tbl_extend("force", km_opts, { desc = "Comment: toggle visual" }))

      keymap("n", "<leader>co", api.insert.linewise.below, vim.tbl_extend("force", km_opts, { desc = "Comment: insert below" }))
      keymap("n", "<leader>cO", api.insert.linewise.above, vim.tbl_extend("force", km_opts, { desc = "Comment: insert above" }))
      keymap("n", "<leader>cA", api.insert.linewise.eol,   vim.tbl_extend("force", km_opts, { desc = "Comment: insert at EOL" }))
    end,
  },
}