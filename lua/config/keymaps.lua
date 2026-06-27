-- lua/config/keymaps.lua
-- Simplified – no custom nmap/imap/vmap helpers
-- All mappings use vim.keymap.set directly
local map = vim.keymap.set
local default_opts = {
  noremap = true,
  silent = true,
}

local function toggle_explorer()
  local open = Snacks.picker.get({
    source = "explorer",
  })
  if #open > 0 then
    for _, picker in ipairs(open) do
      picker:close()
    end
    return
  end
  Snacks.explorer()
end

-- ── 1. Core ─────────────────────────────────────────────────────────────

-- Save
map(
  { "n", "v", "i" },
  "<C-s>",
  "<cmd>update<CR>",
  vim.tbl_extend("force", default_opts, {
    desc = "Save file",
  })
)

-- Quit with confirmation
local function smart_quit()
  if vim.bo.modified then
    local choice = vim.fn.confirm("Save changes before quitting?", "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then
      vim.cmd "silent! wqa"
    elseif choice == 2 then
      vim.cmd "silent! qa!"
    end
  else
    vim.cmd "silent! qa"
  end
end

map(
  { "n", "v", "i" },
  "<C-q>",
  function()
    local mode = vim.api.nvim_get_mode().mode
    if mode:find "i" then
      vim.cmd "stopinsert"
    end
    if mode:find "[vV]" then
      vim.cmd "normal! <Esc>"
    end
    vim.schedule(smart_quit)
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Quit (confirm if modified)",
  })
)

-- Undo / Redo
map("n", "<C-z>", "u", default_opts)
map("n", "<C-S-z>", "<C-r>", default_opts)
map("i", "<C-z>", "<C-o>u", default_opts)
map("i", "<C-S-z>", "<C-o><C-r>", default_opts)

-- ── 2. Navigation ───────────────────────────────────────────────────────

-- map("n", "<C-h>", "<C-w>h", default_opts)
-- map("n", "<C-j>", "<C-w>j", default_opts)
-- map("n", "<C-k>", "<C-w>k", default_opts)
-- map("n", "<C-l>", "<C-w>l", default_opts)

map("n", "<C-Up>", "<cmd>resize +2<CR>", default_opts)
map("n", "<C-Down>", "<cmd>resize -2<CR>", default_opts)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", default_opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", default_opts)

map(
  { "n", "i", "t" },
  "<C-t>",
  function()
    if vim.api.nvim_get_mode().mode:find "i" then
      vim.cmd "stopinsert"
    end

    vim.schedule(function()
      Snacks.terminal.toggle(nil, {
        cwd = vim.fn.getcwd(),
        win = {
          position = "bottom",
          height = 0.32,
        },
        interactive = true,
      })
    end)
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Toggle terminal",
  })
)

-- ── Smart arrows in insert mode (still included) ───────────────────────

local function smart_left()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return col == 0 and "<Up><End>" or "<Left>"
end

local function smart_right()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  return cursor[2] >= #line and "<Down><Home>" or "<Right>"
end

map("i", "<Left>", smart_left, {
  expr = true,
  noremap = true,
  desc = "Smart left – jump to previous line if at start",
})
map("i", "<Right>", smart_right, {
  expr = true,
  noremap = true,
  desc = "Smart right – jump to next line if at end",
})

-- ── 3. Buffers & Tabs ──────────────────────────────────────────────────

map("n", "<C-]>", "<cmd>bnext<CR>", default_opts)
map("n", "<A-[>", "<cmd>bprevious<CR>", default_opts)

-- Buffer 1–9
for i = 1, 9 do
  map("n", "<C-" .. i .. ">", function()
    local bufs = vim.fn.getbufinfo({
      buflisted = 1,
    })
    if i <= #bufs then
      vim.cmd("buffer " .. bufs[i].bufnr)
    else
      vim.notify("No buffer #" .. i, vim.log.levels.WARN)
    end
  end, {
    noremap = true,
    silent = true,
    desc = "Buffer " .. i,
  })
end

map("n", "<leader>tn", "<cmd>tabnew<CR>", default_opts)
map("n", "<leader>tc", "<cmd>tabclose<CR>", default_opts)
map("n", "<leader>to", "<cmd>tabonly<CR>", default_opts)

-- ── 4. Text & Clipboard ────────────────────────────────────────────────

map("v", "<C-c>", '"+y', default_opts)
map("n", "<C-v>", '"+p', default_opts)
map("n", "<C-S-v>", '"+P', default_opts)
map("i", "<C-v>", "<C-r>+", default_opts)
map("v", "<C-v>", '"_dP', default_opts)

map(
  { "n", "v", "i" },
  "<C-a>",
  "<Esc>ggVG",
  vim.tbl_extend("force", default_opts, {
    desc = "Select all",
  })
)

map("v", "<Tab>", ">gv", default_opts)
map("v", "<S-Tab>", "<gv", default_opts)

-- ── 5. Search / Picker (Snacks) ────────────────────────────────────────────

map(
  "n",
  ";",
  function()
    Snacks.picker.smart()
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Smart find",
  })
)

map(
  "n",
  ".",
  function()
    Snacks.picker.grep()
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Live grep",
  })
)

map(
  "n",
  ",",
  function()
    Snacks.picker.buffers()
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Buffers",
  })
)

map(
  { "n", "v", "i" },
  "<C-S-f>",
  function()
    local mode = vim.api.nvim_get_mode().mode
    if mode:find "i" then
      vim.cmd "stopinsert"
    elseif mode:find "[vV]" then
      vim.cmd "normal! <Esc>"
    end

    vim.schedule(function()
      Snacks.picker.grep({
        hidden = true,
        ignored = false,
        exclude = { ".git" },
      })
    end)
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Find in files",
  })
)

map(
  "n",
  "\\",
  function()
    toggle_explorer()
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "File explorer",
  })
)

map(
  "n",
  "<C-e>",
  function()
    toggle_explorer()
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Toggle Explorer",
  })
)

map(
  "n",
  "<C-f>",
  function()
    Snacks.picker.lines()
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Fuzzy find in current buffer",
  })
)

map(
  "n",
  "<leader>qg",
  function()
    Snacks.picker.grep({
      hidden = true,
      ignored = false,
      exclude = { ".git" },
      title = "Grep -> quickfix with <C-q>",
    })
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Grep to quickfix",
  })
)

map(
  "n",
  "<leader>qd",
  function()
    vim.diagnostic.setqflist({
      open = true,
      title = "Diagnostics",
    })
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Diagnostics to quickfix",
  })
)

-- ── 6. Plugins & Utilities ─────────────────────────────────────────────

map(
  "n",
  "<C-b>",
  function()
    local ok, nabla = pcall(require, "nabla")
    if not ok then
      vim.notify("nabla is not available", vim.log.levels.WARN)
      return
    end

    nabla.popup({
      border = "single",
    })
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Nabla popup",
  })
)

map(
  "n",
  "<F7>",
  function()
    if vim.fn.exists ":CopilotChatModels" == 2 then
      vim.cmd "CopilotChatModels"
    else
      vim.notify("CopilotChatModels command is not available", vim.log.levels.WARN)
    end
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Select Copilot Chat model",
  })
)

map(
  "n",
  "<F8>",
  function()
    local bufnr = 0
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diagnostics = vim.diagnostic.get(bufnr, {
      lnum = line,
    })
    vim.lsp.buf.code_action({
      context = {
        diagnostics = diagnostics,
      },
    })
  end,
  vim.tbl_extend("force", default_opts, {
    desc = "Show code actions",
  })
)
