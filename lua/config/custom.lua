local M = {}

-- Core telescope requirements
local telescope = {
    actions = require('telescope.actions'),
    state = require('telescope.actions.state'),
    pickers = require('telescope.pickers'),
    finders = require('telescope.finders'),
    conf = require('telescope.config').values
}

-- Utility function to get all matches in current buffer
local function get_all_matches(pattern)
    local matches = {}
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    
    for lnum, line in ipairs(lines) do
        if line:find(pattern) then
            table.insert(matches, {
                lnum = lnum,
                text = line
            })
        end
    end
    return matches
end

-- Create the find and replace windows
local function create_windows(search_text, matches)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.min(#matches + 4, math.floor(vim.o.lines * 0.8))
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Preview buffer setup with proper options
    local preview_buf = vim.api.nvim_create_buf(false, true)
    pcall(function()
        vim.api.nvim_buf_set_option(preview_buf, 'modifiable', true)
        vim.api.nvim_buf_set_option(preview_buf, 'readonly', false)
        vim.api.nvim_buf_set_option(preview_buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(preview_buf, 'swapfile', false)
        vim.api.nvim_buf_set_option(preview_buf, 'bufhidden', 'wipe')
    end)
    
    -- Preview window
    local preview_win = vim.api.nvim_open_win(preview_buf, false, {
        relative = 'editor',
        row = row,
        col = col,
        width = width,
        height = height - 2,
        style = 'minimal',
        border = 'rounded',
        title = ' Preview ',
        title_pos = 'center',
    })

    -- Replace buffer setup
    local replace_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(replace_buf, 'buftype', 'prompt')
    
    -- Replace window
    local replace_win = vim.api.nvim_open_win(replace_buf, true, {
        relative = 'editor',
        row = row + height - 1,
        col = col,
        width = width,
        height = 1,
        style = 'minimal',
        border = 'rounded',
        title = ' Replace ',
        title_pos = 'center',
    })

    return {
        preview_win = preview_win,
        preview_buf = preview_buf,
        replace_win = replace_win,
        replace_buf = replace_buf
    }
end

-- Update preview with current matches and replacement
local function update_preview(bufnr, windows, search_text, replace_text)
    -- Get current buffer content
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local preview_lines = {}
    local found = false

    -- Add header
    table.insert(preview_lines, "Previewing replacements for: " .. search_text)
    table.insert(preview_lines, string.rep("-", 40))
    table.insert(preview_lines, "")

    -- Find all matches
    for lnum, line in ipairs(lines) do
        local has_match = false
        local pos = 1
        while true do
            local start_idx, end_idx = line:find(search_text, pos, true)
            if not start_idx then break end
            
            if not has_match then
                -- Add line number and original line
                table.insert(preview_lines, string.format("Line %d:", lnum))
                table.insert(preview_lines, "Original: " .. line)
                has_match = true
                found = true
            end
            
            pos = end_idx + 1
        end
        
        if has_match then
            -- Add replacement preview
            local new_line = line:gsub(vim.pesc(search_text), replace_text or "")
            table.insert(preview_lines, "Replace:  " .. new_line)
            table.insert(preview_lines, "")
        end
    end

    if not found then
        table.insert(preview_lines, "No matches found")
    end

    -- Update preview buffer with error handling
    local ok = pcall(function()
        if vim.api.nvim_buf_is_valid(windows.preview_buf) then
            vim.api.nvim_buf_set_option(windows.preview_buf, 'modifiable', true)
            vim.api.nvim_buf_set_option(windows.preview_buf, 'readonly', false)
            vim.api.nvim_buf_set_lines(windows.preview_buf, 0, -1, false, preview_lines)
            vim.api.nvim_buf_set_option(windows.preview_buf, 'modifiable', false)
            vim.api.nvim_buf_set_option(windows.preview_buf, 'readonly', true)
        end
    end)
    
    if not ok then
        -- If we failed to update the preview, at least ensure the buffer is in a good state
        pcall(function()
            if vim.api.nvim_buf_is_valid(windows.preview_buf) then
                vim.api.nvim_buf_set_option(windows.preview_buf, 'modifiable', false)
                vim.api.nvim_buf_set_option(windows.preview_buf, 'readonly', true)
            end
        end)
    end
end
-- Setup replace prompt with live preview
local function setup_replace_prompt(bufnr, windows, search_text)
    local preview_text = ""

    -- Set up the prompt label and initial value
    vim.fn.prompt_setprompt(windows.replace_buf, 'Replace with: ')
    vim.api.nvim_buf_set_lines(windows.replace_buf, 0, -1, false, { "" })

    -- Sync preview on input
    vim.api.nvim_buf_attach(windows.replace_buf, false, {
        on_lines = function(_, _, _, _, _, _)
            local input = vim.api.nvim_buf_get_lines(windows.replace_buf, 0, 1, false)[1] or ""
            -- Remove prompt label if still present
            input = input:gsub("^Replace with: ", "")
            if input ~= preview_text then
                preview_text = input
                update_preview(bufnr, windows, search_text, input)
            end
        end,
        on_detach = function()
            if vim.api.nvim_win_is_valid(windows.preview_win) then
                vim.api.nvim_win_close(windows.preview_win, true)
            end
        end,
    })

    -- Handle Enter to apply substitution
    vim.fn.prompt_setcallback(windows.replace_buf, function(text)
        if vim.api.nvim_win_is_valid(windows.preview_win) then
            vim.api.nvim_win_close(windows.preview_win, true)
        end
        if vim.api.nvim_win_is_valid(windows.replace_win) then
            vim.api.nvim_win_close(windows.replace_win, true)
        end

        if text and text ~= "" then
            local cmd = string.format("%%s/%s/%s/gc",
                vim.fn.escape(search_text, '/'),
                vim.fn.escape(text, '/'))
            vim.cmd(cmd)
        end
    end)

    -- Optional: exit on <Esc>
    vim.keymap.set("i", "<Esc>", function()
        if vim.api.nvim_win_is_valid(windows.replace_win) then
            vim.api.nvim_win_close(windows.replace_win, true)
        end
        if vim.api.nvim_win_is_valid(windows.preview_win) then
            vim.api.nvim_win_close(windows.preview_win, true)
        end
    end, { buffer = windows.replace_buf })

    update_preview(bufnr, windows, search_text, "")
    vim.cmd("startinsert!")
end

function M.find_and_replace()
    local bufnr = vim.api.nvim_get_current_buf()
    
    local picker = telescope.pickers.new({
        layout_strategy = 'vertical',
        layout_config = {
            width = 0.8,
            height = 0.8,
            prompt_position = "top",
        },
        attach_mappings = function(prompt_bufnr, map)
            map('i', '<CR>', function()
                local search_text = telescope.state.get_current_line()
                if not search_text or search_text == "" then return end
                
                telescope.actions.close(prompt_bufnr)
                
                if search_text ~= "" then
                    local matches = get_all_matches(search_text)
                    local windows = create_windows(search_text, matches)
                    setup_replace_prompt(bufnr, windows, search_text)
                end
            end)
            return true
        end,
        finder = telescope.finders.new_table {
            results = (function()
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local results = {}
                for i, line in ipairs(lines) do
                    if line ~= "" then
                        table.insert(results, { lnum = i, text = line })
                    end
                end
                return results
            end)(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    ordinal = entry.text,
                    display = string.format("Line %d: %s", entry.lnum, entry.text),
                    lnum = entry.lnum,
                    text = entry.text
                }
            end
        },
        sorter = telescope.conf.generic_sorter({}),
        previewer = telescope.conf.grep_previewer({}),
        prompt_title = "Find text (Enter to select)",
    })

    picker:find()
end


return {
    find_and_replace = M.find_and_replace
}
