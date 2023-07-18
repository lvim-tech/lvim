local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "julia",
}
local julials_config = require("languages.base.languages._configs").default_config(ft, "julia")

local language_configs = {}

language_configs["dependencies"] = { "julia-lsp" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "julia",
        ["ft"] = ft,
        ["julia-lsp"] = { "julials", julials_config },
    })
end

return language_configs
