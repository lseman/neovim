-- plugins/scroll.lua  (or wherever you keep it)
return {
  "karb94/neoscroll.nvim",
  event = { "BufReadPost", "BufNewFile" },  -- or "WinScrolled" for even lazier
  opts = {
    -- Core
    hide_cursor = true,              -- Hide cursor during scroll (most prefer this)
    stop_eof = true,                 -- Don't scroll past EOF
    respect_scrolloff = true,        -- Respect 'scrolloff' setting
    cursor_scrolls_alone = true,     -- Cursor moves independently in some cases

    -- Easing: "cubic" feels natural & smooth in 2025/2026 setups
    easing_function = "cubic",

    -- Performance
    performance_mode = false,        -- Global default off; we toggle per-buffer
    ignored_events = {               -- Prevent redraw spam
      "WinScrolled",
      "CursorMoved",
      "CursorMovedI",
      "TextChanged",
      "TextChangedI",
    },

    -- Mappings: only half-page/line + z- commands (no full-page jumps)
    mappings = {
      "<C-u>", "<C-d>",
      "<C-y>",            -- line-wise (optional but nice)
      "zt", "zz", "zb",
    },

    -- Flicker reduction: disable cursorline while scrolling
    pre_hook = function()
      vim.opt_local.cursorline = false
    end,
    post_hook = function()
      vim.opt_local.cursorline = true
    end,

    -- Speed tweak (lower = faster, higher = slower/more pronounced)
    duration_multiplier = 1.0,
  },

  config = function(_, opts)
    local neoscroll = require("neoscroll")
    neoscroll.setup(opts)

    -- ── Buffer-local smart tweaks ───────────────────────────────────────
    local augroup = vim.api.nvim_create_augroup("NeoscrollCustom", { clear = true })

    -- Enable performance mode (disables syntax hl during scroll) in heavy buffers
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = {
        "toggleterm", "terminal", "lazyterm",
        "dashboard", "alpha", "starter", "mini.starter",
        "lazy", "mason", "lspinfo",
      },
      callback = function()
        vim.b.neoscroll_performance_mode = true
      end,
    })

    -- Fully disable in interactive/float/prompt buffers (prevents glitches)
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = {
        "TelescopePrompt", "TelescopeResults",
        "neo-tree", "neo-tree-popup",
        "NeogitStatus", "Trouble", "qf",
        "OverseerList", "spectre_panel",
        "WhichKey", "noice", "notify",
        "DressingInput", "DressingSelect",
      },
      callback = function()
        vim.b.neoscroll_disable = true
      end,
    })

    -- Auto-disable perf mode in huge files (>15k lines)
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