local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "dockerfile",
}
local language_server_config = require("languages.base.languages._configs").default_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "dockerfile-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "dockerfile",
        ["ft"] = ft,
        ["dockerfile-language-server"] = { "dockerls", language_server_config },
    })
end

return language_configs
