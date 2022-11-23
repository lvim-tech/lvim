local languages_setup = require("languages.base.utils")
local texlab_config = require("languages.base.languages._configs").default_config({ "bib", "tex" }, "latex")

local language_configs = {}

language_configs["dependencies"] = { "texlab" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "latex",
        ["texlab"] = { "texlab", texlab_config },
    })
end

return language_configs
