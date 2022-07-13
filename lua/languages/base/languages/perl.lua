local languages_setup = require("languages.base.utils")
local perlnavigator_config = require("languages.base.languages._configs").default_config({ "perl" }, "perl")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["perlnavigator"] = { "perlnavigator", perlnavigator_config },
    })
end

return language_configs
