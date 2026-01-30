return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave" },
  config = function()
    local lint = require("lint")
    local uv = vim.uv or vim.loop

    -- Linters per filetype
    lint.linters_by_ft = {
      lua = { "stylua", "luacheck" },
      python = {}, -- Assuming you're using ruff LSP instead
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      zsh = { "shellcheck" },
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      markdown = {},
      -- Add more filetypes here as needed
    }

    -- Optional: Custom linter overrides (example for ruff if you ever want to use the standalone one)
    -- lint.linters.ruff = {
    --   args = { "--quiet", "--output-format", "json" },
    --   stdin = true,
    --   stream = "stdout",
    --   ignore_exitcode = true,
    -- }

    -- Debounce settings
    local debounce_timer = nil
    local DEBOUNCE_MS = 120

    local function debounce_lint(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()

      -- Safety checks
      if not vim.api.nvim_buf_is_loaded(bufnr) then
        return
      end

      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local filesize = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
      if line_count > 10000 or filesize > 500 * 1024 then
        return -- skip very large files
      end

      -- Cancel any previous pending timer
      if debounce_timer then
        uv.timer_stop(debounce_timer)
        uv.close(debounce_timer)
        debounce_timer = nil
      end

      -- Create and start new debounce timer
      debounce_timer = uv.new_timer()
      uv.timer_start(
        debounce_timer,
        DEBOUNCE_MS,
        0,
        -- Wrap in schedule to avoid fast-event-context errors (E5560)
        vim.schedule_wrap(function()
          -- Clean up timer
          uv.close(debounce_timer)
          debounce_timer = nil

          -- Optional: skip if ruff LSP is attached (prevents duplicate diagnostics)
          local clients = vim.lsp.get_clients({ bufnr = bufnr })
          for _, client in ipairs(clients) do
            if client.name == "ruff" or client.name == "ruff_lsp" then
              return
            end
          end

          -- Finally run the linter
          lint.try_lint(nil, { bufnr = bufnr })
        end)
      )
    end

    -- Auto-trigger linting on these events
    vim.api.nvim_create_autocmd(
      { "BufReadPost", "BufWritePost", "InsertLeave" },
      {
        group = vim.api.nvim_create_augroup("nvim-lint-auto", { clear = true }),
        callback = function(args)
          debounce_lint(args.buf)
        end,
        desc = "Debounced lint on buffer events",
      }
    )

    -- Cleanup timer when buffer is deleted
    vim.api.nvim_create_autocmd("BufDelete", {
      group = vim.api.nvim_create_augroup("nvim-lint-cleanup", { clear = true }),
      callback = function()
        if debounce_timer then
          uv.timer_stop(debounce_timer)
          uv.close(debounce_timer)
          debounce_timer = nil
        end
      end,
    })

    -- Handy manual lint command
    vim.api.nvim_create_user_command("Lint", function()
      local bufnr = vim.api.nvim_get_current_buf()
      lint.try_lint(nil, { bufnr = bufnr })

      local diagnostics = vim.diagnostic.get(bufnr)
      local count = #diagnostics
      vim.notify(
        string.format("Buffer linted: %d %s", count, count == 1 and "diagnostic" or "diagnostics"),
        count == 0 and vim.log.levels.INFO or vim.log.levels.WARN
      )
    end, { desc = "Manually lint current buffer" })

    -- Optional: reset diagnostics before write (uncomment if you prefer fresh diagnostics on save)
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   group = vim.api.nvim_create_augroup("lint-clear-before-write", { clear = true }),
    --   callback = function()
    --     vim.diagnostic.reset(nil, vim.api.nvim_get_current_buf())
    --   end,
    -- })
  end,
}