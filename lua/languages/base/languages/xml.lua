local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "xml",
    "xsd",
    "xsl",
    "xslt",
    "svg",
}
local lemminx_config = require("languages.base.languages._configs").default_config(ft, "xml")

local language_configs = {}

language_configs["dependencies"] = { "lemminx" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "xml",
        ["ft"] = ft,
        ["lemminx"] = { "lemminx", lemminx_config },
    })
end

return language_configs
