
local function evaluate_line()
    require("config.molten_kernel").with_kernel(function(kernel)
        vim.api.nvim_cmd({ cmd = "MoltenEvaluateLine", args = { kernel } }, {})
    end)
end

local function evaluate_current_cell()
    require("config.molten_kernel").with_kernel(function()
        require("quarto.runner").run_cell()
    end)
end

-- Molten exposes no "execution finished" event, so batch runs (Run All /
-- Restart & Run All) are tracked by polling its own "molten-extmarks"
-- namespace for the "... Running" virt_text it writes per busy cell (see
-- outputbuffer.py). Finishing requires that marker to be *absent* for a
-- short debounce window, not just momentarily gone, since Molten briefly
-- shows no "Running" cell while stepping from one queued cell to the next.
local function watch_execution(bufnr, handle)
    local ns = vim.api.nvim_get_namespaces()["molten-extmarks"]
    if not ns then
        handle:finish()
        return
    end

    local function any_running()
        local ok, marks = pcall(vim.api.nvim_buf_get_extmarks, bufnr, ns, 0, -1, { details = true })
        if not ok then
            return false
        end
        for _, mark in ipairs(marks) do
            local details = mark[4] or {}
            local segments = {}
            vim.list_extend(segments, details.virt_text or {})
            for _, line in ipairs(details.virt_lines or {}) do
                vim.list_extend(segments, line)
            end
            for _, seg in ipairs(segments) do
                if type(seg[1]) == "string" and seg[1]:find("Running", 1, true) then
                    return true
                end
            end
        end
        return false
    end

    local seen_running = false
    local quiet_since = nil
    local start = vim.uv.now()
    local timer = vim.uv.new_timer()

    timer:start(
        200,
        200,
        vim.schedule_wrap(function()
            local running = any_running()
            if running then
                seen_running = true
                quiet_since = nil
            elseif seen_running then
                quiet_since = quiet_since or vim.uv.now()
            end

            local elapsed = vim.uv.now() - start
            local quiet_long_enough = quiet_since and (vim.uv.now() - quiet_since) > 500
            local timed_out = elapsed > 10 * 60 * 1000 -- 10 min safety cap

            if quiet_long_enough or timed_out then
                timer:stop()
                timer:close()
                handle:finish()
            end
        end)
    )
end

local function with_progress(title, message, run)
    local ok, progress = pcall(require, "fidget.progress")
    local handle = ok
        and progress.handle.create({
            title = title,
            message = message,
            lsp_client = { name = "molten" },
        })

    local bufnr = vim.api.nvim_get_current_buf()
    run(function()
        if handle then
            watch_execution(bufnr, handle)
        end
    end)
end

local function evaluate_all_cells()
    require("config.molten_kernel").with_kernel(function(kernel)
        with_progress("Running notebook", "Evaluating all cells…", function(started)
            local line_count = vim.api.nvim_buf_line_count(0)
            local ok, err = pcall(vim.fn.MoltenEvaluateRange, kernel, 1, line_count)
            if not ok then
                vim.notify("Molten range evaluation failed: " .. tostring(err), vim.log.levels.ERROR)
                return
            end
            started()
        end)
    end)
end

local function restart_and_run_all()
    local kernels = require("config.molten_kernel").buffer_kernels()
    if #kernels == 0 then
        vim.notify("No running kernel to restart. Use :MoltenInit first.", vim.log.levels.WARN)
        return
    end

    local done = false
    local function run_once()
        if done then
            return
        end
        done = true
        evaluate_all_cells()
    end

    local group = vim.api.nvim_create_augroup("MoltenRestartRunAll", { clear = true })
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "MoltenKernelReady",
        once = true,
        callback = run_once,
    })
    vim.defer_fn(function()
        if not done then
            pcall(vim.api.nvim_del_augroup_by_id, group)
            run_once()
        end
    end, 15000)

    vim.notify("Restarting kernel…", vim.log.levels.INFO)
    vim.cmd "MoltenRestart!"
end

local function evaluate_visual()
    require("config.molten_kernel").with_kernel(function(kernel)
        vim.api.nvim_cmd({ cmd = "MoltenEvaluateVisual", args = { kernel } }, {})
    end)
end
return { -- 1) Molten
    {
        "benlubas/molten-nvim",
        dependencies = { "folke/snacks.nvim" },
        -- Remote plugins auto-register in Neovim 0.10+ (no UpdateRemotePlugins needed).
        -- Do NOT use `cmd` here — it creates lazy stubs that shadow the real
        -- remote-plugin commands.  Load eagerly on notebook/python filetypes.
        lazy = false,
        init = function()
            -- Output window behaviour
            vim.g.molten_auto_open_output = true
            vim.g.molten_auto_close_output = false
            vim.g.molten_enter_output_behavior = "open_then_enter"
            vim.g.molten_auto_init_behavior = "raise"

            -- Output window appearance
            vim.g.molten_output_win_max_height = 20
            vim.g.molten_output_win_max_width = 100
            vim.g.molten_output_win_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
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
            vim.g.molten_image_provider = "snacks.nvim"
            vim.g.molten_auto_image_popup = true
            vim.g.molten_image_location = "both" -- show inline AND in popup
            vim.g.molten_save_path = vim.fn.stdpath "data" .. "/molten"

            -- Performance
            vim.g.molten_tick_rate = 150
            vim.g.molten_copy_output = false
        end,
        config = function()
            local kernel = require "config.molten_kernel"
            local prompt = require "prompt"
            prompt.prompt_init = kernel.prompt_init
            prompt.prompt_init_and_run = kernel.prompt_init_and_run

            vim.g._prompt_init = prompt.prompt_init
            vim.g._prompt_init_and_run = prompt.prompt_init_and_run

            local function state_path()
                local file = vim.api.nvim_buf_get_name(0)
                local name = file ~= "" and vim.fn.fnamemodify(file, ":t:r") or "scratch"
                local safe = name:gsub("[^%w_.-]", "_")
                vim.fn.mkdir(vim.g.molten_save_path, "p")
                return vim.g.molten_save_path .. "/" .. safe .. ".json"
            end

            vim.api.nvim_create_user_command("NotebookMode", function()
                vim.opt_local.spell = false
                vim.opt_local.conceallevel = 0
                pcall(vim.cmd, "RenderMarkdown buf_disable")
                pcall(function()
                    require("quarto").activate()
                end)
                vim.notify("Notebook mode ready. Use :MoltenInit to pick a kernel.", vim.log.levels.INFO)
            end, {
                desc = "Prepare current buffer for notebook work",
            })

            vim.api.nvim_create_user_command("MoltenStateSave", function()
                vim.cmd("MoltenSave " .. vim.fn.fnameescape(state_path()))
            end, {
                desc = "Save Molten state for this buffer",
            })

            vim.api.nvim_create_user_command("MoltenStateLoad", function()
                vim.cmd("MoltenLoad " .. vim.fn.fnameescape(state_path()))
            end, {
                desc = "Load Molten state for this buffer",
            })
        end,
        keys = {
            {
                "<leader>mi",
                "<cmd>MoltenInit<CR>",
                desc = "Molten Init (select kernel)",
            },
            {
                "<leader>ml",
                evaluate_line,
                desc = "Evaluate current line",
            },
            {
                "<leader>mo",
                "<cmd>MoltenShowOutput<CR>",
                desc = "Show/enter output window",
            },
            {
                "<leader>mh",
                "<cmd>MoltenHideOutput<CR>",
                desc = "Hide output window",
            },
            {
                "<leader>md",
                "<cmd>MoltenDelete<CR>",
                desc = "Delete current cell output",
            },
            {
                "<leader>mr",
                "<cmd>MoltenReevaluateCell<CR>",
                desc = "Re-evaluate cell",
            },
            {
                "<leader>mc",
                evaluate_visual,
                mode = "v",
                desc = "Evaluate visual selection",
            },
            {
                "<leader>ms",
                "<cmd>MoltenStateSave<CR>",
                desc = "Save Molten state",
            },
            {
                "<leader>mL",
                "<cmd>MoltenStateLoad<CR>",
                desc = "Load Molten state",
            },
            {
                "<leader>mn",
                "<cmd>NotebookMode<CR>",
                desc = "Notebook mode",
            },
            {
                "<leader>mR",
                "<cmd>MoltenRestart!<CR>",
                desc = "Restart kernel (clear outputs)",
            },
            {
                "<leader>mA",
                restart_and_run_all,
                desc = "Restart kernel & run all cells",
            },
            {
                "<leader>mI",
                "<cmd>MoltenInterrupt<CR>",
                desc = "Interrupt kernel",
            },
            {
                "<leader>mm",
                evaluate_current_cell,
                desc = "Run current %% cell",
            },
            {
                "<F5>",
                evaluate_current_cell,
                desc = "Run current cell (F5)",
            },
            {
                "<F6>",
                evaluate_all_cells,
                desc = "Run all cells (F6)",
            },
        },
    },
}
