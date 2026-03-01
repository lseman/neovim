return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8", -- still very stable in 2026; remove if you want bleeding edge
    -- branch = "0.1.x",     -- alternative if you prefer minor updates

    dependencies = {"nvim-lua/plenary.nvim", {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make"
    }, "nvim-telescope/telescope-ui-select.nvim", -- Most popular frecency implementation right now
    "nvim-telescope/telescope-frecency.nvim", -- Very useful extensions (uncomment what you like)
    "debugloop/telescope-undo.nvim" -- <leader>fu → undo tree
    -- "nvim-telescope/telescope-live-grep-args.nvim",  -- dynamic rg flags
    -- "danielfalk/smart-open.nvim",              -- smart frecency + recency + cwd bias
    },

    keys = { -- Telescope-only extras (Snacks handles core picker maps)
    {
        "<leader>sf",
        "<cmd>Telescope frecency workspace=CWD<CR>",
        desc = "Frecency (CWD)"
    }, {
        "<leader>sF",
        "<cmd>Telescope frecency workspace=global<CR>",
        desc = "Frecency (Global)"
    }, {
        "<leader>sc",
        "<cmd>Telescope command_history<CR>",
        desc = "Command History"
    }, {
        "<leader>fu",
        "<cmd>Telescope undo<CR>",
        desc = "Undo Tree"
    } -- { "<leader>fG", "<cmd>Telescope live_grep_args<CR>", desc = "Live Grep (args)" },
    },

    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local themes = require("telescope.themes")

        telescope.setup({
            defaults = {
                prompt_prefix = "   ",
                selection_caret = "➤ ",
                entry_prefix = "  ",
                multi_icon = "󰣉 ",
                path_display = {"filename_first", "truncate"}, -- very popular in 2025+
                sorting_strategy = "ascending",
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.58,
                        results_width = 0.42
                    },
                    vertical = {
                        mirror = false
                    },
                    width = function(_, max_cols)
                        return math.min(150, math.floor(max_cols * 0.92))
                    end,
                    height = 0.88,
                    preview_cutoff = 120 -- lower = more previews
                },

                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-n>"] = actions.cycle_history_next,
                        ["<C-p>"] = actions.cycle_history_prev,
                        ["<esc>"] = actions.close, -- very common preference
                        ["<C-c>"] = actions.close,
                        ["<CR>"] = actions.select_default,
                        ["<C-x>"] = actions.select_horizontal,
                        ["<C-v>"] = actions.select_vertical,
                        ["<C-t>"] = actions.select_tab,
                        ["<C-u>"] = actions.preview_scrolling_up,
                        ["<C-d>"] = actions.preview_scrolling_down,
                        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist
                    },

                    n = {
                        ["q"] = actions.close,
                        ["<esc>"] = actions.close,
                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous,
                        ["gg"] = actions.move_to_top,
                        ["G"] = actions.move_to_bottom,
                        ["<CR>"] = actions.select_default,
                        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist
                    }
                }

                -- file_ignore_patterns = { "node_modules", "%.git/", "%.o", "%.a", "%.out", "%.class" },
            },

            pickers = {
                buffers = {
                    theme = "ivy",
                    sort_mru = true,
                    sort_lastused = true,
                    previewer = false,
                    mappings = {
                        i = {
                            ["<C-d>"] = actions.delete_buffer
                        },
                        n = {
                            ["dd"] = actions.delete_buffer
                        }
                    }
                },

                find_files = {
                    hidden = true
                    -- no_ignore = false,   -- toggle with :Telescope find_files no_ignore=true
                },

                live_grep = {
                    additional_args = {"--hidden", "--glob=!.git/"}
                },

                oldfiles = {
                    cwd_only = true
                } -- many people prefer cwd-restricted recent files
            },

            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case"
                },

                ["ui-select"] = {themes.get_dropdown({}) -- nice compact look for code actions etc.
                },

                frecency = {
                    show_scores = true,
                    show_filter_column = false,
                    matcher = "fuzzy",
                    workspace = "CWD", -- default behavior
                    db_root = vim.fn.stdpath("data") .. "/databases" -- explicit is safer
                    -- frecency is quite good nowadays — most people keep default algo
                },

                undo = {
                    side_by_side = true,
                    layout_strategy = "vertical"
                } -- if you add telescope-undo
            }
        })

        -- Load everything
        telescope.load_extension("fzf")
        telescope.load_extension("ui-select")
        telescope.load_extension("frecency")
        -- telescope.load_extension("undo")             -- if added
        -- telescope.load_extension("live_grep_args")   -- if added
    end
}
