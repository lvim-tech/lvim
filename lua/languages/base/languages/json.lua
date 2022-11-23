local languages_setup = require("languages.base.utils")
local jsonls_config = require("languages.base.languages._configs").default_config({ "json" }, "json")

local language_configs = {}

language_configs["dependencies"] = { "json-lsp" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "json",
        ["json-lsp"] = { "jsonls", jsonls_config },
    })
end

return language_configs
