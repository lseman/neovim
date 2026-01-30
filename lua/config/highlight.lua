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
local function get_theme_colors()
  local scheme = vim.g.colors_name or "default"

  local palettes = {
    ["ayu-mirage"] = {
      blue    = "#73D0FF",
      yellow  = "#FFD173",
      orange  = "#FF8A65",
      green   = "#BAE67E",
      violet  = "#D4BFFF",
      cyan    = "#95E6CB",
    },
    ["tokyonight"] = {
      blue    = "#7AA2F7",
      yellow  = "#E0AF68",
      orange  = "#FF9E64",
      green   = "#9ECE6A",
      violet  = "#BB9AF7",
      cyan    = "#7DCFFF",
    },
    ["gruvbox"] = {
      blue    = "#83A598",
      yellow  = "#FABD2F",
      orange  = "#FE8019",
      green   = "#B8BB26",
      violet  = "#D3869B",
      cyan    = "#8EC07C",
    },
    -- Add more themes here if needed
  }

  return palettes[scheme] or {
    blue   = "#61AFEF",
    yellow = "#E0C07B",  -- slight tweak to match common fallbacks
    orange = "#D19A66",
    green  = "#98C379",
    violet = "#C678DD",
    cyan   = "#56B6C2",
  }
end

-- Create highlight groups (called on colorscheme change and initially)
local function setup_highlights()
  local colors = get_theme_colors()

  local scope_groups = {
    ScopeBlue   = colors.blue,
    ScopeYellow = colors.yellow,
    ScopeOrange = colors.orange,
    ScopeGreen  = colors.green,
    ScopeViolet = colors.violet,
    ScopeCyan   = colors.cyan,
  }

  for name, color in pairs(scope_groups) do
    vim.api.nvim_set_hl(0, name, { fg = color, bold = true })
  end

  -- Optional: you can also set underline or other attrs for scope start/end
  -- vim.api.nvim_set_hl(0, "ScopeStart", { sp = colors.blue, underline = true })
end

-- Register hook → runs before highlights are applied, perfect for colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, setup_highlights)

-- Force initial setup (in case hook doesn't fire immediately)
setup_highlights()

-- ============================================================================
-- Toggle Function
-- ============================================================================
local function toggle_indent_guides()
  if ibl.is_enabled() then
    ibl.disable()
    vim.notify("Indent guides → disabled", vim.log.levels.INFO)
  else
    ibl.enable()
    vim.notify("Indent guides → enabled", vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<leader>ti", toggle_indent_guides, {
  desc = "Toggle indent guides",
})

-- ============================================================================
-- IBL Configuration
-- ============================================================================
ibl.setup {
  enabled = true,

  indent = {
    char         = "▏",
    tab_char     = "▏",  -- optional: same for tabs if you want
    highlight    = "LineNr",  -- subtle grayish look
    smart_indent_cap = true,
  },

  scope = {
    enabled     = true,
    show_start  = true,
    show_end    = true,
    char        = "▎",
    highlight   = { "ScopeBlue", "ScopeYellow", "ScopeOrange", "ScopeGreen", "ScopeViolet", "ScopeCyan" },
    priority    = 500,  -- high enough to override most things
  },

  whitespace = {
    highlight         = { "Whitespace", "NonText" },
    remove_blankline_trail = true,
  },

  exclude = {
    filetypes = {
      "help", "dashboard", "lazy", "mason", "notify", "toggleterm",
      "lazyterm", "alpha", "neo-tree", "Trouble", "TelescopePrompt",
      "TelescopeResults", "lspinfo", "packer", "null-ls-info",
    },
    buftypes = { "terminal", "nofile", "quickfix", "prompt" },
  },
}

-- ============================================================================
-- Autocommands
-- ============================================================================
local group = vim.api.nvim_create_augroup("IndentGuidesSetup", { clear = true })

-- Disable in certain filetypes (redundant with exclude.filetypes, but explicit)
vim.api.nvim_create_autocmd("FileType", {
  group   = group,
  pattern = {
    "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason",
  },
  callback = function()
    vim.b.ibl_enabled = false
  end,
})

-- Colorscheme change → re-apply highlights (hook already handles most cases)
-- But this is a safety net
vim.api.nvim_create_autocmd("ColorScheme", {
  group   = group,
  callback = setup_highlights,
})