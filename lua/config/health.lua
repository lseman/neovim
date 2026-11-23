local M = {}

local function executable(name, purpose, required)
    local path = vim.fn.exepath(name)
    if path ~= "" then
        vim.health.ok(purpose .. ": " .. path)
    elseif required then
        vim.health.error(purpose .. ": missing " .. name)
    else
        vim.health.warn(purpose .. ": missing " .. name .. " (needed only for this workflow)")
    end
end

function M.check()
    vim.health.start("Neovim configuration")
    if vim.fn.has("nvim-0.12") == 1 then
        vim.health.ok("Neovim 0.12+ with native LSP inline completion")
    else
        vim.health.error("Neovim 0.12 or newer is required")
    end
    executable("git", "Plugin installation", true)
    for name, purpose in pairs({ rg = "Project search", fd = "File search", stylua = "Lua formatting" }) do
        executable(name, purpose)
    end
    local lazy = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")
    if vim.uv.fs_stat(lazy) then
        vim.health.ok("lazy.nvim installed")
    else
        vim.health.error("lazy.nvim is missing; start Neovim with this configuration to bootstrap it")
    end

    vim.health.start("Python and notebooks")
    executable("python3", "Python runner")
    for _, name in ipairs({ "jupyter", "jupytext", "quarto", "magick" }) do
        executable(name, name)
    end
    local host = vim.g.python3_host_prog or vim.fn.exepath("python3")
    if host and host ~= "" and vim.fn.executable(host) == 1 then
        local result = vim.system({ host, "-c", "import pynvim, jupyter_client, nbformat, PIL, requests, websocket" },
            { text = true }):wait(5000)
        if result.code == 0 then
            vim.health.ok("Python remote host and Molten dependencies: " .. host)
        else
            vim.health.warn("Python host dependencies unavailable: " .. host, { vim.trim(result.stderr or "") })
        end
    else
        vim.health.warn("No Python remote host configured")
    end
    vim.health.info("Active environment: " .. (vim.env.VIRTUAL_ENV or vim.env.CONDA_DEFAULT_ENV or "system"))
end

return M
