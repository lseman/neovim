return {
  "ojroques/nvim-osc52",
  lazy = false,  -- usually needs to be loaded early for clipboard to work
  priority = 100,  -- load before most other things

  config = function()
    local osc52 = require("osc52")

    osc52.setup({
      max_length = 0,       -- 0 = unlimited (terminal may still truncate ~100-500 KB)
      silent = true,        -- no messages in normal usage
      trim = false,         -- preserve trailing newlines
    })

    -- Optional internal cache (useful for round-trip yanks within same session)
    local clipboard_cache = { ["+"] = "", ["*"] = "" }

    vim.g.clipboard = {
      name = "OSC52",

      copy = {
        ["+"] = function(lines)
          local text = table.concat(lines, "\n")
          osc52.copy(text)
          clipboard_cache["+"] = text
          -- Optional: only notify on very large yanks
          if #text > 100000 then
            vim.notify("Large yank sent via OSC 52 (" .. #text .. " bytes)", vim.log.levels.INFO)
          end
        end,

        ["*"] = function(lines)
          local text = table.concat(lines, "\n")
          osc52.copy(text)
          clipboard_cache["*"] = text
        end,
      },

      paste = {
        -- Try real system paste if possible, fallback to cache
        ["+"] = function()
          -- Most OSC52 terminals don't support paste → return cached value
          local text = clipboard_cache["+"]
          if text == "" then
            vim.notify_once("OSC52 paste: no previous yank in this session", vim.log.levels.WARN)
          end
          return vim.split(text, "\n", { plain = true }), "v"
        end,

        ["*"] = function()
          local text = clipboard_cache["*"]
          return vim.split(text, "\n", { plain = true }), "v"
        end,
      },

      -- Optional: improve experience in tmux/ssh
      cache_enabled = true,
    }

    -- Optional: force OSC52 on tmux + ssh (very common use-case)
    if vim.env.TMUX and vim.env.SSH_TTY then
      vim.g.clipboard = vim.tbl_extend("force", vim.g.clipboard or {}, {
        copy = {
          ["+"] = osc52.copy,
          ["*"] = osc52.copy,
        },
      })
    end

    -- Optional: keymap to manually copy entire buffer or selection to system clipboard
    vim.keymap.set({ "n", "v" }, "<leader>y", function()
      vim.cmd('normal! "+y')
      vim.notify("Yanked to system clipboard via OSC52", vim.log.levels.INFO)
    end, { desc = "Yank to system clipboard (OSC52)" })
  end,
}