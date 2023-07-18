local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "d",
}
local serve_d_config = require("languages.base.languages._configs").default_config(ft, "d")

local language_configs = {}

language_configs["dependencies"] = { "serve-d" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "d",
        ["ft"] = ft,
        ["serve-d"] = { "serve_d", serve_d_config },
    })
end

return language_configs
