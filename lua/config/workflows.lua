local M = {}

local environment = require "config.environment"
M.on_venv_activated = environment.on_activated

local function detect_and_activate_venv()
    return environment.activate_for_dir(vim.uv.cwd() or vim.fn.getcwd())
end

local function setup_runner_maps()
    local runner = require "config.runner"
    runner.setup({
        python_cmd = "python3",
        auto_save = true,
        notify = true,
        clear_terminal = true,
    })

    vim.keymap.set("n", "<leader>py", runner.run_file, {
        desc = "Run Python file",
    })
    vim.keymap.set("n", "<leader>pa", runner.run_with_args, {
        desc = "Run with args",
    })
    vim.keymap.set("n", "<leader>pi", runner.run_interactive, {
        desc = "Python interactive",
    })
    vim.keymap.set("n", "<leader>pt", runner.toggle_terminal, {
        desc = "Toggle Python terminal",
    })
    vim.keymap.set("n", "<leader>pr", runner.repeat_last, {
        desc = "Repeat last run",
    })
    vim.keymap.set("n", "<leader>ph", runner.run_from_history, {
        desc = "Run from history",
    })
end

local function setup_user_commands()
    vim.api.nvim_create_user_command("ConfigHealth", function()
        vim.cmd.checkhealth("config")
    end, { desc = "Check configuration dependencies" })

    vim.api.nvim_create_user_command("HealthCheck", function()
        vim.cmd "ConfigHealth"
    end, {
        desc = "Show configuration health status",
    })

    vim.api.nvim_create_user_command("Rconf", function()
        require("config.reload").reload()
    end, {
        desc = "Reload editor configuration",
    })

    vim.keymap.set("n", "<leader>ch", "<cmd>ConfigHealth<CR>", {
        desc = "Config health",
    })
end

function M.setup()
    local group = vim.api.nvim_create_augroup("ConfigWorkflows", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        once = true,
        callback = function()
            detect_and_activate_venv()
        end,
    })

    -- Re-detect per-buffer: a notebook/script opened from a different
    -- project than the one Neovim started in needs its own venv on PATH.
    -- Without this, jupytext.nvim's ipynb<->qmd conversion silently uses
    -- whichever venv (or system PATH) happened to be active at startup —
    -- if that one lacks `quarto`/`jupytext`, conversion fails or falls
    -- back to a stale paired file, which looks like broken cell detection.
    --
    -- BufEnter also restores the environment when returning to an open buffer.
    -- Uses BufAdd, not BufReadPre: jupytext.nvim owns BufReadCmd for
    -- *.ipynb, and a custom BufReadCmd suppresses BufReadPre/Post entirely
    -- for that buffer. BufAdd still fires beforehand regardless.
    vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter" }, {
        group = vim.api.nvim_create_augroup("PerBufferVenvDetect", { clear = true }),
        pattern = { "*.ipynb", "*.qmd", "*.py" },
        callback = function(args)
            environment.activate_for_dir(vim.fn.fnamemodify(args.file, ":p:h"))
        end,
        desc = "Activate the venv matching this buffer's project",
    })

    setup_runner_maps()
    setup_user_commands()
end

M.setup()

return M
