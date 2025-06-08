-- Safely load required modules
local function safe_require(module)
    local status_ok, lib = pcall(require, module)
    if not status_ok then
        vim.notify(string.format("Failed to load %s: %s", module, lib), vim.log.levels.ERROR)
        return nil
    end
    return lib
end

local dap = safe_require("dap")
local dapui = safe_require("dapui")

if not (dap and dapui) then return end

-- Enhanced path handling with history
local path_history = {}
local function get_executable_path()
    local default_path = vim.fn.getcwd() .. '/build/'
    local path = vim.fn.input({
        prompt = 'Path to executable: ',
        default = default_path,
        completion = function(_, cmdline, _)
            return vim.tbl_filter(function(p) return p:match('^' .. cmdline) end, path_history)
        end
    })
    
    if path and path ~= '' then
        -- Add to history if unique
        if not vim.tbl_contains(path_history, path) then
            table.insert(path_history, 1, path)
            if #path_history > 10 then table.remove(path_history) end
        end
        return path
    end
    return dap.ABORT
end

-- Improved GDB adapter with validation
dap.adapters.gdb = {
    type = 'executable',
    command = 'gdb',
    args = {'--quiet', '--interpreter=dap'},
    options = {
        initialize_timeout_sec = 15,
        verify_connection = true
    },
    setup = function()
        local handle = io.popen('which gdb')
        if not handle then
            vim.notify("Failed to check GDB installation", vim.log.levels.ERROR)
            return false
        end
        local result = handle:read("*a")
        handle:close()
        if not result or result == "" then
            vim.notify("GDB not found in PATH. Please install GDB.", vim.log.levels.ERROR)
            return false
        end
        return true
    end
}

-- Enhanced program arguments handling
local function parse_arguments(args_str)
    local args = {}
    local current_arg = ''
    local in_quotes = false
    local escape_next = false
    
    for i = 1, #args_str do
        local char = args_str:sub(i, i)
        if escape_next then
            current_arg = current_arg .. char
            escape_next = false
        elseif char == '\\' then
            escape_next = true
        elseif char == '"' then
            in_quotes = not in_quotes
        elseif char == ' ' and not in_quotes then
            if current_arg ~= '' then
                table.insert(args, current_arg)
                current_arg = ''
            end
        else
            current_arg = current_arg .. char
        end
    end
    
    if current_arg ~= '' then
        table.insert(args, current_arg)
    end
    
    return args
end

-- Improved C/C++ configurations
dap.configurations.cpp = {
    {
        name = "Launch Program (GDB)",
        type = "gdb",
        request = "launch",
        program = get_executable_path,
        cwd = "${workspaceFolder}",
        stopAtEntry = true,
        runInTerminal = false,
        args = function()
            local args_str = vim.fn.input('Arguments: ')
            return parse_arguments(args_str)
        end,
        env = function()
            local env_str = vim.fn.input('Environment variables (KEY=VALUE,...): ')
            local env = {}
            for pair in env_str:gmatch('[^,]+') do
                local k, v = pair:match('([^=]+)=(.*)')
                if k and v then env[k:trim()] = v:trim() end
            end
            return env
        end,
        setupCommands = {
            {
                text = "-enable-pretty-printing",
                description = "Enable pretty printing for better struct/array visualization",
                ignoreFailures = false
            }
        }
    },
    {
        name = "Attach to Process (GDB)",
        type = "gdb",
        request = "attach",
        processId = function()
            local output = io.popen('ps -e -o pid,command | grep -v grep'):read('*a')
            local processes = {}
            for line in output:gmatch('[^\n]+') do
                local pid, cmd = line:match('^%s*(%d+)%s+(.+)$')
                if pid and cmd then
                    table.insert(processes, string.format("%s: %s", pid, cmd))
                end
            end
            return require('dap.utils').pick_process(processes)
        end,
        cwd = "${workspaceFolder}",
    },
    {
        name = "Attach to gdbserver",
        type = "gdb",
        request = "attach",
        gdbserver = true,
        remote = true,
        host = function()
            local host = vim.fn.input('Host [localhost]: ')
            return (host ~= '') and host or 'localhost'
        end,
        port = function()
            local port = vim.fn.input('Port [1234]: ')
            if port ~= '' and not tonumber(port) then
                vim.notify("Invalid port number", vim.log.levels.ERROR)
                return dap.ABORT
            end
            return (port ~= '') and port or '1234'
        end,
        program = get_executable_path,
        cwd = "${workspaceFolder}",
    }
}
dap.configurations.c = dap.configurations.cpp

-- UI setup with improvements
dapui.setup({
    icons = {
        expanded = "▾",
        collapsed = "▸",
        current_frame = "→",
        error = "✗",
        success = "✓"
    },
    mappings = {
        expand = {"<CR>", "<2-LeftMouse>"},
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t"
    },
    layouts = {
        {
            elements = {
                { id = "scopes", size = 0.25 },
                { id = "breakpoints", size = 0.25 },
                { id = "stacks", size = 0.25 },
                { id = "watches", size = 0.25 }
            },
            size = 40,
            position = "left"
        },
        {
            elements = {
                { id = "repl", size = 0.5 },
                { id = "console", size = 0.5 }
            },
            size = 15,
            position = "bottom"
        }
    },
    floating = {
        max_height = 0.9,
        max_width = 0.5,
        border = "rounded",
        mappings = {
            close = {"q", "<Esc>"}
        }
    },
    controls = {
        enabled = true,
        element = "repl",
        icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
        }
    },
    render = {
        max_type_length = 100,
        max_value_lines = 100
    }
})

-- Enhanced breakpoint handling
local sign_define = vim.fn.sign_define
sign_define('DapBreakpoint', { text='●', texthl='DapBreakpoint', linehl='', numhl='' })
sign_define('DapBreakpointCondition', { text='◆', texthl='DapBreakpointCondition', linehl='', numhl='' })
sign_define('DapLogPoint', { text='◆', texthl='DapLogPoint', linehl='', numhl='' })
sign_define('DapStopped', { text='▶', texthl='DapStopped', linehl='DapStoppedLine', numhl='' })
sign_define('DapBreakpointRejected', { text='○', texthl='DapBreakpointRejected', linehl='', numhl='' })

-- GDB command with history
local gdb_history = {}
local function send_gdb_command()
    local command = vim.fn.input({
        prompt = 'GDB command: ',
        completion = function(_, cmdline, _)
            return vim.tbl_filter(function(cmd) return cmd:match('^' .. cmdline) end, gdb_history)
        end
    })
    
    if command and command ~= "" then
        table.insert(gdb_history, 1, command)
        if #gdb_history > 50 then table.remove(gdb_history) end
        
        dap.repl.run_command('-exec ' .. command)
        vim.notify('Executed: ' .. command, vim.log.levels.INFO)
    end
end

-- Enhanced keymappings with better descriptions
local keymap_set = vim.keymap.set

-- Debug control
keymap_set('n', '<F5>', dap.continue, { desc = 'Debug: Continue' })
keymap_set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
keymap_set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
keymap_set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })

-- Breakpoints
keymap_set('n', '<Leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
keymap_set('n', '<Leader>B', function()
    vim.ui.input({
        prompt = 'Breakpoint condition: ',
        completion = 'expression'
    }, function(condition)
        if condition then dap.set_breakpoint(condition) end
    end)
end, { desc = 'Debug: Set Conditional Breakpoint' })

-- UI control
keymap_set('n', '<Leader>dc', send_gdb_command, { desc = 'Debug: Send GDB Command' })
keymap_set('n', '<Leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })
keymap_set('n', '<Leader>dl', dap.run_last, { desc = 'Debug: Run Last' })

-- Watch expression
keymap_set('n', '<Leader>dw', function()
    local word = vim.fn.expand('<cword>')
    dap.ui.widgets.hover(word, {
        border = "rounded",
        max_width = 80,
        max_height = 40
    })
end, { desc = 'Debug: Watch Expression' })

-- Automatic UI handling with notifications
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
    vim.notify('Debug session started', vim.log.levels.INFO)
end

dap.listeners.before.event_terminated["dapui_config"] = function()
    vim.notify('Debug session terminated', vim.log.levels.WARN)
    dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
    vim.notify('Debug session exited', vim.log.levels.WARN)
    dapui.close()
end

-- Error handling
dap.listeners.after.event_error["dapui_config"] = function(err)
    vim.notify(string.format("Debug error: %s", err), vim.log.levels.ERROR)
end

-- Create user commands with completions
vim.api.nvim_create_user_command("GdbCommand", send_gdb_command, {
    desc = "Send a command to GDB",
    nargs = '*',
    complete = function(arglead)
        return vim.tbl_filter(function(cmd)
            return cmd:match('^' .. arglead)
        end, gdb_history)
    end
})

-- Add debug status to statusline
vim.o.statusline = vim.o.statusline .. '%{%v:lua.require("dap").status()%}'