local languages_setup = require("languages.base.utils")
local r_language_server_config = require("languages.base.languages._configs").default_config({ "r", "rmd" }, "r")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["r-languageserver"] = { "r_language_server", r_language_server_config },
    })
end

return language_configs
