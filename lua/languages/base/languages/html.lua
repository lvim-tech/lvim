local languages_setup = require("languages.base.utils")
local html_config = require("languages.base.languages._configs").default_config({ "html" }, "html")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["html-lsp"] = { "html", html_config },
    })
end

return language_configs
