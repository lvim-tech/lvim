local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "go",
    "gomod",
}
local gopls_config = require("languages.base.languages._configs").go(ft, "go")
local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "gopls", "delve", "golangci-lint" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "go",
        ["ft"] = ft,
        ["dap"] = { "delve" },
        ["gopls"] = { "gopls", gopls_config },
        ["efm"] = {
            "golangci-lint",
        },
    })
end

language_configs["dap"] = function()
    dap.adapters.go = function(callback)
        local handle
        local port = 38697
        handle = vim.loop.spawn("dlv", {
            args = { "dap", "-l", "127.0.0.1:" .. port },
            detached = true,
        }, function(_)
            handle:close()
        end)
        vim.defer_fn(function()
            callback({ type = "server", host = "127.0.0.1", port = port })
        end, 100)
    end
    dap.configurations.go = {
        {
            type = "go",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
        },
        {
            type = "go",
            name = "Launch test",
            request = "launch",
            mode = "test",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
        },
    }
end

return language_configs
