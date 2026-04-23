return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim"},
    lazy = false,

    keys = {{
        "<leader>nt",
        "<cmd>Neotree toggle<CR>",
        desc = "Toggle Neo-tree"
    }, {
        "<leader>nf",
        "<cmd>Neotree reveal<CR>",
        desc = "Reveal file in tree"
    }, {
        "<leader>nr",
        "<cmd>Neotree refresh<CR>",
        desc = "Refresh tree"
    }, {
        "<leader>nc",
        "<cmd>Neotree close<CR>",
        desc = "Close tree"
    }, {
        "<leader>ng",
        "<cmd>Neotree float git_status<CR>",
        desc = "Git status (float)"
    }},

    opts = {
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        sort_case_insensitive = false,

        -- Open files in the last used window, not the tree window
        open_files_do_not_replace_types = {"terminal", "trouble", "qf"},

        default_component_configs = {
            container = {
                enable_character_fade = true
            },
            indent = {
                indent_size = 2,
                padding = 1,
                with_markers = true,
                indent_marker = "│",
                last_indent_marker = "└",
                highlight = "NeoTreeIndentMarker",
                with_expanders = true,
                expander_collapsed = "",
                expander_expanded = "",
                expander_highlight = "NeoTreeExpander"
            },
            icon = {
                folder_closed = "",
                folder_open = "",
                folder_empty = "󰜌",
                default = "*",
                highlight = "NeoTreeFileIcon"
            },
            modified = {
                symbol = "●",
                highlight = "NeoTreeModified"
            },
            name = {
                trailing_slash = true,
                use_git_status_colors = true,
                highlight = "NeoTreeFileName"
            },
            git_status = {
                symbols = {
                    added = "✓",
                    modified = "",
                    deleted = "✗",
                    renamed = "➜",
                    untracked = "★",
                    ignored = "◌",
                    unstaged = "",
                    staged = "",
                    conflict = ""
                }
            },
            diagnostics = {
                symbols = {
                    hint = " ",
                    info = " ",
                    warn = " ",
                    error = " "
                },
                highlights = {
                    hint = "DiagnosticSignHint",
                    info = "DiagnosticSignInfo",
                    warn = "DiagnosticSignWarn",
                    error = "DiagnosticSignError"
                }
            }
        },

        window = {
            position = "left",
            width = 35,
            mapping_options = {
                noremap = true,
                nowait = true
            },
            mappings = {
                ["<space>"] = {
                    "toggle_node",
                    nowait = false
                },
                ["<2-LeftMouse>"] = "open",
                ["<cr>"] = "open",
                ["<esc>"] = "cancel",
                ["P"] = {
                    "toggle_preview",
                    config = {
                        use_float = true,
                        use_image_nvim = false
                    }
                },
                ["l"] = "focus_preview",
                ["S"] = "open_split",
                ["s"] = "open_vsplit",
                ["t"] = "open_tabnew",
                ["w"] = "open_with_window_picker",
                ["C"] = "close_node",
                ["z"] = "close_all_nodes",
                ["a"] = {
                    "add",
                    config = {
                        show_path = "relative"
                    }
                },
                ["A"] = "add_directory",
                ["d"] = "delete",
                ["r"] = "rename",
                ["y"] = "copy_to_clipboard",
                ["x"] = "cut_to_clipboard",
                ["p"] = "paste_from_clipboard",
                ["c"] = "copy",
                ["m"] = "move",
                ["q"] = "close_window",
                ["R"] = "refresh",
                ["?"] = "show_help",
                ["<"] = "prev_source",
                [">"] = "next_source",
                ["i"] = "show_file_details",
                ["Y"] = {
                    function(state)
                        local node = state.tree:get_node()
                        vim.fn.setreg("+", node:get_id())
                        vim.notify("Copied: " .. node:get_id(), vim.log.levels.INFO)
                    end,
                    desc = "Copy absolute path"
                }
            }
        },

        filesystem = {
            filtered_items = {
                visible = false,
                hide_dotfiles = true,
                hide_gitignored = false,
                hide_hidden = true,
                hide_by_name = {"node_modules", ".git"},
                hide_by_pattern = {"*.csv", "*.css", "*.pdf", "*.xlsx", "*.null-ls*"},
                always_show = {".gitignore", ".env"},
                never_show = {".DS_Store", "thumbs.db"}
            },
            follow_current_file = {
                enabled = true,
                leave_dirs_open = false
            },
            group_empty_dirs = true,
            hijack_netrw_behavior = "open_current",
            use_libuv_file_watcher = true
        },

        buffers = {
            follow_current_file = {
                enabled = true
            },
            group_empty_dirs = true,
            show_unloaded = true
        },

        git_status = {
            window = {
                position = "float"
            }
        }
    }
}
