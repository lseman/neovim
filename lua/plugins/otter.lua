return {
  "jmbuhr/otter.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    -- Optional but strongly recommended:
    { "hrsh7th/nvim-cmp", optional = true },           -- for completions inside code blocks
    { "neovim/nvim-lspconfig", optional = true },      -- for LSP diagnostics & go-to-definition
  },

  opts = {
    -- Which languages should be treated as code blocks inside markdown/quarto
    handle_leading_whitespace = true,

    -- Which languages otter should look for
    languages = {
      "python",
      "lua",
      "rust",
      "cpp",
      "c",
      "go",
      "javascript",
      "typescript",
      "bash",
      "fish",
      "sh",
      "r",
      "julia",
      -- add more as needed
    },

    -- Controls when otter activates
    strip_wrapping_quote_characters = { "'", '"', "`" },

    -- Whether to remove extra blank lines inside code blocks
    remove_extra_blank_lines = true,

    -- Debug level (set to true during setup if things don't work)
    debug = false,
  },

  config = function(_, opts)
    require("otter").activate(opts.languages, true, true)  -- auto-activate + treesitter injections

    -- Optional: keymaps (very useful in practice)
    vim.keymap.set("n", "<leader>oo", function()
      require("otter").activate()
      vim.notify("Otter activated", vim.log.levels.INFO)
    end, { desc = "Activate Otter" })

    vim.keymap.set("n", "<leader>od", function()
      require("otter").deactivate()
      vim.notify("Otter deactivated", vim.log.levels.INFO)
    end, { desc = "Deactivate Otter" })

    vim.keymap.set("n", "<leader>or", function()
      require("otter").activate()
      require("otter").sync_raft()
      vim.notify("Otter synced", vim.log.levels.INFO)
    end, { desc = "Refresh Otter" })

    -- Optional: auto-activate in markdown/quarto files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto", "rmd" },
      callback = function()
        vim.defer_fn(function()
          if vim.bo.filetype == "markdown" or vim.bo.filetype == "quarto" then
            require("otter").activate()
          end
        end, 100)
      end,
    })
  end,
}