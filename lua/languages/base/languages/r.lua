local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "r",
    "rmd",
}
local r_language_server_config = require("languages.base.languages._configs").default_config(ft, "r")

local language_configs = {}

language_configs["dependencies"] = { "r-languageserver" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "r",
        ["ft"] = ft,
        ["r-languageserver"] = { "r_language_server", r_language_server_config },
    })
end

return language_configs
