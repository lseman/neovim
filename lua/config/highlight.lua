local highlight_styles = {
    Comment = {
        italic = true,
    },
    ["@comment"] = {
        italic = true,
    },
    ["@comment.documentation"] = {
        italic = true,
    },
    ["@string.documentation"] = {
        italic = true,
    },
    pythonDocString = {
        italic = true,
    },
    Function = {
        italic = false,
    },
    Type = {
        italic = false,
    },
    ["@keyword"] = {
        italic = false,
    },
    ["@variable"] = {
        bold = false,
    },
    ["@property"] = {
        italic = false,
    },
    ["@parameter"] = {
        italic = false,
    },

    -- ── Molten output window ──────────────────────────────────────────────
    -- Used when vim.g.molten_use_border_highlights = true
    MoltenOutputBorder = {
        fg = "#5e81ac",
        bold = false,
    }, -- idle border (blue)
    MoltenOutputBorderSuccess = {
        fg = "#a3be8c",
    }, -- success (green)
    MoltenOutputBorderFail = {
        fg = "#bf616a",
    }, -- error   (red)
    MoltenOutputWin = {
        bg = "NONE",
    }, -- transparent background
    MoltenOutputFooter = {
        fg = "#616e88",
        italic = true,
    }, -- "N more lines" footer
    MoltenCell = {
        bg = "#2a2f3a",
    }, -- subtle cell highlight
}

local function merge_style(group, style)
    local ok, current = pcall(vim.api.nvim_get_hl, 0, {
        name = group,
        link = false,
    })
    if not ok then
        current = {}
    end

    local merged = vim.tbl_extend("force", current or {}, style)
    vim.api.nvim_set_hl(0, group, merged)
end

local function apply_highlights()
    for group, style in pairs(highlight_styles) do
        merge_style(group, style)
    end
end

apply_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("ConfigHighlights", {
        clear = true,
    }),
    callback = apply_highlights,
    desc = "Re-apply custom highlight overrides on colorscheme changes",
})
