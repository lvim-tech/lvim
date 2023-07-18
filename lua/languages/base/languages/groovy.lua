local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "groovy",
}
local groovy_lsp_config = require("languages.base.languages._configs").groovy_config(ft, "groovy")

local language_configs = {}

language_configs["dependencies"] = { "groovy-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "groovy",
        ["ft"] = ft,
        ["groovy-language-server"] = { "groovyls", groovy_lsp_config },
    })
end

return language_configs
