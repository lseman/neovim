local M = {}

local function basename(path)
  if not path or path == "" then
    return nil
  end

  return vim.fn.fnamemodify(path, ":t")
end

function M.status()
  local venv = basename(vim.env.VIRTUAL_ENV)
  if venv then
    return " " .. venv
  end

  local conda = vim.env.CONDA_DEFAULT_ENV or basename(vim.env.CONDA_PREFIX)
  if conda then
    return " " .. conda
  end

  return ""
end

function M.notify_loaded(path, version)
  local name = basename(path) or path or "environment"
  local details = version and version ~= "" and (" (" .. version:gsub("\n", "") .. ")") or ""
  local message = "Loaded env: " .. name .. details

  local function notify()
    vim.notify(message, vim.log.levels.INFO)
  end

  if vim.v.vim_did_enter == 1 then
    vim.schedule(notify)
  else
    vim.api.nvim_create_autocmd("UIEnter", {
      once = true,
      callback = notify,
    })
  end
end

return M
