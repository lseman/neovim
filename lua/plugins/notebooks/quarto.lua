-- quarto.nvim: first-class support for .qmd files
-- Quarto is the modern successor to RMarkdown and works with Python, R, Julia, etc.
-- It layers on top of otter.nvim for embedded LSP and molten-nvim for execution.
local function goto_quarto_block(lang, reverse)
  local query = "\\v^```\\s*"
  if lang then
    query = query .. lang .. "\\>"
  end

  local flags = reverse and "bW" or "W"
  local line = vim.fn.search(query, flags)

  if line == 0 then
    local label = lang and (lang .. " ") or ""
    local direction = reverse and "before" or "after"
    vim.notify("No " .. label .. "code block " .. direction .. " cursor.", vim.log.levels.INFO)
    return
  end

  vim.api.nvim_win_set_cursor(0, { line, 0 })
end

return {
  "quarto-dev/quarto-nvim",
  ft = { "quarto", "qmd" },
  dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter" },
  init = function()
    local function quarto_target()
      local path = vim.api.nvim_buf_get_name(0)

      if path == "" then
        vim.notify("Save this file before rendering with Quarto.", vim.log.levels.WARN)
        return nil
      end

      local root = vim.fs.root(0, { "_quarto.yml", "_quarto.yaml" })
      return root or path
    end

    local function render(args)
      local target = quarto_target()

      if not target then
        return
      end

      local cmd = { "quarto", "render", target }

      vim.list_extend(cmd, args or {})
      vim.notify("Quarto render started", vim.log.levels.INFO)

      vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_exit = function(_, code)
          local level = code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
          local message = code == 0 and "Quarto render finished" or ("Quarto render failed with code " .. code)

          vim.schedule(function()
            vim.notify(message, level)
          end)
        end,
      })
    end

    vim.api.nvim_create_user_command("QuartoRender", function()
      render()
    end, {
      desc = "Render the current Quarto file or project",
    })

    vim.api.nvim_create_user_command("QuartoRunCell", function()
      require("quarto.runner").run_cell()
    end, {
      desc = "Run the current Quarto code cell",
    })

    vim.api.nvim_create_user_command("QuartoRunPythonCell", function()
      require("quarto.runner").run_cell()
    end, {
      desc = "Run the current Python code cell in Quarto",
    })

    vim.api.nvim_create_user_command("QuartoRunAbove", function()
      require("quarto.runner").run_above()
    end, {
      desc = "Run all Quarto cells above the cursor",
    })

    vim.api.nvim_create_user_command("QuartoRunLine", function()
      require("quarto.runner").run_line()
    end, {
      desc = "Run the current line in the Quarto code cell",
    })
  end,
  opts = {
    debug = false,
    closePreviewOnExit = true,
    lspFeatures = {
      enabled = true,
      chunks = "curly", -- "curly" = {python} blocks, "all" = any fenced block
      languages = { "python", "r", "julia", "bash", "lua" },
      diagnostics = {
        enabled = true,
        triggers = { "BufWritePost" },
      },
      completion = {
        enabled = true, -- uses blink.cmp
      },
    },
    codeRunner = {
      enabled = true,
      default_method = "molten", -- use molten for interactive execution
      ft_runners = {}, -- per-filetype overrides if needed
      never_run = { "yaml" },
    },
  },
  keys = {
    {
      "<leader>qp",
      function()
        require("quarto").quartoPreview()
      end,
      desc = "Quarto: Preview",
    },
    {
      "<leader>qP",
      function()
        vim.cmd "QuartoPreviewNoWatch"
      end,
      desc = "Quarto: Preview no watch",
    },
    {
      "<leader>qq",
      function()
        require("quarto").quartoClosePreview()
      end,
      desc = "Quarto: Close preview",
    },
    {
      "<leader>qe",
      "<cmd>QuartoRender<CR>",
      desc = "Quarto: Render",
    },
    {
      "<leader>qE",
      "<cmd>QuartoUpdatePreview<CR>",
      desc = "Quarto: Update preview",
    },
    {
      "<leader>qa",
      function()
        require("quarto").activate()
      end,
      desc = "Quarto: Activate LSP",
    }, -- Run cells via quarto's code runner (delegates to molten)
    {
      "<leader>qr",
      function()
        require("quarto.runner").run_cell()
      end,
      desc = "Quarto: Run cell",
    },
    {
      "<C-CR>",
      function()
        require("quarto.runner").run_cell()
      end,
      desc = "Quarto: Run cell",
    },
    {
      "<F5>",
      function()
        require("quarto.runner").run_all()
      end,
      desc = "Quarto: Run all cells (F5)",
    },
    {
      "<leader>qR",
      function()
        require("quarto.runner").run_above()
      end,
      desc = "Quarto: Run above",
    },
    {
      "<leader>qal",
      function()
        require("quarto.runner").run_all()
      end,
      desc = "Quarto: Run all",
    },
    {
      "<leader>ql",
      function()
        require("quarto.runner").run_line()
      end,
      desc = "Quarto: Run line",
    },
    {
      "<leader>qv",
      function()
        require("quarto.runner").run_range()
      end,
      mode = "v",
      desc = "Quarto: Run selection",
    },
    {
      "<leader>qn",
      function()
        goto_quarto_block("python", false)
      end,
      desc = "Quarto: Next Python code block",
    },
    {
      "<leader>qN",
      function()
        goto_quarto_block("python", true)
      end,
      desc = "Quarto: Previous Python code block",
    },
    {
      "<leader>q]",
      function()
        goto_quarto_block(nil, false)
      end,
      desc = "Quarto: Next code block",
    },
    {
      "<leader>q[",
      function()
        goto_quarto_block(nil, true)
      end,
      desc = "Quarto: Previous code block",
    },
  },
}
