local M = {}
-- Retain the existing path so saved selections survive the reorganization.
local path = vim.fn.stdpath("data") .. "/theme_picker_last.txt"

function M.save_theme(name)
    local ok, err = pcall(vim.fn.writefile, { name, vim.o.background }, path)
    if not ok then
        vim.notify("Could not save theme: " .. tostring(err), vim.log.levels.WARN)
    end
end

function M.load_saved_theme()
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok or not lines[1] or lines[1] == "" then return end
    local bg = lines[2]
    if bg ~= "light" and bg ~= "dark" then bg = nil end
    return lines[1], bg
end

function M.restore()
    local name, bg = M.load_saved_theme()
    if bg then vim.o.background = bg end
    for _, candidate in ipairs({ name or "ayu-mirage", "ayu-mirage", "habamax" }) do
        if pcall(vim.cmd.colorscheme, candidate) then
            vim.g.current_theme = candidate
            return
        end
    end
end

return M
