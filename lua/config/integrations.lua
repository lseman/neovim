local M = {}

local function get_snacks()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks then
        return snacks
    end
end

function M.open_picker(snacks_name, telescope_name, opts, fallback)
    local snacks = get_snacks()
    if snacks and snacks.picker and snacks.picker[snacks_name] then
        snacks.picker[snacks_name](opts or {})
        return true
    end

    local ok_tel, builtin = pcall(require, "telescope.builtin")
    if ok_tel and builtin[telescope_name] then
        builtin[telescope_name](opts or {})
        return true
    end

    if fallback then
        fallback()
        return true
    end

    return false
end

function M.picker(snacks_name, telescope_name, opts, fallback)
    return function()
        if not M.open_picker(snacks_name, telescope_name, opts, fallback) then
            vim.notify("No picker backend available", vim.log.levels.WARN)
        end
    end
end

function M.open_current_buffer_picker()
    local snacks = get_snacks()
    if snacks and snacks.picker and snacks.picker.lines then
        snacks.picker.lines()
        return true
    end

    local ok_tel, builtin = pcall(require, "telescope.builtin")
    if ok_tel and builtin.current_buffer_fuzzy_find then
        builtin.current_buffer_fuzzy_find({
            layout_strategy = "vertical",
            layout_config = {
                width = 0.65,
                height = 0.7,
                prompt_position = "top",
                preview_height = 0.45
            },
            sorting_strategy = "ascending"
        })
        return true
    end

    return false
end

function M.toggle_explorer()
    local snacks = get_snacks()
    if snacks and snacks.explorer then
        if snacks.picker and snacks.picker.get then
            local open = snacks.picker.get({source = "explorer"})
            if #open > 0 then
                for _, picker in ipairs(open) do
                    picker:close()
                end
                return true
            end
        end
        snacks.explorer()
        return true
    end

    return false
end

return M
