local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "sh",
    "bash",
    "zsh",
    "csh",
    "ksh",
}
local bashls_config = require("languages.base.languages._configs").without_formatting(ft, "shell")

local language_configs = {}

language_configs["dependencies"] = { "bash-language-server", "shfmt" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "shell",
        ["ft"] = ft,
        ["bash-language-server"] = { "bashls", bashls_config },
        ["efm"] = {
            "shfmt",
        },
    })
end

return language_configs
