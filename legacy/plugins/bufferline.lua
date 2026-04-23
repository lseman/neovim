return {
    "akinsho/bufferline.nvim",
    version = "*", -- or pin to "v4.9.1" if you want stability
    lazy = false,
    enabled = false,
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        -- Requires are safe here (plugin is loaded by the time config runs)
        local bufferline = require("bufferline")
        local devicons = require("nvim-web-devicons")

        --- Keymap helper
        local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, {
                noremap = true,
                silent = true,
                desc = desc
            })
        end

        --- Custom buffer filter (safe with one arg; works in current versions)
        local function filter_valid_buffers(bufnr, _)
            local ft = vim.bo[bufnr].filetype
            local bt = vim.bo[bufnr].buftype
            local name = vim.api.nvim_buf_get_name(bufnr)

            local excluded = {
                qf = true,
                help = true,
                man = true,
                startuptime = true,
                checkhealth = true,
                NvimTree = true,
                ["neo-tree"] = true,
                TelescopePrompt = true,
                alpha = true,
                dashboard = true,
                lspinfo = true,
                ["lsp-installer"] = true,
                ["null-ls-info"] = true,
                toggleterm = true,
                Trouble = true,
                spectre_panel = true
            }

            return not (excluded[ft] or bt == "quickfix" or bt == "terminal" or bt == "nofile" or
                       (name == "" and not vim.bo[bufnr].modified))
        end

        --- Offsets for file explorers and tools
        local offsets = {{
            filetype = "NvimTree",
            text = "󰉋 File Explorer",
            text_align = "center",
            separator = true,
            highlight = "Directory"
        }, {
            filetype = "neo-tree",
            text = "󰉋 File Explorer",
            text_align = "center",
            separator = true,
            highlight = "Directory"
        }, {
            filetype = "undotree",
            text = "󰣜 Undo Tree",
            text_align = "center",
            separator = true
        }, {
            filetype = "Outline",
            text = "󰙅 Symbols",
            text_align = "center",
            separator = true
        }}

        bufferline.setup({
            options = {
                mode = "tabs",
                style_preset = bufferline.style_preset.default,
                separator_style = "slant",
                indicator = {
                    icon = "▎",
                    style = "icon"
                },
                buffer_close_icon = "󰅖",
                modified_icon = "●",
                close_icon = "",
                left_trunc_marker = "",
                right_trunc_marker = "",
                max_name_length = 30,
                max_prefix_length = 20,
                truncate_names = true,
                tab_size = 21,
                color_icons = true,
                show_buffer_icons = true,
                show_buffer_close_icons = false,
                show_close_icon = true,
                show_tab_indicators = true,
                show_duplicate_prefix = false,
                duplicates_across_groups = false,
                persist_buffer_sort = false,
                move_wraps_at_ends = false,
                enforce_regular_tabs = false,
                always_show_bufferline = true,
                auto_toggle_bufferline = true,
                numbers = "ordinal",

                diagnostics = "nvim_lsp",
                diagnostics_update_in_insert = false,
                diagnostics_update_on_event = true,
                diagnostics_indicator = function(count, level, diagnostics_dict)
                    local icon = level:match("error") and "" or level:match("warning") and "" or ""
                    return " " .. icon .. " " .. count
                end,

                custom_filter = filter_valid_buffers,
                get_element_icon = function(element)
                    return devicons.get_icon_by_filetype(element.filetype, {
                        default = false
                    })
                end,

                hover = {
                    enabled = true,
                    delay = 200,
                    reveal = {"close"}
                },

                offsets = offsets,

                highlights = {
                    fill = {
                        bg = {
                            attribute = "bg",
                            highlight = "TabLine"
                        }
                    },
                    background = {
                        italic = false
                    },
                    buffer_visible = {
                        italic = false
                    },
                    buffer_selected = {
                        bold = true,
                        italic = false
                    },
                    diagnostic_selected = {
                        bold = true,
                        italic = false
                    },
                    -- ... (kept your selected bold/italic overrides)
                    close_button = {
                        fg = {
                            attribute = "fg",
                            highlight = "TabLineSel"
                        }
                    },
                    close_button_visible = {
                        fg = {
                            attribute = "fg",
                            highlight = "TabLine"
                        }
                    },
                    close_button_selected = {
                        fg = {
                            attribute = "fg",
                            highlight = "TabLineSel"
                        }
                    }
                }
            }
        })

        -- Tabline keymaps
        map("<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Previous tab")
        map("<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next tab")
        map("<leader>bp", "<cmd>BufferLineCyclePrev<cr>", "Previous tab")
        map("<leader>bn", "<cmd>BufferLineCycleNext<cr>", "Next tab")
        map("<leader>bc", "<cmd>tabclose<cr>", "Close tab")
        map("<leader>bC", "<cmd>tabonly<cr>", "Close other tabs")
        map("<leader>bb", "<cmd>BufferLinePick<cr>", "Pick tab")
        map("]b", "<cmd>BufferLineCycleNext<cr>", "Next tab")
        map("[b", "<cmd>BufferLineCyclePrev<cr>", "Previous tab")

        for i = 1, 9 do
            map("<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", "Go to tab " .. i)
        end

        -- Keep the tabline visible so tab pages are always discoverable.
        vim.opt.showtabline = 2

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("BufferlineColors", {
                clear = true
            }),
            callback = function()
                vim.schedule(function()
                    pcall(require("bufferline").refresh) -- lighter than full setup()
                end)
            end
        })
    end
}
