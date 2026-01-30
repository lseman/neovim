-- python_runner.lua - Refactored Python Code Runner Plugin for Neovim
local M = {}

-- Configuration
M.config = {
    python_cmd = "python3",
    shell = vim.o.shell,
    auto_save = true,
    notify = true,
    clear_terminal = true,
    focus_terminal = true,
    keep_history = true,
    max_history = 50,
    terminal = {
        position = "vertical",
        size = function()
            local pos = M.config.terminal.position
            if pos == "vertical" then
                return math.floor(vim.o.columns * 0.5)
            elseif pos == "horizontal" then
                return math.floor(vim.o.lines * 0.5)
            end
            return 20 -- fallback for tab or nil
        end,
        float_opts = {
            width = 0.8,
            height = 0.6,
            row = 0.1,
            col = 0.1,
            border = "rounded"
        }
    }
}

-- State
M.state = {
    terminal_buf = nil,
    terminal_win = nil,
    terminal_job = nil,
    history = {},
    last_command = nil
}

-- Utility
local function notify(msg, level)
    if M.config.notify then
        vim.notify("[PyRunner] " .. msg, level or vim.log.levels.INFO)
    end
end

local function is_valid(buf, win)
    return buf and vim.api.nvim_buf_is_valid(buf) and win and vim.api.nvim_win_is_valid(win)
end

local function get_python()
    local ok, venv = pcall(require, 'venv')
    return ok and venv.current() and venv.current().python or M.config.python_cmd
end

local function add_to_history(cmd)
    if not M.config.keep_history then
        return
    end
    for i, c in ipairs(M.state.history) do
        if c == cmd then
            table.remove(M.state.history, i);
            break
        end
    end
    table.insert(M.state.history, 1, cmd)
    if #M.state.history > M.config.max_history then
        table.remove(M.state.history)
    end
end

-- Terminal management
local function create_terminal_window()
    local function get_size()
        local s = M.config.terminal.size
        return type(s) == "function" and s() or s
    end

    if M.config.terminal.position == "horizontal" then
        vim.cmd("split")
        vim.cmd("resize " .. get_size())
    elseif M.config.terminal.position == "vertical" then
        vim.cmd("vsplit")
        vim.cmd("vertical resize " .. get_size())

    elseif M.config.terminal.position == "tab" then
        vim.cmd("tabnew")
    elseif M.config.terminal.position == "float" then
        local o = M.config.terminal.float_opts
        local w, h = math.floor(vim.o.columns * o.width), math.floor(vim.o.lines * o.height)
        local row, col = math.floor(vim.o.lines * o.row), math.floor(vim.o.columns * o.col)
        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = w,
            height = h,
            row = row,
            col = col,
            border = o.border,
            style = "minimal"
        })
        return win, buf
    end
    return vim.api.nvim_get_current_win(), nil
end

local function start_terminal()
    local win, buf = create_terminal_window()
    buf = buf or vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, buf)
    M.state.terminal_buf, M.state.terminal_win = buf, win
    M.state.terminal_job = vim.fn.termopen(M.config.shell, {
        on_exit = function()
            M.state.terminal_job = nil
        end
    })
end

local function get_terminal()
    if not is_valid(M.state.terminal_buf, M.state.terminal_win) then
        start_terminal()
    end
    return M.state.terminal_buf, M.state.terminal_win, M.state.terminal_job
end

local function send(cmd)
    local _, win, job = get_terminal()
    if not job then
        return notify("Terminal not available", vim.log.levels.ERROR)
    end
    if M.config.clear_terminal then
        vim.api.nvim_chan_send(job, "clear\n")
    end
    vim.api.nvim_chan_send(job, cmd .. "\n")
    if M.config.focus_terminal and win then
        vim.api.nvim_set_current_win(win)
        vim.cmd("normal! G")
    end
end

-- Execution
function M.run_file(path)
    path = path or vim.api.nvim_buf_get_name(0)
    if path == "" then
        return notify("No file to run", vim.log.levels.WARN)
    end
    if M.config.auto_save and vim.bo.modified then
        vim.cmd("write")
    end
    local cmd = string.format('%s "%s"', get_python(), path)
    add_to_history(cmd);
    M.state.last_command = cmd
    notify("Running: " .. vim.fn.fnamemodify(path, ":t"))
    send(cmd)
end

function M.run_code(code)
    if not code or code:match("^%s*$") then
        return notify("Empty code", vim.log.levels.WARN)
    end
    local escaped = code:gsub('\\', '\\\\'):gsub('"', '\\"')
    local cmd = string.format('%s -c "%s"', get_python(), escaped)
    add_to_history(cmd);
    M.state.last_command = cmd
    notify("Running snippet")
    send(cmd)
end

function M.run_selection()
    local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
    if s[2] == 0 or e[2] == 0 then
        return notify("No selection", vim.log.levels.WARN)
    end
    local lines = vim.api.nvim_buf_get_lines(0, s[2] - 1, e[2], false)
    if #lines == 0 then
        return notify("Empty selection", vim.log.levels.WARN)
    end
    lines[1] = lines[1]:sub(s[3]);
    lines[#lines] = lines[#lines]:sub(1, e[3])
    M.run_code(table.concat(lines, "\n"))
end

function M.run_line()
    local line = vim.api.nvim_get_current_line()
    if not line or line:match("^%s*$") then
        return notify("Empty line", vim.log.levels.WARN)
    end
    M.run_code(line)
end

function M.run_interactive()
    local cmd = get_python()
    add_to_history(cmd);
    M.state.last_command = cmd
    notify("Starting Python REPL")
    send(cmd)
end

function M.run_with_args(args)
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        return notify("No file", vim.log.levels.WARN)
    end
    local function run(argline)
        local cmd = string.format('%s "%s" %s', get_python(), path, argline)
        if M.config.auto_save and vim.bo.modified then
            vim.cmd("write")
        end
        add_to_history(cmd);
        M.state.last_command = cmd
        notify("Running with args: " .. argline)
        send(cmd)
    end
    if args then
        run(args)
    else
        vim.ui.input({
            prompt = "Arguments: "
        }, function(input)
            if input then
                run(input)
            end
        end)
    end
end

function M.repeat_last()
    if not M.state.last_command then
        return notify("No previous command", vim.log.levels.WARN)
    end
    notify("Repeating last command")
    send(M.state.last_command)
end

function M.run_from_history()
    if #M.state.history == 0 then
        return notify("No history", vim.log.levels.WARN)
    end
    vim.ui.select(M.state.history, {
        prompt = "Select command:",
        format_item = function(item)
            return vim.fn.strcharpart(item, 0, 60) .. (#item > 60 and "..." or "")
        end
    }, function(choice)
        if choice then
            M.state.last_command = choice;
            send(choice)
        end
    end)
end

-- Terminal toggle
function M.toggle_terminal()
    if M.state.terminal_win and vim.api.nvim_win_is_valid(M.state.terminal_win) then
        vim.api.nvim_win_close(M.state.terminal_win, false)
        M.state.terminal_win = nil
    else
        get_terminal()
    end
end

function M.close_terminal()
    if M.state.terminal_win then
        vim.api.nvim_win_close(M.state.terminal_win, false)
    end
    if M.state.terminal_buf then
        vim.api.nvim_buf_delete(M.state.terminal_buf, {
            force = true
        })
    end
    M.state.terminal_buf, M.state.terminal_win, M.state.terminal_job = nil, nil, nil
end

function M.clear_history()
    M.state.history = {}
    notify("History cleared")
end

-- Setup
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    vim.api.nvim_create_user_command("PyRun", function(args)
        M.run_file(args.args ~= "" and args.args or nil)
    end, {
        nargs = "?",
        complete = "file"
    })

    vim.api.nvim_create_user_command("PyRunArgs", function()
        M.run_with_args()
    end, {})
    vim.api.nvim_create_user_command("PyRunLine", M.run_line, {})
    vim.api.nvim_create_user_command("PyRunSelection", M.run_selection, {
        range = true
    })
    vim.api.nvim_create_user_command("PyInteractive", M.run_interactive, {})
    vim.api.nvim_create_user_command("PyRepeat", M.repeat_last, {})
    vim.api.nvim_create_user_command("PyHistory", M.run_from_history, {})
    vim.api.nvim_create_user_command("PyTermToggle", M.toggle_terminal, {})
    vim.api.nvim_create_user_command("PyTermClose", M.close_terminal, {})
    vim.api.nvim_create_user_command("PyClearHistory", M.clear_history, {})

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
            local opts = {
                buffer = true,
                silent = true
            }
            -- vim.keymap.set("n", "<F5>", M.run_file, opts)
            vim.keymap.set("n", "<F6>", M.run_with_args, opts)
            vim.keymap.set("n", "<leader>rl", M.run_line, opts)
            vim.keymap.set("v", "<leader>rs", M.run_selection, opts)
            vim.keymap.set("n", "<leader>ri", M.run_interactive, opts)
            vim.keymap.set("n", "<leader>rr", M.repeat_last, opts)
            vim.keymap.set("n", "<leader>rh", M.run_from_history, opts)
        end
    })
end

return M
