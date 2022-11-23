local languages_setup = require("languages.base.utils")

local language_configs = {}

language_configs["dependencies"] = { "cbfmt" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "org",
        ["dependencies"] = {
            "cbfmt",
        },
    })
end

return language_configs
