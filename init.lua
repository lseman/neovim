-- ============================================================================
-- init.lua – Enhanced Neovim Bootstrap & Early Setup
-- ============================================================================

-- ── Lazy.nvim bootstrap ─────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=main",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to clone lazy.nvim:\n" .. result, vim.log.levels.ERROR)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ── Virtual Environment Auto-Activation ─────────────────────────────────────
local function activate_venv(venv_dir)
  local venv_bin = venv_dir .. "/bin"
  vim.env.PATH = venv_bin .. ":" .. vim.env.PATH
  vim.env.VIRTUAL_ENV = venv_dir
end

local function show_popup(lines, timeout)
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, #line)
  end
  width = math.min(width + 4, vim.o.columns - 4)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = width,
    height = #lines,
    row = 1,
    col = vim.o.columns - width - 2,
    style = "minimal",
    border = "rounded",
  })

  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, timeout or 2200)
end

local function detect_and_activate_venv()
  local cwd = vim.loop.cwd() or vim.fn.getcwd()
  local candidates = { ".venv", "venv", ".env", "env" }

  while cwd and cwd ~= "/" do
    for _, name in ipairs(candidates) do
      local dir = cwd .. "/" .. name
      local py = dir .. "/bin/python"
      if vim.fn.executable(py) == 1 then
        vim.g.python3_host_prog = py
        activate_venv(dir)

        local version = vim.fn.systemlist(py .. " --version 2>&1")[1] or "unknown"
        show_popup({
          "✓ Python environment activated",
          "  " .. dir,
          "  " .. version:gsub("\n", ""),
        }, 2200)
        return
      end
    end
    cwd = vim.fn.fnamemodify(cwd, ":h")
  end

  show_popup({ "⚠ No local venv found", "Using system Python" }, 1800)
end

-- Run early (before plugins)
detect_and_activate_venv()

-- ── Early global settings ───────────────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Performance tweaks
vim.opt.shadafile   = "NONE"    -- disable shada on startup
vim.opt.updatetime  = 250
vim.opt.timeoutlen  = 300
vim.opt.splitright  = true

-- ── Load core configuration modules ────────────────────────────────────────
local function safe_require(name)
  local ok, err = pcall(require, name)
  if not ok then
    vim.notify("Failed to load " .. name .. ":\n" .. tostring(err), vim.log.levels.ERROR)
  end
end

local core_modules = {
  "config.options",
  "config.lazy",
  "config.autocmds",
  "config.diagnostics",
  "config.highlight",
  "config.keymaps",
  "config.custom",
}

for _, mod in ipairs(core_modules) do
  safe_require(mod)
end

-- ── Plugin-specific early setup ─────────────────────────────────────────────
-- safe_require("config.patch")     -- if you have patch_make_position_params etc.
-- safe_require("config.patch2")

-- Telescope extensions
pcall(function()
  local telescope = require("telescope")
  telescope.load_extension("ui-select")
  telescope.load_extension("fzf")
end)

-- nvim-notify (override vim.notify early)
pcall(function()
  local notify = require("notify")
  vim.notify = notify
  notify.setup({
    timeout = 3000,
    max_width = 100,
    render = "minimal",
  })
end)

-- Harpoon (optional)
pcall(require, "config.harpoon")

-- Colorscheme
pcall(vim.cmd, "colorscheme ayu-mirage")

-- ── IPython + tmux-slime + Molten utilities ─────────────────────────────────

-- Slime
vim.g.slime_target = "tmux"
vim.g.slime_default_config = { socket_name = "default", target_pane = ":.1" }
vim.g.slime_dont_ask_default = 1

-- Terminal management globals
_G.last_terminal_jobid = nil

-- <leader>tt → open IPython in vertical split
vim.keymap.set("n", "<leader>tt", function()
  local old = vim.o.splitright
  vim.o.splitright = true
  vim.cmd("vsplit | terminal")
  vim.o.splitright = old

  vim.defer_fn(function()
    local jobid = vim.b.terminal_job_id
    if not jobid then
      print("❌ No terminal job ID detected")
      return
    end

    _G.last_terminal_jobid = jobid
    local send = function(cmd) vim.api.nvim_chan_send(jobid, cmd .. "\n") end

    send("tmux")
    send("source .venv/bin/activate 2>/dev/null || true")
    send("ipython")

    print("✓ IPython terminal ready")
  end, 150)
end, { desc = "Open IPython terminal" })

-- <leader>tr → reset IPython
vim.keymap.set("n", "<leader>tr", function()
  local job = _G.last_terminal_jobid
  if job then
    vim.api.nvim_chan_send(job, "%reset -f\n")
    print("↻ IPython reset sent")
  else
    print("❌ No IPython terminal active")
  end
end, { desc = "Reset IPython session" })

-- <leader>rs → send current # %% cell with %cpaste
vim.keymap.set("n", "<leader>rs", function()
  local start = vim.fn.search("^# %%", "bnW")
  local end_   = vim.fn.search("^# %%", "nW")

  start = (start == 0) and 1 or (start + 1)
  end_   = (end_ == 0) and (vim.fn.line("$") + 1) or (end_ - 1)

  local lines = vim.api.nvim_buf_get_lines(0, start - 1, end_, false)
  local code = table.concat(lines, "\n")

  local payload = "%cpaste -q\n" .. code .. "\n--\n"

  if _G.last_terminal_jobid then
    vim.api.nvim_chan_send(_G.last_terminal_jobid, payload)
  else
    vim.notify("No IPython terminal active (use <leader>tt)", vim.log.levels.ERROR)
  end
end, { desc = "Send current cell to IPython (%cpaste)" })

-- <leader>R → send whole buffer via slime
vim.keymap.set("n", "<leader>R", function()
  if vim.fn.exists("*slime#send") == 0 then
    vim.notify("vim-slime not loaded", vim.log.levels.ERROR)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i, line in ipairs(lines) do
    lines[i] = line:gsub("\r", ""):gsub("\t", " "):gsub("%s+$", "")
  end

  vim.fn["slime#send"](table.concat(lines, "\n") .. "\n")
end, { desc = "Send entire buffer via slime" })

-- ── Molten cell handling ────────────────────────────────────────────────────
function _G.select_current_cell()
  local prev = vim.fn.search("^# %%", "bnW")
  local nxt  = vim.fn.search("^# %%", "nW")
  local last = vim.fn.line("$")

  prev = (prev == 0) and 1 or (prev + 1)
  nxt  = (nxt == 0) and (last + 1) or nxt

  local buf = vim.api.nvim_get_current_buf()
  vim.fn.setpos("'<", { buf, prev, 1, 0 })
  vim.fn.setpos("'>", { buf, nxt - 1, 999, 0 })
  vim.cmd("normal! gv")
end

function _G.run_current_cell()
  _G.select_current_cell()
  vim.cmd("MoltenEvaluateVisual")
end

vim.keymap.set("n", "<F4>", _G.select_current_cell, { desc = "Select current # %% cell" })
vim.keymap.set("n", "<F5>", _G.run_current_cell,    { desc = "Run current # %% cell" })
vim.keymap.set("n", "<leader>mr", "<cmd>MoltenRestart<CR>", { desc = "Restart Molten kernel" })

-- ── Venv & Python runner (if modules exist) ────────────────────────────────
pcall(function()
  local env = require("config.env")
  env.setup({ venv_dirs = { ".venv", "venv" }, auto_activate = true, notify = true })

  vim.keymap.set("n", "<leader>va", env.activate,    { desc = "Activate venv" })
  vim.keymap.set("n", "<leader>vd", env.deactivate,  { desc = "Deactivate venv" })
  vim.keymap.set("n", "<leader>vs", env.select,      { desc = "Select venv" })
  vim.keymap.set("n", "<leader>vc", function()
    local cur = env.current()
    print(cur and ("Active: " .. cur.name .. " (" .. cur.root .. ")") or "No venv active")
  end, { desc = "Show current venv" })
end)

pcall(function()
  local runner = require("config.runner")
  runner.setup({
    python_cmd = "python3",
    auto_save = true,
    notify = true,
    clear_terminal = true,
  })

  vim.keymap.set("n", "<leader>py", runner.run_file,        { desc = "Run Python file" })
  vim.keymap.set("n", "<leader>pa", runner.run_with_args,   { desc = "Run with args" })
  vim.keymap.set("n", "<leader>pi", runner.run_interactive, { desc = "Python interactive" })
  vim.keymap.set("n", "<leader>pt", runner.toggle_terminal, { desc = "Toggle Python terminal" })
  vim.keymap.set("n", "<leader>pr", runner.repeat_last,     { desc = "Repeat last run" })
  vim.keymap.set("n", "<leader>ph", runner.run_from_history,{ desc = "Run from history" })
end)

-- ── Health check command ────────────────────────────────────────────────────
vim.api.nvim_create_user_command("HealthCheck", function()
  local checks = {
    { "config.env",       "Virtualenv manager" },
    { "config.runner",    "Python runner" },
    { "telescope",        "Telescope" },
    { "notify",           "nvim-notify" },
  }

  print("┌────────────────────── Health Check ──────────────────────┐")
  for _, check in ipairs(checks) do
    local ok = pcall(require, check[1])
    print(string.format("│ %-20s : %s", check[2], ok and "✓ OK" or "✗ Missing"))
  end
  print("│ vim-slime              : " .. (vim.g.loaded_slime and "✓ OK" or "✗ Missing"))
  print("└──────────────────────────────────────────────────────────┘")
end, { desc = "Show configuration health status" })

vim.keymap.set("n", "<leader>ch", "<cmd>HealthCheck<CR>", { desc = "Health check" })

-- ── Utility mappings ────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>w",  "<cmd>write<CR>",       { desc = "Save" })
vim.keymap.set("n", "<Esc>",      "<cmd>nohlsearch<CR>",  { desc = "Clear hlsearch" })
vim.keymap.set("n", "<leader>tc", function()
  if _G.last_terminal_jobid then
    vim.api.nvim_chan_send(_G.last_terminal_jobid, "exit\n")
    _G.last_terminal_jobid = nil
    print("Terminal session closed")
  else
    print("No active terminal")
  end
end, { desc = "Close IPython terminal" })

-- Config reload
vim.api.nvim_create_user_command("Rconf", function()
  for name in pairs(package.loaded) do
    if name:match("^config%.") then
      package.loaded[name] = nil
    end
  end
  safe_require("config.lazy")
  vim.notify("Configuration reloaded", vim.log.levels.INFO)
end, { desc = "Reload config modules" })

-- Log session start
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local log = vim.fn.stdpath("log") .. "/plugin-errors.log"
    local f = io.open(log, "a")
    if f then
      f:write("Session start: " .. os.date() .. "\n")
      f:close()
    end
  end,
})

-- Optional: early notify override if notify loaded later
vim.defer_fn(function()
  pcall(function()
    vim.notify = require("notify")
  end)
end, 50)