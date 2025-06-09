-- Enhanced config/cmp.lua - preserving your original style
local cmp = require("cmp")

-- Safe require for lspkind with fallback
local has_lspkind, lspkind = pcall(require, 'lspkind')
if not has_lspkind then
    vim.notify("lspkind not found, using fallback icons", vim.log.levels.WARN)
    lspkind = {
        cmp_format = function(opts)
            return function(_, vim_item)
                local kind_icons = {
                    Text = "", Method = "󰆧", Function = "󰊕", Constructor = "",
                    Field = "󰇽", Variable = "󰂡", Class = "󰠱", Interface = "",
                    Module = "", Property = "󰜢", Unit = "", Value = "󰎠",
                    Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
                    File = "󰈙", Reference = "", Folder = "󰉋", EnumMember = "",
                    Constant = "󰏿", Struct = "", Event = "", Operator = "󰆕",
                    TypeParameter = "󰅲"
                }
                vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind] or "", vim_item.kind)
                if opts.maxwidth and #vim_item.abbr > opts.maxwidth then
                    vim_item.abbr = string.sub(vim_item.abbr, 1, opts.maxwidth - 3) .. (opts.ellipsis_char or "...")
                end
                return vim_item
            end
        end
    }
end

local cmpstyle = vim.g.cmp_style or "default"

local field_arrangement = {
    atom = {"kind", "abbr", "menu"},
    atom_colored = {"kind", "abbr", "menu"},
    default = {"abbr", "kind", "menu"},
    minimal = {"abbr", "kind"}
}

local formatting_style = {
    fields = field_arrangement[cmpstyle] or field_arrangement.default,
    format = function(entry, vim_item)
        return lspkind.cmp_format({
            mode = 'symbol_text',
            maxwidth = 50,
            ellipsis_char = '...',
            show_labelDetails = true,
            before = function(entry, vim_item)
                local source_names = {
                    nvim_lsp = "[LSP]",
                    luasnip = "[Snip]",
                    buffer = "[Buf]",
                    path = "[Path]",
                    calc = "[Calc]",
                    emoji = "[Emoji]",
                    spell = "[Spell]",
                    cmdline = "[Cmd]",
                    nvim_lsp_signature_help = "[Sig]"
                }
                vim_item.menu = source_names[entry.source.name] or string.format("[%s]", entry.source.name)
                if cmpstyle == "atom" or cmpstyle == "atom_colored" then
                    vim_item.menu = ""
                end
                return vim_item
            end
        })(entry, vim_item)
    end
}

local function border(hl_name)
    local borders = {
        default = {
            {"╭", hl_name}, {"─", hl_name}, {"╮", hl_name}, {"│", hl_name},
            {"╯", hl_name}, {"─", hl_name}, {"╰", hl_name}, {"│", hl_name}
        },
        rounded = {
            {"╭", hl_name}, {"─", hl_name}, {"╮", hl_name}, {"│", hl_name},
            {"╯", hl_name}, {"─", hl_name}, {"╰", hl_name}, {"│", hl_name}
        },
        sharp = {
            {"┌", hl_name}, {"─", hl_name}, {"┐", hl_name}, {"│", hl_name},
            {"┘", hl_name}, {"─", hl_name}, {"└", hl_name}, {"│", hl_name}
        }
    }
    return borders[vim.g.cmp_border_style or "default"] or borders.default
end

local options = {
    completion = {
        completeopt = "menu,menuone,noinsert",
        keyword_length = 1,
    },
    window = {
        completion = {
            side_padding = (cmpstyle ~= "atom" and cmpstyle ~= "atom_colored") and 1 or 0,
            winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
            scrollbar = false,
            max_height = 12,
            col_offset = 0,
            border = nil,
        },
        documentation = {
            border = border("CmpDocBorder"),
            winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
            max_height = 15,
            max_width = 80,
        }
    },
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end
    },
    formatting = formatting_style,
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),  -- ← This line
        -- ["<Tab>"] = cmp.mapping(function(fallback)
        --     if cmp.visible() then cmp.select_next_item() else fallback() end
        -- end, {"i", "s"}),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item() else fallback() end
        end, {"i", "s"}),
        ["<C-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then require("luasnip").expand_or_jump()
            else fallback() end
        end, {"i", "s"}),
        -- ["<CR>"] = cmp.mapping({
        --     i = function(fallback)
        --         if cmp.visible() and cmp.get_active_entry() then
        --             cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
        --         else fallback() end
        --     end,
        --     s = cmp.mapping.confirm({ select = true }),
        --     c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        -- }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp", max_item_count = 8, priority = 1000, group_index = 1 },
        { name = "luasnip", max_item_count = 5, priority = 750, group_index = 1 },
        { name = "path", max_item_count = 5, priority = 500, group_index = 1 },
    }, {
        { name = "buffer", max_item_count = 5, priority = 250, group_index = 2, keyword_length = 3 }
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
        }
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
        ghost_text = {
            hl_group = "CmpGhostText",
        },
    },
    matching = {
        disallow_fuzzy_matching = false,
        disallow_fullfuzzy_matching = false,
        disallow_partial_fuzzy_matching = true,
        disallow_partial_matching = false,
        disallow_prefix_unmatching = false,
    },
}

if cmpstyle ~= "atom" and cmpstyle ~= "atom_colored" then
    options.window.completion.border = border("CmpBorder")
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text" },
    callback = function()
        cmp.setup.buffer({
            sources = cmp.config.sources({
                { name = "spell", max_item_count = 5 },
                { name = "buffer", max_item_count = 5 },
                { name = "path", max_item_count = 3 },
            })
        })
    end,
})

vim.defer_fn(function()
    pcall(function()
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = 'buffer' } },
        })
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } })
        })
    end)
end, 100)

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
        vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "CmpSel", { bg = "#4C566A", fg = "NONE" })
        vim.api.nvim_set_hl(0, "CmpDoc", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#5E81AC" })
        vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#5E81AC" })
    end,
})

return options
