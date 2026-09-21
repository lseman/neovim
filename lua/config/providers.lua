-- Pin the Neovim Python host so remote plugins (e.g. molten-nvim) always
-- find pynvim, regardless of project venvs.
--
-- Resolving costs a subprocess + `import pynvim` per candidate (~100ms), so
-- the winner is cached in stdpath("state")/python-host.txt. A cached entry is
-- trusted after a cheap executable() check (no subprocess); delete the file
-- to force re-resolution.
do
  local cache = vim.fs.joinpath(vim.fn.stdpath "state", "python-host.txt")

  local function can_host(path)
    return path ~= ""
      and vim.fn.executable(path) == 1
      and vim.system({ path, "-c", "import pynvim" }):wait().code == 0
  end

  local cached = vim.fn.filereadable(cache) == 1 and vim.fn.readfile(cache) or {}
  local host = #cached == 1 and cached[1] or nil

  if host and vim.fn.executable(host) == 1 then
    vim.g.python3_host_prog = host
  else
    local candidates = {
      vim.fs.joinpath(vim.fn.stdpath "data", "python-host", "bin", "python"),
      vim.fn.exepath "python3",
      "/usr/bin/python3",
      "/usr/local/bin/python3",
    }
    for _, path in ipairs(candidates) do
      if can_host(path) then
        vim.g.python3_host_prog = path
        pcall(vim.fn.mkdir, vim.fs.dirname(cache), "p")
        vim.fn.writefile({ path }, cache)
        break
      end
    end
  end
end
