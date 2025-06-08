-- ============================================================================
-- Enhanced Neovim Configuration (Fully Adjusted)
-- ============================================================================

-- Bootstrap lazy.nvim with error handling
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    local result = vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git', '--branch=main', lazypath
    })
    if vim.v.shell_error ~= 0 then
        vim.notify('Failed to clone lazy.nvim: ' .. result, vim.log.levels.ERROR)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Early init
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Performance opts
local opts = { shadafile = "NONE", updatetime = 250, timeoutlen = 300 }
for k, v in pairs(opts) do vim.opt[k] = v end

-- Patch safe load
pcall(function()
  require("config.patch").patch_make_position_params()
  require("config.patch2").patch_start_client()
end)

vim.opt.splitright = true

-- Load core modules
local function load_modules()
  for _, mod in ipairs({
    'config.options', 'config.lazy', 'config.autocmds', 'config.diagnostics',
    'config.highlight', 'config.keymaps', 'config.dap', 'config.custom'
  }) do
    local ok, err = pcall(require, mod)
    if not ok then
      vim.notify('Failed to load ' .. mod .. ':\n' .. err, vim.log.levels.ERROR)
    end
  end
end

-- Setup telescope extensions
local function setup_telescope()
  local ok, telescope = pcall(require, 'telescope')
  if ok then
    for _, ext in ipairs({ 'ui-select', 'fzf' }) do
      pcall(telescope.load_extension, ext)
    end
  end
end

-- Setup notify
local function setup_notify()
  local ok, notify = pcall(require, "notify")
  if ok then
    vim.notify = notify
    notify.setup({ timeout = 3000, max_width = 100, render = "minimal" })
  end
end

-- Initialize
local function init()
  load_modules()
  setup_telescope()
  setup_notify()
  pcall(require, 'config.harpoon')
  pcall(vim.cmd, 'colorscheme ayu-mirage')
end
init()

-- Molten config
vim.g.molten_auto_open_output = false
vim.g.molten_image_provider = "image.nvim"
vim.g.molten_wrap_output = true
vim.g.molten_virt_text_output = true
vim.g.molten_virt_lines_off_by_1 = true

-- Slime config
vim.g.slime_target = "tmux"
vim.g.slime_default_config = { socket_name = "default", target_pane = ":.1" }
vim.g.slime_dont_ask_default = 1

-- Terminal management
_G.last_terminal_jobid = nil
vim.keymap.set("n", "<leader>tt", function()
  local old_splitright = vim.o.splitright
  vim.o.splitright = true
  vim.cmd("vsplit | terminal")
  vim.o.splitright = old_splitright
  vim.defer_fn(function()
    local jobid = vim.b.terminal_job_id
    if jobid then
      _G.last_terminal_jobid = jobid
      local feed = function(cmd) vim.api.nvim_chan_send(jobid, cmd .. "\n") end
      feed("tmux")
      feed("source .venv/bin/activate || . .venv/bin/activate")
      feed("ipython")
      print("✅ Terminal setup complete.")
    else
      print("❌ Could not detect terminal job ID.")
    end
  end, 100)
end, { desc = "Open terminal and IPython" })

vim.keymap.set("n", "<leader>tr", function()
  local jobid = _G.last_terminal_jobid
  if jobid then
    vim.api.nvim_chan_send(jobid, "%reset -f\n")
    print("🔁 Sent reset to terminal.")
  else
    print("❌ No terminal job ID stored.")
  end
end, { desc = "Reset IPython" })

-- Slime cell execution
vim.keymap.set("n", "<leader>r", function()
  local s = vim.fn.search("# %%", "bnW")
  local e = vim.fn.search("# %%", "nW")
  s = (s == 0) and 1 or s + 1
  e = (e == 0) and (vim.fn.line("$") + 1) or (e - 1)
  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
  local base_indent = math.huge
  for _, l in ipairs(lines) do
    local ind = l:match("^(%s*)")
    base_indent = math.min(base_indent, #ind)
  end
  for i, l in ipairs(lines) do
    lines[i] = l:sub(base_indent + 1)
  end
  local text = table.concat(lines, "\n") .. "\n"
  if vim.fn.exists("*slime#send") == 1 then
    vim.fn["slime#send"](text)
  else
    vim.notify("vim-slime not loaded", vim.log.levels.ERROR)
  end
end, { desc = "Send current # %% cell" })

vim.keymap.set("n", "<leader>R", function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i, l in ipairs(lines) do
    lines[i] = l:gsub("\r", ""):gsub("\t", "    "):gsub("%s+$", "")
  end
  local text = table.concat(lines, "\n") .. "\n"
  if vim.fn.exists("*slime#send") == 1 then
    vim.fn["slime#send"](text)
  else
    vim.notify("vim-slime not loaded", vim.log.levels.ERROR)
  end
end, { desc = "Send entire buffer" })

-- Tree selection
pcall(function()
  local sel = require('config.selection')
  vim.keymap.set("n", "vv", sel.start_selection, { desc = "Start selection" })
  vim.api.nvim_set_keymap("v", "<C-Space>", ":lua require('config.selection').expand_selection()<CR>", { noremap = true, silent = true })
  vim.keymap.set("v", "<BS>", sel.contract_selection, { desc = "Contract selection" })
end)

-- Venv setup
pcall(function()
  local env = require("config.env")
  env.setup({ venv_dirs = {".venv", "venv"}, auto_activate = true, notify = true })
  vim.keymap.set("n", "<leader>va", env.activate, { desc = "Activate venv" })
  vim.keymap.set("n", "<leader>vd", env.deactivate, { desc = "Deactivate venv" })
  vim.keymap.set("n", "<leader>vs", env.select, { desc = "Select venv" })
  vim.keymap.set("n", "<leader>vc", function()
    local cur = env.current()
    if cur then print("Active: " .. cur.name .. " (" .. cur.root .. ")")
    else print("No venv active") end
  end, { desc = "Current venv" })
end)

-- Python runner setup
pcall(function()
  local py = require("config.runner")
  py.setup({ python_cmd = "python3", auto_save = true, notify = true, clear_terminal = true })
  vim.keymap.set("n", "<leader>py", py.run_file, { desc = "Run Python file" })
  vim.keymap.set("n", "<leader>pa", py.run_with_args, { desc = "Run Python with args" })
  vim.keymap.set("n", "<leader>pi", py.run_interactive, { desc = "Python interactive" })
  vim.keymap.set("n", "<leader>pt", py.toggle_terminal, { desc = "Toggle Python terminal" })
  vim.keymap.set("n", "<leader>pr", py.repeat_last, { desc = "Repeat last command" })
  vim.keymap.set("n", "<leader>ph", py.run_from_history, { desc = "Run from history" })
end)

-- Health check
vim.api.nvim_create_user_command('HealthCheck', function()
  local modules = {
    { 'config.selection', 'Tree selection' },
    { 'config.env', 'Virtual environment' },
    { 'config.runner', 'Python runner' },
    { 'telescope', 'Telescope' },
    { 'notify', 'Notifications' },
  }
  print("=== Neovim Health Check ===")
  for _, m in ipairs(modules) do
    local ok = pcall(require, m[1])
    print(string.format("%s: %s", m[2], ok and "✅ OK" or "❌ Missing"))
  end
  print("vim-slime: " .. (vim.g.loaded_slime and "✅ OK" or "❌ Missing"))
end, { desc = 'Check config health' })

-- Utility maps
vim.keymap.set('n', '<leader>ch', '<cmd>HealthCheck<cr>', { desc = 'Run health check' })
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save file' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })

vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move left' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move down' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move up' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move right' })

vim.keymap.set('n', '<leader>tc', function()
  if _G.last_terminal_jobid then
    vim.api.nvim_chan_send(_G.last_terminal_jobid, "exit\n")
    _G.last_terminal_jobid = nil
    print("🔒 Terminal closed")
  else
    print("❌ No active terminal")
  end
end, { desc = 'Close terminal session' })

vim.notify = require("notify")  -- if using nvim-notify

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local f = io.open(vim.fn.stdpath("log") .. "/plugin-errors.log", "a")
    if f then
      f:write("Session start: " .. os.date() .. "\\n")
      f:close()
    end
  end,
})
