return {
  "onsails/lspkind-nvim",
  lazy = true,
  event = "InsertEnter",
  dependencies = { "hrsh7th/nvim-cmp" },

  config = function()
    local lspkind = require("lspkind")

    -- Symbol and source icons
    local symbol_map = {
      Text = "󰉿", Method = "󰆧", Function = "󰊕", Field = "󰜢", Variable = "󰀫",
      Class = "󰠱", Property = "󰜢", Unit = "󰑭", Value = "󰎠", Keyword = "󰌋",
      Snippet = "󰘍", Color = "󰏘", File = "󰈙", Reference = "󰈇", Folder = "󰉋",
      Constant = "󰏿", Struct = "󰙅", Operator = "󰆕", Boolean = "󰨙",
      Array = "󰅪", Number = "󰎠", String = "󰀬", Package = "󰏗", Object = "󰅩",
      Key = "󰌋", Null = "󰟢", Calendar = "󰃭", Watch = "󰥔", Terminal = "󰞷",
      Component = "󰡀", Fragment = "󰅴", Copilot = "", TabNine = "󰏚",
      GitCommit = "󰊢",
    }

    local source_names = {
      nvim_lsp = "󰒋 LSP", buffer = "󰦨 Buffer", path = "󰉋 Path",
      luasnip = " Snip", emoji = "󰞅 Emoji", calc = "󰃬 Calc",
      spell = "󰓆 Spell", copilot = " Copilot", cmp_tabnine = "󰏚 TabNine",
      treesitter = " TreeSitter", npm = "󰡘 NPM", latex_symbols = "󰊄 LaTeX",
    }

    -- Init lspkind
    lspkind.init({
      mode = "symbol_text",
      preset = "codicons",
      symbol_map = symbol_map,
      format = function(entry, item)
        local kind_icon = symbol_map[item.kind] or ""
        local source = source_names[entry.source.name] or entry.source.name or ""
        item.kind = kind_icon
        item.menu = (" %s "):format(source)

        local max_width = 50
        local abbr = item.abbr or ""
        local total = #abbr + #item.menu + #kind_icon
        if total > max_width then
          item.abbr = vim.fn.strcharpart(abbr, 0, max_width - #item.menu - #kind_icon - 3) .. "..."
        end

        -- Highlight group for special sources
        if entry.source.name == "copilot" then
          item.kind_hl_group = "CmpItemKindCopilot"
        elseif entry.source.name == "cmp_tabnine" then
          item.kind_hl_group = "CmpItemKindTabNine"
        end

        return item
      end,
    })

    -- Completion popup styling
    vim.opt.completeopt = { "menu", "menuone", "noselect", "preview" }
    vim.opt.pumheight = 15
    vim.opt.pumwidth = 15
    vim.opt.pumblend = 10

    -- Themed highlight groups
    local function setup_highlights()
      local highlights = {
        CmpItemAbbrDeprecated = { strikethrough = true, fg = "#7C7C7C" },
        CmpItemAbbrMatch       = { bold = true, fg = "#82AAFF" },
        CmpItemAbbrMatchFuzzy  = { bold = true, fg = "#82AAFF" },
        CmpItemKindFunction    = { fg = "#C586C0" },
        CmpItemKindMethod      = { fg = "#C586C0" },
        CmpItemKindVariable    = { fg = "#9CDCFE" },
        CmpItemKindText        = { fg = "#9CDCFE" },
        CmpItemKindKeyword     = { fg = "#D4D4D4" },
        CmpItemKindProperty    = { fg = "#D4D4D4" },
        CmpItemKindField       = { fg = "#82B1FF" },
        CmpItemKindConstant    = { fg = "#4FC1FF" },
        CmpItemKindEnum        = { fg = "#4EC9B0" },
        CmpItemKindStruct      = { fg = "#4EC9B0" },
        CmpItemKindClass       = { fg = "#4EC9B0" },
        CmpItemKindSnippet     = { fg = "#F78C6C" },
        CmpItemKindCopilot     = { fg = "#6CC644" },
        CmpItemKindTabNine     = { fg = "#CA42F0" },
        CmpItemMenu            = { italic = true, fg = "#808080" },
        PmenuSbar              = { bg = "#3E4452" },
        PmenuThumb             = { bg = "#5C6370" },
      }
      for group, opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, opts)
      end
    end

    setup_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("LspKindHighlights", { clear = true }),
      callback = setup_highlights,
      desc = "Refresh LspKind highlights on colorscheme change",
    })

    -- Optional command to toggle symbol mode
    vim.api.nvim_create_user_command("LspKindToggleMode", function()
      local new_mode = lspkind.init().mode == "symbol" and "symbol_text" or "symbol"
      lspkind.init({ mode = new_mode })
      vim.notify("LspKind mode set to: " .. new_mode)
    end, { desc = "Toggle LspKind mode" })

    -- Integrate with nvim-cmp if loaded
    local ok, cmp = pcall(require, "cmp")
    if ok then
      local config = cmp.get_config()
      config.formatting = config.formatting or {}
      config.formatting.format = lspkind.cmp_format({
        mode = "symbol_text",
        maxwidth = 50,
        ellipsis_char = "...",
        symbol_map = symbol_map,
      })
      cmp.setup(config)
    end

    -- Preload icons (optional, micro-optim)
    vim.schedule(function()
      for _, icon in pairs(symbol_map) do
        vim.fn.strdisplaywidth(icon)
      end
    end)
  end,
}
