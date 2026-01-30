return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = { "BufReadPost", "BufNewFile" },

  opts = {
    enable = true,
    multiwindow = true,              -- support splits/windows
    max_lines = 0,                   -- unlimited; controlled by threshold
    min_window_height = 15,          -- higher → less intrusive in small windows
    line_numbers = true,
    multiline_threshold = 4,         -- sweet spot for most
    trim_scope = "outer",
    mode = "topline",                -- ← changed: feels more predictable / popular now
    -- separator = "─",                 -- or try "┃" / nil
    zindex = 20,

    on_attach = function(buf)
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype

      local exclude_fts = {
        "help", "alpha", "dashboard", "neo-tree", "Trouble",
        "lazy", "mason", "TelescopePrompt", "toggleterm", "spectre_panel",
      }
      local exclude_bts = { "terminal", "nofile", "prompt", "quickfix", "notify" }

      if vim.tbl_contains(exclude_fts, ft) or vim.tbl_contains(exclude_bts, bt) then
        return false
      end

      -- Better context visibility when scrolling
      vim.opt_local.scrolloff = 8

      return true
    end,
  },

  config = function(_, opts)
    local ctx = require("treesitter-context")
    ctx.setup(opts)

    -- ── Highlights (easy to override per theme if needed) ────────
    local function set_highlights()
      local c = {
        context_bg = "#1f2430",
        context_fg = "#FFB454",
        linenr_fg   = "#59C2FF",
        sep_fg      = "#B3B1AD",
      }

      vim.api.nvim_set_hl(0, "TreesitterContext",          { bg = c.context_bg, fg = c.context_fg, italic = true })
      vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { bg = c.context_bg, fg = c.linenr_fg })
      vim.api.nvim_set_hl(0, "TreesitterContextSeparator",  { bg = c.context_bg, fg = c.sep_fg })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom",     { underline = true, sp = c.sep_fg })
    end

    set_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("TreesitterContextHl", { clear = true }),
      callback = set_highlights,
      desc = "Refresh Treesitter Context highlights on colorscheme change",
    })

    -- ── Keymaps ──────────────────────────────────────────────────
    local map = function(lhs, rhs, desc, mode)
      vim.keymap.set(mode or "n", lhs, rhs, { desc = desc, silent = true })
    end

    map("[c", function() ctx.go_to_context(vim.v.count1) end, "Jump to Treesitter Context")

    map("<leader>tc", function()
      ctx.toggle()
      local enabled = ctx.enabled()
      vim.notify(
        "Treesitter Context " .. (enabled and "enabled" or "disabled"),
        enabled and vim.log.levels.INFO or vim.log.levels.WARN
      )
    end, "Toggle Treesitter Context")

    map("<leader>tC", function()
      if ctx.enabled() then
        ctx.go_to_context(vim.v.count1)
        vim.cmd("normal! zz")
      else
        vim.notify("Treesitter Context is disabled", vim.log.levels.WARN)
      end
    end, "Jump to Context & Center")

    -- Optional: buffer-local navigation (uncomment if preferred)
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = { "*" }, -- or specific fts
    --   callback = function(ev)
    --     if not vim.bo[ev.buf].modifiable then return end
    --     vim.keymap.set("n", "gC", function() ctx.go_to_context(vim.v.count1) end,
    --       { buffer = ev.buf, desc = "Go to Context", silent = true })
    --   end,
    -- })

    -- Commands
    vim.api.nvim_create_user_command("TSContextRefresh", function()
      ctx.invalidate()
      vim.notify("Treesitter Context refreshed", vim.log.levels.INFO)
    end, { desc = "Refresh Treesitter Context display" })

    vim.api.nvim_create_user_command("CtxRefresh", "TSContextRefresh", { desc = "Alias for TSContextRefresh" })
  end,
}