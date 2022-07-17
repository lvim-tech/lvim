local languages_setup = require("languages.base.utils")
local julials_config = require("languages.base.languages._configs").default_config({ "julia" }, "julia")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "julia",
        ["julia-lsp"] = { "julials", julials_config },
    })
end

return language_configs
