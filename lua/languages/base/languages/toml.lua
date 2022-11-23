local languages_setup = require("languages.base.utils")
local taplo_config = require("languages.base.languages._configs").default_config({ "toml" }, "toml")

local language_configs = {}

language_configs["dependencies"] = { "taplo" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "toml",
        ["taplo"] = { "taplo", taplo_config },
    })
end

return language_configs
