local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "ocaml",
    "ocaml.menhir",
    "ocaml.interface",
    "ocaml.ocamllex",
    "reason",
    "dune",
}
local language_server_config = require("languages.base.languages._configs").default_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "ocaml-lsp" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "ocaml",
        ["ft"] = ft,
        ["ocaml-lsp"] = { "ocamllsp", language_server_config },
        ["dependencies"] = {
            "ocamlformat",
        },
    })
end

return language_configs
