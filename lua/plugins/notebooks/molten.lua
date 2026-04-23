return { -- 1) Molten
{
    "benlubas/molten-nvim",
    dependencies = {"3rd/image.nvim"},
    build = ":UpdateRemotePlugins",
    -- Remote plugins register their commands via rplugin.vim at startup.
    -- Do NOT use `cmd` here — it creates lazy stubs that shadow the real
    -- remote-plugin commands.  Load eagerly on notebook/python filetypes.
    lazy = false,
    init = function()
        -- Output window behaviour
        vim.g.molten_auto_open_output = true
        vim.g.molten_auto_close_output = false
        vim.g.molten_enter_output_behavior = "open_then_enter"

        -- Output window appearance
        vim.g.molten_output_win_max_height = 0.6 -- up to 60 % of screen height
        vim.g.molten_output_win_max_width = 0.9 -- up to 90 % of screen width
        vim.g.molten_output_win_border = "rounded"
        vim.g.molten_output_win_style = "minimal" -- cleaner float (no statusline, etc.)
        vim.g.molten_output_win_cover_gutter = false
        vim.g.molten_use_border_highlights = true -- use highlight groups for border colours

        -- Virtual-text inline summary
        vim.g.molten_virt_text_output = true
        vim.g.molten_virt_lines_off_screen = true -- keep virt lines even when cell is off-screen
        vim.g.molten_virt_text_max_lines = 20 -- more lines visible in the inline summary
        vim.g.molten_output_virt_lines = true
        vim.g.molten_output_show_more = true -- show "N more lines" indicator when truncated
        vim.g.molten_wrap_output = true

        -- Images
        vim.g.molten_image_provider = "image.nvim"
        vim.g.molten_auto_image_popup = true
        vim.g.molten_image_location = "both" -- show inline AND in popup

        -- Performance
        vim.g.molten_tick_rate = 150
        vim.g.molten_copy_output = false
    end,
    keys = {{
        "<leader>mi",
        "<cmd>MoltenInit<CR>",
        desc = "Molten Init (select kernel)"
    }, {
        "<leader>ml",
        "<cmd>MoltenEvaluateLine<CR>",
        desc = "Evaluate current line"
    }, {
        "<leader>mo",
        "<cmd>MoltenShowOutput<CR>",
        desc = "Show/enter output window"
    }, {
        "<leader>mh",
        "<cmd>MoltenHideOutput<CR>",
        desc = "Hide output window"
    }, {
        "<leader>md",
        "<cmd>MoltenDelete<CR>",
        desc = "Delete current cell output"
    }, {
        "<leader>mr",
        "<cmd>MoltenReevaluateCell<CR>",
        desc = "Re-evaluate cell"
    }, {
        "<leader>mc",
        "<cmd>MoltenEvaluateVisual<CR>",
        mode = "v",
        desc = "Evaluate visual selection"
    }, {
        "<leader>ms",
        "<cmd>MoltenSave<CR>",
        desc = "Save notebook state"
    }, {
        "<leader>mL",
        "<cmd>MoltenLoad<CR>",
        desc = "Load notebook state"
    }, {
        "<leader>mR",
        "<cmd>MoltenRestart!<CR>",
        desc = "Restart kernel (clear outputs)"
    }, {
        "<leader>mI",
        "<cmd>MoltenInterrupt<CR>",
        desc = "Interrupt kernel"
    }, {
        "<leader>mm",
        function()
            if vim.fn.exists("*MoltenEvaluateRange") == 0 then
                vim.notify("Molten not initialized — run <leader>mi first", vim.log.levels.WARN)
                return
            end
            local start = vim.fn.search("^# %%", "bcnW")
            local stop = vim.fn.search("^# %%", "nW")
            if start == 0 then
                start = 1
            end
            if stop == 0 then
                stop = vim.api.nvim_buf_line_count(0)
            else
                stop = stop - 1
            end
            vim.fn.MoltenEvaluateRange(start, stop)
        end,
        desc = "Run current %% cell"
    }, {
        "<F5>",
        function()
            if vim.fn.exists("*MoltenEvaluateRange") == 0 then
                vim.notify("Molten not initialized — run <leader>mi first", vim.log.levels.WARN)
                return
            end
            local start = vim.fn.search("^# %%", "bcnW")
            local stop = vim.fn.search("^# %%", "nW")
            if start == 0 then
                start = 1
            end
            if stop == 0 then
                stop = vim.api.nvim_buf_line_count(0)
            else
                stop = stop - 1
            end
            vim.fn.MoltenEvaluateRange(start, stop)
        end,
        desc = "Run current %% cell (F5)"
    }}
}, -- 2) image.nvim
{
    "3rd/image.nvim",
    lazy = true,
    opts = {
        backend = "kitty", -- best quality; use "ueberzugpp" if not on kitty
        processor = "magick_rock", -- requires: luarocks --local install magick
        integrations = {
            markdown = {
                enabled = true,
                clear_in_insert_mode = false,
                download_remote_images = true,
                only_render_image_at_cursor = true, -- less visual noise
                filetypes = {"markdown", "quarto", "vimwiki", "python"}
            },
            neorg = {
                enabled = false
            },
            typst = {
                enabled = false
            }
        },
        -- Generous limits so plots aren't clipped
        max_width = nil, -- nil = no limit
        max_height = nil,
        max_width_window_percentage = 80,
        max_height_window_percentage = 60,
        -- Don't clear images when Neovim loses focus (flicker reduction)
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = {"cmp_menu", "cmp_docs", ""},
        editor_only_render_when_focused = true, -- save GPU when not focused
        tmux_show_only_in_active_window = true,
        hijack_file_patterns = {"*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg"}
    }
}}
