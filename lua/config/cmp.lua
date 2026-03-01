-- lua/config/cmp.lua
-- Completion configuration (nvim-cmp) – cleaned up & organized

local cmp = require("cmp")

-- ── lspkind with safe fallback ──────────────────────────────────────────────
local lspkind_ok, lspkind = pcall(require, "lspkind")
if not lspkind_ok then
  vim.notify("lspkind.nvim not found – using minimal fallback icons", vim.log.levels.WARN)

  lspkind = {
    cmp_format = function()
      return function(_, item)
        local icons = {
          Text          = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "󰒓",
          Field         = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
          Module        = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
          Enum          = "", Keyword = "󰌋", Snippet = "󰅱", Color = "󰏘",
          File          = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
          Constant      = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
          TypeParameter = "󰊄",
        }
        item.kind = string.format("%s %s", icons[item.kind] or "", item.kind or "")
        return item
      end
    end,
  }
end

-- ── Style configuration ─────────────────────────────────────────────────────
local style = vim.g.cmp_style or "default"

local field_orders = {
  atom         = { "kind", "abbr", "menu" },
  atom_colored = { "kind", "abbr", "menu" },
  default      = { "abbr", "kind", "menu" },
  minimal      = { "abbr", "kind" },
}

-- ── Formatting ──────────────────────────────────────────────────────────────
local formatting = {
  fields = field_orders[style] or field_orders.default,

  format = lspkind.cmp_format({
    mode           = "symbol_text",
    maxwidth       = 50,
    ellipsis_char  = "...",
    show_labelDetails = true,

    before = function(entry, item)
      local source_labels = {
        nvim_lsp                  = "[LSP]",
        luasnip                   = "[Snip]",
        buffer                    = "[Buf]",
        path                      = "[Path]",
        calc                      = "[Calc]",
        emoji                     = "[Emoji]",
        spell                     = "[Spell]",
        cmdline                   = "[Cmd]",
        nvim_lsp_signature_help   = "[Sig]",
      }

      item.menu = source_labels[entry.source.name]
        or string.format("[%s]", entry.source.name)

      -- Hide menu in atom styles
      if style == "atom" or style == "atom_colored" then
        item.menu = nil
      end

      return item
    end,
  }),
}

-- ── Window borders ──────────────────────────────────────────────────────────
local function get_border(hl_name)
  local styles = {
    default = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    rounded = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    sharp   = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
  }

  local chosen = vim.g.cmp_border_style or "default"
  local chars  = styles[chosen] or styles.default

  return vim.tbl_map(function(c) return { c, hl_name } end, chars)
end

-- ── Main configuration ──────────────────────────────────────────────────────
local config = {
  completion = {
    completeopt   = "menu,menuone,noinsert",
    keyword_length = 1,
  },

  window = {
    completion = {
      side_padding  = (style ~= "atom" and style ~= "atom_colored") and 1 or 0,
      winhighlight  = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
      scrollbar     = false,
      max_height    = 15,
      col_offset    = 0,
      border        = nil, -- set later conditionally
    },

    documentation = {
      border        = get_border("CmpDocBorder"),
      winhighlight  = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
      max_height    = 15,
      max_width     = 80,
    },
  },

  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  formatting = formatting,

  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),   -- changed from <C-d> for consistency
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    -- ["<C-e>"] = cmp.mapping.abort(),           -- modern replacement for close()
    ["<C-CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<C-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
        require("luasnip").expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp", priority = 1000, max_item_count = 8,  group_index = 1 },
    { name = "luasnip",  priority = 750,  max_item_count = 5,  group_index = 1 },
    { name = "path",     priority = 500,  max_item_count = 5,  group_index = 1 },
  }, {
    { name = "buffer",   priority = 250,  max_item_count = 5,  keyword_length = 3, group_index = 2 },
  }),

  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },

  performance = {
    debounce               = 60,
    throttle               = 30,
    fetching_timeout       = 500,
    confirm_resolve_timeout = 80,
    async_budget           = 1,
    max_view_entries       = 200,
  },

  experimental = {
    ghost_text = {
      hl_group = "CmpGhostText",
    },
  },

  matching = {
    disallow_fuzzy_matching         = false,
    disallow_fullfuzzy_matching     = false,
    disallow_partial_fuzzy_matching = true,
    disallow_partial_matching       = false,
    disallow_prefix_unmatching      = false,
  },
}

-- Apply completion border only for non-atom styles
if style ~= "atom" and style ~= "atom_colored" then
  config.window.completion.border = get_border("CmpBorder")
end

-- ── Filetype-specific sources ───────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },  -- added gitcommit as bonus
  group = vim.api.nvim_create_augroup("CmpFiletypeOverrides", { clear = true }),
  callback = function()
    cmp.setup.buffer({
      sources = cmp.config.sources({
        { name = "spell", max_item_count = 5 },
        { name = "buffer", max_item_count = 5 },
        { name = "path", max_item_count = 3 },
      }),
    })
  end,
})

-- ── Cmdline mode completion ─────────────────────────────────────────────────
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = "buffer" } },
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})

-- ── Highlights (updated on colorscheme change) ──────────────────────────────
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("CmpHighlights", { clear = true }),
  callback = function()
    local set = vim.api.nvim_set_hl
    set(0, "CmpGhostText",   { link = "Comment", default = true })
    set(0, "CmpPmenu",       { bg = "NONE" })
    set(0, "CmpPmenuSel",    { bg = "#4C566A", fg = "NONE" })  -- your original color
    set(0, "CmpDoc",         { bg = "NONE" })
    set(0, "CmpBorder",      { fg = "#5E81AC" })
    set(0, "CmpDocBorder",   { fg = "#5E81AC" })
  end,
})

-- Apply highlights once on startup
vim.schedule(function()
  vim.api.nvim_exec_autocmds("ColorScheme", {})
end)

return config