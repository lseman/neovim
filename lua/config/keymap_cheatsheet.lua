local M = {}

local mode_names = {
    n = "Normal",
    i = "Insert",
    v = "Visual",
    x = "Visual (Select)",
    o = "Operator-pending",
    t = "Terminal",
    c = "Command",
}

local mode_order = { "n", "i", "v", "x", "o", "t", "c" }

local function esc_cell(value)
    local text = tostring(value or "")
    text = text:gsub("|", "\\|")
    text = text:gsub("\n", " ")
    return text
end

local function collect_mode_maps(mode)
    local entries = {}
    local seen = {}

    local function add_maps(maps, scope)
        for _, map in ipairs(maps) do
            local lhs = map.lhs or ""
            local desc = map.desc or ""
            local rhs = map.rhs or ""

            if lhs ~= "" and desc ~= "" then
                local key = table.concat({ mode, lhs, desc, rhs, scope }, "\0")
                if not seen[key] then
                    seen[key] = true
                    table.insert(entries, {
                        lhs = lhs,
                        desc = desc,
                        rhs = rhs,
                        scope = scope,
                    })
                end
            end
        end
    end

    add_maps(vim.api.nvim_get_keymap(mode), "global")
    add_maps(vim.api.nvim_buf_get_keymap(0, mode), "buffer")

    table.sort(entries, function(a, b)
        return a.lhs < b.lhs
    end)

    return entries
end

function M.generate_lines()
    local lines = {}
    local filename = vim.api.nvim_buf_get_name(0)
    local file_display = filename ~= "" and vim.fn.fnamemodify(filename, ":~:.") or "[No Name]"

    table.insert(lines, "# Neovim Keymap Cheatsheet")
    table.insert(lines, "")
    table.insert(lines, "- Generated: " .. os.date "%Y-%m-%d %H:%M:%S")
    table.insert(lines, "- Buffer: " .. file_display)
    table.insert(lines, "- Filetype: " .. (vim.bo.filetype ~= "" and vim.bo.filetype or "none"))
    table.insert(lines, "")

    for _, mode in ipairs(mode_order) do
        local maps = collect_mode_maps(mode)
        if #maps > 0 then
            table.insert(lines, "## " .. mode_names[mode])
            table.insert(lines, "")
            table.insert(lines, "| Key | Description | Scope | Action |")
            table.insert(lines, "| --- | --- | --- | --- |")

            for _, map in ipairs(maps) do
                table.insert(
                    lines,
                    string.format(
                        "| `%s` | %s | %s | `%s` |",
                        esc_cell(map.lhs),
                        esc_cell(map.desc),
                        map.scope,
                        esc_cell(map.rhs ~= "" and map.rhs or "lua/callback")
                    )
                )
            end

            table.insert(lines, "")
        end
    end

    return lines
end

function M.open()
    local lines = M.generate_lines()

    vim.cmd "tabnew"
    local buf = vim.api.nvim_get_current_buf()

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true
    vim.bo[buf].filetype = "markdown"

    vim.api.nvim_buf_set_name(buf, "keymap-cheatsheet.md")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false

    vim.keymap.set("n", "q", "<cmd>close<CR>", {
        buffer = buf,
        silent = true,
        noremap = true,
        desc = "Close keymap cheatsheet",
    })
end

function M.write(path)
    local target = path and path ~= "" and vim.fn.expand(path) or (vim.fn.stdpath "config" .. "/KEYMAPS.md")
    local dir = vim.fn.fnamemodify(target, ":h")

    if dir ~= "" then
        vim.fn.mkdir(dir, "p")
    end

    local ok, err = pcall(vim.fn.writefile, M.generate_lines(), target)
    if not ok then
        vim.notify("Failed to write cheatsheet: " .. tostring(err), vim.log.levels.ERROR)
        return
    end

    vim.notify("Keymap cheatsheet written to " .. target, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("KeymapCheatsheet", function()
    M.open()
end, {
    desc = "Generate and open keymap cheatsheet",
})

vim.api.nvim_create_user_command("KeymapCheatsheetWrite", function(opts)
    M.write(opts.args)
end, {
    desc = "Generate and write keymap cheatsheet to disk",
    nargs = "?",
    complete = "file",
})

vim.keymap.set("n", "<leader>fK", M.write, {
    desc = "Write Cheatsheet to Disk",
    silent = true,
    noremap = true,
})

vim.keymap.set("n", "<leader>fW", function()
    M.write()
end, {
    desc = "Write Cheatsheet to Disk",
    silent = true,
    noremap = true,
})

return M
