local api = vim.api
local lsp = vim.lsp
local generation = 0

return function()
    generation = generation + 1
    local request_generation = generation
    local source_buf = api.nvim_get_current_buf()
    local source_win = api.nvim_get_current_win()
    local cursor = api.nvim_win_get_cursor(source_win)
    local changedtick = api.nvim_buf_get_changedtick(source_buf)
    local clients = lsp.get_clients({ bufnr = source_buf, method = "textDocument/rename" })
    if #clients == 0 then
        vim.notify("No language server supports rename in this buffer", vim.log.levels.INFO)
        return
    end
    table.sort(clients, function(a, b)
        local a_prepare = a:supports_method("textDocument/prepareRename", source_buf)
        local b_prepare = b:supports_method("textDocument/prepareRename", source_buf)
        if a_prepare ~= b_prepare then
            return a_prepare
        end
        return a.id < b.id
    end)
    local client = clients[1]
    local params = lsp.util.make_position_params(source_win, client.offset_encoding)
    local cword = vim.fn.expand "<cword>"

    local function source_valid()
        return request_generation == generation
            and api.nvim_win_is_valid(source_win)
            and api.nvim_buf_is_valid(source_buf)
            and api.nvim_win_get_buf(source_win) == source_buf
            and api.nvim_buf_get_changedtick(source_buf) == changedtick
            and vim.deep_equal(api.nvim_win_get_cursor(source_win), cursor)
    end

    local function open_prompt(symbol)
        if not source_valid() or api.nvim_get_current_win() ~= source_win then
            return
        end
        local buf = api.nvim_create_buf(false, true)
        vim.bo[buf].bufhidden = "wipe"
        local win = api.nvim_open_win(buf, true, {
            relative = "cursor",
            row = 1,
            col = 0,
            width = math.min(math.max(vim.fn.strdisplaywidth(symbol) + 8, 24), math.max(1, vim.o.columns - 4)),
            height = 1,
            style = "minimal",
            border = "rounded",
            title = " Rename ",
            title_pos = "center",
        })
        vim.wo[win].winhl = "Normal:NormalFloat,FloatBorder:FloatBorder"
        api.nvim_buf_set_lines(buf, 0, -1, false, { symbol })
        api.nvim_win_set_cursor(win, { 1, #symbol })
        local closed = false
        local function close()
            if closed then
                return
            end
            closed = true
            vim.cmd.stopinsert()
            if api.nvim_win_is_valid(win) then
                api.nvim_win_close(win, true)
            end
            if api.nvim_buf_is_valid(buf) then
                api.nvim_buf_delete(buf, { force = true })
            end
        end
        local function submit()
            local name = vim.trim(api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "")
            local valid = source_valid()
            close()
            if not valid or name == "" or name == symbol then
                return
            end
            -- Reuse the original position and the selected client's encoding.
            local rename_params = vim.tbl_extend("force", params, { newName = name })
            local handler = client.handlers["textDocument/rename"] or lsp.handlers["textDocument/rename"]
            client:request("textDocument/rename", rename_params, handler, source_buf)
        end
        vim.keymap.set({ "i", "n" }, "<CR>", submit, { buffer = buf, nowait = true, desc = "Confirm rename" })
        vim.keymap.set({ "i", "n" }, "<Esc>", close, { buffer = buf, nowait = true, desc = "Cancel rename" })
        vim.keymap.set("i", "<C-c>", close, { buffer = buf, nowait = true, desc = "Cancel rename" })
        api.nvim_create_autocmd("WinLeave", {
            buffer = buf,
            once = true,
            callback = function()
                vim.schedule(close)
            end,
        })
        vim.cmd.startinsert({ bang = true })
    end

    if not client:supports_method("textDocument/prepareRename", source_buf) then
        open_prompt(cword)
        return
    end
    client:request("textDocument/prepareRename", params, function(err, result)
        if not source_valid() or api.nvim_get_current_win() ~= source_win then
            return
        end
        if err or not result then
            vim.notify(err and err.message or "Nothing to rename here", vim.log.levels.INFO)
            return
        end
        local symbol = result.placeholder
        local range = result.range or (result.start and result)
        if not symbol and range then
            symbol = api.nvim_buf_get_text(
                source_buf,
                range.start.line,
                lsp.util._get_line_byte_from_position(source_buf, range.start, client.offset_encoding),
                range["end"].line,
                lsp.util._get_line_byte_from_position(source_buf, range["end"], client.offset_encoding),
                {}
            )[1]
        end
        open_prompt(symbol or cword)
    end, source_buf)
end
