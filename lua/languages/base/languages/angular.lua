-- npm --save-dev install @angular/language-server @angular/language-service typescript
local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "typescript",
    "html",
    "typescriptreact",
    "typescript.tsx",
}
local angularls_config = require("languages.base.languages._configs").angular_config(ft, "angular")

local language_configs = {}

language_configs["dependencies"] = { "angular-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "angular",
        ["ft"] = ft,
        ["angular-language-server"] = { "angularls", angularls_config },
    })
end

return language_configs
