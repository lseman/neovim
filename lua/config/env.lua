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

return M
