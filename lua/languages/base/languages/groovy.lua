local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "groovy",
}
local language_server_config = require("languages.base.languages._configs").groovy_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "groovy-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "groovy",
        ["ft"] = ft,
        ["groovy-language-server"] = { "groovyls", language_server_config },
    })
end

return language_configs
