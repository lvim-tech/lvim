local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "cmake",
}
local cmake_config = require("languages.base.languages._configs").default_config(ft, "cmake")

local language_configs = {}

language_configs["dependencies"] = { "cmake-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "cmake",
        ["ft"] = ft,
        ["cmake-language-server"] = { "cmake", cmake_config },
    })
end

return language_configs
