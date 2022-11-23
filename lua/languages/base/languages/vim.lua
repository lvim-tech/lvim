local languages_setup = require("languages.base.utils")
local vimls_config = require("languages.base.languages._configs").default_config({ "vim" }, "vim")

local language_configs = {}

language_configs["dependencies"] = { "vim-language-server", "vint" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "vim",
        ["vim-language-server"] = { "vimls", vimls_config },
        ["dependencies"] = {
            "vint",
        },
    })
end

return language_configs
