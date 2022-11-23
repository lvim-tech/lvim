local languages_setup = require("languages.base.utils")
local zls_config = require("languages.base.languages._configs").default_config({ "zig", "zir" }, "zig")

local language_configs = {}

language_configs["dependencies"] = { "zls" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "zig",
        ["zls"] = { "zls", zls_config },
    })
end

return language_configs
