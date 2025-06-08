return {
  "karb94/neoscroll.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local neoscroll = require("neoscroll")

    -- Setup Neoscroll with tuned settings
    neoscroll.setup({
      performance_mode = false,
      hide_cursor = false,
      stop_eof = true,
      respect_scrolloff = true,
      cursor_scrolls_alone = true,
      easing_function = "quadratic",

      pre_hook = function()
        vim.wo.cursorline = false
      end,
      post_hook = function()
        vim.wo.cursorline = true
      end,

      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },
      duration_multiplier = 1.0,

      ignored_events = {
        "WinScrolled",
        "CursorMoved",
        "TextChanged",
        "TextChangedI",
      },
    })

    -- ── Autocommand Group Setup ────────────────────────────────
    local augroup = vim.api.nvim_create_augroup("NeoscrollConfig", { clear = true })

    -- Enable performance mode for lightweight UIs
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = { "toggleterm", "dashboard", "alpha", "lazy", "mason" },
      callback = function()
        vim.b.neoscroll_performance_mode = true
      end,
    })

    -- Disable Neoscroll where animations disrupt UX
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = { "TelescopePrompt", "neo-tree", "Trouble", "qf" },
      callback = function()
        vim.b.neoscroll_disable = true
      end,
    })
  end,
}
