-- lua/plugins/conform.lua
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>fm",
      function()
        require("conform").format({
          async = true,
          lsp_fallback = true,
          timeout_ms = 1000,
        })
      end,
      desc = "Format buffer",
    },
  },

  opts = {
    -- ╭──────────────────────────────────────────────╮
    -- │ Formatters per filetype                     │
    -- ╰──────────────────────────────────────────────╯
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescriptreact = { "prettierd" },
      json = { "prettierd" },
      yaml = { "prettierd" },
      html = { "prettierd" },
      css = { "prettierd" },
      scss = { "prettierd" },
      markdown = { "prettierd" },
      cpp = { "clang-format" },
      c = { "clang-format" },
      java = { "google-java-format" },
      rust = { "rustfmt" },
      go = { "gofmt", "goimports" },
    },

    -- ╭──────────────────────────────────────────────╮
    -- │ Global formatter options                    │
    -- ╰──────────────────────────────────────────────╯
    formatters = {
      stylua = {
        prepend_args = { "--indent-type", "spaces", "--indent-width", "2" },
      },
      black = {
        prepend_args = { "--line-length", "88", "--fast" },
      },
      prettierd = {
        prepend_args = { "--print-width", "100", "--tab-width", "2" },
      },
      ["clang-format"] = {
        prepend_args = { "--style", "{BasedOnStyle: google, IndentWidth: 4}" },
      },
    },

    -- ╭──────────────────────────────────────────────╮
    -- │ Format-on-save logic                        │
    -- ╰──────────────────────────────────────────────╯
    format_on_save = function(bufnr)
      local ignore_ft = { "sql", "terraform" }
      local ft = vim.bo[bufnr].filetype
      if vim.tbl_contains(ignore_ft, ft) then return end

      local path = vim.api.nvim_buf_get_name(bufnr)
      if path:match("/node_modules/") or path:match("/%.git/") then return end

      return {
        timeout_ms = 500,
        lsp_fallback = true,
        async = false, -- synchronous by default
      }
    end,

    -- ╭──────────────────────────────────────────────╮
    -- │ Optional post-save reformat                 │
    -- ╰──────────────────────────────────────────────╯
    format_after_save = {
      timeout_ms = 1000,
      lsp_fallback = true,
    },

    -- ╭──────────────────────────────────────────────╮
    -- │ Error notification                          │
    -- ╰──────────────────────────────────────────────╯
    notify_on_error = function(err)
      vim.notify("Formatting error: " .. tostring(err), vim.log.levels.WARN)
    end,

    debug = false,
  },
}
