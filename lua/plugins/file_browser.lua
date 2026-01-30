return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
  },

  keys = {
    {
      "<leader>fb",
      function()
        require("telescope").extensions.file_browser.file_browser({
          path = "%:p:h",              -- start in current file's directory
          cwd = vim.fn.getcwd(),       -- or project root if preferred
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = true,
          select_buffer = true,        -- highlight current file
          initial_mode = "normal",     -- start in normal mode
          theme = "ivy",               -- clean & spacious look
        })
      end,
      desc = "File Browser (Telescope)",
    },
  },

  config = function()
    local telescope = require("telescope")
    local fb_actions = require("telescope").extensions.file_browser.actions

    telescope.setup({
      extensions = {
        file_browser = {
          hijack_netrw = true,           -- disable netrw completely
          hidden = true,
          respect_gitignore = false,
          grouped = true,
          dir_icon = " ",               -- nicer folder icon
          dir_icon_hl = "Directory",

          -- Theme settings (optional but recommended)
          theme = "ivy",
          layout_config = {
            height = 0.8,
            width = 0.9,
            preview_width = 0.55,
          },

          -- Custom actions & mappings
          mappings = {
            ["i"] = {
              ["<C-n>"] = fb_actions.create_from_prompt,
              ["<C-r>"] = fb_actions.rename,
              ["<C-x>"] = fb_actions.remove,
              ["<C-h>"] = fb_actions.goto_parent_dir,
              ["<C-y>"] = function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                if selection then
                  local path = selection.value
                  vim.fn.setreg("+", path)
                  vim.notify("Copied path: " .. path, vim.log.levels.INFO)
                end
              end,
              ["<C-t>"] = fb_actions.toggle_hidden,      -- toggle hidden files
              ["<C-g>"] = fb_actions.toggle_respect_gitignore,
            },

            ["n"] = {
              ["N"] = fb_actions.create_from_prompt,
              ["R"] = fb_actions.rename,
              ["D"] = fb_actions.remove,
              ["h"] = fb_actions.goto_parent_dir,
              ["y"] = function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                if selection then
                  local path = selection.value
                  vim.fn.setreg("+", path)
                  vim.notify("Copied: " .. path, vim.log.levels.INFO)
                end
              end,
              ["<C-t>"] = fb_actions.toggle_hidden,
              ["<C-g>"] = fb_actions.toggle_respect_gitignore,
              ["<CR>"] = fb_actions.open,
              ["<C-v>"] = fb_actions.open_vertical,
              ["<C-x>"] = fb_actions.open_horizontal,
              ["<C-t>"] = fb_actions.open_tab,
            },
          },
        },
      },
    })

    -- Load extension safely
    local ok, _ = pcall(telescope.load_extension, "file_browser")
    if not ok then
      vim.notify("Failed to load telescope-file-browser extension", vim.log.levels.WARN)
    end
  end,
}