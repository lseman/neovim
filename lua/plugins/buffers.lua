return {{
    "romgrk/barbar.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    enabled = false,
    lazy = false,
    init = function()
        vim.g.barbar_auto_setup = false
    end,
    opts = {
        animation = true,
        tabpage_animation = true,
        auto_hide = false,
        buffer_index_format = "",
        icons = {
            button = "",
            diagnostics = {
                [vim.diagnostic.severity.ERROR] = {
                    enabled = false
                },
                [vim.diagnostic.severity.WARN] = {
                    enabled = false
                },
                [vim.diagnostic.severity.INFO] = {
                    enabled = false
                },
                [vim.diagnostic.severity.HINT] = {
                    enabled = false
                }
            },
            gitsigns = {
                added = {
                    enabled = false
                },
                changed = {
                    enabled = false
                },
                deleted = {
                    enabled = false
                }
            },
            filetype = {
                custom_colors = false,
                enabled = true
            },
            separator = {
                left = "▎",
                right = ""
            },
            modified = {
                button = "●"
            },
            pinned = {
                button = "󰍁",
                filename = true
            },
            inactive = {
                button = "",
                separator = {
                    left = "▎",
                    right = "▎"
                }
            }
        },
        sidebar_filetypes = {
            undotree = {
                text = "undotree"
            },
            nerdtree = {
                text = "NERDTree"
            },
            ["neo-tree"] = {
                text = "neo-tree"
            }
        }
    },
    config = function(_, opts)
        vim.o.showtabline = 2
        require("barbar").setup(opts)

        local colors = require("ayu.colors")
        local highlights = {
            BufferCurrent = {
                fg = colors.fg,
                bg = colors.bg
            },
            BufferCurrentIndex = {
                fg = colors.accent,
                bg = colors.bg
            },
            BufferCurrentMod = {
                fg = colors.warning,
                bg = colors.bg,
                bold = true
            },
            BufferCurrentModIcon = {
                fg = colors.warning,
                bg = colors.bg
            },
            BufferCurrentSign = {
                fg = colors.accent,
                bg = colors.bg
            },
            BufferCurrentTarget = {
                fg = colors.error,
                bg = colors.bg,
                bold = true
            },
            BufferVisible = {
                fg = colors.comment,
                bg = colors.bg_secondary
            },
            BufferVisibleIndex = {
                fg = colors.accent,
                bg = colors.bg_secondary
            },
            BufferVisibleMod = {
                fg = colors.warning,
                bg = colors.bg_secondary
            },
            BufferVisibleModIcon = {
                fg = colors.warning,
                bg = colors.bg_secondary
            },
            BufferVisibleSign = {
                fg = colors.accent,
                bg = colors.bg_secondary
            },
            BufferVisibleTarget = {
                fg = colors.error,
                bg = colors.bg_secondary,
                bold = true
            },
            BufferInactive = {
                fg = colors.comment,
                bg = colors.bg_secondary
            },
            BufferInactiveIndex = {
                fg = colors.comment,
                bg = colors.bg_secondary
            },
            BufferInactiveMod = {
                fg = colors.warning,
                bg = colors.bg_secondary
            },
            BufferInactiveModIcon = {
                fg = colors.warning,
                bg = colors.bg_secondary
            },
            BufferInactiveSign = {
                fg = colors.comment,
                bg = colors.bg_secondary
            },
            BufferInactiveTarget = {
                fg = colors.error,
                bg = colors.bg_secondary,
                bold = true
            },
            BufferTabpages = {
                fg = colors.accent,
                bg = colors.bg
            },
            BufferTabpageFill = {
                fg = colors.comment,
                bg = colors.bg_secondary
            }
        }

        for group, hl in pairs(highlights) do
            vim.api.nvim_set_hl(0, group, hl)
        end

        local map = vim.keymap.set
        local b_opts = {
            noremap = true,
            silent = true
        }

        map("n", "<Tab>", "<cmd>BufferNext<CR>", vim.tbl_extend("force", b_opts, {
            desc = "Next buffer"
        }))
        map("n", "<S-Tab>", "<cmd>BufferPrevious<CR>", vim.tbl_extend("force", b_opts, {
            desc = "Previous buffer"
        }))
        map("n", "<leader>bd", "<cmd>BufferClose<CR>", vim.tbl_extend("force", b_opts, {
            desc = "Close buffer"
        }))
        map("n", "<leader>bp", "<cmd>BufferPin<CR>", vim.tbl_extend("force", b_opts, {
            desc = "Toggle pin"
        }))
        map("n", "<leader>bo", "<cmd>BufferOnly<CR>", vim.tbl_extend("force", b_opts, {
            desc = "Close other buffers"
        }))
        map("n", "<leader>bq", "<cmd>BufferCloseBuffersLeft<CR>", vim.tbl_extend("force", b_opts, {
            desc = "Close buffers to the left"
        }))
        map("n", "<leader>bw", "<cmd>BufferCloseBuffersRight<CR>", vim.tbl_extend("force", b_opts, {
            desc = "Close buffers to the right"
        }))
    end
}}
