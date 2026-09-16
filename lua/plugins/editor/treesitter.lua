local ensure_installed = {
    "c",
    "cpp",
    "lua",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
    "latex",
    "javascript",
    "typescript",
    "tsx",
    "html",
    "css",
    "bash",
    "regex",
    "json",
    "yaml",
    "toml",
    "cmake",
    "make",
    "dockerfile",
    "git_config",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "python",
}

local excluded_filetypes = {
    snacks_picker_list = true,
    lazy = true,
    mason = true,
    alpha = true,
    dashboard = true,
}

return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
            opts = {
                enable_autocmd = false,
                languages = {
                    javascript = {
                        __default = "// %s",
                        jsx_element = "{/* %s */}",
                        jsx_fragment = "{/* %s */}",
                        jsx_attribute = "// %s",
                        comment = "// %s",
                    },
                    typescript = { __default = "// %s" },
                    tsx = {
                        __default = "// %s",
                        jsx_element = "{/* %s */}",
                        jsx_fragment = "{/* %s */}",
                        jsx_attribute = "// %s",
                    },
                },
            },
        },
        {
            "windwp/nvim-ts-autotag",
            opts = {},
        },
        {
            -- `main` nvim-treesitter dropped the old built-in textobjects
            -- module; this is the standalone companion rewritten for it.
            "nvim-treesitter/nvim-treesitter-textobjects",
            branch = "main",
            config = function()
                require("nvim-treesitter-textobjects").setup {
                    select = {
                        lookahead = true,
                        selection_modes = {
                            ["@function.outer"] = "V",
                            ["@class.outer"] = "V",
                        },
                    },
                }

                local select = require "nvim-treesitter-textobjects.select"
                local function textobj(query)
                    return function()
                        select.select_textobject(query, "textobjects")
                    end
                end

                vim.keymap.set({ "x", "o" }, "af", textobj "@function.outer", { desc = "Around function" })
                vim.keymap.set({ "x", "o" }, "if", textobj "@function.inner", { desc = "Inside function" })
                vim.keymap.set({ "x", "o" }, "ac", textobj "@class.outer", { desc = "Around class" })
                vim.keymap.set({ "x", "o" }, "ic", textobj "@class.inner", { desc = "Inside class" })
            end,
        },
    },

    config = function()
        local treesitter = require "nvim-treesitter"

        -- `main` is a full rewrite: setup now only configures the install path.
        -- Parsers and queries live together under stdpath("data")/site.
        treesitter.setup()
        treesitter.install(ensure_installed)

        local group = vim.api.nvim_create_augroup("TreesitterFeatures", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            callback = function(args)
                if excluded_filetypes[vim.bo[args.buf].filetype] then
                    return
                end

                -- Measure the buffer's own content, not the file on disk: a
                -- jupytext-converted notebook keeps its buffer name pointing
                -- at the original .ipynb (often multi-MB with embedded
                -- output images) while the displayed qmd/markdown content is
                -- tiny. Stat-ing the file name skipped treesitter entirely
                -- for any such notebook, which looked like broken/missing
                -- syntax highlighting with no relation to the actual size
                -- of what's on screen.
                local line_count = vim.api.nvim_buf_line_count(args.buf)
                local ok_size, byte_size = pcall(vim.api.nvim_buf_get_offset, args.buf, line_count)
                if ok_size and byte_size > 200 * 1024 then
                    return
                end

                -- Not every filetype has a parser. Missing parsers should fall back
                -- to normal syntax highlighting without producing an error.
                if pcall(vim.treesitter.start, args.buf) then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
            desc = "Enable Tree-sitter highlighting and indentation",
        })

        -- Markdown/Quarto: a fenced code block added after an existing one
        -- (e.g. a ```{python} cell appended below a ```{bash} cell) can end
        -- up correctly parsed — the injected language tree and its query
        -- captures are right — but never actually painted, because the
        -- highlighter only populates extmarks for rows a window redraw has
        -- touched, and a newly created injection wasn't part of any redraw
        -- yet. Force a full reparse + redraw shortly after edits so new
        -- fences light up immediately instead of waiting for a scroll.
        local reparse_timers = {}
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = { "markdown", "quarto" },
            callback = function(args)
                local bufnr = args.buf
                if vim.b[bufnr].ts_reparse_attached then
                    return
                end
                vim.b[bufnr].ts_reparse_attached = true

                vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
                    group = group,
                    buffer = bufnr,
                    callback = function()
                        local timer = reparse_timers[bufnr]
                        if timer then
                            timer:stop()
                            timer:close()
                        end
                        timer = vim.uv.new_timer()
                        reparse_timers[bufnr] = timer
                        timer:start(
                            150,
                            0,
                            vim.schedule_wrap(function()
                                reparse_timers[bufnr] = nil
                                local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
                                if ok and parser then
                                    parser:parse(true)
                                    vim.cmd "redraw"
                                end
                            end)
                        )
                    end,
                })

                vim.api.nvim_create_autocmd("BufDelete", {
                    group = group,
                    buffer = bufnr,
                    once = true,
                    callback = function()
                        local timer = reparse_timers[bufnr]
                        if timer then
                            timer:stop()
                            timer:close()
                            reparse_timers[bufnr] = nil
                        end
                    end,
                })
            end,
            desc = "Force full reparse+redraw so new markdown/quarto code-fence injections highlight immediately",
        })

        -- `main` nvim-treesitter also dropped incremental_selection. This is
        -- a small native reimplementation: <C-Space> expands the visual
        -- selection outward node by node, <BS> shrinks back.
        do
            ---@type table<integer, [integer, integer, integer, integer][]>
            local stacks = {}

            local function node_range(bufnr, node)
                local srow, scol, erow, ecol = node:range()
                if ecol == 0 then
                    erow = math.max(erow - 1, srow)
                    ecol = #(vim.api.nvim_buf_get_lines(bufnr, erow, erow + 1, false)[1] or "")
                end
                return { srow, scol, erow, ecol }
            end

            local function select_range(range)
                local srow, scol, erow, ecol = range[1], range[2], range[3], range[4]
                local mode = vim.api.nvim_get_mode().mode
                if mode:match "^[vV\22]" then
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
                end
                vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
                vim.cmd "normal! v"
                vim.api.nvim_win_set_cursor(0, { erow + 1, math.max(ecol - 1, 0) })
            end

            local function ranges_equal(a, b)
                return a and b and a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
            end

            local function expand_selection()
                local bufnr = vim.api.nvim_get_current_buf()
                local mode = vim.api.nvim_get_mode().mode
                local stack = stacks[bufnr]

                if not mode:match "^[vV\22]" or not stack or #stack == 0 then
                    local node = vim.treesitter.get_node { include_anonymous = true }
                    if not node then
                        vim.notify("No Tree-sitter node at cursor", vim.log.levels.WARN)
                        return
                    end
                    local range = node_range(bufnr, node)
                    stacks[bufnr] = { range }
                    select_range(range)
                    return
                end

                local current = stack[#stack]

                -- The point at `current`'s start may belong to a smaller,
                -- unrelated node (e.g. current is itself an identifier), so
                -- first climb to the node that actually contains the whole
                -- current range before climbing further outward from it.
                local node =
                    vim.treesitter.get_node { bufnr = bufnr, pos = { current[1], current[2] }, include_anonymous = true }
                local range
                while node do
                    range = node_range(bufnr, node)
                    local contains = range[1] <= current[1]
                        and range[3] >= current[3]
                        and (range[1] < current[1] or range[2] <= current[2])
                        and (range[3] > current[3] or range[4] >= current[4])
                    if contains then
                        break
                    end
                    node = node:parent()
                end

                while node and ranges_equal(range, current) do
                    node = node:parent()
                    if node then
                        range = node_range(bufnr, node)
                    end
                end

                if not node then
                    vim.notify("Already at the outermost node", vim.log.levels.INFO)
                    return
                end

                table.insert(stack, range)
                select_range(range)
            end

            local function shrink_selection()
                local stack = stacks[vim.api.nvim_get_current_buf()]
                if not stack or #stack < 2 then
                    return
                end
                table.remove(stack)
                select_range(stack[#stack])
            end

            vim.keymap.set({ "n", "x" }, "<C-Space>", expand_selection, { desc = "Expand Tree-sitter selection" })
            vim.keymap.set("x", "<BS>", shrink_selection, { desc = "Shrink Tree-sitter selection" })
        end
    end,
}
