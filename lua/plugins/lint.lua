return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "BufNewFile", "InsertLeave" },
  config = function()
    local lint = require("lint")

    -- Configure linters
    lint.linters_by_ft = {
      python = { "ruff" },
      lua = { "luacheck" },
      sh = { "shellcheck" },
    }

    -- Timers per buffer to debounce safely
    local timers = {}

    local function lint_current_buffer()
      local bufnr = vim.api.nvim_get_current_buf()
      local ft = vim.bo[bufnr].filetype
      local available = lint.linters_by_ft[ft]

      if not available then return end

      if not timers[bufnr] then
        timers[bufnr] = vim.loop.new_timer()
      end

      timers[bufnr]:stop()
      timers[bufnr]:start(100, 0, vim.schedule_wrap(function()
        lint.try_lint(nil, { bufnr = bufnr })
      end))
    end

    -- Auto lint on common events
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      callback = lint_current_buffer,
      desc = "Lint buffer with nvim-lint",
    })

    -- Manual Lint command
    vim.api.nvim_create_user_command("Lint", function()
      local bufnr = vim.api.nvim_get_current_buf()
      lint.try_lint(nil, { bufnr = bufnr })
      vim.notify("Linted buffer " .. bufnr, vim.log.levels.INFO)
    end, {
      desc = "Manually trigger linting for the current buffer",
    })
  end,
}
