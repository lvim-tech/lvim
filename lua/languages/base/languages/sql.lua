local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "sql",
    "mysql",
}
local language_server_config = require("languages.base.languages._configs").default_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "sqls" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "sql",
        ["ft"] = ft,
        ["sqls"] = { "sqls", language_server_config },
    })
end

return language_configs
