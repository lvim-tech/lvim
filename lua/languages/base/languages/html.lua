local languages_setup = require("languages.base.utils")
local html_config = require("languages.base.languages._configs").without_formatting({ "html" }, "html")

local language_configs = {}

language_configs["dependencies"] = { "html-lsp", "prettierd" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "html",
        ["html-lsp"] = { "html", html_config },
        ["dependencies"] = {
            "prettierd",
        },
    })
end

return language_configs
