local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "proto",
}
local language_server_config = require("languages.base.languages._configs").without_formatting(ft)

local language_configs = {}

language_configs["dependencies"] = { "buf-language-server", "buf", "clang-format" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "proto",
        ["ft"] = ft,
        ["buf-language-server"] = { "buf_ls", language_server_config },
        ["efm"] = {
            "buf",
            "clang-format",
        },
    })
end

return language_configs
