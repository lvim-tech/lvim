-- LSP configuration for Go
-- Sets up gopls with comprehensive inlay hints, codelenses, and static analysis.
-- golangci-lint is registered via EFM for linting, and Delve (dlv) is
-- configured as the DAP debug adapter.
---@module "modules.base.configs.languages.lsp.servers.go"
local ft = require("modules.base.configs.languages.lsp.file_types")

---@type string[]  Root-directory markers for Go modules and workspaces
local root_markers = {
    "go.work", -- Go workspace (multi-module) root
    "go.mod", -- single-module root
    ".git",
}

-- Register golangci-lint as an EFM linter; config files drive which linters are active.
local efm_server_config = {
    {
        server_name = "golangci-lint",
        lintCommand = "golangci-lint ${INPUT}",
        lintStdin = true,
        rootMarkers = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" },
    },
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "go",
            cmd = { "gopls" },
            ---Called by nvim-lspconfig after the client attaches to a buffer.
            ---@param client any
            ---@param bufnr  integer
            on_attach = function(client, bufnr)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end,
            settings = {
                gopls = {
                    hints = {
                        -- Show inferred types for all assignments, parameters, and ranges
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                    analyses = {
                        unusedparams = true, -- warn about unused function parameters
                    },
                    staticcheck = true, -- run staticcheck analyses inside gopls
                    codelenses = {
                        -- Enable all available code lenses for full IDE experience
                        references = true,
                        gc_details = true,
                        generate = true,
                        test = true,
                        tidy = true,
                        vendor = true,
                        regenerate_cgo = true,
                        run_govulncheck = true,
                        generate_gopls_mod = true,
                        upgrade_dependency = true,
                        run_vulncheck_exp = true,
                        generate_gopls_sum = true,
                        check_upgrades = true,
                    },
                    semanticTokens = true, -- enable semantic highlighting from gopls
                },
                opts = {
                    inlay_hints = { enabled = true },
                },
            },
        },
    },
    efm = {
        filetypes = ft.go.filetypes,
        tools = efm_server_config,
    },
    dap = {
        -- DAP: spawn dlv in DAP mode on a random port and connect to it as a server.
        -- Using detached = true ensures dlv outlives the callback and is not killed
        -- when the handle goes out of scope.
        adapters = {
            go = function(callback)
                local handle
                local port = 38697
                ---@diagnostic disable-next-line: missing-fields
                handle = vim.uv.spawn("dlv", {
                    args = { "dap", "-l", "127.0.0.1:" .. port },
                    detached = true,
                }, function(_)
                    handle:close()
                end)
                -- Small delay to let dlv bind the port before we attempt to connect
                vim.defer_fn(function()
                    callback({ type = "server", host = "127.0.0.1", port = port })
                end, 100)
            end,
        },
        configurations = {
            go = {
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
                    mode = "test", -- run in test mode so dlv can discover Test* functions
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                },
            },
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
