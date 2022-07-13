local languages_setup = require("languages.base.utils")
local zk_config = require("languages.base.languages._configs").default_config({ "markdown" }, "markdown")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["zk"] = { "zk", zk_config },
    })
end

return language_configs
