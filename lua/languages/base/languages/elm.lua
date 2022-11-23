local languages_setup = require("languages.base.utils")
local elmls_config = require("languages.base.languages._configs").default_config({ "elm" }, "elm")

local language_configs = {}

language_configs["dependencies"] = { "elm-language-server" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "elm",
        ["elm-language-server"] = { "elmls", elmls_config },
    })
end

return language_configs
