-- venv.lua - Python Virtual Environment Plugin for Neovim

local M = {}

-- Configuration
local config = {
  venv_dirs = { ".venv", "venv", "env", ".env" },
  auto_activate = true,
  notify = true,
  python_paths = {},
}

-- State tracking
local state = {
  current_venv = nil,
  original_path = nil,
  original_python = nil,
}

-- Utility functions
local function notify(message, level)
  if config.notify then
    vim.notify("[VEnv] " .. message, level or vim.log.levels.INFO)
  end
end

local function is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

local function get_python_executable(venv_path)
  local python_exe = is_windows() and "python.exe" or "python"
  local scripts_dir = is_windows() and "Scripts" or "bin"
  return vim.fn.resolve(venv_path .. "/" .. scripts_dir .. "/" .. python_exe)
end

local function get_activate_script(venv_path)
  local scripts_dir = is_windows() and "Scripts" or "bin"
  local activate_script = is_windows() and "activate.bat" or "activate"
  return vim.fn.resolve(venv_path .. "/" .. scripts_dir .. "/" .. activate_script)
end

local function find_venv(start_path)
  start_path = start_path or vim.fn.getcwd()
  local current_dir = start_path

  while current_dir ~= "/" and current_dir ~= "" do
    for _, venv_name in ipairs(config.venv_dirs) do
      local venv_path = current_dir .. "/" .. venv_name
      if vim.fn.isdirectory(venv_path) == 1 then
        local python_path = get_python_executable(venv_path)
        if vim.fn.executable(python_path) == 1 then
          return {
            path = venv_path,
            python = python_path,
            activate = get_activate_script(venv_path),
            name = venv_name,
            root = current_dir,
          }
        end
      end
    end
    local parent = vim.fn.fnamemodify(current_dir, ":h")
    if parent == current_dir then break end
    current_dir = parent
  end
  return nil
end

local function set_venv_environment(venv_info)
  if not venv_info then return false end
  if not state.original_path then
    state.original_path = vim.fn.getenv("PATH")
    state.original_python = vim.fn.getenv("PYTHONPATH")
  end

  vim.fn.setenv("VIRTUAL_ENV", venv_info.path)

  local scripts_dir = is_windows() and "Scripts" or "bin"
  local venv_bin = venv_info.path .. "/" .. scripts_dir
  local current_path = vim.fn.getenv("PATH")

  local path_parts = vim.split(current_path, is_windows() and ";" or ":")
  local cleaned_parts = {}
  for _, part in ipairs(path_parts) do
    if not part:match(".*[\\/](Scripts|bin)$") then
      table.insert(cleaned_parts, part)
    end
  end

  table.insert(cleaned_parts, 1, venv_bin)
  local new_path = table.concat(cleaned_parts, is_windows() and ";" or ":")
  vim.fn.setenv("PATH", new_path)

  vim.g.python3_host_prog = venv_info.python

  return true
end

local function restore_environment()
  if state.original_path then
    vim.fn.setenv("PATH", state.original_path)
  end
  if state.original_python then
    vim.fn.setenv("PYTHONPATH", state.original_python)
  else
    vim.fn.setenv("PYTHONPATH", nil)
  end
  vim.fn.setenv("VIRTUAL_ENV", nil)

  state.current_venv = nil
  state.original_path = nil
  state.original_python = nil
end

function M.activate(venv_path)
  local venv_info
  if venv_path then
    if vim.fn.isdirectory(venv_path) == 1 then
      local python_path = get_python_executable(venv_path)
      if vim.fn.executable(python_path) == 1 then
        venv_info = {
          path = venv_path,
          python = python_path,
          activate = get_activate_script(venv_path),
          name = vim.fn.fnamemodify(venv_path, ":t"),
          root = vim.fn.fnamemodify(venv_path, ":h"),
        }
      end
    end
  else
    venv_info = find_venv()
  end

  if not venv_info then
    notify("No virtual environment found", vim.log.levels.WARN)
    return false
  end

  if state.current_venv then
    M.deactivate()
  end

  if set_venv_environment(venv_info) then
    state.current_venv = venv_info
    notify("Activated: " .. venv_info.name .. " (" .. venv_info.root .. ")")
    M.update_terminals()
    return true
  else
    notify("Failed to activate virtual environment", vim.log.levels.ERROR)
    return false
  end
end

function M.deactivate()
  if not state.current_venv then
    notify("No virtual environment is currently active")
    return false
  end
  local venv_name = state.current_venv.name
  restore_environment()
  notify("Deactivated: " .. venv_name)
  M.update_terminals()
  return true
end

function M.current()
  return state.current_venv
end

local cached_version = nil

function M.status()
  if not state.current_venv then
    cached_version = nil
    return ""
  end

  if not cached_version then
    local python = state.current_venv.python
    local handle = io.popen(string.format('"%s" --version 2>&1', python))
    local version = handle and handle:read("*a") or ""
    if handle then handle:close() end
    version = version:gsub("\n", ""):gsub("Python ", "")
    cached_version = version
  end

  return string.format(" %s (%s)", state.current_venv.name, cached_version)
end


function M.update_terminals()
  local term_bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local bt = vim.api.nvim_buf_get_option(buf, "buftype")
      if bt == "terminal" then
        table.insert(term_bufs, buf)
      end
    end
  end
  for _, buf in ipairs(term_bufs) do
    local ok, chan = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
    if ok and chan then
      if state.current_venv then
        local activate_cmd = is_windows()
          and '"' .. state.current_venv.activate .. '"'
          or "source " .. state.current_venv.activate
        vim.api.nvim_chan_send(chan, activate_cmd .. "\n")
      else
        if not is_windows() then
          vim.api.nvim_chan_send(chan, "deactivate 2>/dev/null || true\n")
        end
      end
    end
  end
end

function M.list()
  local venvs = {}
  local current_dir = vim.fn.getcwd()
  while current_dir ~= "/" and current_dir ~= "" do
    for _, venv_name in ipairs(config.venv_dirs) do
      local venv_path = current_dir .. "/" .. venv_name
      if vim.fn.isdirectory(venv_path) == 1 then
        local python_path = get_python_executable(venv_path)
        if vim.fn.executable(python_path) == 1 then
          table.insert(venvs, {
            name = venv_name,
            path = venv_path,
            root = current_dir,
            python = python_path,
          })
        end
      end
    end
    local parent = vim.fn.fnamemodify(current_dir, ":h")
    if parent == current_dir then break end
    current_dir = parent
  end
  return venvs
end

function M.select()
  local venvs = M.list()
  if #venvs == 0 then
    notify("No virtual environments found", vim.log.levels.WARN)
    return
  end
  local choices = {}
  for i, venv in ipairs(venvs) do
    local active_marker = (state.current_venv and state.current_venv.path == venv.path) and "* " or "  "
    table.insert(choices, string.format("%s%s (%s)", active_marker, venv.name, venv.root))
  end
  vim.ui.select(choices, {
    prompt = "Select virtual environment:",
  }, function(choice, idx)
    if choice and idx then
      M.activate(venvs[idx].path)
    end
  end)
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  if config.auto_activate then
    vim.defer_fn(function()
      M.activate()
    end, 100)
  end
  vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
      if config.auto_activate then
        M.activate()
      end
    end,
  })
  vim.api.nvim_create_user_command("VenvActivate", function(args)
    M.activate(args.args ~= "" and args.args or nil)
  end, { nargs = "?", complete = "dir", desc = "Activate Python virtual environment" })
  vim.api.nvim_create_user_command("VenvDeactivate", M.deactivate, { desc = "Deactivate Python virtual environment" })
  vim.api.nvim_create_user_command("VenvSelect", M.select, { desc = "Select Python virtual environment" })
  vim.api.nvim_create_user_command("VenvCurrent", function()
    local current = M.current()
    if current then
      print("Active: " .. current.name .. " (" .. current.root .. ")")
      print("Python: " .. current.python)
    else
      print("No virtual environment active")
    end
  end, { desc = "Show current virtual environment" })
end

return M