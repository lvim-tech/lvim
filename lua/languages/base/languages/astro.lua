-- npm --save-dev install @angular/language-server @angular/language-service typescript
local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "astro",
}
local language_server_config = require("languages.base.languages._configs").astro_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "astro-language-server", "prettierd", "emmet" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "astro",
        ["ft"] = ft,
        ["astro-language-server"] = { "astro", language_server_config },
        ["efm"] = {
            "prettierd",
        },
    })
end

return language_configs
