local languages_setup = require("languages.base.utils")
local sqls_config = require("languages.base.languages._configs").default_config({ "sql", "mysql" }, "sql")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["sqls"] = { "sqls", sqls_config },
    })
end

return language_configs
