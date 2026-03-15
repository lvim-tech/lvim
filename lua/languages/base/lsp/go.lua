-- LSP configuration for Go
-- Sets up gopls with comprehensive inlay hints, codelenses, and static analysis.
-- golangci-lint is registered via EFM for linting, and Delve (dlv) is
-- configured as the DAP debug adapter.
---@module "languages.base.lsp.go"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "efm",
    "gopls",
    "golangci-lint",
    "delve",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for Go modules and workspaces
local root_markers = {
    "go.work",  -- Go workspace (multi-module) root
    "go.mod",   -- single-module root
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    -- DAP: spawn dlv in DAP mode on a random port and connect to it as a server.
    -- Using detached = true ensures dlv outlives the callback and is not killed
    -- when the handle goes out of scope.
    dap.adapters.go = function(callback)
        local handle
        local port = 38697
        ---@diagnostic disable-next-line: missing-fields
        handle = vim.loop.spawn("dlv", {
            args = { "dap", "-l", "127.0.0.1:" .. port },
            detached = true,
        }, function(_)
            handle:close()
        end)
        -- Small delay to let dlv bind the port before we attempt to connect
        vim.defer_fn(function()
            callback({ type = "server", host = "127.0.0.1", port = port })
        end, 100)
    end
    ---@type table<string, any>
    dap.configurations = dap.configurations or {}
    dap.configurations.go = dap.configurations.go or {}
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
            mode = "test",  -- run in test mode so dlv can discover Test* functions
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
        },
    }

    -- Register golangci-lint as an EFM linter; config files drive which linters are active.
    local efm_server_config = {
        {
            server_name = "golangci-lint",
            lPrefix = "golint",
            lintCommand = "golangci-lint ${INPUT}",
            lintStdin = true,
            rootMarkers = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" },
        },
    }
    lsp_manager.setup_efm(_G.LVIM.file_types.go, efm_server_config)

    lsp_config = {
        name = "go",
        cmd = { "gopls" },
        filetypes = _G.LVIM.file_types.go,
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
                    unusedparams = true,  -- warn about unused function parameters
                },
                staticcheck = true,  -- run staticcheck analyses inside gopls
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
                semanticTokens = true,  -- enable semantic highlighting from gopls
            },
            opts = {
                inlay_hints = { enabled = true },
            },
        },
        capabilities = setup_diagnostics.get_capabilities(),
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
