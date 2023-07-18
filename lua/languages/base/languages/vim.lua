local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "vim",
}
local vimls_config = require("languages.base.languages._configs").default_config(ft, "vim")

local language_configs = {}

language_configs["dependencies"] = { "vim-language-server", "vint" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "vim",
        ["ft"] = ft,
        ["vim-language-server"] = { "vimls", vimls_config },
        ["efm"] = {
            "vint",
        },
    })
end

return language_configs
