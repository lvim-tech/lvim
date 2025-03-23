local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "fortran",
}
local language_server_config = require("languages.base.languages._configs").default_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "fortls" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "fortran",
        ["ft"] = ft,
        ["fortls"] = { "fortls", language_server_config },
    })
end

return language_configs
