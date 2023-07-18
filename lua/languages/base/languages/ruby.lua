local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "ruby",
}
local solargraph_config = require("languages.base.languages._configs").default_config(ft, "ruby")
local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "solargraph", "rubocop" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "ruby",
        ["ft"] = ft,
        ["solargraph"] = { "solargraph", solargraph_config },
        ["efm"] = {
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
