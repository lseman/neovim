return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {"nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim"},
    lazy = false,

    keys = {{
        "<leader>nt",
        "<cmd>NvimTreeToggle<CR>",
        desc = "Toggle NvimTree"
    }, {
        "<leader>nf",
        "<cmd>NvimTreeFindFile<CR>",
        desc = "Find file in tree"
    }, {
        "<leader>nr",
        "<cmd>NvimTreeRefresh<CR>",
        desc = "Refresh tree"
    }, {
        "<leader>nc",
        "<cmd>NvimTreeCollapse<CR>",
        desc = "Collapse tree"
    }},

    opts = {
        -- ─── Core ───────────────────────────────────────────────
        disable_netrw = true,
        hijack_netrw = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,

        update_focused_file = {
            enable = true,
            update_root = true,
            ignore_list = {"help"}
        },

        filesystem_watchers = {
            enable = true,
            debounce_delay = 100
            -- NOTE: "ignore_dirs" is not required; we filter via `filters.custom`
        },

        sort = {
            sorter = "case_sensitive",
            folders_first = true,
            files_first = false
        },

        -- ─── View ────────────────────────────────────────────────
        view = {
            width = {
                min = 30,
                max = 50,
                padding = 1
            },
            side = "left",
            number = false,
            relativenumber = false,
            signcolumn = "yes",
            preserve_window_proportions = true,
            float = {
                enable = false,
                open_win_config = {
                    relative = "editor",
                    border = "rounded",
                    width = 30,
                    height = 30,
                    row = 1,
                    col = 1
                }
            }
        },

        -- ─── Renderer ─────────────────────────────────────────────
        renderer = {
            add_trailing = true,
            group_empty = true,
            highlight_git = true,
            highlight_opened_files = "all",
            highlight_modified = "all",
            indent_width = 2,

            indent_markers = {
                enable = true,
                inline_arrows = true,
                icons = {
                    corner = "└",
                    edge = "│",
                    item = "│",
                    none = " "
                }
            },

            icons = {
                web_devicons = {
                    file = {
                        enable = true,
                        color = true
                    },
                    folder = {
                        enable = true,
                        color = true
                    }
                },
                git_placement = "before",
                modified_placement = "after",
                padding = " ",
                symlink_arrow = " ➜ ",
                show = {
                    file = true,
                    folder = true,
                    folder_arrow = true,
                    git = true,
                    modified = true
                    -- NOTE: do NOT put `diagnostics` here; it's configured in `diagnostics` below
                },
                glyphs = {
                    -- Keep defaults for safety; empty strings can cause odd spacing
                    bookmark = "󰆤",
                    modified = "●",
                    git = {
                        unstaged = "✗",
                        staged = "✓",
                        renamed = "➜",
                        untracked = "★",
                        ignored = "◌",
                        unmerged = "",
                        deleted = ""
                    }
                }
            },

            special_files = {"Cargo.toml", "Makefile", "README.md", "readme.md", "CMakeLists.txt"},
            symlink_destination = true
        },

        -- ─── Filters ─────────────────────────────────────────────
        filters = {
            dotfiles = true,
            git_ignored = false,
            -- Lua patterns (NOT PCRE): escape dot with %.
            custom = {"^%.git$", -- .git directories
            "^node_modules$", -- node_modules directories
            "^%.null%-ls.*$", -- .null-ls* (use %- to escape -)
            "%.csv$", -- files ending with .csv
            "%.css$", -- files ending with .css
            "%.pdf$", -- files ending with .pdf
            "%.xlsx$" -- files ending with .xlsx
            },
            exclude = {".gitignore", ".env"} -- always show exactly these
        },

        -- ─── Git & Modified ──────────────────────────────────────
        git = {
            enable = true,
            ignore = false,
            show_on_dirs = true,
            show_on_open_dirs = true,
            timeout = 400
        },

        modified = {
            enable = true,
            show_on_dirs = true,
            show_on_open_dirs = true
        },

        -- ─── Actions ─────────────────────────────────────────────
        actions = {
            change_dir = {
                enable = true,
                global = true,
                restrict_above_cwd = false
            },
            expand_all = {
                max_folder_discovery = 300,
                exclude = {".git", "node_modules", "build"}
            },
            file_popup = {
                open_win_config = {
                    col = 1,
                    row = 1,
                    relative = "cursor",
                    border = "rounded",
                    style = "minimal"
                }
            },
            open_file = {
                quit_on_open = false,
                resize_window = true,
                window_picker = {
                    enable = true,
                    picker = "default",
                    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                    exclude = {
                        filetype = {"notify", "packer", "qf", "diff", "fugitive", "fugitiveblame"},
                        buftype = {"nofile", "terminal", "help"}
                    }
                }
            },
            remove_file = {
                close_window = true
            }
        },

        -- ─── Diagnostics ─────────────────────────────────────────
        -- Keep disabled to avoid Unknown sign issues.
        diagnostics = {
            enable = false,
            show_on_dirs = true,
            show_on_open_dirs = true,
            debounce_delay = 50,
            severity = {
                min = vim.diagnostic.severity.HINT,
                max = vim.diagnostic.severity.ERROR
            }
            -- No custom icons -> use defaults when enabling
            -- icons = { hint="", info="", warning="", error="" },
        },

        -- ─── Extras ──────────────────────────────────────────────
        live_filter = {
            prefix = "[FILTER]: ",
            always_show_folders = true
        },

        tab = {
            sync = {
                open = false,
                close = false,
                ignore = {}
            }
        },

        notify = {
            threshold = vim.log.levels.INFO,
            absolute_path = true
        },

        help = {
            sort_by = "key"
        },

        ui = {
            confirm = {
                remove = true,
                trash = true,
                default_yes = false
            }
        },

        trash = {
            cmd = "trash",
            require_confirm = true
        },

        -- ─── Attach Keymaps ──────────────────────────────────────
        on_attach = function(bufnr)
            local api = require("nvim-tree.api")
            local function map(lhs, fn, desc)
                vim.keymap.set("n", lhs, fn, {
                    buffer = bufnr,
                    desc = "nvim-tree: " .. desc,
                    noremap = true,
                    silent = true,
                    nowait = true
                })
            end

            -- Defaults
            api.config.mappings.default_on_attach(bufnr)

            -- Custom
            map("?", api.tree.toggle_help, "Help")
            map("Z", api.node.run.system, "Run System")
            map("gs", api.node.run.system, "Run System")
            map("yy", api.fs.copy.node, "Copy Node")
            map("yn", api.fs.copy.filename, "Copy Filename")
            map("yp", api.fs.copy.absolute_path, "Copy Absolute Path")
            map("<C-k>", api.node.show_info_popup, "Show Info")
            map("S", api.tree.search_node, "Search Node")
            map("U", api.tree.toggle_custom_filter, "Toggle Filter")
        end
    }
}
