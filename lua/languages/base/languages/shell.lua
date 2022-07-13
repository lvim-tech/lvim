local languages_setup = require("languages.base.utils")
local bashls_config = require("languages.base.languages._configs").default_config({ "sh" }, "shell")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["bash-language-server"] = { "bashls", bashls_config },
    })
end

return language_configs
