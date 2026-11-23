local M = { large_file_bytes = 1024 * 1024, treesitter_bytes = 200 * 1024 }

function M.is_large(bufnr, limit)
    if not vim.api.nvim_buf_is_loaded(bufnr) then return false end
    local bytes = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
    return bytes >= (limit or M.large_file_bytes)
end

return M
