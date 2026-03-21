-- LSP configuration for JavaScript and TypeScript
-- Uses typescript-language-server (tsserver wrapper) with exhaustive inlay
-- hints and code lenses. js-debug-adapter (pwa-node) provides DAP debugging
-- for both JS and TS; the TypeScript config reuses the JavaScript DAP setup.
---@module "modules.base.configs.languages.lsp.servers.jsts"

---@type string[]  Root-directory markers for JS/TS projects
local root_markers = {
    "tsconfig.json",
    "jsconfig.json",
    "package.json",
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "jsts",
            cmd = { "typescript-language-server", "--stdio" },
            root_dir = nil, -- let lspconfig auto-detect from root_markers above
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
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end,
        },
    },
    dap = {
        -- Register the js-debug-adapter as a DAP server adapter.
        -- ${port} is replaced by nvim-dap with an automatically chosen free port.
        adapters = {
            ["pwa-node"] = {
                type = "server",
                host = "127.0.0.1",
                port = "${port}",
                executable = {
                    command = "js-debug-adapter",
                    args = {
                        "${port}",
                    },
                },
            },
        },
        configurations = {
            -- TypeScript and JavaScript share identical DAP configurations
            javascript = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}", -- debug the currently open file
                    cwd = "${workspaceFolder}",
                },
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach to Node app",
                    address = "localhost",
                    port = 9229, -- default Node.js inspector port
                    cwd = "${workspaceFolder}",
                    restart = true, -- auto-reconnect when the process restarts (nodemon-friendly)
                },
            },
            typescript = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}", -- debug the currently open file
                    cwd = "${workspaceFolder}",
                },
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach to Node app",
                    address = "localhost",
                    port = 9229, -- default Node.js inspector port
                    cwd = "${workspaceFolder}",
                    restart = true, -- auto-reconnect when the process restarts (nodemon-friendly)
                },
            },
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
