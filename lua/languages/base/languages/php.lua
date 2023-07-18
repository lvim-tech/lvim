local global = require("core.global")
local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "php",
}
local intelephense_config = require("languages.base.languages._configs").default_config(ft, "php")
local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "intelephense", "php-debug-adapter" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "php",
        ["ft"] = ft,
        ["dap"] = { "php-debug-adapter" },
        ["intelephense"] = { "intelephense", intelephense_config },
    })
end

language_configs["dap"] = function()
    dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { global.mason_path .. "/packages/php-debug-adapter/extension/out/phpDebug.js" },
    }
    dap.configurations.php = {
        {
            type = "php",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${fileDirname}",
            port = function()
                local val = tonumber(vim.fn.input("Port: "))
                assert(val, "Please provide a port number")
                return val
            end,
            runtimeArgs = {
                "-dxdebug.start_with_request=yes",
            },
            env = {
                XDEBUG_MODE = "debug,develop",
                XDEBUG_CONFIG = "client_port=${port}",
            },
        },
    }
end

return language_configs
