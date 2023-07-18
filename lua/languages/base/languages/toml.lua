local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "toml",
}
local taplo_config = require("languages.base.languages._configs").default_config(ft, "toml")

local language_configs = {}

language_configs["dependencies"] = { "taplo" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "toml",
        ["ft"] = ft,
        ["taplo"] = { "taplo", taplo_config },
    })
end

return language_configs
