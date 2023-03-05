local languages_setup = require("languages.base.utils")
local groovy_lsp_config = require("languages.base.languages._configs").groovy_config({ "groovy" }, "groovy")

local language_configs = {}

language_configs["dependencies"] = { "groovy-language-server" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "groovy",
        ["groovy-language-server"] = { "groovyls", groovy_lsp_config },
    })
end

return language_configs
