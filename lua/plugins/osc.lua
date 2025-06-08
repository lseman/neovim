return {
  "ojroques/nvim-osc52",
  config = function()
    local osc52 = require("osc52")

    osc52.setup({
      max_length = 0,     -- No length limit
      silent = false,     -- Show messages
      trim = false,       -- Don't trim trailing newline
    })

    -- Internal clipboard cache to simulate registers
    local clipboard_cache = {
      ["+"] = "",
      ["*"] = "",
    }

    vim.g.clipboard = {
      name = "osc52+cache",
      copy = {
        ["+"] = function(lines)
          local text = table.concat(lines, "\n")
          osc52.copy(text)
          clipboard_cache["+"] = text
          -- vim.notify("Copied to system clipboard via OSC52", vim.log.levels.INFO)
        end,
        ["*"] = function(lines)
          local text = table.concat(lines, "\n")
          osc52.copy(text)
          clipboard_cache["*"] = text
          -- vim.notify("Copied to primary selection via OSC52", vim.log.levels.INFO)
        end,
      },
      paste = {
        ["+"] = function()
          local text = clipboard_cache["+"]
          return vim.split(text, "\n", { plain = true }), "v"
        end,
        ["*"] = function()
          local text = clipboard_cache["*"]
          return vim.split(text, "\n", { plain = true }), "v"
        end,
      },
    }
  end,
}
