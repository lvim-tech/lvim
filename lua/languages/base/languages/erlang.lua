local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "erlang",
}
local erlangls_config = require("languages.base.languages._configs").default_config(ft, "erlang")

local language_configs = {}

language_configs["dependencies"] = { "erlang-ls" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "erlang",
        ["ft"] = ft,
        ["erlang-ls"] = { "erlangls", erlangls_config },
    })
end

return language_configs
