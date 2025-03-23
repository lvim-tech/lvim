local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "css",
    "scss",
    "less",
}
local language_server_config = require("languages.base.languages._configs").without_winbar_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "stylelint-lsp" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "stylelint",
        ["ft"] = ft,
        ["stylelint-lsp"] = { "stylelint_lsp", language_server_config },
    })
end

return language_configs
