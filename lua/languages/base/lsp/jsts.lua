-- LSP configuration for JavaScript and TypeScript
-- Uses typescript-language-server (tsserver wrapper) with exhaustive inlay
-- hints and code lenses. js-debug-adapter (pwa-node) provides DAP debugging
-- for both JS and TS; the TypeScript config reuses the JavaScript DAP setup.
---@module "languages.base.lsp.jsts"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "typescript-language-server",
    "js-debug-adapter",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for JS/TS projects
local root_markers = {
    "tsconfig.json",
    "jsconfig.json",
    "package.json",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    -- Register the js-debug-adapter as a DAP server adapter.
    -- ${port} is replaced by nvim-dap with an automatically chosen free port.
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
            program = "${file}",  -- debug the currently open file
            cwd = "${workspaceFolder}",
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node app",
            address = "localhost",
            port = 9229,   -- default Node.js inspector port
            cwd = "${workspaceFolder}",
            restart = true,  -- auto-reconnect when the process restarts (nodemon-friendly)
        },
    }
    -- TypeScript and JavaScript share identical DAP configurations
    dap.configurations.typescript = dap.configurations.javascript

    lsp_config = {
        name = "jsts",
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = _G.LVIM.file_types.jsts,
        root_dir = nil,  -- let lspconfig auto-detect from root_markers above
        settings = {
            typescript = {
                inlayHints = {
                    -- Show all parameter name hints, even when they match the argument name
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
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---@param client any
        ---@param bufnr  integer
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        -- Advertise codeLens capability so tsserver returns reference/implementation counts
        capabilities = (function()
            local capabilities = setup_diagnostics.get_capabilities()
            capabilities.textDocument.codeLens = { ---@diagnostic disable-line: undefined-field
                dynamicRegistration = true,
                resolveProvider = true,
            }
            return capabilities
        end)(),
    }
end)

return setmetatable({}, {
    ---@param _ table
    ---@param key string
    ---@return table|nil
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
