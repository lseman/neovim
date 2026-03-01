local M = {}

local function activate_venv(venv_dir)
    local venv_bin = venv_dir .. "/bin"
    vim.env.PATH = venv_bin .. ":" .. vim.env.PATH
    vim.env.VIRTUAL_ENV = venv_dir
end

local function detect_and_activate_venv()
    local cwd = vim.uv.cwd() or vim.fn.getcwd()
    local candidates = {".venv", "venv", ".env", "env"}

    while cwd and cwd ~= "/" do
        for _, name in ipairs(candidates) do
            local dir = cwd .. "/" .. name
            local py = dir .. "/bin/python"
            if vim.fn.executable(py) == 1 then
                vim.g.python3_host_prog = py
                activate_venv(dir)
                local version = vim.fn.systemlist(py .. " --version 2>&1")[1] or "unknown"
                vim.notify("Python env: " .. dir .. " (" .. version:gsub("\n", "") .. ")", vim.log.levels.INFO)
                return true
            end
        end
        cwd = vim.fn.fnamemodify(cwd, ":h")
    end

    return false
end

local function select_current_cell()
    local prev = vim.fn.search("^# %%", "bnW")
    local next_cell = vim.fn.search("^# %%", "nW")
    local last = vim.fn.line("$")

    prev = (prev == 0) and 1 or (prev + 1)
    next_cell = (next_cell == 0) and (last + 1) or next_cell

    local buf = vim.api.nvim_get_current_buf()
    vim.fn.setpos("'<", {buf, prev, 1, 0})
    vim.fn.setpos("'>", {buf, next_cell - 1, 999, 0})
    vim.cmd("normal! gv")
end

local function run_current_cell()
    select_current_cell()
    vim.cmd("MoltenEvaluateVisual")
    vim.schedule(function()
        pcall(vim.cmd, "MoltenShowOutput")
    end)
end

local function setup_ipython_terminal_maps()
    _G.last_terminal_jobid = _G.last_terminal_jobid or nil

    vim.keymap.set("n", "<leader>tt", function()
        local old = vim.o.splitright
        vim.o.splitright = true
        vim.cmd("vsplit | terminal")
        vim.o.splitright = old

        vim.defer_fn(function()
            local jobid = vim.b.terminal_job_id
            if not jobid then
                vim.notify("No terminal job ID detected", vim.log.levels.ERROR)
                return
            end

            _G.last_terminal_jobid = jobid
            local send = function(cmd)
                vim.api.nvim_chan_send(jobid, cmd .. "\n")
            end

            send("tmux")
            send("source .venv/bin/activate 2>/dev/null || true")
            send("ipython")
            vim.notify("IPython terminal ready", vim.log.levels.INFO)
        end, 150)
    end, {
        desc = "Open IPython terminal"
    })

    vim.keymap.set("n", "<leader>tr", function()
        local job = _G.last_terminal_jobid
        if job then
            vim.api.nvim_chan_send(job, "%reset -f\n")
            vim.notify("IPython reset sent", vim.log.levels.INFO)
        else
            vim.notify("No IPython terminal active", vim.log.levels.WARN)
        end
    end, {
        desc = "Reset IPython session"
    })

    vim.keymap.set("n", "<leader>rs", function()
        local start = vim.fn.search("^# %%", "bnW")
        local end_ = vim.fn.search("^# %%", "nW")

        start = (start == 0) and 1 or (start + 1)
        end_ = (end_ == 0) and (vim.fn.line("$") + 1) or (end_ - 1)

        local lines = vim.api.nvim_buf_get_lines(0, start - 1, end_, false)
        local code = table.concat(lines, "\n")
        local payload = "%cpaste -q\n" .. code .. "\n--\n"

        if _G.last_terminal_jobid then
            vim.api.nvim_chan_send(_G.last_terminal_jobid, payload)
        else
            vim.notify("No IPython terminal active (use <leader>tt)", vim.log.levels.ERROR)
        end
    end, {
        desc = "Send current cell to IPython"
    })

    vim.keymap.set("n", "<leader>tx", function()
        if _G.last_terminal_jobid then
            vim.api.nvim_chan_send(_G.last_terminal_jobid, "exit\n")
            _G.last_terminal_jobid = nil
            vim.notify("Terminal session closed", vim.log.levels.INFO)
        else
            vim.notify("No active terminal", vim.log.levels.WARN)
        end
    end, {
        desc = "Close IPython terminal"
    })
end

local function setup_slime_and_molten_maps()
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = {
        socket_name = "default",
        target_pane = ":.1"
    }
    vim.g.slime_dont_ask_default = 1

    vim.keymap.set("n", "<leader>R", function()
        if vim.fn.exists("*slime#send") == 0 then
            vim.notify("vim-slime not loaded", vim.log.levels.ERROR)
            return
        end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for i, line in ipairs(lines) do
            lines[i] = line:gsub("\r", ""):gsub("\t", " "):gsub("%s+$", "")
        end
        vim.fn["slime#send"](table.concat(lines, "\n") .. "\n")
    end, {
        desc = "Send entire buffer via slime"
    })

    vim.keymap.set("n", "<F4>", select_current_cell, {
        desc = "Select current # %% cell"
    })
    vim.keymap.set("n", "<F5>", run_current_cell, {
        desc = "Run current # %% cell"
    })
    vim.keymap.set("n", "<leader>mr", "<cmd>MoltenRestart<CR>", {
        desc = "Restart Molten kernel"
    })
end

local function setup_runner_maps()
    pcall(function()
        local env = require("config.env")
        env.setup({
            venv_dirs = {".venv", "venv"},
            auto_activate = true,
            notify = true
        })

        vim.keymap.set("n", "<leader>va", env.activate, {
            desc = "Activate venv"
        })
        vim.keymap.set("n", "<leader>vd", env.deactivate, {
            desc = "Deactivate venv"
        })
        vim.keymap.set("n", "<leader>vs", env.select, {
            desc = "Select venv"
        })
        vim.keymap.set("n", "<leader>vc", function()
            local cur = env.current()
            vim.print(cur and ("Active: " .. cur.name .. " (" .. cur.root .. ")") or "No venv active")
        end, {
            desc = "Show current venv"
        })
    end)

    pcall(function()
        local runner = require("config.runner")
        runner.setup({
            python_cmd = "python3",
            auto_save = true,
            notify = true,
            clear_terminal = true
        })

        vim.keymap.set("n", "<leader>py", runner.run_file, {
            desc = "Run Python file"
        })
        vim.keymap.set("n", "<leader>pa", runner.run_with_args, {
            desc = "Run with args"
        })
        vim.keymap.set("n", "<leader>pi", runner.run_interactive, {
            desc = "Python interactive"
        })
        vim.keymap.set("n", "<leader>pt", runner.toggle_terminal, {
            desc = "Toggle Python terminal"
        })
        vim.keymap.set("n", "<leader>pr", runner.repeat_last, {
            desc = "Repeat last run"
        })
        vim.keymap.set("n", "<leader>ph", runner.run_from_history, {
            desc = "Run from history"
        })
    end)
end

local function setup_user_commands()
    vim.api.nvim_create_user_command("HealthCheck", function()
        local checks = {{"config.runner", "Python runner"}, {"telescope", "Telescope"}, {"notify", "nvim-notify"},
                        {"snacks", "Snacks"}}

        vim.print(
            "┌────────────────────── Health Check ──────────────────────┐")
        for _, check in ipairs(checks) do
            local ok = pcall(require, check[1])
            vim.print(string.format("│ %-20s : %s", check[2], ok and "✓ OK" or "✗ Missing"))
        end
        vim.print("│ vim-slime              : " .. (vim.g.loaded_slime and "✓ OK" or "✗ Missing"))
        vim.print(
            "└──────────────────────────────────────────────────────────┘")
    end, {
        desc = "Show configuration health status"
    })

    vim.api.nvim_create_user_command("Rconf", function()
        for name in pairs(package.loaded) do
            if name:match("^config%.") or name:match("^plugins%.") then
                package.loaded[name] = nil
            end
        end
        dofile(vim.fn.stdpath("config") .. "/init.lua")
        vim.notify("Configuration reloaded", vim.log.levels.INFO)
    end, {
        desc = "Reload entire config"
    })

    vim.keymap.set("n", "<leader>ch", "<cmd>HealthCheck<CR>", {
        desc = "Health check"
    })
end

function M.setup()
    detect_and_activate_venv()
    setup_ipython_terminal_maps()
    setup_slime_and_molten_maps()
    setup_runner_maps()
    setup_user_commands()
end

M.setup()

return M
