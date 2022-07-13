local languages_setup = require("languages.base.utils")
local gopls_config = require("languages.base.languages._configs").default_config({ "go", "gomod" }, "go")
local golangci_lint_ls_config =
    require("languages.base.languages._configs").without_winbar_config({ "go", "gomod" }, "go")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["dap"] = { "delve" },
        ["gopls"] = { "gopls", gopls_config },
        ["golangci-lint-langserver"] = { "golangci_lint_ls", golangci_lint_ls_config },
    })
end

language_configs["dap"] = function()
    dap.adapters.go = function(callback)
        local handle
        local port = 38697
        handle = vim.loop.spawn("dlv", {
            args = { "dap", "-l", "127.0.0.1:" .. port },
            detached = true,
        }, function(code)
            handle:close()
            vim.notify("Delve exited with exit code: " .. code)
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
