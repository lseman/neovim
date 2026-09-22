local M = {}

function M.setup()
    require("theme_picker.state").restore()
end

for _, method in ipairs({ "open", "close", "toggle" }) do
    M[method] = function(...)
        return require("theme_picker.picker")[method](...)
    end
end

return M
