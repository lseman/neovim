return {
  -- 1) Molten
  {
    "benlubas/molten-nvim",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_auto_close_output = false
      vim.g.molten_output_win_max_height = 0.4
      vim.g.molten_output_win_border = "rounded"

      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_screen = false
      vim.g.molten_virt_text_max_lines = 12
      vim.g.molten_wrap_output = true

      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_auto_image_popup = true
      vim.g.molten_image_location = "both"
      vim.g.molten_output_virt_lines = true
      -- vim.g.molten_output_show_more = true
      -- vim.g.molten_use_border_highlights = false
      -- vim.g.molten_virt_lines_on_init_behavior = "split"

      -- Polling responsiveness
      vim.g.molten_tick_rate = 150

      vim.g.molten_copy_output = false
      vim.g.molten_enter_output_behavior = "open_then_enter"

      -- (Optional) nicer default highlight groups if you theme supports it
      -- vim.g.molten_output_win_border = "single"
    end,
    keys = {
      { "<localleader>mi", "<cmd>MoltenInit<CR>", desc = "Molten Init (select kernel)" },
      { "<localleader>ml", "<cmd>MoltenEvaluateLine<CR>", desc = "Evaluate current line" },
      { "<localleader>mo", "<cmd>MoltenShowOutput<CR>", desc = "Show/enter output window" },
      { "<localleader>mh", "<cmd>MoltenHideOutput<CR>", desc = "Hide output window" },
      { "<localleader>md", "<cmd>MoltenDelete<CR>", desc = "Delete current cell output" },
      { "<localleader>mr", "<cmd>MoltenReevaluateCell<CR>", desc = "Re-evaluate cell" },
      { "<localleader>mc", "<cmd>MoltenEvaluateVisual<CR>", mode = "v", desc = "Evaluate visual selection" },
      { "<localleader>ms", "<cmd>MoltenSave<CR>", desc = "Save notebook state" },
      { "<localleader>mL", "<cmd>MoltenLoad<CR>", desc = "Load notebook state" },

      -- Recommended: run “current cell” via your function (set this if you want)
      -- { "<localleader>mm", function() RunCurrentCell() end, desc = "Run current cell" },
    },
  },

  -- 2) image.nvim
  {
    "3rd/image.nvim",
    lazy = true,
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          -- When jupytext writes markdown notebooks, these often appear as markdown/quarto
          filetypes = { "markdown", "quarto", "vimwiki" },
        },
      },
      max_width = 400,
      max_height = 48,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = false,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg" },
    },
  },
}
