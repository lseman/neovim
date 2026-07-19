-- ── GitHub Dark Default Colorscheme ─────────────────────────────────────────
-- Pure Lua implementation. No external plugin needed.

-- Color palette
local palette = {
    bg = "#0d1117",
    bg_dark = "#010409",
    bg_highlight = "#161b22",
    border = "#30363d",
    fg = "#c9d1d9",
    fg_dim = "#8b949e",
    fg_dark = "#6e7681",
    blue = "#58a6ff",
    cyan = "#39d2c0",
    green = "#3fb950",
    orange = "#d29922",
    pink = "#f778ba",
    purple = "#d2a8ff",
    red = "#ff7b72",
    yellow = "#e3b341",
}

vim.g.colors_name = "github-dark"

local function hl(group, opts)
    opts.fg = opts.fg and palette[opts.fg] or opts.fg
    opts.bg = opts.bg and palette[opts.bg] or opts.bg
    opts.sp = opts.sp and palette[opts.sp] or opts.sp
    vim.api.nvim_set_hl(0, group, opts)
end

-- ── Core ────────────────────────────────────────────────────────────────────
hl("Normal", { fg = "fg", bg = "bg" })
hl("NormalNC", { fg = "fg", bg = "bg_dark" })
hl("NormalFloat", { fg = "fg", bg = "bg_highlight" })
hl("FloatBorder", { fg = "border", bg = "bg_highlight" })
hl("FloatTitle", { fg = "fg", bg = "bg_highlight", bold = true })
hl("VertSplit", { fg = "border" })
hl("WinSeparator", { fg = "border" })
hl("Folded", { fg = "fg_dim", bg = "bg_highlight" })
hl("FoldColumn", { fg = "fg_dim" })
hl("SignColumn", { fg = "fg_dim" })
hl("CursorLine", { bg = "bg_highlight" })
hl("CursorLineNr", { fg = "yellow", bg = "bg_highlight" })
hl("LineNr", { fg = "fg_dim" })
hl("Visual", { bg = "bg_highlight" })
hl("VisualNOS", { bg = "bg_highlight" })
hl("Search", { fg = "bg", bg = "orange" })
hl("CurSearch", { fg = "bg", bg = "orange" })
hl("IncSearch", { fg = "bg", bg = "orange" })
hl("MatchParen", { bg = "bg_highlight", bold = true })

-- ── UI Elements ─────────────────────────────────────────────────────────────
hl("Pmenu", { fg = "fg", bg = "bg_highlight" })
hl("PmenuSbar", { bg = "bg_highlight" })
hl("PmenuSel", { fg = "bg", bg = "blue" })
hl("PmenuThumb", { bg = "blue" })
hl("SpellBad", { undercurl = true, sp = "red" })
hl("SpellCap", { undercurl = true, sp = "purple" })
hl("SpellLocal", { undercurl = true, sp = "cyan" })
hl("SpellRare", { undercurl = true, sp = "green" })
hl("SpecialKey", { fg = "fg_dim" })
hl("NonText", { fg = "fg_dim" })
hl("EndOfBuffer", { fg = "border" })
hl("Whitespace", { fg = "border" })
hl("Cursor", { fg = "bg", bg = "fg" })
hl("lCursor", { fg = "bg", bg = "fg" })
hl("CursorIM", { fg = "bg", bg = "blue" })
hl("CursorLine", { bg = "bg_highlight" })
hl("Directory", { fg = "blue" })
hl("Conceal", { fg = "fg_dim" })

-- ── StatusLine & WinBar ─────────────────────────────────────────────────────
hl("StatusLine", { fg = "fg_dim", bg = "bg_highlight" })
hl("StatusLineNC", { fg = "fg_dark", bg = "bg_highlight" })
hl("WinBar", { fg = "fg_dim", bg = "bg" })
hl("WinBarNC", { fg = "fg_dark", bg = "bg" })
hl("TabLine", { fg = "fg_dim", bg = "bg_highlight" })
hl("TabLineFill", { fg = "fg_dim", bg = "bg_highlight" })
hl("TabLineSel", { fg = "fg", bg = "bg_highlight", bold = true })

-- ── Diagnostics ─────────────────────────────────────────────────────────────
hl("DiagnosticError", { fg = "red" })
hl("DiagnosticWarn", { fg = "orange" })
hl("DiagnosticInfo", { fg = "blue" })
hl("DiagnosticHint", { fg = "cyan" })
hl("DiagnosticUnderlineError", { sp = "red", undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = "orange", undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = "blue", undercurl = true })
hl("DiagnosticUnderlineHint", { sp = "cyan", undercurl = true })
hl("DiagnosticVirtualTextError", { fg = "red", bg = "bg_highlight" })
hl("DiagnosticVirtualTextWarn", { fg = "orange", bg = "bg_highlight" })
hl("DiagnosticVirtualTextInfo", { fg = "blue", bg = "bg_highlight" })
hl("DiagnosticVirtualTextHint", { fg = "cyan", bg = "bg_highlight" })
hl("DiagnosticFloatingError", { fg = "red" })
hl("DiagnosticFloatingWarn", { fg = "orange" })
hl("DiagnosticFloatingInfo", { fg = "blue" })
hl("DiagnosticFloatingHint", { fg = "cyan" })
hl("DiagnosticDeprecated", { fg = "fg_dim", strikethrough = true })

-- ── Git / Gitsigns ──────────────────────────────────────────────────────────
hl("GitSignsAdd", { fg = "green" })
hl("GitSignsChange", { fg = "orange" })
hl("GitSignsDelete", { fg = "red" })
hl("GitSignsCurrentLineBlame", { fg = "fg_dim" })

-- ── Treesitter ──────────────────────────────────────────────────────────────
hl("@comment", { fg = "fg_dim", italic = true })
hl("@comment.documentation", { fg = "fg_dim", italic = true })
hl("@comment.note", { fg = "fg_dim", italic = true })
hl("@comment.todo", { fg = "yellow", italic = true })
hl("@comment.warning", { fg = "orange", italic = true })
hl("@comment.error", { fg = "red", italic = true })

hl("@constant", { fg = "blue" })
hl("@constant.builtin", { fg = "blue" })
hl("@constant.macro", { fg = "purple" })

hl("@string", { fg = "green" })
hl("@string.documentation", { fg = "green", italic = true })
hl("@string.regexp", { fg = "cyan" })
hl("@string.escape", { fg = "pink" })
hl("@string.special", { fg = "yellow" })
hl("@string.special.path", { fg = "yellow" })
hl("@string.special.url", { fg = "cyan", underline = true })

hl("@number", { fg = "orange" })
hl("@number.float", { fg = "orange" })

hl("@boolean", { fg = "orange" })
hl("@character", { fg = "green" })
hl("@character.special", { fg = "pink" })

hl("@function", { fg = "blue" })
hl("@function.builtin", { fg = "cyan" })
hl("@function.call", { fg = "blue" })
hl("@function.macro", { fg = "purple" })
hl("@method", { fg = "blue" })
hl("@method.call", { fg = "blue" })

hl("@operator", { fg = "fg" })

hl("@keyword", { fg = "pink" })
hl("@keyword.coroutine", { fg = "pink" })
hl("@keyword.function", { fg = "pink" })
hl("@keyword.operator", { fg = "pink" })
hl("@keyword.return", { fg = "pink" })
hl("@keyword.debug", { fg = "pink" })
hl("@keyword.exception", { fg = "pink" })
hl("@keyword.import", { fg = "pink" })
hl("@keyword.directive", { fg = "pink" })

hl("@keyword.conditional", { fg = "pink" })
hl("@keyword.conditional.ternary", { fg = "pink" })
hl("@keyword.repeat", { fg = "pink" })

hl("@label", { fg = "yellow" })

hl("@namespace", { fg = "yellow" })
hl("@namespace.builtin", { fg = "blue" })

hl("@number", { fg = "orange" })

hl("@parameter", { fg = "blue" })

hl("@property", { fg = "blue" })

hl("@reference", { fg = "cyan", underline = true })

hl("@tag", { fg = "red" })
hl("@tag.attribute", { fg = "orange" })
hl("@tag.delimiter", { fg = "fg_dim" })

hl("@punctuation.delimiter", { fg = "fg_dim" })
hl("@punctuation.bracket", { fg = "fg" })
hl("@punctuation.special", { fg = "yellow" })

hl("@type", { fg = "yellow" })
hl("@type.builtin", { fg = "cyan" })
hl("@type.definition", { fg = "purple" })
hl("@type.qualifier", { fg = "pink" })

hl("@variable", { fg = "fg" })
hl("@variable.builtin", { fg = "purple" })
hl("@variable.parameter", { fg = "blue" })
hl("@variable.member", { fg = "blue" })

hl("@module", { fg = "yellow" })
hl("@module.builtin", { fg = "blue" })

hl("@function.macro", { fg = "purple" })
hl("@function.macro.call", { fg = "purple" })

-- ── LSP & Language-specific ─────────────────────────────────────────────────
hl("@lsp.type.parameter", { fg = "blue" })
hl("@lsp.type.variable", { fg = "fg" })
hl("@lsp.type.comment", { fg = "fg_dim", italic = true })
hl("@lsp.type.keyword", { fg = "pink" })
hl("@lsp.type.string", { fg = "green" })
hl("@lsp.type.number", { fg = "orange" })
hl("@lsp.type.boolean", { fg = "orange" })
hl("@lsp.type.class", { fg = "yellow" })
hl("@lsp.type.typeParameter", { fg = "yellow" })
hl("@lsp.type.function", { fg = "blue" })
hl("@lsp.type.method", { fg = "blue" })
hl("@lsp.type.decorator", { fg = "purple" })

-- ── DAP (Debug Adapter Protocol) ───────────────────────────────────────────
hl("DapStopped", { fg = "orange", bg = "bg_highlight" })
hl("DapBreakpoint", { fg = "red" })
hl("DapBreakpointRejected", { fg = "red" })
hl("DapLogPoint", { fg = "cyan" })

-- ── Lazy.nvim UI ────────────────────────────────────────────────────────────
hl("LazyProgressDone", { fg = "blue", bold = true })
hl("LazyProgressTodo", { fg = "fg_dim" })
hl("LazyButton", { fg = "fg", bg = "bg_highlight" })
hl("LazyButtonActive", { fg = "bg", bg = "blue" })
hl("LazyH1", { fg = "fg", bg = "bg_highlight", bold = true })
hl("LazyReasonCmd", { fg = "orange" })
hl("LazyReasonEvent", { fg = "cyan" })
hl("LazyReasonFt", { fg = "blue" })
hl("LazyReasonImport", { fg = "purple" })
hl("LazyReasonKeys", { fg = "pink" })
hl("LazyReasonPlugin", { fg = "yellow" })
hl("LazyReasonRuntime", { fg = "orange" })
hl("LazyReasonSource", { fg = "fg_dim" })
hl("LazyReasonStart", { fg = "green" })

-- ── Neotree / File Explorer ─────────────────────────────────────────────────
hl("NeotreeTitle", { fg = "blue", bold = true })
hl("NeotreeNormal", { fg = "fg", bg = "bg_highlight" })
hl("NeotreeNormalNC", { fg = "fg", bg = "bg_highlight" })
hl("NeotreeRoot", { fg = "yellow", bold = true })
hl("NeotreeIndent", { fg = "fg_dim" })
hl("NeoTreeDimText", { fg = "fg_dim" })
hl("NeoTreeModified", { fg = "orange" })
hl("NeoTreeGitModified", { fg = "orange" })
hl("NeoTreeGitAdded", { fg = "green" })
hl("NeoTreeGitDeleted", { fg = "red" })
hl("NeoTreeGitIgnored", { fg = "fg_dark" })
hl("NeoTreeGitUntracked", { fg = "cyan" })

-- ── WhichKey ────────────────────────────────────────────────────────────────
hl("WhichKey", { fg = "blue" })
hl("WhichKeySeparator", { fg = "fg_dark" })
hl("WhichKeyGroup", { fg = "yellow" })
hl("WhichKeyDesc", { fg = "pink" })
hl("WhichKeySec", { fg = "orange", bold = true })
hl("WhichKeyBorder", { fg = "border", bg = "bg_highlight" })
hl("WhichKeyValue", { fg = "fg_dim" })
hl("WhichKeySep", { fg = "fg_dark" })
hl("WhichKeyFloat", { bg = "bg_highlight" })

-- ── Snacks (Picker, Dashboard, etc.) ────────────────────────────────────────
hl("SnacksPickerNormal", { fg = "fg", bg = "bg_highlight" })
hl("SnacksPickerPreviewLine", { bg = "bg_highlight" })
hl("SnacksPickerTitle", { fg = "blue", bg = "bg_highlight" })
hl("SnacksPickerTitleBorder", { fg = "border" })
hl("SnacksPickerInput", { fg = "blue" })
hl("SnacksPickerInputBorder", { fg = "fg" })
hl("SnacksPickerBorder", { fg = "border" })
hl("SnacksPickerCurrentLine", { bg = "bg_highlight" })
hl("SnacksPickerScrollThumb", { bg = "fg_dim" })
hl("SnacksPickerScrollGutter", { bg = "bg_highlight" })

-- ── Dashboard / Alpha ───────────────────────────────────────────────────────
hl("DashboardHeader", { fg = "blue" })
hl("DashboardCenter", { fg = "green" })
hl("DashboardFooter", { fg = "fg_dim" })
hl("DashboardShortcut", { fg = "cyan" })
hl("DashboardMruIcon", { fg = "yellow" })
hl("DashboardMruTitle", { fg = "fg" })
hl("DashboardKey", { fg = "cyan" })
hl("DashboardDesc", { fg = "fg" })
hl("DashboardIcon", { fg = "blue" })

-- ── Treesitter Context ──────────────────────────────────────────────────────
hl("TSCurrentContext", { fg = "orange", bg = "bg_highlight" })

-- ── Telescope ───────────────────────────────────────────────────────────────
hl("TelescopeBorder", { fg = "fg_dim", bg = "bg_highlight" })
hl("TelescopeTitle", { fg = "blue", bg = "bg_highlight" })
hl("TelescopePreviewTitle", { fg = "green", bg = "bg_highlight" })
hl("TelescopePromptTitle", { fg = "red", bg = "bg_highlight" })
hl("TelescopeResultsTitle", { fg = "cyan", bg = "bg_highlight" })

-- ── Trouble / Diagnostic List ───────────────────────────────────────────────
hl("TroubleNormal", { fg = "fg", bg = "bg_highlight" })
hl("TroubleCount", { fg = "blue" })
hl("TroublePos", { fg = "fg_dim" })
hl("TroubleText", { fg = "fg" })
hl("TroubleSign", { fg = "fg_dim" })
hl("TroubleLocation", { fg = "cyan" })
hl("TroubleLocationOpen", { fg = "cyan" })
hl("TroubleLocationClose", { fg = "fg_dim" })
hl("TroubleBookmark", { fg = "yellow" })
hl("TroubleIconFile", { fg = "yellow" })
hl("TroubleIconFolder", { fg = "yellow" })
hl("TroubleIconWarning", { fg = "orange" })
hl("TroubleIconError", { fg = "red" })
hl("TroubleIconInfo", { fg = "blue" })
hl("TroubleIconHint", { fg = "cyan" })
hl("TroubleIconBookmarks", { fg = "yellow" })
hl("TroubleIconNewFile", { fg = "cyan" })
hl("TroubleIconClose", { fg = "pink" })

-- ── LspSignature ────────────────────────────────────────────────────────────
hl("LspSignatureActiveParameter", { fg = "orange" })

-- ── ColorColumn ─────────────────────────────────────────────────────────────
hl("ColorColumn", { bg = "bg_highlight" })

-- ── Terminal ────────────────────────────────────────────────────────────────
hl("TermCursor", { fg = "bg", bg = "fg" })
hl("TermCursorNC", { fg = "bg", bg = "fg_dim" })

-- ── Molten (if used) ────────────────────────────────────────────────────────
hl("MoltenOutputBorder", { fg = "blue" })
hl("MoltenOutputBorderSuccess", { fg = "green" })
hl("MoltenOutputBorderFail", { fg = "red" })
hl("MoltenOutputWin", { bg = "NONE" })
hl("MoltenOutputFooter", { fg = "fg_dim", italic = true })
hl("MoltenCell", { bg = "bg_highlight" })

-- ── Diff / Git ──────────────────────────────────────────────────────────────
hl("DiffAdd", { fg = "green", bg = "#052d1b" })
hl("DiffChange", { fg = "blue", bg = "#0d1f31" })
hl("DiffDelete", { fg = "red", bg = "#381f25" })
hl("DiffText", { fg = "yellow", bg = "#362c0c" })

-- ── Neogit ──────────────────────────────────────────────────────────────────
hl("NeogitBranch", { fg = "blue", bold = true })
hl("NeogitRemote", { fg = "green" })
hl("NeogitHunkHeader", { fg = "blue", bg = "bg_highlight" })
hl("NeogitDiffHeader", { fg = "yellow" })
hl("NeogitDiffContext", { fg = "fg_dim" })
hl("NeogitDiffAdd", { fg = "green" })
hl("NeogitDiffDelete", { fg = "red" })
hl("NeogitNotificationInfo", { fg = "blue" })
hl("NeogitNotificationWarning", { fg = "orange" })
hl("NeogitNotificationError", { fg = "red" })

print "github-dark loaded"
