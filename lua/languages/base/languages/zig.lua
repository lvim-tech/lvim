local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "zig",
    "zir",
}
local language_server_config = require("languages.base.languages._configs").default_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "zls" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "zig",
        ["ft"] = ft,
        ["zls"] = { "zls", language_server_config },
    })
end

return language_configs
