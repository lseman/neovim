return {
  "nvim-telescope/telescope.nvim",
--   tag = "0.1.8",  -- pin to stable if you prefer; or remove for latest
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
    -- Recommended addition: frecency for intelligent recent files
    "nvim-telescope/telescope-frecency.nvim",
    -- Optional: if you use dap later → uncomment
    -- "nvim-telescope/telescope-dap.nvim",
  },

  keys = {
    { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find Files" },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Live Grep" },
    { "<leader>fb", function() require("telescope.builtin").buffers() end,    desc = "Buffers" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help Tags" },
    { "<leader>fr", function() require("telescope.builtin").oldfiles() end,  desc = "Recent Files" },
    { "<leader>fc", function() require("telescope.builtin").command_history() end, desc = "Command History" },
    { "<leader>fd", function() require("telescope.builtin").diagnostics() end,     desc = "Diagnostics" },
    -- Smart git-aware files
    { "<leader>fF", function()
      local ok = pcall(require("telescope.builtin").git_files)
      if not ok then require("telescope.builtin").find_files() end
    end, desc = "Git Files (or fallback)" },
    -- Frecency (if added)
    { "<leader>sf", "<cmd>Telescope frecency workspace=CWD<CR>", desc = "Frecency (CWD)" },
  },

  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local themes = require("telescope.themes")

    telescope.setup({
      defaults = {
        prompt_prefix = "❯ ",
        selection_caret = "➤ ",
        entry_prefix = "  ",
        multi_icon = "󰣉 ",  -- nicer multi-select icon

        path_display = { "filename_first", "truncate" },  -- modern: filename first
        -- path_display = { "smart" }, -- alternative

        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.60,       -- slightly wider preview
            results_width = 0.40,
          },
          vertical = { mirror = false },
          width = function(_, max_columns)
            return math.min(140, math.floor(max_columns * 0.90))
          end,
          height = 0.85,
          preview_cutoff = 200,         -- show preview for larger terminals
        },

        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-c>"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,  -- very useful
            ["<C-s>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
          n = {
            ["<esc>"] = actions.close,
            ["q"] = actions.close,
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["gg"] = actions.move_to_top,
            ["G"] = actions.move_to_bottom,
            ["<CR>"] = actions.select_default,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
          },
        },

        -- Dynamic border / winblend if you like transparency
        -- winblend = 10,
      },

      pickers = {
        -- Example: use ivy theme for buffers (cleaner for lists)
        buffers = {
          theme = "ivy",
          sort_lastused = true,
          previewer = false,
          mappings = {
            i = { ["<C-d>"] = actions.delete_buffer },
          },
        },
        find_files = { hidden = true },  -- show dotfiles by default
        live_grep = {
          additional_args = function() return { "--hidden" } end,
        },
      },

      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        ["ui-select"] = {
          themes.get_dropdown({}),
        },
        frecency = {
          show_scores = true,
          show_filter_column = false,
          matcher = "fuzzy",
          workspace = "CWD",
        },
        -- dap = { theme = "dropdown" },  -- if using later
      },
    })

    -- Load extensions
    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")
    telescope.load_extension("frecency")
    -- telescope.load_extension("dap")  -- when ready

    -- Optional: vim.ui integration is already via ui-select
  end,
}