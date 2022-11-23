local languages_setup = require("languages.base.utils")
local clojure_lsp_config = require("languages.base.languages._configs").default_config({ "clojure", "edn" }, "clojure")

local language_configs = {}

language_configs["dependencies"] = { "clojure-lsp" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "clojure",
        ["clojure-lsp"] = { "clojure_lsp", clojure_lsp_config },
    })
end

return language_configs
