local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "kotlin",
}
local language_server_config = require("languages.base.languages._configs").default_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "kotlin-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "kotlin",
        ["ft"] = ft,
        ["kotlin-language-server"] = { "kotlin_language_server", language_server_config },
    })
end

return language_configs
