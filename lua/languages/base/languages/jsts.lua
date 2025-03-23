local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
}
local language_server_config = require("languages.base.languages._configs").jsts_config(ft)

local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "typescript-language-server", "js-debug-adapter" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "jsts",
        ["ft"] = ft,
        ["typescript-language-server"] = { "ts_ls", language_server_config },
        ["dap"] = { "js-debug-adapter" },
    })
end
language_configs["dap"] = function()
    dap.adapters["pwa-node"] = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
            command = "js-debug-adapter",
            args = {
                "${port}",
            },
        },
    }
    dap.configurations.javascript = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node app",
            address = "localhost",
            port = 9229,
            cwd = "${workspaceFolder}",
            restart = true,
        },
    }
    dap.configurations.typescript = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node app",
            address = "localhost",
            port = 9229,
            cwd = "${workspaceFolder}",
            restart = true,
        },
    }
end

return language_configs
