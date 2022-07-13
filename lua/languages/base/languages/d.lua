local languages_setup = require("languages.base.utils")
local serve_d_config = require("languages.base.languages._configs").default_config({ "d" }, "d")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["serve-d"] = { "serve_d", serve_d_config },
    })
end

return language_configs
