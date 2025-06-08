return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },

  opts = {
    padding = true,
    sticky = true,
    ignore = "^%s*$",
    toggler = {
      line = "gcc",
      block = "gbc",
    },
    opleader = {
      line = "gc",
      block = "gb",
    },
    extra = {
      above = "gcO",
      below = "gco",
      eol = "gcA",
    },
    mappings = {
      basic = true,
      extra = true,
      extended = false,
    },

    --- Integrate ts-context-commentstring
    pre_hook = function(ctx)
      local ok, utils = pcall(require, "Comment.utils")
      local ok_ts, ts_utils = pcall(require, "ts_context_commentstring.utils")
      local ok_internal, ts_internal = pcall(require, "ts_context_commentstring.internal")
      if not (ok and ok_ts and ok_internal) then return end

      local location
      if ctx.ctype == utils.ctype.block then
        location = ts_utils.get_cursor_location()
      elseif ctx.cmotion == utils.cmotion.v or ctx.cmotion == utils.cmotion.V then
        location = ts_utils.get_visual_start_location()
      end

      return ts_internal.calculate_commentstring({ location = location })
    end,
  },

  config = function(_, opts)
    local comment = require("Comment")
    local api = require("Comment.api")
    comment.setup(opts)

    --- Custom keybindings
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    keymap("n", "<leader>/", api.toggle.linewise.current, vim.tbl_extend("force", opts, { desc = "Toggle comment (line)" }))
    keymap("v", "<leader>/", function() api.toggle.linewise(vim.fn.visualmode()) end,
      vim.tbl_extend("force", opts, { desc = "Toggle comment (visual)" }))

    keymap("n", "<leader>co", api.insert.linewise.below, vim.tbl_extend("force", opts, { desc = "Comment below" }))
    keymap("n", "<leader>cO", api.insert.linewise.above, vim.tbl_extend("force", opts, { desc = "Comment above" }))
    keymap("n", "<leader>cA", api.insert.linewise.eol,   vim.tbl_extend("force", opts, { desc = "Comment end of line" }))
  end,
}
