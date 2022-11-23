local languages_setup = require("languages.base.utils")
local sqls_config = require("languages.base.languages._configs").default_config({ "sql", "mysql" }, "sql")

local language_configs = {}

language_configs["dependencies"] = { "sqls" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "sql",
        ["sqls"] = { "sqls", sqls_config },
    })
end

return language_configs
