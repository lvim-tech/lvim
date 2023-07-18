local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "kotlin",
}
local clojure_lsp_config = require("languages.base.languages._configs").default_config(ft, "kotlin")

local language_configs = {}

language_configs["dependencies"] = { "kotlin-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "kotlin",
        ["ft"] = ft,
        ["kotlin-language-server"] = { "kotlin_language_server", clojure_lsp_config },
    })
end

return language_configs
