local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "yaml",
}
local language_server_config = require("languages.base.languages._configs").yaml_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "yaml-language-server", "yamllint", "yamlfmt" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "yaml",
        ["ft"] = ft,
        ["yaml-language-server"] = { "yamlls", language_server_config },
        ["efm"] = {
            "yamllint",
            "yamlfmt",
        },
    })
end

return language_configs
