-- lua/plugins/pi-agent/client.lua
-- RPC client for pi coding agent

local PiAgentClient = {}
PiAgentClient.__index = PiAgentClient

function PiAgentClient:new()
    local obj = {
        process = nil,
        callbacks = {
            message_update = {},
            agent_end = {},
            agent_settled = {},
            tool_execution_start = {},
            tool_execution_end = {},
            error = {},
        },
        is_running = false,
    }
    setmetatable(obj, self)
    return obj
end

function PiAgentClient:start()
    if self.process then
        return
    end

    local cmd = { "pi", "--mode", "rpc", "--no-session" }

    self.process = vim.fn.jobstart(cmd, {
        stdio = { "pipe", "pipe", vim.stderr },
        on_stdout = vim.schedule_wrap(function(err, data)
            if err or not data then
                return
            end
            self:_handle_stdout(data)
        end),
        on_exit = vim.schedule_wrap(function(code, signal)
            self.is_running = false
            self.process = nil
        end),
    })

    self.is_running = true
end

function PiAgentClient:stop()
    if self.process then
        vim.fn.jobstop(self.process)
        self.process = nil
        self.is_running = false
    end
end

function PiAgentClient:_handle_stdout(data)
    for line in data:gmatch "[^\r\n]+" do
        if line == "" then
            goto continue
        end

        local ok, event = pcall(vim.json.decode, line)
        if not ok then
            goto continue
        end

        local etype = event and event.type
        if etype == "message_update" then
            for _, cb in ipairs(self.callbacks.message_update) do
                cb(event)
            end
        elseif etype == "agent_end" then
            for _, cb in ipairs(self.callbacks.agent_end) do
                cb(event)
            end
        elseif etype == "agent_settled" then
            for _, cb in ipairs(self.callbacks.agent_settled) do
                cb(event)
            end
        elseif etype == "tool_execution_start" then
            for _, cb in ipairs(self.callbacks.tool_execution_start) do
                cb(event)
            end
        elseif etype == "tool_execution_end" then
            for _, cb in ipairs(self.callbacks.tool_execution_end) do
                cb(event)
            end
        elseif etype == "extension_error" then
            for _, cb in ipairs(self.callbacks.error) do
                cb(event)
            end
        end

        ::continue::
    end
end

function PiAgentClient:send(cmd)
    if not self.process or not self.is_running then
        self:start()
    end

    local json_cmd = vim.json.encode(cmd)
    local success, err = vim.fn.jobsend(self.process, { json_cmd .. "\n" })

    if not success then
        vim.notify("pi-agent: failed to send command: " .. tostring(err), vim.log.levels.ERROR)
    end
end

function PiAgentClient:on(event, cb)
    if self.callbacks[event] then
        table.insert(self.callbacks[event], cb)
    end
end

function PiAgentClient:prompt(message, images)
    local cmd = {
        type = "prompt",
        message = message,
    }
    if images and #images > 0 then
        cmd.images = images
    end
    self:send(cmd)
end

function PiAgentClient:abort()
    self:send({ type = "abort" })
end

function PiAgentClient:get_last_assistant_text()
    self:send({ type = "get_last_assistant_text" })
end

function PiAgentClient:get_state()
    self:send({ type = "get_state" })
end

return PiAgentClient
