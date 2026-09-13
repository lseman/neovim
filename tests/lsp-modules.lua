-- Run: nvim --headless -u NONE -i NONE -l tests/lsp-modules.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path
vim.opt.rtp:prepend(root)
local api = vim.api
local rename = require "plugins.lsp.interactive-rename"
local signature = require "plugins.lsp.signature"
local requests, clients, messages = {}, {}, {}
vim.lsp.get_clients = function() return clients end
vim.notify = function(message) table.insert(messages, message) end
local source = api.nvim_get_current_buf()
api.nvim_buf_set_lines(source, 0, -1, false, { "😀 target(value)" })
api.nvim_win_set_cursor(0, { 1, 5 })
local source_win = api.nvim_get_current_win()
local handler = function() end
local client = {
    id = 1,
    offset_encoding = "utf-16",
    handlers = { ["textDocument/rename"] = handler },
    server_capabilities = { signatureHelpProvider = { triggerCharacters = { "(" } } },
    supports_method = function() return true end,
    request = function(_, method, params, callback, bufnr)
        table.insert(requests, { method = method, params = params, callback = callback, bufnr = bufnr })
        return true, #requests
    end,
}
clients = { client }
local function key(lhs)
    for _, map in ipairs(api.nvim_buf_get_keymap(0, "n")) do
        if map.lhs == lhs then return map.callback() end
    end
    error("Missing mapping " .. lhs)
end
local function prepare()
    rename()
    local request = requests[#requests]
    assert(request.method == "textDocument/prepareRename")
    assert(request.params.position.character == 3, "prepare uses UTF-16")
    return request
end
prepare().callback(nil, { placeholder = "target" })
assert(api.nvim_get_current_buf() ~= source, "rename prompt opened")
assert(api.nvim_get_current_line() == "target")
api.nvim_buf_set_lines(0, 0, -1, false, { "updated" })
key("<CR>")
local request = requests[#requests]
assert(request.method == "textDocument/rename")
assert(request.bufnr == source and request.params.position.character == 3, "rename retains source and encoding")
assert(request.params.newName == "updated" and request.callback == handler)
assert(api.nvim_get_current_win() == source_win)
vim.wait(10)

local count = #requests
prepare().callback(nil, { placeholder = "target" })
key("<Esc>")
assert(#requests == count + 1, "cancel sends no rename")
vim.wait(10)
prepare().callback(nil, { placeholder = "target" })
key("<CR>")
assert(requests[#requests].method == "textDocument/prepareRename", "unchanged name is ignored")
vim.wait(10)

request = prepare()
api.nvim_win_set_cursor(0, { 1, 6 })
request.callback(nil, { placeholder = "target" })
assert(api.nvim_get_current_buf() == source, "stale prepare response ignored")
api.nvim_win_set_cursor(0, { 1, 5 })
prepare().callback({ message = "Not renameable" }, nil)
assert(api.nvim_get_current_buf() == source and messages[#messages] == "Not renameable")
prepare().callback(nil, { start = { line = 0, character = 3 }, ["end"] = { line = 0, character = 9 } })
assert(api.nvim_get_current_line() == "target", "UTF-16 range resolves the symbol")
key("<Esc>")
vim.wait(10)

client.supports_method = function(_, method) return method ~= "textDocument/prepareRename" end
rename()
assert(api.nvim_get_current_line() == "target", "rename without prepare uses current word")
key("<Esc>")
vim.wait(10)
clients = {}
rename()
assert(api.nvim_get_current_buf() == source and messages[#messages]:find("No language server"))

local help_count = 0
vim.lsp.buf.signature_help = function(opts)
    assert(opts.focus == false and opts.silent == true)
    help_count = help_count + 1
end
local real_mode = api.nvim_get_mode
api.nvim_get_mode = function() return { mode = "i" } end
local second = vim.deepcopy(client)
second.id = 2
second.server_capabilities.signatureHelpProvider = { triggerCharacters = { "," }, retriggerCharacters = { ";" } }
clients = { client, second }
signature.setup(client, source)
signature.setup(second, source)
assert(#api.nvim_get_autocmds({ group = "LspSignature", buffer = source }) == 1, "single callback per buffer")
local function type_line(line)
    api.nvim_buf_set_lines(source, 0, -1, false, { line .. " " })
    api.nvim_win_set_cursor(0, { 1, #line })
    api.nvim_exec_autocmds("TextChangedI", { buffer = source })
end
type_line("call(")
type_line("call(a,")
type_line("call(a;")
assert(help_count == 3, "triggers from both clients and retriggers work")
type_line("call(a")
assert(help_count == 3, "no extra request for the previous character")
clients = {}
type_line("call(")
assert(help_count == 3, "detached clients do not trigger help")
api.nvim_get_mode = real_mode

-- Exercise the actual lazy config callback and on_attach wiring without plugins.
package.preload["blink.cmp"] = function() return { get_lsp_capabilities = function() return {} end } end
package.preload["clangd_extensions"] = function() return { setup = function() end } end
package.preload["cmake-tools"] = function() return { setup = function() end } end
local attach
vim.lsp.config = function(name, opts) if name == "*" then attach = opts.on_attach end end
vim.lsp.enable = function() end
vim.lsp.inlay_hint.enable = function() end
require("plugins.lsp.lspconfig")[1].config()
assert(type(attach) == "function")
attach(client, source)
local found = false
for _, map in ipairs(api.nvim_buf_get_keymap(source, "n")) do
    if map.desc == "Interactive Rename" then
        assert(map.callback == rename)
        found = true
    end
end
assert(found, "LSP attach installs interactive rename mapping")
print("PASS: rename encoding, submit/cancel, stale responses, prepare rejection/ranges, signature triggers/detach, LSP loading")
