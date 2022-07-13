local languages_setup = require("languages.base.utils")
local emmet_ls_config = require("languages.base.languages._configs").without_winbar_config(
    { "html", "css", "typescriptreact", "javascriptreact" },
    "_emmet"
)

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["emmet-ls"] = { "emmet_ls", emmet_ls_config },
    })
end

return language_configs
