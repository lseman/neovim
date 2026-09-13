return {
    "lewis6991/gitsigns.nvim",
    event = "User FilePost",
    opts = {
        signs = {
            add = {
                text = "▎",
            },
            change = {
                text = "▎",
            },
            delete = {
                text = "▁",
            },
            topdelete = {
                text = "▔",
            },
            changedelete = {
                text = "▔",
            },
            untracked = {
                text = "▎",
            },
        },
        signs_staged = {
            add = {
                text = "▎",
            },
            change = {
                text = "▎",
            },
            delete = {
                text = "▁",
            },
            topdelete = {
                text = "▔",
            },
            changedelete = {
                text = "▔",
            },
        },
        signcolumn = false,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
            interval = 1000,
            follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
            delay = 500,
            ignore_whitespace = true,
            virt_text_priority = 100,
        },
        current_line_blame_formatter = function(name, info)
            local time_str = os.date("%Y-%m-%d %H:%M", info.author_time)

            return {
                { name .. ", ", "GitSignsCurrentLineBlameAuthor" }, -- or just "Comment"
                { time_str .. " - ", "GitSignsCurrentLineBlameTime" },
                { info.abbrev_sha .. " - ", "GitSignsCurrentLineBlameSha" },
                { info.summary or "(no message)", "GitSignsCurrentLineBlameSummary" },
            }
        end,

        sign_priority = 6,
        update_debounce = 100,
        max_file_length = 40000,
        preview_config = {
            border = "rounded",
            style = "minimal",
            relative = "cursor",
            row = 0,
            col = 1,
            width = 80, -- or 0.8 for relative width
        },


        on_attach = function(bufnr)
            local gs = require "gitsigns"

            local function is_notebook_buffer(bufnr)
                local ft = vim.bo[bufnr].filetype
                if ft == "quarto" or ft == "markdown" then
                    return true
                end

                if ft == "python" or ft == "julia" or ft == "r" then
                    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 20, false)
                    for _, line in ipairs(lines) do
                        if line:match "^%s*# %%%%" or line:match "^%s*%-%- %%%%" then
                            return true
                        end
                    end
                end

                return false
            end

            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, {
                    buffer = bufnr,
                    desc = "Gitsigns: " .. desc,
                })
            end

            -- Navigation (smart: skips when in diff mode)
            if not is_notebook_buffer(bufnr) then
                map("n", "]c", function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(gs.next_hunk)
                    return "<Ignore>"
                end, "Next Hunk")

                map("n", "[c", function()
                    if vim.wo.diff then
                        return "[c"
                    end
                    vim.schedule(gs.prev_hunk)
                    return "<Ignore>"
                end, "Prev Hunk")
            end

            -- Actions
            map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
            map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
            map("v", "<leader>hs", function()
                gs.stage_hunk({ vim.fn.line ".", vim.fn.line "v" })
            end, "Stage Selection")
            map("v", "<leader>hr", function()
                gs.reset_hunk({ vim.fn.line ".", vim.fn.line "v" })
            end, "Reset Selection")

            map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
            map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
            map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")

            map("n", "<leader>hp", gs.preview_hunk_inline, "Preview Hunk Inline") -- ← many prefer inline in 2025+
            -- or gs.preview_hunk() for classic popup

            map("n", "<leader>hb", function()
                gs.blame_line({
                    full = true,
                })
            end, "Blame Line (full)")
            map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Line Blame")

            map("n", "<leader>hd", gs.diffthis, "Diff This")
            map("n", "<leader>hD", function()
                gs.diffthis "~"
            end, "Diff This ~")

            map("n", "<leader>td", gs.toggle_deleted, "Toggle Show Deleted")

            -- Text object (very useful)
            map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Hunk")

        end,
    },

    config = function(_, opts)
        require("gitsigns").setup(opts)
    end,
}
