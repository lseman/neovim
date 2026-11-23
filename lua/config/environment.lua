-- Project environments belong to the Neovim process; keep this module loaded on reload.
local M = {}
local inherited = { path = vim.env.PATH or "", venv = vim.env.VIRTUAL_ENV }
local active_bin
local previous_path
local callbacks = {}
local versions = {}
local generation = 0

function M.on_activated(callback)
    callbacks[#callbacks + 1] = callback
end

function M.find(start_dir)
    for dir in vim.fs.parents(vim.fs.joinpath(start_dir, "__environment__")) do
        for _, name in ipairs({ ".venv", "venv", ".env", "env" }) do
            local path = vim.fs.joinpath(dir, name)
            if vim.fn.executable(vim.fs.joinpath(path, "bin", "python")) == 1 then
                return path
            end
        end
    end
end

local function remove_bin(path, bin)
    local entries = vim.split(path, ":", { plain = true })
    return table.concat(vim.tbl_filter(function(entry) return entry ~= bin end, entries), ":")
end

function M.activate_for_dir(dir)
    local venv = M.find(dir)
    if not venv then
        if active_bin then
            generation = generation + 1
            -- Keep tools added while the project was active (for example Mason),
            -- while restoring the inherited environment's original PATH entries.
            local original = {}
            for _, entry in ipairs(vim.split(previous_path, ":", { plain = true })) do
                original[entry] = true
            end
            local added = vim.tbl_filter(function(entry)
                return entry ~= active_bin and not original[entry]
            end, vim.split(vim.env.PATH or "", ":", { plain = true }))
            vim.env.PATH = (#added > 0 and (table.concat(added, ":") .. ":") or "") .. previous_path
            vim.env.VIRTUAL_ENV = inherited.venv
            active_bin = nil
        end
        return false
    end
    if venv == vim.env.VIRTUAL_ENV then
        return true
    end
    local path = vim.env.PATH or inherited.path
    if not active_bin then previous_path = path end
    if active_bin then
        path = remove_bin(path, active_bin)
    elseif inherited.venv then
        path = remove_bin(path, vim.fs.joinpath(inherited.venv, "bin"))
    end
    generation = generation + 1
    local activation = generation
    active_bin = vim.fs.joinpath(venv, "bin")
    vim.env.PATH = active_bin .. ":" .. remove_bin(path, active_bin)
    vim.env.VIRTUAL_ENV = venv
    vim.schedule(function()
        if activation ~= generation then return end
        for _, callback in ipairs(callbacks) do
            local ok, err = pcall(callback, venv)
            if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
        end
    end)
    -- Resolve a version once per environment without blocking buffer switches.
    if not versions[venv] then
        versions[venv] = true
        vim.system({ vim.fs.joinpath(active_bin, "python"), "--version" }, { text = true }, function(result)
            vim.schedule(function()
                if result.code == 0 and activation == generation then
                    require("config.env").notify_loaded(venv, vim.trim(result.stdout or ""))
                end
            end)
        end)
    end
    return true
end

return M
