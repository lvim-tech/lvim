local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "css",
    "scss",
    "less",
    "sass",
}
local cssls_config = require("languages.base.languages._configs").without_formatting(ft, "css")

local language_configs = {}

language_configs["dependencies"] = { "css-lsp", "prettierd" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "css",
        ["ft"] = ft,
        -- ["css-lsp"] = { "cssls", cssls_config },
        ["efm"] = {
            "prettierd",
        },
    })
end

return language_configs
