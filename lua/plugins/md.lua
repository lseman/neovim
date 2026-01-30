return {
  -- Optional: inline LaTeX math rendering (works in markdown buffers)
  "jbyuki/nabla.nvim",

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    cmd = { "RenderMarkdown", "RenderMarkdownToggle" },

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      -- "echasnovski/mini.nvim", -- Optional styling helper
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
        -- IMPORTANT: don't auto-enable for all markdown, since jupytext/quarto notebook markdown
        -- should behave like "code" buffers for Molten, not like prose docs.
        enable_on_load = false,
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
            "#F38BA8",
            "#FAB387",
            "#F9E2AF",
            "#A6E3A1",
            "#89B4FA",
            "#CBA6F7",
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

      -- Detect jupytext/quarto notebook markdown buffers (YAML frontmatter w/ jupytext/jupyter keys)
      local function is_jupytext_notebook(bufnr)
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local n = math.min(160, line_count)
        if n <= 0 then return false end

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, n, false)
        if #lines == 0 then return false end

        -- Must start with YAML frontmatter
        if not (lines[1] or ""):match("^%s*%-%-%-%s*$") then
          return false
        end

        local text = table.concat(lines, "\n")
        -- jupytext frontmatter often includes either top-level `jupytext:` or `jupyter:`
        if text:match("\njupytext:%s*\n") or text:match("\njupyter:%s*\n") then
          return true
        end
        return false
      end

      -- Markdown-specific buffer options — but SKIP jupytext notebook markdown
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("RenderMarkdownBufferOpts", { clear = true }),
        pattern = "markdown",
        callback = function(ev)
          if is_jupytext_notebook(ev.buf) then
            -- Notebook markdown should behave like a code buffer for Molten; don't force prose UX.
            -- You can still toggle preview manually with <leader>mp.
            vim.opt_local.spell = false
            vim.opt_local.conceallevel = 0
            return
          end

          local set = vim.opt_local
          set.spell = true
          set.spelllang = "en_us"
          set.textwidth = 80
          set.conceallevel = 2
          set.wrap = true
          set.linebreak = true
          vim.keymap.set("n", "j", "gj", { buffer = ev.buf })
          vim.keymap.set("n", "k", "gk", { buffer = ev.buf })
        end,
        desc = "Markdown buffer UX (skip jupytext notebook markdown)",
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
