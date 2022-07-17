local languages_setup = require("languages.base.utils")
local sumneko_lua_config = require("languages.base.languages._configs").default_config({ "lua" }, "lua")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "lua",
        ["lua-language-server"] = { "sumneko_lua", sumneko_lua_config },
    })
end

language_configs["dap"] = function()
    dap.adapters.nlua = function(callback, config)
        callback({ type = "server", host = config.host, port = config.port })
    end
    dap.configurations.lua = {
        {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
            host = function()
                local value = vim.fn.input("Host [127.0.0.1]: ")
                if value ~= "" then
                    return value
                end
                return "127.0.0.1"
            end,
            port = function()
                local val = tonumber(vim.fn.input("Port: "))
                assert(val, "Please provide a port number")
                return val
            end,
        },
    }
end

return language_configs
