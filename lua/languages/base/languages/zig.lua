local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "zig",
    "zir",
}
local zls_config = require("languages.base.languages._configs").default_config(ft, "zig")

local language_configs = {}

language_configs["dependencies"] = { "zls" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "zig",
        ["ft"] = ft,
        ["zls"] = { "zls", zls_config },
    })
end

return language_configs
