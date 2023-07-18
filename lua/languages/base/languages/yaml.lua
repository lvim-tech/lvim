local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "yaml",
}
local yamlls_config = require("languages.base.languages._configs").yaml_config(ft, "yaml")

local language_configs = {}

language_configs["dependencies"] = { "yaml-language-server", "yamllint", "yamlfmt" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "yaml",
        ["ft"] = ft,
        ["yaml-language-server"] = { "yamlls", yamlls_config },
        ["efm"] = {
            "yamllint",
            "yamlfmt",
        },
    })
end

return language_configs
