local M = {}
local api = vim.api

function M.setup(client, bufnr)
    if not api.nvim_buf_is_valid(bufnr) or not client:supports_method("textDocument/signatureHelp", bufnr) then
        return
    end
    local group = api.nvim_create_augroup("LspSignature", { clear = false })
    -- One callback per buffer, regardless of how many servers attach.
    api.nvim_clear_autocmds({ group = group, buffer = bufnr })
    api.nvim_create_autocmd("TextChangedI", {
        group = group,
        buffer = bufnr,
        desc = "Show LSP signatures after a trigger character",
        callback = function()
            if api.nvim_get_current_buf() ~= bufnr or vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
                return
            end
            local col = api.nvim_win_get_cursor(0)[2]
            local before_cursor = api.nvim_get_current_line():sub(1, col)
            -- Query attached clients at trigger time so detach and additional
            -- servers cannot leave stale or overwritten trigger characters.
            for _, attached in ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/signatureHelp" })) do
                local provider = attached.server_capabilities.signatureHelpProvider or {}
                local triggers = vim.list_extend(
                    vim.deepcopy(provider.triggerCharacters or {}),
                    provider.retriggerCharacters or {}
                )
                for _, char in ipairs(triggers) do
                    if #char > 0 and before_cursor:sub(-#char) == char then
                        vim.lsp.buf.signature_help({ focus = false, silent = true, max_height = 7, border = "rounded" })
                        return
                    end
                end
            end
        end,
    })
end

return M
