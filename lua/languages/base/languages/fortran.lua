local languages_setup = require("languages.base.utils")
local fortls_config = require("languages.base.languages._configs").default_config({ "fortran" }, "fortran")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "fortran",
        ["fortls"] = { "fortls", fortls_config },
    })
end

return language_configs
