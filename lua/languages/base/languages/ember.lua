local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "handlebars",
    "typescript",
    "javascript",
}
local ember_config = require("languages.base.languages._configs").ember_config(ft, "ember")

local language_configs = {}

language_configs["dependencies"] = { "ember-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "ember",
        ["ft"] = ft,
        ["ember-language-server"] = { "ember", ember_config },
    })
end

return language_configs
