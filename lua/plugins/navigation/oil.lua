local git_ns = vim.api.nvim_create_namespace("OilGitStatus")

-- Global git-root cache: once per repo, reused for all subdirectory Oil buffers.
-- Key = normalized git root dir, value = { entry_name = { sign_char, hl_group } }
local git_root_cache = {}

--- Paint git status extmarks on an Oil buffer.
local function paint(bufnr, statuses)
    vim.api.nvim_buf_clear_namespace(bufnr, git_ns, 0, -1)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    for lnum = 0, line_count - 1 do
        local entry = vim.api.nvim_call_function("oil#get_entry", { bufnr, lnum + 1 })
        if entry then
            local name = entry.name
            if entry.type == "directory" then
                name = name .. "/"
            end
            local status = statuses[name]
            if status then
                vim.api.nvim_buf_set_extmark(bufnr, git_ns, lnum, 0, {
                    sign_text = status[1],
                    sign_hl_group = status[2],
                    priority = 1
                })
            end
        end
    end
end

--- Build directory-specific statuses from root-level data and paint.
local function apply_root_statuses(bufnr, root_statuses, root, dir)
    local dir_norm = vim.fs.normalize(dir):gsub("/+$", "")
    local prefix = dir_norm == root and "" or (dir_norm:sub(#root + 2) .. "/")

    local full_statuses = {}
    for rel, st in pairs(root_statuses) do
        local name = (prefix ~= "" and (prefix .. rel) or rel)
        full_statuses[name] = st
        if rel:match("/$") then
            -- Also cache without trailing slash for direct children
            full_statuses[rel:sub(1, #rel - 1)] = st
        end
    end
    git_root_cache[dir] = full_statuses
    vim.schedule(function()
        paint(bufnr, full_statuses)
    end)
end

--- Refresh git status for an Oil buffer, using a global root cache to avoid
--- re-running `git rev-parse` on every directory entry.
local function refresh_git_status(bufnr)
    local oil = require("oil")
    local dir = oil.get_current_dir(bufnr)
    if not dir then
        return
    end

    -- If we have a cached entry for this directory, paint immediately.
    local cached = git_root_cache[dir]
    if cached then
        paint(bufnr, cached)
        return
    end

    -- Find the git root for this directory.
    vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }, function(root_res)
        if root_res.code ~= 0 then
            git_root_cache[dir] = {}
            vim.schedule(function()
                paint(bufnr, {})
            end)
            return
        end

        local root = vim.trim(root_res.stdout)
        local root_norm = vim.fs.normalize(root)

        -- Reuse root-level statuses if already fetched.
        local raw_statuses = git_root_cache[root_norm]
        if not raw_statuses then
            -- Fetch git status for the root once.
            vim.system({ "git", "-C", root, "status", "--porcelain", "--ignored" }, { text = true }, function(res)
                if res.code ~= 0 or not res.stdout then
                    git_root_cache[root_norm] = {}
                    git_root_cache[dir] = {}
                    vim.schedule(function()
                        paint(bufnr, {})
                    end)
                    return
                end

                local lines = {}
                for line in res.stdout:gmatch("[^\n]+") do
                    table.insert(lines, line)
                end

                -- Parse statuses: { entry_name = { sign_char, hl_group } }
                local statuses = {}
                for _, line in ipairs(lines) do
                    local xy = line:sub(1, 2)
                    local name = line:sub(4)
                    name = name:match("%-> (.+)$") or name

                    local direct, is_nested = name:match("^([^/]+)(/?.*)$")
                    if direct then
                        local hl
                        if xy == "??" or xy == "!!" then
                            hl = "GitSignsUntracked"
                        elseif xy:sub(1, 1) == "A" then
                            hl = "GitSignsAdd"
                        elseif xy:sub(1, 1) == "D" or xy:sub(2, 2) == "D" then
                            hl = "GitSignsDelete"
                        else
                            hl = "GitSignsChange"
                        end
                        local sign_char = xy:gsub(" ", ""):sub(1, 1)
                        local key = (is_nested ~= "" and is_nested ~= nil) and (direct .. "/") or direct
                        if not statuses[key] then
                            statuses[key] = { sign_char, hl }
                        end
                    end
                end
                git_root_cache[root_norm] = statuses
                apply_root_statuses(bufnr, statuses, root, dir)
            end)
            return
        end

        -- Root statuses already cached; build directory-specific view.
        apply_root_statuses(bufnr, raw_statuses, root, dir)
    end)
end

--- Fuzzy-jump to a file/dir within the current Oil buffer using snacks.nvim picker.
local function fzf_jump(bufnr)
    local oil = require("oil")
    local dir = oil.get_current_dir(bufnr)
    if not dir then
        return
    end

    local dir_norm = vim.fs.normalize(dir):gsub("/+$", "")

    local picker = Snacks.picker.new({
        cwd = dir,
        files = false,
        ignore = { ".git" },
        on_select = function(entry)
            if not entry then
                return
            end
            local file_path = vim.fs.normalize(entry.path)
            local target_dir = vim.fn.fnamemodify(file_path, ":h")
            local target_name = vim.fn.fnamemodify(file_path, ":t")

            if target_dir ~= dir_norm then
                oil.open(target_dir)
            else
                for lnum = 1, vim.api.nvim_buf_line_count(bufnr) do
                    local e = vim.api.nvim_call_function("oil#get_entry", { bufnr, lnum })
                    if e and e.name == target_name then
                        vim.api.nvim_win_set_cursor(0, { lnum, 0 })
                        break
                    end
                end
            end
        end,
    })
    picker:find_files()
end

return {{
    "stevearc/oil.nvim",
    event = "User FilePost",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {{
        "<leader>-",
        function()
            require("oil").open()
        end,
        desc = "Open oil file explorer"
    }, {
        "<leader>cw",
        function()
            require("oil").open(vim.fn.getcwd())
        end,
        desc = "Open oil in nvim's working directory"
    }, {
        "<c-up>",
        function()
            require("oil").open(vim.fn.getcwd())
        end,
        desc = "Open oil in cwd"
    }, {
        "\\",
        function()
            require("oil").open()
        end,
        desc = "Open oil"
    }},
    opts = {
        delete_to_trash = true,
        buf_options = {
            buftype = "nofile",
            filetype = "oil"
        },
        view_options = {
            show_hidden = true,
            is_hidden_file = function(name, _)
                return vim.startswith(name, ".")
            end,
            highlight_filename = function()
                return nil
            end,
            natural_order = true,
            sort = {{"type", "asc"}, {"name", "asc"}}
        },
        columns = {"icon"},
        float = {
            padding = 2,
            border = "rounded",
            max_height = 0.9,
            min_height = 6,
            width = 0.6,
            win_options = {
                winblend = 0
            }
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,CursorLineNr:Visual",
            signcolumn = "yes",
            number = true,
            relativenumber = true,
            foldenable = false,
            cursorcolumn = false,
            foldcolumn = "0",
            spell = false,
            list = false
        },
        preview_win = {
            update_on_cursor_moved = true,
            preview_method = "fast_scratch"
        },
        keymaps = {
            ["<C-h>"] = false,
            ["<C-l>"] = false,
            ["<CR>"] = "actions.select",
            ["<C-s>"] = {
                "actions.select",
                opts = {
                    horizontal = true
                },
                desc = "Open split"
            },
            ["<C-v>"] = {
                "actions.select",
                opts = {
                    vertical = true
                },
                desc = "Open vsplit"
            },
            ["<C-t>"] = {
                "actions.select",
                opts = {
                    tab = true
                },
                desc = "Open in new tab"
            },
            ["<C-c>"] = "actions.close",
            ["q"] = "actions.close",
            ["<C-u>"] = {
                "actions.preview",
                desc = "Preview"
            },
            ["<C-k>"] = {
                "actions.preview_scroll_up",
                mode = "n",
                desc = "Scroll preview up"
            },
            ["<C-j>"] = {
                "actions.preview_scroll_down",
                mode = "n",
                desc = "Scroll preview down"
            },
            ["-"] = "actions.parent",
            ["_"] = "actions.open_cwd",
            ["g."] = "actions.toggle_hidden",
            ["g\\"] = "actions.toggle_trash",
            ["<tab>"] = {
                "actions.select",
                opts = {
                    tab = true
                },
                desc = "Open in new tab"
            },
            ["p"] = {
                "actions.preview",
                desc = "Preview"
            },
            ["g?"] = {
                "actions.show_help",
                mode = "n",
                desc = "Show Oil keymaps"
            },
            ["<C-f>"] = {
                function()
                    fzf_jump(vim.api.nvim_get_current_buf())
                end,
                mode = "n",
                desc = "Fuzzy jump to file/dir"
            }
        }
    },
    config = function(_, opts)
        require("oil").setup(opts)
        vim.api.nvim_create_autocmd("User", {
            pattern = "OilEnter",
            group = vim.api.nvim_create_augroup("OilGitStatus", {clear = true}),
            callback = function(args)
                refresh_git_status(args.data.buf)
            end
        })
    end
}}
