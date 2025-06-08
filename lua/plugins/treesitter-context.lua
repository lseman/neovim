return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },

  config = function()
    local ctx = require("treesitter-context")

    -- ─── Setup ──────────────────────────────────────────────
    ctx.setup({
      enable = true,
      max_lines = 4,
      min_window_height = 15,
      line_numbers = true,
      multiline_threshold = 3,
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
      zindex = 20,

      patterns = {
        default = {
          "class", "function", "method", "for", "while", "if",
          "switch", "case", "interface", "struct", "enum"
        },
        rust = {
          "impl_item", "struct", "enum", "fn", "mod", "trait", "match_expression"
        },
        typescript = {
          "class_declaration", "interface_declaration", "function_declaration",
          "method_definition", "arrow_function", "function_expression", "export_statement"
        },
        javascript = {
          "function_declaration", "function_expression", "arrow_function",
          "method_definition", "class_declaration", "object_expression"
        },
        lua = {
          "function_declaration", "function_definition", "local_function",
          "if_statement", "for_statement", "while_statement"
        },
        python = {
          "function_definition", "class_definition", "if_statement",
          "for_statement", "while_statement", "with_statement", "try_statement"
        },
        go = {
          "function_declaration", "method_declaration", "type_declaration",
          "if_statement", "for_statement", "switch_statement"
        },
        c = {
          "function_definition", "struct_specifier", "if_statement",
          "for_statement", "while_statement", "switch_statement"
        },
        cpp = {
          "function_definition", "class_specifier", "namespace_definition",
          "if_statement", "for_statement", "while_statement", "switch_statement"
        },
        java = {
          "class_declaration", "interface_declaration", "method_declaration",
          "constructor_declaration", "if_statement", "for_statement", "while_statement"
        },
      },

      on_attach = function(buf)
        vim.opt_local.scrolloff = 5
        vim.keymap.set("n", "gC", function()
          ctx.go_to_context(vim.v.count1)
        end, { buffer = buf, desc = "Go to Treesitter Context", silent = true })
      end,
    })

    -- ─── Highlights ─────────────────────────────────────────
    local function setup_highlights()
      local c = {
        context_bg = "#1f2430",
        context_fg = "#FFB454",
        line_number_fg = "#59C2FF",
        separator_fg = "#B3B1AD",
      }

      vim.api.nvim_set_hl(0, "TreesitterContext", {
        fg = c.context_fg, bg = c.context_bg, italic = true
      })
      vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", {
        fg = c.line_number_fg, bg = c.context_bg
      })
      vim.api.nvim_set_hl(0, "TreesitterContextSeparator", {
        fg = c.separator_fg, bg = c.context_bg
      })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", {
        underline = true, sp = c.separator_fg
      })
    end

    setup_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("TreesitterContextHighlights", { clear = true }),
      callback = setup_highlights,
      desc = "Update Treesitter Context highlights on colorscheme change",
    })

    -- ─── Keymaps ────────────────────────────────────────────
    local function map(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { desc = desc, silent = true, noremap = true })
    end

    map("[c", function()
      ctx.go_to_context(vim.v.count1)
    end, "Go to Treesitter Context")

    map("<leader>tc", function()
      ctx.toggle()
      local status = ctx.enabled and ctx.enabled()
      vim.notify("Treesitter Context " .. (status and "enabled" or "disabled"))
    end, "Toggle Treesitter Context")

    map("<leader>tC", function()
      if ctx.enabled and ctx.enabled() then
        ctx.go_to_context()
        vim.cmd("normal! zz")
      else
        vim.notify("Treesitter Context is disabled", vim.log.levels.WARN)
      end
    end, "Jump to Context and Center")

    vim.api.nvim_create_user_command("TSContextRefresh", function()
      ctx.invalidate()
      vim.notify("Treesitter Context refreshed")
    end, { desc = "Refresh Treesitter Context display" })

    -- ─── Auto-disable for UI/utility buffers ───────────────
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("TreesitterContextAutoDisable", { clear = true }),
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local bt = vim.bo[args.buf].buftype
        local exclude_fts = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" }
        local exclude_bts = { "terminal", "nofile", "quickfix" }

        if vim.tbl_contains(exclude_fts, ft) or vim.tbl_contains(exclude_bts, bt) then
          vim.b[args.buf].treesitter_context_enabled = false
        end
      end,
      desc = "Disable Treesitter Context for non-code buffers",
    })
  end,
}
