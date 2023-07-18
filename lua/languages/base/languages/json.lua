local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "json",
}
local jsonls_config = require("languages.base.languages._configs").default_config(ft, "json")

local language_configs = {}

language_configs["dependencies"] = { "json-lsp" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "json",
        ["ft"] = ft,
        ["json-lsp"] = { "jsonls", jsonls_config },
    })
end

return language_configs
