-- plugins/term.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  keys = {
    { "<C-\\>",         desc = "Toggle default terminal" },
    { "<leader>tf",     desc = "Toggle float terminal" },
    { "<leader>th",     desc = "Toggle horizontal terminal" },
    { "<leader>tv",     desc = "Toggle vertical terminal" },
    { "<leader>lg",     desc = "Toggle Lazygit terminal" },
  },
  config = function()
    local toggleterm = require("toggleterm")
    local Terminal = require("toggleterm.terminal").Terminal

    -- Setup
    toggleterm.setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.4)
        end
      end,
      open_mapping = [[<C-\>]],
      shade_terminals = true,
      shading_factor = 2,
      direction = "horizontal",
      start_in_insert = true,
      persist_size = true,
      close_on_exit = true,
      shell = vim.o.shell,
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
    })

    -- Terminal Instances
    local lazygit = Terminal:new({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
      float_opts = {
        border = "double",
      },
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = term.bufnr, silent = true })
      end,
    })

    -- Toggle Functions
    local function toggle_float()
      toggleterm.exec("", 1, { direction = "float" })
    end

    local function toggle_horizontal()
      toggleterm.exec("", 1, { size = 15, direction = "horizontal" })
    end

    local function toggle_vertical()
      toggleterm.exec("", 1, { size = 60, direction = "vertical" })
    end

    local function toggle_lazygit()
      lazygit:toggle()
    end

    -- Safe Keymaps
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    map("n", "<leader>tf", toggle_float,     vim.tbl_extend("force", opts, { desc = "Toggle float terminal" }))
    map("n", "<leader>th", toggle_horizontal, vim.tbl_extend("force", opts, { desc = "Toggle horizontal terminal" }))
    map("n", "<leader>tv", toggle_vertical,   vim.tbl_extend("force", opts, { desc = "Toggle vertical terminal" }))
    map("n", "<leader>lg", toggle_lazygit,    vim.tbl_extend("force", opts, { desc = "Toggle Lazygit" }))

    -- Terminal Mode Navigation
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function()
        local tmap = function(lhs, rhs)
          vim.keymap.set("t", lhs, rhs, { buffer = true, noremap = true })
        end
        tmap("<Esc>", [[<C-\><C-n>]])
        tmap("<C-h>", [[<C-\><C-n><C-w>h]])
        tmap("<C-j>", [[<C-\><C-n><C-w>j]])
        tmap("<C-k>", [[<C-\><C-n><C-w>k]])
        tmap("<C-l>", [[<C-\><C-n><C-w>l]])
      end,
    })
  end,
}
