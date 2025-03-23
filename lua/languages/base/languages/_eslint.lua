local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
}
local language_server_config = require("languages.base.languages._configs").without_winbar_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "eslint-lsp" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "eslint",
        ["ft"] = ft,
        ["eslint-lsp"] = { "eslint", language_server_config },
    })
end

return language_configs
