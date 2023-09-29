local global = require("core.global")
local lsp_manager = require("languages.utils.lsp_manager")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local navic = require("nvim-navic")
local ft = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
}
local typescript_config = require("languages.base.languages._configs").jsts_config(ft, "jsts")
local dap = require("dap")

local language_configs = {}

local function start_server_tools()
    local ts_tools = require("typescript-tools")
    ts_tools.setup({
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.omni(client, bufnr)
            setup_diagnostics.tag(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_formatting(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                },
            },
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                },
            },
        },
    })
end

language_configs["dependencies"] = { "typescript-language-server", "js-debug-adapter" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "jsts",
        ["ft"] = ft,
        ["typescript-language-server"] = {},
        ["dap"] = { "js-debug-adapter" },
    })

    local function check_status()
        if global.install_proccess == false then
            start_server_tools()
            vim.cmd("LspStart rust_analyzer")
        else
            vim.defer_fn(function()
                check_status()
            end, 3100)
        end
    end

    check_status()
end

language_configs["dap"] = function()
    dap.configurations.javascript = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
        },
        {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            trace = true,
            runtimeExecutable = "node",
            runtimeArgs = {
                "./node_modules/jest/bin/jest.js",
                "--runInBand",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
        },
        {
            type = "pwa-node",
            request = "launch",
            name = "Debug Mocha Tests",
            trace = true,
            runtimeExecutable = "node",
            runtimeArgs = {
                "./node_modules/mocha/bin/mocha.js",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
        },
    }
    dap.configurations.typescript = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
        },
        {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            trace = true, -- include debugger info
            runtimeExecutable = "node",
            runtimeArgs = {
                "./node_modules/jest/bin/jest.js",
                "--runInBand",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
        },
        {
            type = "pwa-node",
            request = "launch",
            name = "Debug Mocha Tests",
            trace = true, -- include debugger info
            runtimeExecutable = "node",
            runtimeArgs = {
                "./node_modules/mocha/bin/mocha.js",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
        },
    }
end

return language_configs
