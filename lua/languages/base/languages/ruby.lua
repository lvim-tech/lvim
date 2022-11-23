local languages_setup = require("languages.base.utils")
local solargraph_config = require("languages.base.languages._configs").default_config({ "ruby" }, "ruby")
local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "solargraph", "rubocop" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "ruby",
        ["solargraph"] = { "solargraph", solargraph_config },
        ["dependencies"] = {
            "rubocop",
        },
    })
end

language_configs["dap"] = function()
    dap.adapters.ruby = function(callback, config)
        callback({
            type = "server",
            host = "127.0.0.1",
            port = "${port}",
            executable = {
                command = "bundle",
                args = {
                    "exec",
                    "rdbg",
                    "-n",
                    "--open",
                    "--port",
                    "${port}",
                    "-c",
                    "--",
                    "bundle",
                    "exec",
                    config.command,
                    config.script,
                },
            },
        })
    end

    dap.configurations.ruby = {
        {
            type = "ruby",
            name = "Debug current file",
            request = "attach",
            localfs = true,
            command = "ruby",
            script = "${file}",
        },
        {
            type = "ruby",
            name = "Run current spec file",
            request = "attach",
            localfs = true,
            command = "rspec",
            script = "${file}",
        },
    }
end

return language_configs
