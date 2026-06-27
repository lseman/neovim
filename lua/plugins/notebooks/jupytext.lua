-- plugins/jupytext.lua  (or wherever you keep notebook-related plugins)
return {
  "GCBallesteros/jupytext.nvim",
  version = "*",
  lazy = false, -- MUST be false: registers BufReadCmd for *.ipynb at startup

  opts = {
    -- Command to call (usually 'jupytext' if in PATH)
    jupytext = "jupytext",

    -- Local notebook output format for Jupytext.
    -- Use Quarto markdown so notebook markdown and LaTeX render more easily.
    output_extension = "qmd",
    style = "quarto",

    -- Automatically sync .ipynb ↔ text file on save/read
    autosync = true,
    custom_language_formatting = {
      python = {
        extension = "qmd",
        style = "quarto",
        force_ft = "quarto",
      },
    },
    -- File patterns to sync (add more if needed)
    sync_patterns = {
      "*.ipynb", -- always include the notebook itself
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

  config = function(_, opts)
    require("jupytext").setup(opts)

    -- Check after venv is activated (PATH updated) so jupytext inside .venv is found
    local checked = false
    local function check_jupytext()
      if checked then
        return
      end
      checked = true
      if vim.fn.executable(opts.jupytext or "jupytext") ~= 1 then
        vim.notify(
          "jupytext.nvim: 'jupytext' CLI not found. Install with:\n  pip install jupytext",
          vim.log.levels.WARN
        )
      end
    end

    local ok, workflows = pcall(require, "config.workflows")
    if ok then
      -- Fires after venv PATH is set — correct order
      workflows.on_venv_activated(check_jupytext)
    end
    -- Fallback: no venv found, still check at VimEnter
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = check_jupytext,
    })
  end,
}
