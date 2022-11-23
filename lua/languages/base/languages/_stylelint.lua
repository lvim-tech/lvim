local languages_setup = require("languages.base.utils")
local stylelint_lsp_config = require("languages.base.languages._configs").without_winbar_config({
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "sugarss",
}, "_stylelint")

local language_configs = {}

language_configs["dependencies"] = {"stylelint-lsp"}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "stylelint",
        ["stylelint-lsp"] = { "stylelint_lsp", stylelint_lsp_config },
    })
end

return language_configs
