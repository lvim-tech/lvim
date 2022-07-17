local languages_setup = require("languages.base.utils")
local elixirls_config = require("languages.base.languages._configs").default_config({ "elixir", "eelixir" }, "elixir")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "elixir",
        ["elixir-lsp"] = { "elixirls", elixirls_config },
    })
end

return language_configs
