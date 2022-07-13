local languages_setup = require("languages.base.utils")
local diagnosticls_config = require("languages.base.languages._configs_diagnosticls").default_config({
    "c",
    "cpp",
    "html",
    "json",
    "less",
    "lua",
    "markdown",
    "objc",
    "objcpp",
    "python",
    "sh",
    "vim",
}, "_diagnosticls")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["dependencies"] = {
            "black",
            "cpplint",
            "luacheck",
            "prettier",
            "pylint",
            "shellcheck",
            "shfmt",
            "stylua",
            "vint",
        },
        ["diagnostic-languageserver"] = { "diagnosticls", diagnosticls_config },
    })
end

return language_configs
