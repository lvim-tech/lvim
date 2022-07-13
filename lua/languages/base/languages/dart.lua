local flutter_tools = require("flutter-tools")

local language_configs = {}

language_configs["lsp"] = function()
    flutter_tools.setup({
        debugger = {
            enabled = true,
        },
        closing_tags = {
            prefix = " ",
        },
    })
end

return language_configs
