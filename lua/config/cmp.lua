-- lua/config/cmp.lua
-- Completion configuration for blink.cmp
return function()
    -- ── Source labels ─────────────────────────────────────────────────────────────
    local source_labels = {
        lsp = "[LSP]",
        luasnip = "[Snip]",
        buffer = "[Buf]",
        path = "[Path]",
        spell = "[Spell]",
        cmdline = "[Cmd]"
    }

    local style = vim.g.cmp_style or "default"
    local is_atom = style == "atom" or style == "atom_colored"

    -- ── Border helpers ────────────────────────────────────────────────────────────
    local function get_border(hl_name)
        local styles = {
            default = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            rounded = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            sharp = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
        }
        local chars = styles[vim.g.cmp_border_style or "default"] or styles.default
        return vim.tbl_map(function(c) return { c, hl_name } end, chars)
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
                "fallback"
            },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-CR>"] = { "accept", "fallback" }
        },

        snippets = {
            preset = "luasnip"
        },

        completion = {
            keyword = {
                range = "prefix"
            },
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false
                }
            },
            accept = {
                auto_brackets = {
                    enabled = true
                }
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 150,
                border = get_border("BlinkCmpDocBorder"),
                winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder",
                max_height = 15,
                max_width = 80
            },
            ghost_text = {
                enabled = false
            },
            menu = {
                border = not is_atom and get_border("BlinkCmpMenuBorder") or nil,
                draw = {
                    treesitter = { "lsp" },
                    columns = {
                        { "kind_icon" },
                        { "label", "label_description", gap = 1 },
                        not is_atom and { "source_name" } or nil
                    }
                },
                max_height = 15,
                scrollbar = false,
                winhighlight = "Normal:BlinkCmpMenu,CursorLine:BlinkCmpMenuSelection,Search:None",
                side_padding = is_atom and 0 or 1
            },
            sort = {
                enabled = true
            }
        },

        sources = {
            default = { "lsp", "snippets", "path", "buffer" },

            providers = {
                lsp = {
                    opts = {
                        max_item_count = 8,
                        priority = 1000
                    }
                },
                snippets = {
                    opts = {
                        max_item_count = 5,
                        priority = 750
                    }
                },
                path = {
                    opts = {
                        max_item_count = 5,
                        priority = 500
                    }
                },
                buffer = {
                    opts = {
                        max_item_count = 5,
                        priority = 250,
                        keyword_length = 3
                    }
                }
            },

            format = function(_, items)
                for _, item in ipairs(items) do
                    local label = item.source_name or ""
                    item.menu = source_labels[label] or string.format("[%s]", label)
                    if is_atom then
                        item.menu = nil
                    end
                end
                return items
            end
        },

        fuzzy = {
            disallow_fuzzy_matching = false,
            disallow_fullfuzzy_matching = false,
            disallow_partial_fuzzy_matching = true,
            disallow_partial_matching = false,
            disallow_prefix_unmatching = false
        },

        appearance = {
            nerd_font_variant = "mono"
        },

        cmdline = {
            enabled = true,
            completion = {
                menu = {
                    auto_show = false
                }
            },
            sources = {
                ["/"] = { "buffer" },
                ["?"] = { "buffer" },
                [":"] = { "path", "cmdline" }
            }
        },

        per_filetype = {
            markdown = { inherit_defaults = true, "spell" },
            text = { inherit_defaults = true, "spell" },
            gitcommit = { inherit_defaults = true, "spell" }
        }
    }
end
