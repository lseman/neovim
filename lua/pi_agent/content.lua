-- lua/plugins/pi-agent/content.lua
-- Content awareness for pi coding agent

local Content = {}

function Content.get_current_buffer()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    return {
        bufnr = bufnr,
        filename = vim.api.nvim_buf_get_name(bufnr),
        filetype = vim.api.nvim_buf_get_option(bufnr, "filetype"),
        content = table.concat(lines, "\n"),
        lines = lines,
    }
end

function Content.get_selected_text()
    local mode = vim.fn.mode()
    local selected = nil

    if mode == "v" or mode == "V" or mode == "\22" then
        local start_pos = vim.fn.getpos "v"
        local end_pos = vim.fn.getpos "."

        local start_line = start_pos[2]
        local start_col = start_pos[3]
        local end_line = end_pos[2]
        local end_col = end_pos[3]

        if start_line > end_line then
            start_line, end_line = end_line, start_line
            start_col, end_col = end_col, start_col
        elseif start_line == end_line and start_col > end_col then
            start_col, end_col = end_col, start_col
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

        if #lines == 1 then
            selected = lines[1]:sub(start_col, end_col)
        else
            lines[1] = lines[1]:sub(start_col)
            lines[#lines] = lines[#lines]:sub(1, end_col)
            selected = table.concat(lines, "\n")
        end
    end

    return selected
end

function Content.get_project_context()
    local cwd = vim.fn.getcwd()
    local context = {
        files = {},
    }

    -- Get recent files or open buffers
    local buffers = vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })
    for _, buf in ipairs(buffers) do
        if buf.name and buf.name ~= "" and buf.name ~= "NO_FILE" then
            table.insert(context.files, buf.name)
        end
    end

    return context
end

function Content.build_prompt_message(user_message)
    local content_parts = {}

    -- Add selected text if exists
    local selected = Content.get_selected_text()
    if selected and selected ~= "" then
        local buf = Content.get_current_buffer()
        table.insert(
            content_parts,
            string.format("Selected code from %s:\n```%s\n%s\n```", buf.filename, buf.filetype, selected)
        )
    end

    -- Add current buffer context
    local buf = Content.get_current_buffer()
    if not selected or selected == "" then
        table.insert(
            content_parts,
            string.format("Current file (%s):\n```%s\n%s\n```", buf.filename, buf.filetype, buf.content)
        )
    end

    -- Add project context
    local project = Content.get_project_context()
    if #project.files > 0 then
        table.insert(content_parts, "Open buffers:\n" .. table.concat(project.files, "\n"))
    end

    local final_message = user_message or ""
    if #content_parts > 0 then
        final_message = final_message .. "\n\n--- Context ---\n" .. table.concat(content_parts, "\n\n")
    end

    return final_message
end

return Content
