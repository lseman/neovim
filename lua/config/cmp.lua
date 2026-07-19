-- lua/config/cmp.lua
-- Completion configuration for blink.cmp
return function()
    -- ── Source labels ─────────────────────────────────────────────────────────────
    local source_labels = {
        LSP = "[LSP]",
        Snippets = "[Snip]",
        Buffer = "[Buf]",
        Path = "[Path]",
        Cmdline = "[Cmd]",
    }

    local style = vim.g.cmp_style or "default"
    local is_atom = style == "atom" or style == "atom_colored"

    -- ── Border helpers ────────────────────────────────────────────────────────────
    local function get_border(hl_name)
        local styles = {
            default = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            rounded = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            sharp = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
        }
        local chars = styles[vim.g.cmp_border_style or "default"] or styles.default
        return vim.tbl_map(function(c)
            return { c, hl_name }
        end, chars)
    end

    -- ── Main blink.cmp config ──────────────────────────────────────────────────
    return {
        keymap = {
            preset = "default",
            ["<Tab>"] = {
                function(cmp)
                    local ok, suggestion = pcall(require, "copilot.suggestion")
                    if ok and suggestion and suggestion.is_visible() then
                        suggestion.accept()
                        return true
                    end

                    if cmp.is_visible() then
                        return cmp.select_next()
                    end
                end,
                "snippet_forward",
                "fallback",
            },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-b>"] = { function(cmp)
                    return cmp.scroll_documentation_up()
                end, "fallback" },
            ["<C-f>"] = { function(cmp)
                    return cmp.scroll_documentation_down()
                end, "fallback" },
            ["<C-CR>"] = { "accept", "fallback" },
        },

        snippets = {
            preset = "luasnip",
        },

        completion = {
            keyword = {
                range = "prefix",
            },
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false,
                },
            },
            accept = {
                auto_brackets = {
                    enabled = true,
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 150,
                window = {
                    border = get_border "BlinkCmpDocBorder",
                    winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder",
                    max_width = 80,
                    max_height = 15,
                },
            },
            ghost_text = {
                enabled = false,
            },
            menu = {
                border = not is_atom and get_border "BlinkCmpMenuBorder" or nil,
                draw = {
                    treesitter = { "lsp" },
                    columns = {
                        { "kind_icon" },
                        { "label", "label_description", gap = 1 },
                        not is_atom and { "source_name" } or nil,
                    },
                    padding = is_atom and 0 or 1,
                },
                max_height = 15,
                scrollbar = false,
                winhighlight = "Normal:BlinkCmpMenu,CursorLine:BlinkCmpMenuSelection,Search:None",
            },
        },

        sources = {
            default = { "lsp", "snippets", "path", "buffer" },

            transform_items = function(_, items)
                for _, item in ipairs(items) do
                    local label = item.source_name or ""
                    item.source_name = source_labels[label] or string.format("[%s]", label)
                    if is_atom then
                        item.source_name = nil
                    end
                end
                return items
            end,

            providers = {
                lsp = {
                    opts = {
                        max_item_count = 12,
                        priority = 1000,
                        enable = true,
                    },
                },
                snippets = {
                    opts = {
                        max_item_count = 8,
                        priority = 750,
                    },
                },
                path = {
                    opts = {
                        max_item_count = 8,
                        priority = 500,
                    },
                },
                buffer = {
                    opts = {
                        max_item_count = 10,
                        priority = 250,
                        keyword_length = 2,
                    },
                },
            },
        },

        appearance = {
            nerd_font_variant = "mono",
        },

        cmdline = {
            enabled = true,
            completion = {
                menu = {
                    auto_show = false,
                },
            },
            sources = {
                default = function()
                    local cmdtype = vim.fn.getcmdtype()
                    if cmdtype == "/" or cmdtype == "?" then
                        return { "buffer" }
                    end
                    if cmdtype == ":" or cmdtype == "@" then
                        return { "path", "cmdline" }
                    end
                    return {}
                end,
            },
        },
    }
end
