local languages_setup = require("languages.base.utils")
local erlangls_config = require("languages.base.languages._configs").default_config({ "erlang" }, "erlang")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["erlang-ls"] = { "erlangls", erlangls_config },
    })
end

return language_configs
