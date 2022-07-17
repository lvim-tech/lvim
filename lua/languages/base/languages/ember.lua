local languages_setup = require("languages.base.utils")
local ember_config =
    require("languages.base.languages._configs").ember_config({ "handlebars", "typescript", "javascript" }, "ember")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "ember",
        ["ember-language-server"] = { "ember", ember_config },
    })
end

return language_configs
