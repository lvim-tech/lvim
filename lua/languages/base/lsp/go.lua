local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

local lsp_dependencies = {
    "efm",
    "gopls",
    "golangci-lint",
    "delve",
}

local lsp_config = nil
local root_markers = {
    "go.work",
    "go.mod",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
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
            mode = "test",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
        },
    }

    local efm_server_config = {
        {
            server_name = "golangci-lint",
            lPrefix = "golint",
            lintCommand = "golangci-lint ${INPUT}",
            lintStdin = true,
            rootMarkers = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" },
        },
    }
    lsp_manager.setup_efm(_G.file_types.go, efm_server_config)

    lsp_config = {
        name = "go",
        cmd = { "gopls" },
        filetypes = _G.file_types.go,
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
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
                codelenses = {
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
                semanticTokens = true,
            },
            opts = {
                inlay_hints = { enabled = true },
            },
        },
        capabilities = setup_diagnostics.get_capabilities(),
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
