local languages_setup = require("languages.base.utils")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["dependencies"] = {
            "cbfmt",
        },
    })
end

return language_configs
