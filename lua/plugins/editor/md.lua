return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto", "qmd", "python", "ipynb" },
    cmd = { "RenderMarkdown", "RenderMarkdownToggle" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },

    keys = {
      {
        "<leader>mp",
        "<cmd>RenderMarkdown toggle<CR>",
        desc = "Toggle Markdown render",
      },
    },

    opts = {
      -- Normal notes/docs render automatically. Notebook-flavoured markdown
      -- can also be rendered in markdown/quarto/qmd/python/ipynb buffers.
      enabled = true,
      file_types = { "markdown", "quarto", "qmd", "python", "ipynb" },
      render_modes = { "n", "c" }, -- render in normal + command mode only (not insert)
      latex = {
        enabled = true,
        -- Better converters (try in this order)
        converter = { "latex2text" }, -- ← Change this
        -- converter = "latex2text",              -- or just one
        position = "center", -- or "above" / "below" / "center"
        top_pad = 0,
        bottom_pad = 0,
      },
      ignore = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft ~= "python" then
          return false
        end

        local name = vim.api.nvim_buf_get_name(bufnr)
        if name:match "%.ipynb$" or name:match "%.py$" then
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 80, false)
          for _, line in ipairs(lines) do
            if line:match "^# %%%%" then
              return false
            end
          end
        end

        return true
      end,
      injections = {
        gitcommit = {
          enabled = true,
          query = [[
                    ((message) @injection.content
                        (#set! injection.combined)
                        (#set! injection.include-children)
                        (#set! injection.language "markdown"))
                ]],
        },
        python = {
          enabled = true,
          query = [[
                    ((comment) @injection.content
                        (#set! injection.combined)
                        (#set! injection.include-children)
                        (#set! injection.language "markdown"))
                ]],
        },
      },
      anti_conceal = {
        enabled = true, -- reveal raw syntax on the cursor line while editing
      },

      -- ── Headings ──────────────────────────────────────────────────────
      heading = {
        enabled = true,
        sign = false,
        position = "overlay",
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        width = { "full", "full", "block", "block", "block", "block" },
        left_pad = 0,
        right_pad = 4,
        border = false,
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },

      -- ── Code blocks ───────────────────────────────────────────────────
      code = {
        enabled = true,
        sign = false,
        style = "full",
        position = "left",
        language_icon = true,
        language_name = true,
        width = "block",
        left_pad = 2,
        right_pad = 4,
        min_width = 45,
        border = "thin",
        inline = true,
        inline_pad = 1,
      },

      -- ── Bullets ───────────────────────────────────────────────────────
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        left_pad = 0,
        right_pad = 1,
      },

      -- ── Checkboxes ────────────────────────────────────────────────────
      checkbox = {
        enabled = true,
        unchecked = {
          icon = "󰄱 ",
          highlight = "RenderMarkdownUnchecked",
        },
        checked = {
          icon = "󰱒 ",
          highlight = "RenderMarkdownChecked",
        },
        custom = {
          todo = {
            raw = "[-]",
            rendered = "󰥔 ",
            highlight = "RenderMarkdownTodo",
          },
        },
      },

      -- ── Tables ────────────────────────────────────────────────────────
      pipe_table = {
        enabled = true,
        preset = "round",
        style = "full",
        cell = "padded",
      },

      -- ── Block quotes & callouts ───────────────────────────────────────
      quote = {
        enabled = true,
        icon = "▋",
        repeat_linebreak = true,
      },

      -- callout defaults are already comprehensive (NOTE/TIP/WARNING/etc.) — inherit them

      -- ── Horizontal rules ──────────────────────────────────────────────
      dash = {
        enabled = true,
        icon = "─",
        width = "full",
      },

      -- ── Links ─────────────────────────────────────────────────────────
      link = {
        enabled = true,
        footnote = {
          superscript = true,
        },
        image = "󰥶 ",
        email = "󰀓 ",
        hyperlink = "󰌹 ",
      },

      -- ── Inline highlights (==text== syntax) ───────────────────────────
      inline_highlight = {
        enabled = true,
      },

      -- ── No sign column clutter ────────────────────────────────────────
      sign = {
        enabled = false,
      },

      -- ── blink.cmp completions for callouts/checkboxes ─────────────────
      completions = {
        blink = {
          enabled = true,
        },
      },
    },

    config = function(_, opts)
      require("render-markdown").setup(opts)

      vim.api.nvim_create_user_command("RenderMarkdownToggle", function()
        vim.cmd "RenderMarkdown toggle"
      end, {
        nargs = 0,
        desc = "Toggle RenderMarkdown",
      })

      -- Detect jupytext/quarto notebook markdown (YAML frontmatter with jupytext/jupyter keys)
      local function is_jupytext_notebook(bufnr)
        local n = math.min(160, vim.api.nvim_buf_line_count(bufnr))
        if n <= 0 then
          return false
        end
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, n, false)
        if not (lines[1] or ""):match "^%s*%-%-%-%s*$" then
          return false
        end
        local text = table.concat(lines, "\n")
        return text:match "\njupytext:%s*\n" ~= nil or text:match "\njupyter:%s*\n" ~= nil
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("RenderMarkdownBufferOpts", {
          clear = true,
        }),
        pattern = { "markdown", "quarto", "qmd" },
        callback = function(ev)
          local set = vim.opt_local
          set.spell = true
          set.spelllang = "en_us"
          set.textwidth = 80
          set.conceallevel = 2
          set.wrap = true
          set.linebreak = true
          require("render-markdown").buf_enable()
          vim.keymap.set("n", "j", "gj", {
            buffer = ev.buf,
          })
          vim.keymap.set("n", "k", "gk", {
            buffer = ev.buf,
          })
        end,
        desc = "Markdown buffer UX",
      })
    end,
  },
}
