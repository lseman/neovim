return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    -- Snippets
    {
      "L3MON4D3/LuaSnip",
      build = "make install_jsregexp",
      dependencies = {
        "rafamadriz/friendly-snippets",
        "honza/vim-snippets",
      },
      opts = {
        history = true,
        updateevents = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged,InsertLeave",
        enable_autosnippets = true,
        region_check_events = "CursorMoved",
      },
      config = function(_, opts)
        local ls = require("luasnip")
        ls.setup(opts)
        require("luasnip.loaders.from_vscode").lazy_load()
        pcall(require, "config.luasnip")

        vim.keymap.set({ "i", "s" }, "<C-k>", function()
          if ls.expand_or_jumpable() then ls.expand_or_jump() end
        end, { silent = true, desc = "Expand or jump snippet" })

        vim.keymap.set({ "i", "s" }, "<C-j>", function()
          if ls.jumpable(-1) then ls.jump(-1) end
        end, { silent = true, desc = "Jump back in snippet" })
      end,
    },

    -- Autopairs (configured in its own spec)
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = [[[%'%"%)%>%]%)%}%,] ]],
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "PmenuSel",
          highlight_grey = "LineNr",
        },
        disable_filetype = {
          "TelescopePrompt", "vim", "spectre_panel", "dap-repl", "guihua", "guihua_rust",
        },
        enable_moveright = true,
        enable_afterquote = true,
        enable_check_bracket_line = true,
        enable_bracket_in_quote = true,
        break_undo = true,
        map_cr = true,
        map_bs = true,
        map_c_h = false,
        map_c_w = false,
        disable_in_macro = true,
        disable_in_visualblock = false,
        disable_in_replace_mode = true,
        enable_abbr = false,
      },
      config = function(_, opts)
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")
        local cond = require("nvim-autopairs.conds")
        npairs.setup(opts)
        npairs.add_rules({
          Rule("f'", "'", "python"):with_pair(cond.before_regex("%a+")),
          Rule('f"', '"', "python"):with_pair(cond.before_regex("%a+")),
          Rule("```", "```", "markdown"):with_cr(cond.none()),
          Rule("$", "$", "tex"):with_pair(cond.not_after_regex("%%")),
        })
      end,
    },

    -- Sources
    { "saadparwaiz1/cmp_luasnip", priority = 1000 },
    { "hrsh7th/cmp-nvim-lsp", priority = 1000 },
    { "hrsh7th/cmp-nvim-lsp-signature-help", priority = 900 },
    { "hrsh7th/cmp-buffer", priority = 500 },
    { "hrsh7th/cmp-path", priority = 750 },
    { "hrsh7th/cmp-calc", priority = 300 },
    { "hrsh7th/cmp-cmdline" },     -- you were calling cmdline without this
    { "hrsh7th/cmp-emoji" },       -- you listed emoji source
    { "f3fora/cmp-spell" },        -- you listed spell source
  },

  config = function()
    local cmp = require("cmp")
    local ls = require("luasnip")
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")

    -- Super Tab helpers
    local function has_words_before()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      if col == 0 then return false end
      local prev = vim.api.nvim_buf_get_text(0, line - 1, col - 1, line - 1, col, {})[1]
      return prev and not prev:match("%s")
    end

    local icons = {
      Text = "", Method = "󰆧", Function = "󰊕", Field = "󰇽", Variable = "󰂡",
      Class = "󰠱", Property = "󰜢", Value = "󰎠", Keyword = "󰌋", Color = "󰏘",
      File = "󰈙", Folder = "󰉋", Constant = "󰏿", Operator = "󰆕", TypeParameter = "󰅲",
    }

    local source_labels = {
      nvim_lsp = "[LSP]", nvim_lsp_signature_help = "[Sig]",
      luasnip = "[Snip]", path = "[Path]", buffer = "[Buf]",
      calc = "[Calc]", emoji = "[Emoji]", spell = "[Spell]",
    }

    cmp.setup({
      snippet = {
        expand = function(args) ls.lsp_expand(args.body) end,
      },
      completion = {
        completeopt = "menu,menuone,noinsert",
        keyword_length = 1,
        max_item_count = 20,
      },
      confirmation = {
        behavior = cmp.ConfirmBehavior.Replace,
        get_commit_characters = function(chars)
          return vim.tbl_filter(function(c) return c ~= " " end, chars)
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping(function(fb)
          if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fb()
          end
        end, { "i", "s", "c" }),

        -- -- Super Tab: cmp -> snippet jump -> insert tab
        -- ["<Tab>"] = cmp.mapping(function(fb)
        --   if cmp.visible() then
        --     cmp.select_next_item()
        --   elseif ls.expand_or_jumpable() then
        --     ls.expand_or_jump()
        --   elseif has_words_before() then
        --     cmp.complete()
        --   else
        --     fb()
        --   end
        -- end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fb)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif ls.jumpable(-1) then
            ls.jump(-1)
          else
            fb()
          end
        end, { "i", "s" }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "nvim_lsp_signature_help", priority = 850 },
        { name = "luasnip", priority = 750 },
        { name = "path", priority = 600 },
      }, {
        { name = "buffer", priority = 350, keyword_length = 3 },
        { name = "calc", priority = 200 },
        { name = "emoji", priority = 120 },
        { name = "spell", priority = 80, keyword_length = 4, option = { keep_all_entries = false } },
      }),

      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          vim_item.kind = string.format("%s %s", icons[vim_item.kind] or "", vim_item.kind)
          vim_item.menu = source_labels[entry.source.name] or ("[" .. entry.source.name .. "]")
          if #vim_item.abbr > 40 then
            vim_item.abbr = vim_item.abbr:sub(1, 37) .. "..."
          end
          return vim_item
        end,
      },

      window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel",
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:CmpDoc",
        }),
      },

      performance = {
        debounce = 60,
        throttle = 30,
        fetching_timeout = 500,
        confirm_resolve_timeout = 80,
        async_budget = 1,
        max_view_entries = 200,
      },

      experimental = {
        ghost_text = { hl_group = "CmpGhostText" },
      },
    })

    -- Optional user overrides
    local ok, user_config = pcall(require, "config.cmp")
    if ok and type(user_config) == "table" then
      cmp.setup(vim.tbl_deep_extend("force", {}, user_config))
    end

    -- Hook autopairs on confirm (don’t re-run npairs.setup here)
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

    -- Cmdline completion (requires cmp-cmdline)
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
    })

    -- Filetype-specific tweaks
    cmp.setup.filetype("gitcommit", {
      sources = cmp.config.sources({ { name = "buffer", keyword_length = 3 }, { name = "spell", keyword_length = 4 } }),
    })
    cmp.setup.filetype("markdown", {
      sources = cmp.config.sources({
        { name = "spell", keyword_length = 4 },
        { name = "buffer", keyword_length = 3 },
        { name = "path" },
        { name = "emoji" },
      }),
    })

    -- Cleanup snippets on insert leave
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = vim.api.nvim_create_augroup("LuaSnipCleanup", { clear = true }),
      desc = "Clean up snippet session on insert leave",
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        if ls.session.current_nodes[buf] and not ls.session.jump_active then
          ls.unlink_current()
        end
      end,
    })

    -- Highlights
    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "CmpSel", { bg = "#4C566A", fg = "NONE" })
    vim.api.nvim_set_hl(0, "CmpDoc", { bg = "NONE" })
  end,
}
