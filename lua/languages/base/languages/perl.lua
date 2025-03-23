local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "perl",
}
local language_server_config = require("languages.base.languages._configs").default_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "perlnavigator" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "perl",
        ["ft"] = ft,
        ["perlnavigator"] = { "perlnavigator", language_server_config },
    })
end

return language_configs
