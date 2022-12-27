local languages_setup = require("languages.base.utils")
local ocaml_config = require("languages.base.languages._configs").default_config(
    { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
    "ocaml"
)

local language_configs = {}

language_configs["dependencies"] = { "ocaml-lsp" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "ocaml",
        ["ocaml-lsp"] = { "ocamllsp", ocaml_config },
    })
end

return language_configs
