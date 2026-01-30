return {
  "karb94/neoscroll.nvim",
  event = { "BufReadPost", "BufNewFile" },

  opts = {
    -- Core behavior
    hide_cursor = true,                    -- most users prefer this now
    stop_eof = true,
    respect_scrolloff = true,
    cursor_scrolls_alone = true,

    -- Easing — "cubic" or "circular" often feel smoother in 2025+
    easing_function = "cubic",

    -- Performance & redraw
    performance_mode = false,
    ignored_events = {
      "WinScrolled",
      "CursorMoved",
      "CursorMovedI",
      "TextChanged",
      "TextChangedI",
    },

    -- Mappings (explicitly exclude page keys)
    mappings = {
      "<C-u>", "<C-d>",
      "<C-e>", "<C-y>",     -- optional: line scroll
      "zt", "zz", "zb",
      -- Do NOT include: "<C-f>", "<C-b>", "<C-d>", "<C-u>" if you want vanilla page behavior
    },

    -- Hooks (disable cursorline during scroll to reduce flicker)
    pre_hook = function()
      vim.opt_local.cursorline = false
    end,
    post_hook = function()
      vim.opt_local.cursorline = true
    end,

    -- Multiplier (1.0 = default speed)
    duration_multiplier = 1.0,
  },

  config = function(_, opts)
    local neoscroll = require("neoscroll")

    neoscroll.setup(opts)

    -- ── Buffer-local performance / disable tweaks ────────────────────────
    local augroup = vim.api.nvim_create_augroup("NeoscrollTweaks", { clear = true })

    -- Enable performance mode in heavy UI buffers
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = {
        "toggleterm", "lazyterm", "terminal",
        "dashboard", "alpha", "starter", "mini.starter",
        "lazy", "mason", "lspinfo", "null-ls-info",
      },
      callback = function()
        vim.b.neoscroll_performance_mode = true
      end,
    })

    -- Completely disable in floating/prompt buffers
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = {
        "TelescopePrompt", "TelescopeResults",
        "neo-tree", "neo-tree-popup", "NeogitStatus",
        "Trouble", "qf", "OverseerList", "spectre_panel",
        "WhichKey", "noice", "notify", "DressingInput", "DressingSelect",
      },
      callback = function()
        vim.b.neoscroll_disable = true
      end,
    })

    -- Optional: disable in very large files (> 15k lines)
    vim.api.nvim_create_autocmd("BufRead", {
      group = augroup,
      callback = function(args)
        vim.schedule(function()
          if vim.api.nvim_buf_line_count(args.buf) > 15000 then
            vim.b[args.buf].neoscroll_performance_mode = true
          end
        end)
      end,
    })
  end,
}