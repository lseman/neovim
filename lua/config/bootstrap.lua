local M = {}

function M.setup()
    local lazypath = vim.fs.joinpath(vim.fn.stdpath "data", "lazy", "lazy.nvim")
    if not vim.uv.fs_stat(lazypath) then
        local result = vim.system({
            "git",
            "clone",
            "--filter=blob:none",
            "--branch=stable",
            "https://github.com/folke/lazy.nvim.git",
            lazypath,
        }):wait()
        if result.code ~= 0 then
            vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { result.stderr, "WarningMsg" } }, true, {})
            return false
        end
    end
    vim.opt.rtp:prepend(lazypath)
    return true
end

return M
