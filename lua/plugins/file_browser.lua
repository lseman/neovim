return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    -- Optional but highly recommended for speed
    -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    -- Your file browser key
    {
      "<leader>fb",
      function()
        require("telescope").extensions.file_browser.file_browser {
          path = "%:p:h",               -- start from current file dir
          cwd = vim.fn.getcwd(),        -- fallback to cwd
          respect_gitignore = false,
          no_ignore = false,            -- allow :NoIgnore to toggle
          hidden = true,
          grouped = true,
          previewer = true,
          select_buffer = true,
          initial_mode = "normal",
          theme = "ivy",
          layout_config = {
            height = 0.85,
            width = 0.92,
            preview_width = 0.58,
          },
        }
      end,
      desc = "File Browser (Telescope)",
    },
  },

  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local fb_actions = require("telescope._extensions.file_browser.actions")

    telescope.setup {
      defaults = {
        -- Global defaults (affects all pickers)
        layout_strategy = "ivy",
        layout_config = {
          height = 0.85,
          width = 0.92,
          preview_width = 0.58,
        },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
          },
        },
      },

      extensions = {
        file_browser = {
          theme = "ivy",
          hijack_netrw = true,
          hidden = { file_browser = true, folder_browser = true },
          respect_gitignore = false,
          no_ignore = false,                  -- :NoIgnore to show ignored files
          grouped = true,
          dir_icon = "",
          dir_icon_hl = "Directory",
          select_buffer = true,
          initial_mode = "normal",

          -- Custom actions
          mappings = {
            ["i"] = {
              ["<C-c>"] = fb_actions.create_from_prompt,    -- create file/folder
              ["<C-r>"] = fb_actions.rename,
              ["<C-d>"] = fb_actions.remove,                -- delete
              ["<C-y>"] = fb_actions.copy,                  -- copy selected
              ["<C-p>"] = fb_actions.goto_parent_dir,
              ["<C-t>"] = fb_actions.toggle_hidden,
              ["<C-g>"] = fb_actions.toggle_respect_gitignore,
              ["<C-a>"] = fb_actions.toggle_all_buffers,    -- nice bonus
              -- Copy full path to clipboard
              ["<C-f>"] = function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                if selection then
                  local path = vim.fn.fnamemodify(selection.path, ":p")
                  vim.fn.setreg("+", path)
                  vim.notify("Copied full path: " .. path, vim.log.levels.INFO)
                end
              end,
            },

            ["n"] = {
              ["c"] = fb_actions.create_from_prompt,
              ["r"] = fb_actions.rename,
              ["d"] = fb_actions.remove,
              ["y"] = fb_actions.copy,
              ["p"] = fb_actions.goto_parent_dir,
              ["<C-t>"] = fb_actions.toggle_hidden,
              ["<C-g>"] = fb_actions.toggle_respect_gitignore,
              ["<CR>"] = fb_actions.open,
              ["v"] = fb_actions.open_vertical,
              ["x"] = fb_actions.open_horizontal,
              ["t"] = fb_actions.open_tab,
              ["f"] = function(prompt_bufnr)   -- copy full path in normal mode too
                local selection = require("telescope.actions.state").get_selected_entry()
                if selection then
                  local path = vim.fn.fnamemodify(selection.path, ":p")
                  vim.fn.setreg("+", path)
                  vim.notify("Copied: " .. path, vim.log.levels.INFO)
                end
              end,
            },
          },
        },
      },
    }

    -- Load extensions
    pcall(telescope.load_extension, "file_browser")
    -- pcall(telescope.load_extension, "fzf")  -- uncomment if you add fzf-native

    -- Optional: notify once on load failure
    vim.api.nvim_create_autocmd("User", {
      pattern = "TelescopeFindPre",
      once = true,
      callback = function()
        if not pcall(telescope.load_extension, "file_browser") then
          vim.notify("Telescope file-browser failed to load", vim.log.levels.WARN)
        end
      end,
    })
  end,
}