-- NvChad-style visual theme picker
-- Floating window: name left · color swatches right, each row has theme bg.

local M = {}
local api = vim.api

-- ── State ────────────────────────────────────────────────────────────────
local S = {
    ns = api.nvim_create_namespace "ThemePicker",
    buf = nil,
    win = nil,
    input_buf = nil,
    input_win = nil,
    themes = {},
    filtered = {},
    index = 1,
    active_theme = vim.g.colors_name or "default",
    widest_name = 0,
    confirmed = false,
    original_theme = nil,
    original_background = nil,
}

-- ── Helpers ──────────────────────────────────────────────────────────────

local function get_all_themes()
    local names = vim.fn.getcompletion("", "color")
    if package.loaded.lazy then
        local paths = require("lazy.core.util").get_unloaded_rtp("")
        for _, path in ipairs(paths) do
            for _, file in ipairs(vim.fn.globpath(path, "colors/*", false, true)) do
                local ext = vim.fn.fnamemodify(file, ":e")
                if ext == "vim" or ext == "lua" then
                    names[#names + 1] = vim.fn.fnamemodify(file, ":t:r")
                end
            end
        end
    end
    local result, seen = {}, {}
    for _, name in ipairs(names) do
        if name ~= "default" and name ~= "" and not seen[name] then
            result[#result + 1] = name
            seen[name] = true
        end
    end
    table.sort(result)
    return result
end

local function get_hl_color(which, group)
    local ok, hl = pcall(api.nvim_get_hl, 0, { name = group, link = false })
    if ok and hl then
        local val = hl[which]
        if val ~= nil then
            return string.format("#%02x%02x%02x", bit.rshift(val, 16) % 256, bit.rshift(val, 8) % 256, val % 256)
        end
    end
    return nil
end

local _palette_cache = {}
local SWATCH_KEYS = { "red", "green", "blue", "yellow", "cyan", "purple" }

local function get_palette(name)
    if _palette_cache[name] then return _palette_cache[name] end

    local saved_cs = vim.g.colors_name or "default"
    local saved_bg = vim.o.background

    local palette = {
        bg = "#1e1e2e", fg = "#cdd6f4",
        red = "#f38ba8", green = "#a6e3a1", blue = "#89b4fa",
        yellow = "#f9e2af", cyan = "#94e2d5", purple = "#cba6f7",
    }

    local ok = pcall(vim.cmd.colorscheme, name)
    if not ok then
        vim.o.background = saved_bg
        pcall(vim.cmd.colorscheme, saved_cs)
        _palette_cache[name] = palette
        return palette
    end

    palette.bg = get_hl_color("bg", "Normal")
        or get_hl_color("bg", "NormalNC")
        or get_hl_color("bg", "EndOfBuffer")
        or palette.bg
    palette.fg = get_hl_color("fg", "Normal")
        or get_hl_color("fg", "Statement")
        or palette.fg

    local accent_map = {
        red    = { "Error", "DiagnosticError", "Identifier" },
        green  = { "Success", "DiagnosticOk", "String" },
        blue   = { "Constant", "Type", "Statement" },
        yellow = { "Number", "Conditional", "Function" },
        cyan   = { "Special", "SpecialChar", "Label" },
        purple = { "Type", "StorageClass", "Structure" },
    }
    for key, groups in pairs(accent_map) do
        for _, g in ipairs(groups) do
            local c = get_hl_color("fg", g)
            if c then palette[key] = c; break end
        end
    end

    if saved_cs ~= name then
        vim.o.background = saved_bg
        pcall(vim.cmd.colorscheme, saved_cs)
    end

    _palette_cache[name] = palette
    return palette
end

-- ── Rendering ────────────────────────────────────────────────────────────
-- Each theme row is real buffer text:
--   "  catppuccin-mocha  ██████ ┃"  (name + swatches + active-bar, NvChad-style)
-- Background = theme bg via bufhl, name/swatch colors via syntax highlights.

local function render_themes()
    if not S.buf or not api.nvim_buf_is_valid(S.buf) then return end

    -- Clear all highlights in our namespace first
    api.nvim_buf_clear_namespace(S.buf, S.ns, 0, -1)

    -- ── Phase 1: build text + column offsets for every row ────────────
    -- (nvim_buf_add_highlight must run AFTER the text exists in the buffer —
    -- adding it against a still-empty/stale line clamps to a zero-width
    -- range, so highlights silently never attach. Hence the two-phase split.)
    local lines = {}
    local rows = {}
    for i = 1, #S.filtered do
        local name = S.filtered[i]
        local palette = get_palette(name)
        local is_active_row = (i == S.index)
        local safe = name:gsub("[^a-zA-Z0-9]", "_")

        -- Define this row's highlight groups from its sampled palette
        -- (nvim_buf_add_highlight below only *references* these by name).
        api.nvim_set_hl(S.ns, "TP_bg_" .. safe, { bg = palette.bg })
        api.nvim_set_hl(S.ns, "TP_name_" .. safe, { fg = palette.fg, bg = palette.bg })
        for _, key in ipairs(SWATCH_KEYS) do
            api.nvim_set_hl(S.ns, "TP_sw_" .. safe .. "_" .. key, { fg = palette[key], bg = palette.bg })
        end

        -- Build the text, tracking byte offsets (not char counts) since
        -- "█"/"┃"/"│" are multi-byte UTF-8 and nvim_buf_add_highlight wants bytes.
        local col = 0
        local pieces = {}
        local function put(s)
            pieces[#pieces + 1] = s
            col = col + #s
            return col
        end

        put "  "
        local name_start = col
        put(name)
        local name_end = col
        put(string.rep(" ", S.widest_name - #name) .. " ")

        local swatch_start = col
        for _ in ipairs(SWATCH_KEYS) do put "█" end

        put " "
        local bar_start = col
        put(is_active_row and "┃" or "│")
        local bar_end = col

        lines[i] = table.concat(pieces, "")
        rows[i] = {
            safe = safe,
            is_active_row = is_active_row,
            name_start = name_start, name_end = name_end,
            swatch_start = swatch_start,
            bar_start = bar_start, bar_end = bar_end,
            line_len = #lines[i],
        }
    end

    if #lines == 0 then lines = { "No matching themes." } end

    vim.bo[S.buf].modifiable = true
    api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)
    vim.bo[S.buf].modifiable = false

    -- ── Phase 2: now that the text exists, attach highlights to it ─────
    for i, row in ipairs(rows) do
        -- ── Background: apply theme bg to the entire row ──────────────
        api.nvim_buf_add_highlight(S.buf, S.ns, "TP_bg_" .. row.safe, i - 1, 0, row.line_len)

        -- ── Name highlight: theme fg on theme bg ─────────────────────
        api.nvim_buf_add_highlight(S.buf, S.ns, "TP_name_" .. row.safe, i - 1, row.name_start, row.name_end)

        -- ── Swatch highlights: each swatch gets its color ────────────
        local scol = row.swatch_start
        for _, key in ipairs(SWATCH_KEYS) do
            local hl_name = "TP_sw_" .. row.safe .. "_" .. key
            api.nvim_buf_add_highlight(S.buf, S.ns, hl_name, i - 1, scol, scol + 3)
            scol = scol + 3
        end

        -- ── Active-row indicator: accent bar, NvChad-style ────────────
        api.nvim_buf_add_highlight(
            S.buf, S.ns,
            row.is_active_row and "TP_bar_active" or "TP_bar_inactive",
            i - 1, row.bar_start, row.bar_end
        )
    end
end

-- ── Layout ───────────────────────────────────────────────────────────────

local function calc_layout()
    local lines = vim.o.lines
    local cols = vim.o.columns

    local max_visible = math.min(#S.filtered, lines - 6)
    max_visible = math.max(max_visible, 3)

    -- Width: widest name + arrow + padding + swatches + margins
    local w = S.widest_name + 2 + #SWATCH_KEYS + 8
    local h = max_visible + 2

    local row = math.floor((lines - h) / 2)
    local col = math.floor((cols - w) / 2)

    row = math.max(1, row)
    col = math.max(0, col)
    w = math.max(16, math.min(w, cols - 2))
    h = math.max(3, math.min(h, lines - 5))

    return { row = row, col = col, width = w, height = h }
end

-- ── Open / Close ─────────────────────────────────────────────────────────

M.open = function()
    if S.win and api.nvim_win_is_valid(S.win) then
        api.nvim_set_current_win(S.input_win)
        return
    end

    S.active_theme = vim.g.colors_name or "default"
    S.confirmed = false
    S.original_theme = S.active_theme
    S.original_background = vim.o.background

    -- Gather themes
    S.themes = get_all_themes()
    S.filtered = {}
    for _, t in ipairs(S.themes) do table.insert(S.filtered, t) end
    S.index = 1
    for i, theme in ipairs(S.filtered) do
        if theme == S.active_theme then S.index = i; break end
    end

    -- Find widest name
    S.widest_name = 0
    for _, t in ipairs(S.filtered) do
        if #t > S.widest_name then S.widest_name = #t end
    end

    -- Create buffers
    S.buf = api.nvim_create_buf(false, true)
    S.input_buf = api.nvim_create_buf(false, true)

    local layout = calc_layout()

    -- Input window (search bar above preview)
    S.input_win = api.nvim_open_win(S.input_buf, true, {
        relative = "editor",
        row = math.max(0, layout.row - 1),
        col = layout.col,
        width = layout.width,
        height = 1,
        style = "minimal",
        border = "single",
        title = " Search themes ",
        title_pos = "left",
    })

    vim.bo[S.input_buf].buftype = "nofile"
    vim.bo[S.input_buf].bufhidden = "wipe"
    vim.bo[S.input_buf].swapfile = false

    -- Theme preview window (below input)
    S.win = api.nvim_open_win(S.buf, false, {
        relative = "win",
        win = S.input_win,
        row = 2,
        col = 0,
        width = layout.width,
        height = layout.height - 2,
        style = "minimal",
        border = "single",
    })

    vim.bo[S.buf].buftype = "nofile"
    vim.bo[S.buf].bufhidden = "wipe"
    vim.wo[S.win].cursorline = false
    vim.wo[S.input_win].cursorline = false
    vim.wo[S.input_win].spell = false

    -- Namespace highlights (global defaults)
    api.nvim_set_hl(S.ns, "FloatBorder", { link = "FloatBorder" })
    api.nvim_set_hl(S.ns, "Normal", { link = "Normal" })
    api.nvim_set_hl(S.ns, "TP_bar_active", { fg = "#89b4fa", bold = true })
    api.nvim_set_hl(S.ns, "TP_bar_inactive", { link = "Comment" })
    api.nvim_win_set_hl_ns(S.win, S.ns)

    -- Render themes first (so highlights have content to attach to)
    render_themes()

    -- ── Keymaps ──────────────────────────────────────────────────────

    -- Live-preview: apply the highlighted theme to the whole editor as you
    -- browse (NvChad-style). Reverted in M.close() unless a pick is confirmed.
    local function preview_current()
        if S.index < 1 or S.index > #S.filtered then return end
        pcall(vim.cmd.colorscheme, S.filtered[S.index])
    end

    local function on_select()
        if #S.filtered == 0 then return end
        local chosen = S.filtered[S.index]
        vim.cmd.stopinsert()
        local ok, err = pcall(vim.cmd.colorscheme, chosen)
        if not ok then vim.notify(err, vim.log.levels.ERROR); return end
        S.confirmed = true
        vim.g.current_theme = chosen
        vim.notify("Theme: " .. chosen, vim.log.levels.INFO)
        M.close()
    end

    local function on_filter_change()
        local input = api.nvim_buf_get_lines(S.input_buf, 0, 1, false)[1] or ""
        S.filtered = {}
        for _, t in ipairs(S.themes) do
            if t:lower():find(input:lower(), 1, true) then
                table.insert(S.filtered, t)
            end
        end
        S.index = #S.filtered > 0 and 1 or 0
        render_themes()
        preview_current()
    end

    -- Enter selects (both windows)
    vim.keymap.set({ "i", "n" }, "<CR>", on_select, { buffer = S.input_buf, noremap = true })
    vim.keymap.set("n", "<CR>", on_select, { buffer = S.buf })

    -- Close
    vim.keymap.set("n", "q", M.close, { buffer = S.buf })
    vim.keymap.set("n", "q", M.close, { buffer = S.input_buf })
    vim.keymap.set({ "i", "n" }, "<Esc>", M.close, { buffer = S.input_buf })
    vim.keymap.set("i", "<C-c>", M.close, { buffer = S.input_buf })

    -- Navigate (j/k on theme window)
    vim.keymap.set("n", "j", function()
        if S.index < #S.filtered then S.index = S.index + 1; render_themes(); preview_current() end
    end, { buffer = S.buf })
    vim.keymap.set("n", "k", function()
        if S.index > 1 then S.index = S.index - 1; render_themes(); preview_current() end
    end, { buffer = S.buf })

    -- Navigate (arrows on input window)
    vim.keymap.set("i", "<Up>", function()
        if S.index > 1 then S.index = S.index - 1; render_themes(); preview_current() end
    end, { buffer = S.input_buf })
    vim.keymap.set("i", "<Down>", function()
        if S.index < #S.filtered then S.index = S.index + 1; render_themes(); preview_current() end
    end, { buffer = S.input_buf })

    -- Filter on type (auto via autocmd)
    local group = api.nvim_create_augroup("ThemePickerInput", { clear = true })
    api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
        group = group,
        buffer = S.input_buf,
        callback = on_filter_change,
    })

    -- Close when focus leaves both windows
    local input_win, theme_win = S.input_win, S.win
    api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = function()
            local cur = api.nvim_get_current_win()
            if cur ~= input_win and cur ~= theme_win then M.close() end
        end,
    })

    vim.cmd.startinsert()
end

M.close = function()
    local win, input_win, buf, input_buf = S.win, S.input_win, S.buf, S.input_buf
    local confirmed, orig_theme, orig_bg = S.confirmed, S.original_theme, S.original_background
    S.win, S.input_win, S.buf, S.input_buf = nil, nil, nil, nil
    S.confirmed = false
    pcall(api.nvim_del_augroup_by_name, "ThemePickerInput")
    vim.cmd.stopinsert()
    for _, w in ipairs({ win, input_win }) do
        if w and api.nvim_win_is_valid(w) then api.nvim_win_close(w, true) end
    end
    for _, b in ipairs({ buf, input_buf }) do
        if b and api.nvim_buf_is_valid(b) then api.nvim_buf_delete(b, { force = true }) end
    end

    -- Cancelled (Esc/q/focus-lost) rather than confirmed: revert the live preview.
    if not confirmed and orig_theme then
        vim.o.background = orig_bg
        pcall(vim.cmd.colorscheme, orig_theme)
    end
end

-- ── Public API ───────────────────────────────────────────────────────────

M.toggle = function()
    if S.win and api.nvim_win_is_valid(S.win) then
        M.close()
    else
        M.open()
    end
end

return M
