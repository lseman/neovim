vim.g.snacks_animate = false

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,

    ---@type snacks.Config
    opts = {
        bigfile = {
            enabled = true
        },
        dashboard = {
            enabled = true,
            width = 64,
            pane_gap = 5,
            preset = {
                header = [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
                keys = {{
                    icon = " ",
                    key = "f",
                    desc = "Find files",
                    action = function()
                        Snacks.picker.files()
                    end
                }, {
                    icon = " ",
                    key = "g",
                    desc = "Grep text",
                    action = function()
                        Snacks.picker.grep()
                    end
                }, {
                    icon = " ",
                    key = "r",
                    desc = "Recent files",
                    action = function()
                        Snacks.picker.recent()
                    end
                }, {
                    icon = " ",
                    key = "c",
                    desc = "Edit config",
                    action = function()
                        Snacks.picker.files({
                            cwd = vim.fn.stdpath("config")
                        })
                    end
                }, {
                    icon = "󰌌 ",
                    key = "k",
                    desc = "Keymaps",
                    action = function()
                        Snacks.picker.keymaps()
                    end
                }, {
                    icon = "󰒲 ",
                    key = "l",
                    desc = "Lazy",
                    action = ":Lazy"
                }, {
                    icon = "󰓙 ",
                    key = "h",
                    desc = "Health check",
                    action = ":checkhealth"
                }, {
                    icon = " ",
                    key = "q",
                    desc = "Quit",
                    action = ":qa"
                }}
            },
            sections = {{
                section = "header",
                padding = 1
            }, {
                icon = " ",
                section = "keys",
                gap = 1,
                indent = 2,
                padding = 1
            }, {
                pane = 2,
                section = "terminal",
                cmd = "colorscript -e square",
                height = 5,
                padding = 1
            }, {
                pane = 2,
                icon = " ",
                title = "Recent",
                section = "recent_files",
                indent = 2,
                padding = 1
            }, {
                pane = 2,
                icon = " ",
                title = "Projects",
                section = "projects",
                indent = 2,
                padding = 1
            }, {
                pane = 2,
                icon = " ",
                title = "Git Status",
                section = "terminal",
                enabled = function()
                    return Snacks.git.get_root() ~= nil
                end,
                cmd = "git status --short --branch --renames",
                height = 6,
                indent = 3,
                padding = 1,
                ttl = 300
            }, {
                section = "startup",
                padding = 1
            }}
        },
        explorer = {
            enabled = true,
            replace_netrw = true,
            trash = true
        },
        indent = {
            enabled = true
        },
        input = {
            enabled = true
        },
        picker = {
            enabled = true,
            ui_select = true,
            sources = {
                files = {},
                explorer = {
                    hidden = true,
                    ignored = false,
                    follow_file = true,
                    watch = true,
                    diagnostics = true,
                    git_status = true,
                    auto_close = false,
                    layout = {
                        preset = "sidebar",
                        preview = false
                    },
                    win = {
                        list = {
                            keys = {
                                ["<CR>"] = "confirm",
                                ["<2-LeftMouse>"] = "confirm",
                                ["<C-s>"] = "edit_split",
                                ["<C-v>"] = "edit_vsplit",
                                ["<C-t>"] = "tab",
                                ["Y"] = {
                                    function(picker)
                                        local item = picker:selected({
                                            fallback = true
                                        })[1]
                                        if not item or not item.file then
                                            return
                                        end
                                        local path = vim.fn.fnamemodify(item.file, ":p")
                                        vim.fn.setreg("+", path)
                                        vim.notify("Copied: " .. path, vim.log.levels.INFO)
                                    end,
                                    mode = {"n", "x"}
                                }
                            }
                        }
                    }
                }
            },
            layout = {
                preset = "default"
            }
        },
        quickfile = {
            enabled = true
        },
        scroll = {
            enabled = false
        },
        scope = {
            enabled = true
        },
        statuscolumn = {
            enabled = true
        },
        words = {
            enabled = true
        },
        notifier = {
            enabled = true,
            timeout = 3000,
            style = "compact"
        },
        zen = {
            enabled = true
        }
    },

    keys = {{
        "<leader>e",
        function()
            Snacks.explorer()
        end,
        desc = "File Explorer"
    }, {
        "<leader>un",
        function()
            Snacks.notifier.hide()
        end,
        desc = "Dismiss all notifications"
    }, {
        "<leader>ff",
        function()
            Snacks.picker.files()
        end,
        desc = "Find Files"
    }, {
        "<leader>fg",
        function()
            Snacks.picker.grep()
        end,
        desc = "Grep (project)"
    }, {
        "<leader>fb",
        function()
            Snacks.picker.buffers()
        end,
        desc = "Buffers"
    }, {
        "<leader>fr",
        function()
            Snacks.picker.recent()
        end,
        desc = "Recent Files"
    }, {
        "<leader>fs",
        function()
            Snacks.picker.lsp_symbols()
        end,
        desc = "Document Symbols"
    }, {
        "<leader>fS",
        function()
            Snacks.picker.lsp_workspace_symbols()
        end,
        desc = "Workspace Symbols"
    }, {
        "<leader>fd",
        function()
            Snacks.picker.diagnostics()
        end,
        desc = "Diagnostics"
    }, {
        "<leader>fh",
        function()
            Snacks.picker.help()
        end,
        desc = "Help Pages"
    }, {
        "<leader>fk",
        function()
            Snacks.picker.keymaps()
        end,
        desc = "Keymaps"
    }, {
        "<leader>fn",
        function()
            Snacks.picker.notifications()
        end,
        desc = "Notifications"
    }, {
        "<leader>z",
        function()
            Snacks.zen()
        end,
        desc = "Zen Mode"
    }, {
        "<leader>gb",
        function()
            Snacks.gitbrowse()
        end,
        desc = "Git Browse (line/repo)"
    }, {
        "<leader>nt",
        function()
            require("config.integrations").toggle_explorer()
        end,
        desc = "Toggle Explorer"
    }, {
        "<leader>nf",
        function()
            Snacks.explorer.reveal()
        end,
        desc = "Reveal File"
    }, {
        "<leader>nr",
        function()
            Snacks.explorer.reveal()
        end,
        desc = "Refresh Explorer"
    }, {
        "<leader>ng",
        function()
            Snacks.picker.git_status()
        end,
        desc = "Git Status"
    }}
}
