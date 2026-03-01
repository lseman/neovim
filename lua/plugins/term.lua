-- plugins/term.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  keys = {
    { "<C-\\>",    desc = "Toggle terminal" },
    { "<leader>tf", desc = "Toggle floating terminal" },
    { "<leader>th", desc = "Toggle horizontal terminal" },
    { "<leader>tv", desc = "Toggle vertical terminal" },
    { "<leader>lg", desc = "Toggle Lazygit" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end
      -- float uses float_opts.width/height
    end,

    open_mapping = [[<C-\>]],
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    persist_size = true,
    persist_mode = true,     -- remember insert/normal mode
    direction = "horizontal", -- default fallback
    close_on_exit = true,
    shell = vim.o.shell,
    auto_scroll = true,

    float_opts = {
      border = "curved",
      width = function() return math.floor(vim.o.columns * 0.8) end,
      height = function() return math.floor(vim.o.lines * 0.8) end,
      winblend = 3,
      highlights = {
        border = "FloatBorder",
        background = "Normal",
      },
      title_pos = "center",
    },
  },

  config = function(_, opts)
    require("toggleterm").setup(opts)

    -- ── Custom terminal instances ───────────────────────────────────────
    local Terminal = require("toggleterm.terminal").Terminal

    local float_term = Terminal:new({
      direction = "float",
      hidden = true,
      float_opts = { border = "curved" },
    })

    local horizontal_term = Terminal:new({
      direction = "horizontal",
      size = 15,
      hidden = true,
    })

    local vertical_term = Terminal:new({
      direction = "vertical",
      size = math.floor(vim.o.columns * 0.4),
      hidden = true,
    })

    local lazygit = Terminal:new({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
      float_opts = { border = "double" },
      on_open = function(term)
        vim.cmd("startinsert!")
        -- Quick close with q in normal mode
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = term.bufnr, silent = true, noremap = true })
      end,
    })

    -- ── Toggle functions ────────────────────────────────────────────────
    local function toggle_float()      float_term:toggle()      end
    local function toggle_horizontal() horizontal_term:toggle() end
    local function toggle_vertical()   vertical_term:toggle()   end
    local function toggle_lazygit()    lazygit:toggle()         end

    -- ── Keymaps (override / add to defaults) ────────────────────────────
    local map = vim.keymap.set
    local km_opts = { noremap = true, silent = true }

    map("n", "<leader>tf", toggle_float,      vim.tbl_extend("error", km_opts, { desc = "Terminal: float" }))
    map("n", "<leader>th", toggle_horizontal, vim.tbl_extend("error", km_opts, { desc = "Terminal: horizontal" }))
    map("n", "<leader>tv", toggle_vertical,   vim.tbl_extend("error", km_opts, { desc = "Terminal: vertical" }))
    map("n", "<leader>lg", toggle_lazygit,    vim.tbl_extend("error", km_opts, { desc = "Terminal: lazygit" }))

    -- ── Terminal-mode improvements ──────────────────────────────────────
    local function set_terminal_keymaps()
      local t_opts = { buffer = 0, noremap = true, silent = true }
      local tmap   = function(lhs, rhs) vim.keymap.set("t", lhs, rhs, t_opts) end

      tmap("<Esc>", [[<C-\><C-n>]])           -- exit insert → normal
      -- tmap("<C-h>", [[<C-\><C-n><C-w>h]])
      tmap("<C-j>", [[<C-\><C-n><C-w>j]])
      tmap("<C-k>", [[<C-\><C-n><C-w>k]])
      tmap("<C-l>", [[<C-\><C-n><C-w>l]])
    end

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",   -- only for toggleterm buffers
      callback = set_terminal_keymaps,
    })
  end,
}