local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "elm",
}
local elmls_config = require("languages.base.languages._configs").default_config(ft, "elm")

local language_configs = {}

language_configs["dependencies"] = { "elm-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "elm",
        ["ft"] = ft,
        ["elm-language-server"] = { "elmls", elmls_config },
    })
end

return language_configs
