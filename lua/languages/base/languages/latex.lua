local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "bib",
    "tex",
}
local language_server_config = require("languages.base.languages._configs").default_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "texlab" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "latex",
        ["ft"] = ft,
        ["texlab"] = { "texlab", language_server_config },
    })
end

return language_configs
