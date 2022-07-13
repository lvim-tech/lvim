local languages_setup = require("languages.base.utils")
local lemminx_config =
    require("languages.base.languages._configs").default_config({ "xml", "xsd", "xsl", "xslt", "svg" }, "xml")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["lemminx"] = { "lemminx", lemminx_config },
    })
end

return language_configs
