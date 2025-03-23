local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "clojure",
    "edn",
}
local language_server_config = require("languages.base.languages._configs").default_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "clojure-lsp" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "clojure",
        ["ft"] = ft,
        ["clojure-lsp"] = { "clojure_lsp", language_server_config },
    })
end

return language_configs
