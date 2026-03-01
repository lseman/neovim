-- plugins/jupytext.lua  (or wherever you keep notebook-related plugins)
return {
  "GCBallesteros/jupytext.nvim",
  version = "*",  -- pin to latest stable minor version (check repo for updates)
  lazy = false,       -- usually recommended (small plugin, needs to hook BufRead early)
  -- event = { "BufReadPre *.ipynb", "BufNewFile *.ipynb" },  -- alternative lazy loading

  opts = {
    -- Command to call (usually 'jupytext' if in PATH)
    jupytext = "jupytext",

    -- Default format when creating/editing .ipynb as text
    -- "py:percent" → # %% cells (most popular for Python)
    -- Alternatives: "py:light", "py:percent", "md", "qmd", etc.
    format = "py:percent",

    -- Automatically sync .ipynb ↔ text file on save/read
    autosync = true,

    -- File patterns to sync (add more if needed)
    sync_patterns = {
      "*.ipynb",     -- always include the notebook itself
      "*.py",
      "*.md",
      "*.qmd",
      "*.jl",
      "*.R",
      "*.Rmd",
    },

    -- Enable handling of jupytext://... URL schemes (optional)
    handle_url_schemes = true,

    -- Custom filetype detection (uncomment and adjust if needed)
    -- filetype = function(path)
    --   -- Example: force python for percent-format files
    --   if path:match("%.py$") and vim.fn.getline(1):match("^# %%") then
    --     return "python"
    --   end
    --   return require("jupytext").get_filetype(path)
    -- end,

    -- Template for new notebooks (uncomment if you want custom defaults)
    -- new_template = require("jupytext").default_new_template(),
  },

  -- Optional: ensure jupytext CLI is installed + add helpful message
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ipynb",  -- or when opening .ipynb
      once = true,
      callback = function()
        vim.schedule(function()
          if vim.fn.executable("jupytext") ~= 1 then
            vim.notify(
              "jupytext.nvim: 'jupytext' CLI not found. Install with:\n  pip install jupytext",
              vim.log.levels.WARN
            )
          end
        end)
      end,
    })
  end,
}