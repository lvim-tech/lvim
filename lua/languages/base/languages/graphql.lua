local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "graphql",
}
local graphql_config = require("languages.base.languages._configs").default_config(ft, "graphql")

local language_configs = {}

language_configs["dependencies"] = { "graphql-language-service-cli" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "graphql",
        ["ft"] = ft,
        ["graphql-language-service-cli"] = { "graphql", graphql_config },
    })
end

return language_configs
