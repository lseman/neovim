local git_ns = vim.api.nvim_create_namespace("OilGitStatus")
local git_cache = {}

local function refresh_git_status(bufnr)
    local oil = require("oil")
    local dir = oil.get_current_dir(bufnr)
    if not dir then
        return
    end

    local cache_key = dir
    local function paint(statuses)
        vim.api.nvim_buf_clear_namespace(bufnr, git_ns, 0, -1)
        if not vim.api.nvim_buf_is_valid(bufnr) then
            return
        end
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        for lnum = 0, line_count - 1 do
            local entry = oil.get_entry_on_line(bufnr, lnum + 1)
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

    if git_cache[cache_key] then
        paint(git_cache[cache_key])
    end

    vim.system({"git", "-C", dir, "rev-parse", "--show-toplevel"}, {text = true}, function(root_res)
        if root_res.code ~= 0 then
            git_cache[cache_key] = {}
            vim.schedule(function()
                paint({})
            end)
            return
        end
        local root = vim.trim(root_res.stdout)
        local dir_norm = vim.fs.normalize(dir):gsub("/+$", "")
        local prefix = dir_norm == root and "" or (dir_norm:sub(#root + 2) .. "/")

        vim.system({"git", "-C", root, "status", "--porcelain", "--ignored"}, {text = true}, function(res)
            local statuses = {}
            if res.code == 0 and res.stdout then
                for line in res.stdout:gmatch("[^\n]+") do
                    local xy = line:sub(1, 2)
                    local name = line:sub(4)
                    name = name:match("%-> (.+)$") or name

                    if prefix == "" or vim.startswith(name, prefix) then
                        local rel = name:sub(#prefix + 1)
                        local direct, is_nested = rel:match("^([^/]+)(/?.*)$")
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
                                statuses[key] = {sign_char, hl}
                            end
                        end
                    end
                end
            end
            git_cache[cache_key] = statuses
            vim.schedule(function()
                paint(statuses)
            end)
        end)
    end)
end

local function fzf_jump(bufnr)
    local oil = require("oil")
    local dir = oil.get_current_dir(bufnr)
    if not dir then
        return
    end
    local dir_norm = vim.fs.normalize(dir):gsub("/+$", "")

    require("fzf-lua").files({
        cwd = dir,
        actions = {
            ["default"] = function(selected, opts)
                if not selected[1] then
                    return
                end
                local file_path = require("fzf-lua.path").entry_to_file(selected[1], opts).path
                if not file_path then
                    return
                end
                local target_dir = vim.fn.fnamemodify(file_path, ":h")
                local target_name = vim.fn.fnamemodify(file_path, ":t")

                if target_dir ~= dir_norm then
                    oil.open(target_dir)
                else
                    for lnum = 1, vim.api.nvim_buf_line_count(bufnr) do
                        local entry = oil.get_entry_on_line(bufnr, lnum)
                        if entry and entry.name == target_name then
                            vim.api.nvim_win_set_cursor(0, {lnum, 0})
                            break
                        end
                    end
                end
            end
        }
    })
end

return {{
    "stevearc/oil.nvim",
    event = "VeryLazy",
    dependencies = {"nvim-tree/nvim-web-devicons", "ibhagwan/fzf-lua"},
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
