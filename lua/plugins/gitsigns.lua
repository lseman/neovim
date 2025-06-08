return {
    "lewis6991/gitsigns.nvim",
    event = {"BufReadPre", "BufNewFile"},

    opts = {
        -- Git Signs
        signs = {
            add = {
                text = "│"
            },
            change = {
                text = "│"
            },
            delete = {
                text = "│"
            },
            topdelete = {
                text = "‾"
            },
            changedelete = {
                text = "~"
            },
            untracked = {
                text = "┆"
            }
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        sign_priority = 6,
        update_debounce = 100,
        max_file_length = 40000,
        watch_gitdir = {
            follow_files = true,
            interval = 1000
        },
        auto_attach = true,
        attach_to_untracked = true,

        -- Current line blame
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol",
            delay = 500,
            ignore_whitespace = true,
            virt_text_priority = 100
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d %H:%M> - <abbrev_sha> - <summary>",

        -- Preview window
        preview_config = {
            border = "rounded",
            style = "minimal",
            relative = "cursor",
            row = 0,
            col = 1,
            width = 80
        },

        -- Status line summary
        status_formatter = function(status)
            local added = status.added or 0
            local changed = status.changed or 0
            local removed = status.removed or 0

            local status_txt = {}
            if added > 0 then
                table.insert(status_txt, '+' .. added)
            end
            if changed > 0 then
                table.insert(status_txt, '~' .. changed)
            end
            if removed > 0 then
                table.insert(status_txt, '-' .. removed)
            end

            return table.concat(status_txt, ' ')
        end,

        -- On attach mappings
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, {
                    buffer = bufnr,
                    desc = desc
                })
            end

            -- Navigation
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

            -- Actions
            map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
            map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
            map("v", "<leader>hs", function()
                gs.stage_hunk({vim.fn.line("."), vim.fn.line("v")})
            end, "Stage Selection")
            map("v", "<leader>hr", function()
                gs.reset_hunk({vim.fn.line("."), vim.fn.line("v")})
            end, "Reset Selection")
            map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
            map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage")
            map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
            map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
            map("n", "<leader>hb", function()
                gs.blame_line({
                    full = true
                })
            end, "Blame Line")
            map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Line Blame")
            map("n", "<leader>hd", gs.diffthis, "Diff This")
            map("n", "<leader>hD", function()
                gs.diffthis("~")
            end, "Diff This ~")
            map("n", "<leader>td", gs.toggle_deleted, "Toggle Deleted")

            -- Text object
            map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
        end
    },

    config = function(_, opts)
        require("gitsigns").setup(opts)

        -- Optional: Highlight tweaks
        vim.cmd([[
      highlight GitSignsAdd    guifg=#00ff00 gui=bold
      highlight GitSignsChange guifg=#ffff00 gui=bold
      highlight GitSignsDelete guifg=#ff0000 gui=bold
    ]])
    end
}
