return {
  "jmbuhr/otter.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",

    -- Optional but very useful:
    { "hrsh7th/nvim-cmp",      optional = true }, -- completions inside code blocks
    { "neovim/nvim-lspconfig", optional = true }, -- LSP features in injected code
  },

  ft = { "markdown", "quarto", "rmd", "qmd" },  -- lazy-load only for these filetypes

  opts = {
    -- Which languages otter should recognize inside fenced code blocks
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
      -- "latex", "html", "css", "json", ... → add as needed
    },

    -- Behavior tweaks
    handle_leading_whitespace = true,
    strip_wrapping_quote_characters = { "'", '"', "`" },
    remove_extra_blank_lines = true,

    -- Performance / debug
    debug = false,
  },

  config = function(_, opts)
    local otter = require("otter")

    -- Activate otter with your preferred settings
    otter.activate(opts.languages, true, true)  -- true = auto-activate, true = treesitter injections

    -- ── Useful keymaps ───────────────────────────────────────────────────────
    local map = vim.keymap.set
    local opts_key = { noremap = true, silent = true }

    map("n", "<leader>oo", function()
      otter.activate()
      vim.notify("Otter activated", vim.log.levels.INFO)
    end, vim.tbl_extend("force", opts_key, { desc = "Otter: Activate" }))

    map("n", "<leader>od", function()
      otter.deactivate()
      vim.notify("Otter deactivated", vim.log.levels.INFO)
    end, vim.tbl_extend("force", opts_key, { desc = "Otter: Deactivate" }))

    map("n", "<leader>or", function()
      otter.activate()
      otter.sync_raft()
      vim.notify("Otter refreshed", vim.log.levels.INFO)
    end, vim.tbl_extend("force", opts_key, { desc = "Otter: Refresh / Sync" }))

    -- Debug toggle (handy when troubleshooting)
    map("n", "<leader>odbg", function()
      opts.debug = not opts.debug
      otter.activate(opts.languages, true, true)
      vim.notify("Otter debug: " .. (opts.debug and "ON" or "OFF"), vim.log.levels.INFO)
    end, vim.tbl_extend("force", opts_key, { desc = "Otter: Toggle Debug" }))

    -- ── Auto-activate on relevant filetypes ─────────────────────────────────
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto", "rmd", "qmd" },
      group = vim.api.nvim_create_augroup("OtterAutoActivate", { clear = true }),
      callback = function()
        vim.defer_fn(function()
          -- Only activate if buffer is still valid and filetype matches
          if vim.api.nvim_buf_is_valid(0) and
             vim.bo.filetype:match("markdown|quarto|rmd|qmd") then
            otter.activate(opts.languages, true, true)
          end
        end, 80)  -- small delay to let treesitter settle
      end,
    })

    -- ── Keep otter in sync when writing / changing text ─────────────────────
    vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "TextChangedI" }, {
      pattern = { "*.md", "*.qmd", "*.rmd", "*.quarto" },
      group = vim.api.nvim_create_augroup("OtterAutoSync", { clear = true }),
      callback = function()
        if otter.is_active() then
          vim.defer_fn(otter.sync_raft, 150)
        end
      end,
    })
  end,
}