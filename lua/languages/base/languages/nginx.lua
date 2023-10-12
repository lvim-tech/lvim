local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "nginx",
}
local nginx_config = require("languages.base.languages._configs").default_config(ft, "nginx")

local language_configs = {}

language_configs["dependencies"] = { "nginx-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "nginx",
        ["ft"] = ft,
        ["nginx-language-server"] = { "nginx_language_server", nginx_config },
    })
end

return language_configs
