local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

local lsp_dependencies = {
    "rust-analyzer",
    "cpptools",
}

local lsp_config = nil
local root_markers = {
    "Cargo.toml",
}

local function reload_workspace(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" })
    for _, client in ipairs(clients) do
        vim.notify("Reloading Cargo Workspace")
        client.request("rust-analyzer/reloadWorkspace", nil, function(err)
            if err then
                error(tostring(err))
            end
            vim.notify("Cargo workspace reloaded")
        end, 0)
    end
end

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = global.mason_path .. "/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
    }
    ---@type table<string, any>
    dap.configurations = dap.configurations or {}
    dap.configurations.rust = dap.configurations.rust or {}
    dap.configurations.rust = {
        {
            name = "Launch file",
            type = "cppdbg",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = true,
        },
    }

    lsp_config = {
        name = "rust",
        cmd = { "rust-analyzer" },
        filetypes = _G.file_types.rust,
        settings = {
            ["rust-analyzer"] = {
                assist = {
                    importEnforceGranularity = true,
                    importPrefix = "crate",
                },
                cargo = {
                    allFeatures = true,
                },
                checkOnSave = true,
                inlayHints = { locationLinks = false },
                diagnostics = {
                    enable = true,
                    experimental = {
                        enable = true,
                    },
                },
                lens = {
                    enable = true,
                    implementations = { enable = true },
                    references = { enable = true },
                    run = { enable = true },
                    debug = { enable = true },
                    methodReferences = { enable = true },
                    enumVariantReferences = { enable = true },
                },
            },
        },
        before_init = function(init_params, config)
            if config.settings and config.settings["rust-analyzer"] then
                init_params.initializationOptions = config.settings["rust-analyzer"]
            end
        end,
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
            vim.api.nvim_buf_create_user_command(0, "LspCargoReload", function()
                reload_workspace(0)
            end, { desc = "Reload current cargo workspace" })
        end,
        capabilities = (function()
            local capabilities = setup_diagnostics.get_capabilities()
            capabilities.textDocument = capabilities.textDocument or {}
            capabilities.textDocument.codeLens = {
                dynamicRegistration = true,
                resolveProvider = true,
            }
            capabilities.workspace = capabilities.workspace or {}
            capabilities.workspace.codeLens = {
                refreshSupport = true,
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
