return {
  -- Optional: Inline LaTeX math rendering
  "jbyuki/nabla.nvim",

  {
    "MeanderingProgrammer/render-markdown.nvim",
    event = { "BufReadPost *.md", "BufNewFile *.md" },
    cmd = { "RenderMarkdown", "RenderMarkdownToggle" },

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      -- "echasnovski/mini.nvim", -- Optional: styling helper
      -- {
      --   "iamcco/markdown-preview.nvim",
      --   build = function() vim.fn["mkdp#util#install"]() end,
      -- },
    },

    keys = {
      { "<leader>mp", "<cmd>RenderMarkdownToggle<CR>", desc = "Toggle Markdown Preview" },
      { "<leader>mr", "<cmd>RenderMarkdown<CR>", desc = "Render Markdown" },
    },

    opts = {
      default = {
        enable_on_load = true,
        realtime = true,
      },
      appearance = {
        code_blocks = {
          highlight_background = true,
          padding = { top = 1, bottom = 1 },
        },
        headlines = {
          bold = true,
          italic = false,
          underline = false,
        },
      },
      content = {
        collapse_level = 6,
        frontmatter = true,
        checkboxes = true,
      },
      highlights = {
        colors = {
          text = "#FFFFFF",
          background = "#1E1E2E",
          headlines = {
            "#F38BA8", "#FAB387", "#F9E2AF", "#A6E3A1", "#89B4FA", "#CBA6F7",
          },
        },
      },
      window = {
        type = "float",
        float = {
          border = "rounded",
          title = "Markdown Preview",
          title_align = "center",
          margin = { top = 2, bottom = 2, left = 2, right = 2 },
        },
      },
    },

    config = function(_, opts)
      local ok, md = pcall(require, "render-markdown")
      if not ok then
        vim.notify("render-markdown.nvim not found", vim.log.levels.WARN)
        return
      end

      md.setup(opts or {})

      -- Markdown-specific buffer options
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          local set = vim.opt_local
          set.spell = true
          set.spelllang = "en_us"
          set.textwidth = 80
          set.conceallevel = 2
          set.wrap = true
          set.linebreak = true
          vim.keymap.set("n", "j", "gj", { buffer = true })
          vim.keymap.set("n", "k", "gk", { buffer = true })
        end,
      })

      -- Dynamic headline highlights
      local headlines = opts.highlights and opts.highlights.colors and opts.highlights.colors.headlines or {}
      if #headlines > 0 then
        vim.api.nvim_create_autocmd("ColorScheme", {
          group = vim.api.nvim_create_augroup("MarkdownHighlightGroup", { clear = true }),
          callback = function()
            for i, color in ipairs(headlines) do
              vim.api.nvim_set_hl(0, "MarkdownH" .. i, { fg = color, bold = true })
            end
          end,
          desc = "Set headline highlight colors for markdown",
        })
      end
    end,
  },
}
