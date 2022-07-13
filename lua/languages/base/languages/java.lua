local languages_setup = require("languages.base.utils")
local jdtls_config = require("languages.base.languages._configs").default_config({ "java" }, "java")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["jdtls"] = { "jdtls", jdtls_config },
    })
end

return language_configs
