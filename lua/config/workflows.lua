local M = {}

local venv_activated_callbacks = {}

local function on_venv_activated(fn)
    table.insert(venv_activated_callbacks, fn)
end

M.on_venv_activated = on_venv_activated

local function activate_venv(venv_dir)
    local venv_bin = venv_dir .. "/bin"
    vim.env.PATH = venv_bin .. ":" .. vim.env.PATH
    vim.env.VIRTUAL_ENV = venv_dir
    vim.schedule(function()
        for _, fn in ipairs(venv_activated_callbacks) do
            pcall(fn, venv_dir)
        end
    end)
end

local function detect_and_activate_venv()
    local cwd = vim.uv.cwd() or vim.fn.getcwd()
    local candidates = {".venv", "venv", ".env", "env"}

    while cwd and cwd ~= "/" do
        for _, name in ipairs(candidates) do
            local dir = cwd .. "/" .. name
            local py = dir .. "/bin/python"
            if vim.fn.executable(py) == 1 then
                -- NOTE: do NOT override python3_host_prog here; the remote
                -- plugin host is already running by this point and changing
                -- it has no effect.  System python3 (set in init.lua) must
                -- have pynvim installed.
                activate_venv(dir)
                local version = vim.fn.systemlist(py .. " --version 2>&1")[1] or "unknown"
                require("config.env").notify_loaded(dir, version)
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

    return prev, next_cell - 1
end

local function run_current_cell()
    local start_line, end_line = select_current_cell()

    local ok, err = pcall(vim.fn.MoltenEvaluateRange, start_line, end_line)
    if not ok then
        vim.notify("Molten range evaluation failed: " .. tostring(err), vim.log.levels.ERROR)
        return
    end

    vim.schedule(function()
        pcall(vim.cmd, "MoltenShowOutput")
    end)
end

local function setup_runner_maps()
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
    local function config_health()
        local checks = {{"config.runner", "Python runner"}, {"snacks", "Snacks"}, {"blink.cmp", "Blink cmp"},
                        {"conform", "Conform"}, {"lint", "nvim-lint"}, {"render-markdown", "Markdown renderer"},
                        {"grug-far", "GrugFar"}, {"kulala", "Kulala"}, {"lazydev", "LazyDev"}}
        local tools = {{"python3", "Python"}, {"jupyter", "Jupyter"}, {"quarto", "Quarto"}, {"magick", "ImageMagick"},
                       {"rg", "ripgrep"}, {"fd", "fd"}, {"stylua", "Stylua"}}
        local python_host = vim.g.python3_host_prog or vim.fn.exepath("python3")
        local python_host_ok = python_host ~= "" and vim.fn.executable(python_host) == 1
        local molten_deps_ok = python_host_ok and
                                   vim.system(
                                       {python_host, "-c",
                                        "import pynvim, jupyter_client, nbformat, PIL, requests, websocket"}):wait()
                                       .code == 0

        vim.print(
            "┌────────────────────── Config Health ──────────────────────┐")
        for _, check in ipairs(checks) do
            local ok = pcall(require, check[1])
            vim.print(string.format("│ %-22s : %s", check[2], ok and "✓ OK" or "✗ Missing"))
        end
        for _, tool in ipairs(tools) do
            local ok = vim.fn.executable(tool[1]) == 1
            vim.print(string.format("│ %-22s : %s", tool[2], ok and "✓ OK" or "✗ Missing"))
        end
        vim.print(string.format("│ %-22s : %s", "Python host",
            python_host_ok and "✓ " .. python_host or "✗ Missing"))
        vim.print(string.format("│ %-22s : %s", "Molten Python deps", molten_deps_ok and "✓ OK" or "✗ Missing"))
        vim.print("│ env                    : " .. (vim.env.VIRTUAL_ENV or vim.env.CONDA_DEFAULT_ENV or "none"))
        vim.print(
            "└──────────────────────────────────────────────────────────┘")
    end

    vim.api.nvim_create_user_command("ConfigHealth", config_health, {
        desc = "Show configuration health status"
    })

    vim.api.nvim_create_user_command("HealthCheck", function()
        vim.cmd("ConfigHealth")
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

    vim.keymap.set("n", "<leader>ch", "<cmd>ConfigHealth<CR>", {
        desc = "Config health"
    })
end

function M.setup()
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
            detect_and_activate_venv()
        end,
    })
    setup_runner_maps()
    setup_user_commands()
end

M.setup()

return M
