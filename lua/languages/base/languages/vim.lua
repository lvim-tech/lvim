local languages_setup = require("languages.base.utils")
local vimls_config = require("languages.base.languages._configs").default_config({ "vim" }, "vim")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["vim-language-server"] = { "vimls", vimls_config },
    })
end

return language_configs
