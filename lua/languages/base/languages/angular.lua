-- npm --save-dev install @angular/language-server @angular/language-service typescript
local languages_setup = require("languages.base.utils")
local angularls_config = require("languages.base.languages._configs").angular_config(
    { "typescript", "html", "typescriptreact", "typescript.tsx" },
    "angular"
)

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "angular",
        ["angular-language-server"] = { "angularls", angularls_config },
    })
end

return language_configs
