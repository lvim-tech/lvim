local languages_setup = require("languages.base.utils")
local volar_config = require("languages.base.languages._configs").default_config({ "vue" }, "vue")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["vue-language-server"] = { "volar", volar_config },
    })
end

return language_configs
