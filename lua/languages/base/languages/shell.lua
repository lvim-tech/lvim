local languages_setup = require("languages.base.utils")
local bashls_config =
    require("languages.base.languages._configs").without_formatting({ "sh", "bash", "zsh", "csh", "ksh" }, "shell")

local language_configs = {}

language_configs["dependencies"] = { "bash-language-server", "shfmt", "shellcheck" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "shell",
        ["bash-language-server"] = { "bashls", bashls_config },
        ["dependencies"] = {
            "shfmt",
            "shellcheck",
        },
    })
end

return language_configs
