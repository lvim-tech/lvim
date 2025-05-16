local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

local lsp_dependencies = {
    "typescript-language-server",
    "js-debug-adapter",
}

local lsp_config = nil
local root_markers = {
    "tsconfig.json",
    "jsconfig.json",
    "package.json",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
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
    ---@type table<string, any>
    dap.configurations = dap.configurations or {}
    dap.configurations.typescript = dap.configurations.typescript or {}
    dap.configurations.javascript = dap.configurations.javascript or {}
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
    dap.configurations.typescript = dap.configurations.javascript

    lsp_config = {
        name = "jsts",
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = _G.file_types.jsts,
        root_dir = nil,
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
                implementationsCodeLens = {
                    enabled = true,
                },
                referencesCodeLens = {
                    enabled = true,
                },
                codeLens = true,
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
                implementationsCodeLens = {
                    enabled = true,
                },
                referencesCodeLens = {
                    enabled = true,
                },
                codeLens = true,
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = (function()
            local capabilities = setup_diagnostics.get_capabilities()
            capabilities.textDocument.codeLens = {
                dynamicRegistration = true,
                resolveProvider = true,
            }
            return capabilities
        end)(),
    }
end)

return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
