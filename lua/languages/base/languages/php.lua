local global = require("core.global")
local languages_setup = require("languages.base.utils")
local intelephense_config = require("languages.base.languages._configs").default_config({ "php" }, "php")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "php",
        ["dap"] = { "php-debug-adapter" },
        ["intelephense"] = { "intelephense", intelephense_config },
    })
end

language_configs["dap"] = function()
    dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { global.mason_path .. "packages/php-debug-adapter/extension/out/phpDebug.js" },
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
            port = 0,
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
