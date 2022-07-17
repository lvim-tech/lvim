local languages_setup = require("languages.base.utils")
local solargraph_config = require("languages.base.languages._configs").default_config({ "ruby" }, "ruby")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "ruby",
        ["solargraph"] = { "solargraph", solargraph_config },
    })
end

return language_configs
