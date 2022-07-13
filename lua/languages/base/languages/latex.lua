local languages_setup = require("languages.base.utils")
local ltex_config = require("languages.base.languages._configs").default_config({ "bib", "tex" }, "latex")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["ltex-ls"] = { "ltex", ltex_config },
    })
end

return language_configs
