local languages_setup = require("languages.base.utils")
local yamlls_config = require("languages.base.languages._configs").without_formatting({ "yaml" }, "yaml")

local language_configs = {}

language_configs["dependencies"] = { "yaml-language-server", "yamllint" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "yaml",
        ["yaml-language-server"] = { "yamlls", yamlls_config },
        ["dependencies"] = {
            "yamllint",
            "yamlfmt",
        },
    })
end

return language_configs
