-- Local dashboard layout. Keep this outside plugins/, which Lazy scans for specs.
local function fit(text, width)
    text = text:gsub("[\r\n\t]", " ")
    if vim.fn.strdisplaywidth(text) <= width then return text end
    while vim.fn.strdisplaywidth(text) > width - 1 do
        text = vim.fn.strcharpart(text, 1)
    end
    return "…" .. text
end

local function heading(title, width, pane)
    return {
        pane = pane,
        text = {
            { title .. "  ", hl = "Title" },
            { string.rep("─", math.max(0, width - #title - 2)), hl = "Comment" },
        },
        padding = 1,
    }
end

local actions = {
    { "f", "", "Find a file", function() Snacks.picker.smart() end },
    { "n", "", "New buffer", ":ene | startinsert" },
    { "g", "", "Search text", function() Snacks.picker.grep() end },
    { "r", "", "Recent files", function() Snacks.picker.recent() end },
    { "p", "", "Find a project", function() Snacks.picker.projects() end },
    { "c", "", "Neovim config", function() Snacks.picker.files({ cwd = vim.fn.stdpath "config" }) end },
    { "k", "󰌌", "Shortcut cheatsheet", function() require("config.cheatsheet").open() end },
    { "l", "󰒲", "Manage plugins", ":Lazy" },
    { "h", "󰓙", "Health check", ":checkhealth" },
    { "t", "", "Choose theme", function() require("config.themes").toggle() end },
    { "q", "", "Quit", ":qa" },
}

return {
    enabled = true,
    width = 44,
    pane_gap = 8,
    -- Reserve letters for actions; file and project entries receive digits.
    autokeys = "1234567890",
    sections = function(dashboard)
        local window_width = vim.api.nvim_win_get_width(dashboard.win)
        local window_height = vim.api.nvim_win_get_height(dashboard.win)
        local width = math.max(20, math.min(44, window_width - 6))
        dashboard.opts.width = width
        local wide = window_width >= 2 * width + 14
        local compact = window_height < 28
        local pane = wide and 2 or 1
        local cwd = fit(vim.fn.fnamemodify(vim.fn.getcwd(), ":~"), width - 3)
        local items = {
            { text = { { "N E O V I M", hl = "Special" } }, padding = 1 },
            { text = { { fit(os.date("%A, %d %B"), width), hl = "Comment" } } },
            { text = { { "  ", hl = "Directory" }, { cwd, hl = "Comment" } }, padding = 1 },
            heading("START HERE", width, 1),
        }
        for _, action in ipairs(actions) do
            items[#items + 1] = {
                key = action[1],
                action = action[4],
                text = {
                    { action[2] .. "  ", hl = "Special", width = 4 },
                    { fit(action[3], width - 9), hl = "Normal", width = width - 9 },
                    { "[" .. action[1] .. "]", hl = "Special" },
                },
            }
        end
        items[#items + 1] = {
            text = { { string.rep("─", width), hl = "Comment" } },
            padding = { 1, 1 },
        }
        local version = vim.version()
        items[#items + 1] = {
            text = { { fit(("v%d.%d.%d  ·  choose a shortcut"):format(version.major, version.minor, version.patch), width), hl = "Comment" } },
        }

        -- On short, narrow windows the action list is enough; r/p still open
        -- the full pickers. Wider windows keep context alongside the actions.
        if wide or not compact then
            items[#items + 1] = { pane = pane, text = { { "CONTINUE WORKING", hl = "Special" } }, padding = 1 }
            items[#items + 1] = heading("RECENT FILES", width, pane)
            local recent = Snacks.dashboard.sections.recent_files({ limit = compact and 3 or 4 })()
            if #recent == 0 then
                recent = { { text = { { fit("Your next file starts the list.", width - 1), hl = "Comment" } } } }
            end
            for _, item in ipairs(recent) do
                item.pane = pane
                item.indent = 1
                items[#items + 1] = item
            end
            items[#items + 1] = { pane = pane, text = "", padding = 1 }
            items[#items + 1] = heading("PROJECTS", width, pane)
            local projects = Snacks.dashboard.sections.projects({ limit = 3, session = false })
            if #projects == 0 then
                projects = { { text = { { fit("Open a Git project to see it here.", width - 1), hl = "Comment" } } } }
            end
            for _, item in ipairs(projects) do
                item.pane = pane
                item.indent = 1
                items[#items + 1] = item
            end
        end
        return items
    end,
}
