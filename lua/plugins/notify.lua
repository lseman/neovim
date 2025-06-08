return {
  "rcarriga/nvim-notify",
  keys = {
    {
      "<leader>un",
      function()
        require("notify").dismiss({ silent = true, pending = true })
      end,
      desc = "Dismiss All Notifications",
    },
    {
      "<leader>fn",
      function()
        require("telescope").extensions.notify.notify()
      end,
      desc = "Find Notifications",
    },
  },

  config = function()
    local notify = require("notify")

    -- ── Setup Notify ───────────────────────────────────────
    notify.setup({
      stages = "fade_in_slide_out",
      timeout = 3000,
      fps = 60,
      top_down = true,
      level = "info",
      render = "default",
      virtual_text = true,
      highlight = true,
      title_timeout = 2000,
      background_colour = "#1e222a",
      position = "bottom_right",

      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,

      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,

      icons = {
        ERROR = "",
        WARN  = "",
        INFO  = "",
        DEBUG = "",
        TRACE = "✎",
      },

      format = function(n)
        return (n.title and #n.title > 0)
          and (n.title .. "\n" .. n.message)
          or n.message
      end,
    })

    vim.notify = notify

    -- ── Telescope Integration ──────────────────────────────
    local ok, telescope = pcall(require, "telescope")
    if ok and telescope.load_extension then
      telescope.load_extension("notify")
    end

    vim.api.nvim_create_user_command("NotifyHistory", function()
      require("telescope").extensions.notify.notify()
    end, {})

    -- ── Highlight Groups ───────────────────────────────────
    local function set_notify_highlights()
      local hl = vim.api.nvim_set_hl
      local palette = {
        ERROR = "#f7768e",
        WARN  = "#e0af68",
        INFO  = "#7dcfff",
        DEBUG = "#bb9af7",
        TRACE = "#9ece6a",
        BORDER = "#7aa2f7",
        BACKGROUND = "#1a1b26",
      }

      for type, color in pairs(palette) do
        if type == "BACKGROUND" then
          hl(0, "NotifyBackground", { bg = color })
        elseif type == "BORDER" then
          hl(0, "NotifyBorder", { fg = color })
        else
          hl(0, "Notify" .. type .. "Border", { fg = color })
        end
      end
    end

    set_notify_highlights()

    -- ── One-Time Notification Utility ──────────────────────
    _G.notify_once = setmetatable({}, {
      __call = function(self, msg, level, opts)
        if not self[msg] then
          self[msg] = true
          vim.notify(msg, level, opts)
        end
      end,
    })
  end,
}
