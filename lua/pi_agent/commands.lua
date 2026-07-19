-- lua/plugins/pi-agent/commands.lua
-- Neovim commands for pi coding agent

local Content = require "pi_agent.content"
local PiAgentClient = require "pi_agent.client"

local client = PiAgentClient:new()

local function ask_pi(prompt)
    local final_message = Content.build_prompt_message(prompt)
    client:prompt(final_message)
end

local function ask_pi_selection()
    local selected = Content.get_selected_text()
    if not selected or selected == "" then
        vim.notify("pi-agent: no text selected", vim.log.levels.WARN)
        return
    end
    ask_pi("Please review and help with this selected code:\n\n" .. selected)
end

local function abort_pi()
    client:abort()
    vim.notify("pi-agent: aborted", vim.log.levels.INFO)
end

local function show_state()
    client:get_state()
    vim.notify("pi-agent: state requested", vim.log.levels.INFO)
end

local function register_commands()
    vim.api.nvim_create_user_command("PiAgentAsk", function(opts)
        ask_pi(opts.args)
    end, {
        nargs = "*",
        desc = "Ask pi coding agent",
    })

    vim.api.nvim_create_user_command("PiAgentAskSelection", function()
        ask_pi_selection()
    end, {
        desc = "Ask pi coding agent about selected text",
    })

    vim.api.nvim_create_user_command("PiAgentAbort", function()
        abort_pi()
    end, {
        desc = "Abort pi coding agent",
    })

    vim.api.nvim_create_user_command("PiAgentState", function()
        show_state()
    end, {
        desc = "Get pi coding agent state",
    })
end

return {
    client = client,
    register_commands = register_commands,
}
