local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "clojure",
    "edn",
}
local clojure_lsp_config = require("languages.base.languages._configs").default_config(ft, "clojure")

local language_configs = {}

language_configs["dependencies"] = { "clojure-lsp" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "clojure",
        ["ft"] = ft,
        ["clojure-lsp"] = { "clojure_lsp", clojure_lsp_config },
    })
end

return language_configs
