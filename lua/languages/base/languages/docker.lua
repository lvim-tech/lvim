local languages_setup = require("languages.base.utils")
local docker_config = require("languages.base.languages._configs").default_config({ "dockerfile" }, "docker-langserver")

local language_configs = {}

language_configs["dependencies"] = { "dockerfile-language-server" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "dockerfile",
        ["dockerfile-language-server"] = { "dockerls", docker_config },
    })
end

return language_configs
