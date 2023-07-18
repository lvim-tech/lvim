local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "org",
}

local language_configs = {}

language_configs["dependencies"] = { "cbfmt" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "org",
        ["ft"] = ft,
        ["efm"] = {
            "cbfmt",
        },
    })
end

return language_configs
