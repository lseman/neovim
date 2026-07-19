return {
    "stevearc/oil.nvim",
    event = "VeryLazy",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    keys = {{
        "<leader>-",
        function()
            require("oil").open()
        end,
        desc = "Open oil file explorer"
    }, {
        "<leader>cw",
        function()
            require("oil").open(vim.fn.getcwd())
        end,
        desc = "Open oil in nvim's working directory"
    }, {
        "<c-up>",
        function()
            require("oil").open(vim.fn.getcwd())
        end,
        desc = "Open oil in cwd"
    }, {
        "\\",
        function()
            require("oil").open()
        end,
        desc = "Open oil"
    }},
    opts = {
        delete_to_trash = true,
        buf_options = {
            buftype = "nofile",
            filetype = "oil"
        },
        view_options = {
            show_hidden = true,
            is_hidden_file = function(name, _)
                return vim.startswith(name, ".")
            end,
            highlight_filename = function()
                return nil
            end,
            natural_order = true,
            sort = {{"type", "asc"}, {"name", "asc"}}
        },
        columns = {"icon"},
        float = {
            padding = 2,
            border = "rounded",
            max_height = 0.9,
            min_height = 6,
            width = 0.6,
            win_options = {
                winblend = 0
            }
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,CursorLineNr:Visual",
            signcolumn = "yes",
            number = true,
            relativenumber = true,
            foldenable = false,
            cursorcolumn = false,
            foldcolumn = "0",
            spell = false,
            list = false
        },
        preview_win = {
            update_on_cursor_moved = true,
            preview_method = "fast_scratch"
        },
        keymaps = {
            ["<C-h>"] = false,
            ["<C-l>"] = false,
            ["<CR>"] = "actions.select",
            ["<C-s>"] = {
                "actions.select",
                opts = {
                    horizontal = true
                },
                desc = "Open split"
            },
            ["<C-v>"] = {
                "actions.select",
                opts = {
                    vertical = true
                },
                desc = "Open vsplit"
            },
            ["<C-t>"] = {
                "actions.select",
                opts = {
                    tab = true
                },
                desc = "Open in new tab"
            },
            ["<C-c>"] = "actions.close",
            ["q"] = "actions.close",
            ["<C-u>"] = {
                "actions.preview",
                desc = "Preview"
            },
            ["<C-k>"] = {
                "actions.preview_scroll_up",
                mode = "n",
                desc = "Scroll preview up"
            },
            ["<C-j>"] = {
                "actions.preview_scroll_down",
                mode = "n",
                desc = "Scroll preview down"
            },
            ["-"] = "actions.parent",
            ["_"] = "actions.open_cwd",
            ["g."] = "actions.toggle_hidden",
            ["g\\"] = "actions.toggle_trash",
            ["<tab>"] = {
                "actions.select",
                opts = {
                    tab = true
                },
                desc = "Open in new tab"
            },
            ["p"] = {
                "actions.preview",
                desc = "Preview"
            },
            ["g?"] = {
                "actions.show_help",
                mode = "n",
                desc = "Show Oil keymaps"
            }
        }
    },
    config = function(_, opts)
        require("oil").setup(opts)
    end
}
