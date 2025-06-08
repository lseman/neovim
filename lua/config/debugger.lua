local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local dap = require('dap')

local debugger_cache = require('config.debugger_cache')

local M = {}

function M.launch_debugger()
    vim.ui.input({
        prompt = 'Path to executable: ',
        completion = 'file'
    }, function(program)
        if program and program ~= "" then
            vim.ui.input({
                prompt = 'Arguments: '
            }, function(args)
                if args == nil then
                    args = ""
                end
                local args_table = vim.split(args, " ")
                debugger_cache.add_entry(program, args_table)

                print("Program: " .. program)
                print("Arguments: " .. vim.inspect(args_table))

                dap.run({
                    name = "Launch executable",
                    type = "cppdbg",
                    request = "launch",
                    program = program,
                    args = args_table,
                    cwd = vim.fn.getcwd(),
                    stopAtEntry = true
                })
            end)
        else
            print("No executable specified.")
        end
    end)
end

function M.select_cached_entry()
    local entries = debugger_cache.get_entries()
    if #entries == 0 then
        print("No cached entries available.")
        return
    end

    pickers.new({}, {
        prompt_title = "Select Debugger Entry",
        finder = finders.new_table {
            results = entries,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.name .. " " ..
                        (type(entry.args) == "table" and table.concat(entry.args, " ") or entry.args),
                    ordinal = entry.name
                }
            end
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local entry = selection.value

                print("Selected Program: " .. entry.name)
                print("Selected Arguments: " .. vim.inspect(entry.args))

                dap.run({
                    name = "Launch executable",
                    type = "cppdbg",
                    request = "launch",
                    program = entry.name,
                    args = type(entry.args) == "table" and entry.args or vim.split(entry.args, " "),
                    cwd = vim.fn.getcwd(),
                    stopAtEntry = true
                })
            end)
            return true
        end
    }):find()
end

return M
