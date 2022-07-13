local languages_setup = require("languages.base.utils")
local eslint_config = require("languages.base.languages._configs").without_winbar_config({
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
}, "_eslint")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["eslint-lsp"] = { "eslint", eslint_config },
    })
end

return language_configs
