local languages_setup = require("languages.base.utils")
local cmake_config = require("languages.base.languages._configs").default_config({ "cmake" }, "cmake")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "cmake",
        ["cmake-language-server"] = { "cmake", cmake_config },
    })
end

return language_configs
