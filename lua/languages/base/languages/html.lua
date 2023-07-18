local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "html",
}
local html_config = require("languages.base.languages._configs").without_formatting(ft, "html")

local language_configs = {}

language_configs["dependencies"] = { "html-lsp", "prettierd" }

html_config.settings = {
    html = {
        format = false,
    },
}

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "html",
        ["ft"] = ft,
        ["html-lsp"] = { "html", html_config },
    })
end

return language_configs
