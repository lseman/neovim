local ok, ibl = pcall(require, "ibl")
if not ok then
  vim.keymap.set("n", "<leader>ti", function()
    vim.notify("indent-blankline not installed", vim.log.levels.WARN)
  end, { desc = "Toggle indent guides (not available)" })
  return
end

local hooks = require("ibl.hooks")

-- ============================================================================
-- Theme-Aware Color Definitions
-- ============================================================================

local function fetch_theme_colors()
  local scheme = vim.g.colors_name or "default"
  local palette = {
    ["ayu-mirage"] = {
      blue = "#73D0FF", yellow = "#FFD173", orange = "#FF8A65",
      green = "#BAE67E", violet = "#D4BFFF", cyan = "#95E6CB"
    },
    ["tokyonight"] = {
      blue = "#7AA2F7", yellow = "#E0AF68", orange = "#FF9E64",
      green = "#9ECE6A", violet = "#BB9AF7", cyan = "#7DCFFF"
    },
    ["gruvbox"] = {
      blue = "#83A598", yellow = "#FABD2F", orange = "#FE8019",
      green = "#B8BB26", violet = "#D3869B", cyan = "#8EC07C"
    },
  }
  return palette[scheme] or {
    blue = "#61AFEF", yellow = "#E5C07B", orange = "#D19A66",
    green = "#98C379", violet = "#C678DD", cyan = "#56B6C2"
  }
end

local colors = fetch_theme_colors()
local scopes = {
  Blue = colors.blue, Yellow = colors.yellow, Orange = colors.orange,
  Green = colors.green, Violet = colors.violet, Cyan = colors.cyan,
}

local function set_scope_highlights()
  for name, color in pairs(scopes) do
    vim.api.nvim_set_hl(0, "Scope" .. name, { fg = color, bold = true })
  end
end

hooks.register(hooks.type.HIGHLIGHT_SETUP, set_scope_highlights)

-- ============================================================================
-- Toggle Function
-- ============================================================================

local function toggle_indent_blankline()
  if ibl.is_enabled() then
    ibl.disable()
    vim.notify("Indent guides disabled", vim.log.levels.INFO)
  else
    ibl.enable()
    vim.notify("Indent guides enabled", vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<leader>ti", toggle_indent_blankline, {
  desc = "Toggle indent-blankline"
})

-- ============================================================================
-- IBL Configuration
-- ============================================================================

ibl.setup({
  enabled = true,
  scope = {
    enabled = true,
    highlight = vim.tbl_map(function(name) return "Scope" .. name end, vim.tbl_keys(scopes)),
    priority = 500,
    show_start = true,
    show_end = true,
    char = "▎",
  },
  indent = {
    char = "▏",
    highlight = "LineNr",
    smart_indent_cap = true,
  },
  whitespace = {
    highlight = { "Whitespace", "NonText" },
    remove_blankline_trail = true,
  },
  exclude = {
    filetypes = {
      "help", "dashboard", "lazy", "mason", "notify", "toggleterm",
      "lazyterm", "alpha", "neo-tree", "Trouble", "TelescopePrompt",
    },
    buftypes = {
      "terminal", "nofile", "quickfix", "prompt",
    },
  },
})

-- ============================================================================
-- Autocommands
-- ============================================================================

local group = vim.api.nvim_create_augroup("IndentGuides", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = {
    "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason",
  },
  callback = function() vim.b.ibl_enabled = false end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    colors = fetch_theme_colors()
    scopes = {
      Blue = colors.blue, Yellow = colors.yellow, Orange = colors.orange,
      Green = colors.green, Violet = colors.violet, Cyan = colors.cyan,
    }
    set_scope_highlights()
  end,
})
