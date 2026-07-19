-- lua/plugins/pi-agent/keymaps.lua
-- Keybindings for pi coding agent

local PiAgentCommands = require "pi_agent.commands"

local function register_keymaps()
    local map = vim.keymap.set
    local default_opts = {
        noremap = true,
        silent = true,
    }

    -- Ask pi about selected text
    map(
        "v",
        "<C-p>",
        "<cmd>PiAgentAskSelection<CR>",
        vim.tbl_extend("force", default_opts, {
            desc = "pi-agent: ask about selection",
        })
    )

    -- Ask pi with current buffer context
    map(
        "n",
        "<C-p>",
        "<cmd>PiAgentAsk<CR>",
        vim.tbl_extend("force", default_opts, {
            desc = "pi-agent: ask with context",
        })
    )

    -- Abort pi agent
    map(
        "n",
        "<C-\\>",
        "<cmd>PiAgentAbort<CR>",
        vim.tbl_extend("force", default_opts, {
            desc = "pi-agent: abort",
        })
    )
end

return {
    register_keymaps = register_keymaps,
}
