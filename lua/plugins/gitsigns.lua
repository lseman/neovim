return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "│" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    signcolumn = true,   -- toggle with :Gitsigns toggle_signs
    numhl      = false,
    linehl     = false,
    word_diff  = false,
    watch_gitdir = { interval = 1000, follow_files = true },
    attach_to_untracked = true,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",          -- 'eol' | 'overlay' | 'right_align'
      delay = 500,
      ignore_whitespace = true,
      virt_text_priority = 100,
    },
current_line_blame_formatter = function(name, info)
  -- name = author name
  -- info = table with: author_mail, author_time (seconds since epoch), abbrev_sha, summary, etc.

  local time_str = os.date("%Y-%m-%d %H:%M", info.author_time)   -- or "%R" for relative time like "2 hours ago"

  return {
    { name .. ", ",                       "GitSignsCurrentLineBlameAuthor" },   -- or just "Comment"
    { time_str .. " - ",                  "GitSignsCurrentLineBlameTime"   },
    { info.abbrev_sha .. " - ",           "GitSignsCurrentLineBlameSha"    },
    { info.summary or "(no message)",     "GitSignsCurrentLineBlameSummary"},
  }
end,
    -- or keep your original string formatter if you prefer
    -- current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d %H:%M> - <abbrev_sha> - <summary>",

    sign_priority = 6,
    update_debounce = 100,
    max_file_length = 40000,
    preview_config = {
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
      width = 80,   -- or 0.8 for relative width
    },

    -- Optional: better statusline component (many use this in lualine)
    -- You can remove or keep — depends if you have a custom statusline
    -- _signs_by_lnum = {},  -- internal

    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Gitsigns: " .. desc })
      end

      -- Navigation (smart: skips when in diff mode)
      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(gs.next_hunk)
        return "<Ignore>"
      end, "Next Hunk")

      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(gs.prev_hunk)
        return "<Ignore>"
      end, "Prev Hunk")

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
      map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Selection")
      map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Selection")

      map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")

      map("n", "<leader>hp", gs.preview_hunk_inline, "Preview Hunk Inline")   -- ← many prefer inline in 2025+
      -- or gs.preview_hunk() for classic popup

      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line (full)")
      map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Line Blame")

      map("n", "<leader>hd", gs.diffthis, "Diff This")
      map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff This ~")

      map("n", "<leader>td", gs.toggle_deleted, "Toggle Show Deleted")

      -- Text object (very useful)
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Hunk")

      -- Optional extras many people add
      -- map("n", "<leader>hB", function() gs.blame_line({ full = true, ignore_whitespace = true }) end, "Blame Line (ignore ws)")
      -- map("n", "]d", gs.next_changed_hunk, "Next Changed Hunk")  -- if you want separate from ]c
    end,
  },

  config = function(_, opts)
    require("gitsigns").setup(opts)

    -- Optional highlight overrides (many themes handle this now, but good fallback)
    vim.api.nvim_set_hl(0, "GitSignsAdd",    { fg = "#00ff00", bold = true })
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#ffff00", bold = true })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ff0000", bold = true })
    -- You can also link to existing groups: vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "diffAdded" })
  end,
}