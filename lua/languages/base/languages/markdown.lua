local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "markdown",
}
local marksman_config = require("languages.base.languages._configs").without_formatting(ft, "markdown")

local language_configs = {}

language_configs["dependencies"] = { "marksman", "prettierd", "cbfmt" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "markdown",
        ["ft"] = ft,
        ["marksman"] = { "marksman", marksman_config },
        ["efm"] = {
            "prettierd",
            "cbfmt",
        },
    })
end

return language_configs
