local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "vue",
}
local volar_config = require("languages.base.languages._configs").default_config(ft, "vue")

local language_configs = {}

language_configs["dependencies"] = { "vue-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "vue",
        ["ft"] = ft,
        ["vue-language-server"] = { "volar", volar_config },
    })
end

return language_configs
