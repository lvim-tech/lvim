local languages_setup = require("languages.base.utils")
local cssls_config =
    require("languages.base.languages._configs").default_config({ "css", "scss", "less", "sass" }, "css")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "css",
        ["css-lsp"] = { "cssls", cssls_config },
    })
end

return language_configs
