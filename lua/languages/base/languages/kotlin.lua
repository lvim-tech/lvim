local languages_setup = require("languages.base.utils")
local clojure_lsp_config = require("languages.base.languages._configs").default_config({ "kotlin" }, "kotlin")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["kotlin-language-server"] = { "kotlin_language_server", clojure_lsp_config },
    })
end

return language_configs
