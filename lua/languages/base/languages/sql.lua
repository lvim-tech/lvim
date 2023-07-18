local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "sql",
    "mysql",
}
local sqls_config = require("languages.base.languages._configs").default_config(ft, "sql")

local language_configs = {}

language_configs["dependencies"] = { "sqls" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "sql",
        ["ft"] = ft,
        ["sqls"] = { "sqls", sqls_config },
    })
end

return language_configs
