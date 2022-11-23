local languages_setup = require("languages.base.utils")
local graphql_config = require("languages.base.languages._configs").default_config({ "graphql" }, "graphql")

local language_configs = {}

language_configs["dependencies"] = { "graphql-language-service-cli" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "graphql",
        ["graphql-language-service-cli"] = { "graphql", graphql_config },
    })
end

return language_configs
