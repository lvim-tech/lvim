-- LSP configuration for Rust
-- Uses rust-analyzer for the language server with all code lenses enabled,
-- and the cpptools DAP adapter (OpenDebugAD7) for debugging via GDB/LLDB.
---@module "modules.base.configs.languages.lsp.servers.rust"

---@type string[]  Root-directory markers; Cargo.toml is mandatory for any Rust workspace
local root_markers = {
    "Cargo.toml",
}

---Sends the rust-analyzer/reloadWorkspace request to force-reload Cargo metadata.
---Useful after adding a new dependency or changing Cargo.toml.
---@param bufnr integer  Buffer whose workspace should be reloaded
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

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "rust",
            cmd = { "rust-analyzer" },
            settings = {
                ["rust-analyzer"] = {
                    assist = {
                        -- importEnforceGranularity: merge use paths to the finest possible level
                        importEnforceGranularity = true,
                        importPrefix = "crate", -- use crate-relative paths in auto-imports
                    },
                    cargo = {
                        allFeatures = true, -- analyse all feature-gated code paths
                    },
                    checkOnSave = true, -- run cargo check on every save
                    inlayHints = { locationLinks = false }, -- disable clickable location links in hints
                    diagnostics = {
                        enable = true,
                        experimental = {
                            enable = true, -- opt into unstable diagnostic improvements
                        },
                    },
                    lens = {
                        -- Enable all code lens types for a full IDE experience
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
            ---Copies rust-analyzer settings into initializationOptions so that
            ---the server receives them before the initialized notification.
            ---@param init_params table  LSP InitializeParams being built
            ---@param config     table  Full lspconfig server config
            before_init = function(init_params, config)
                if config.settings and config.settings["rust-analyzer"] then
                    init_params.initializationOptions = config.settings["rust-analyzer"]
                end
            end,
            ---Called by nvim-lspconfig after the client attaches to a buffer.
            ---@param client any
            ---@param bufnr  integer
            on_attach = function(client, bufnr)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
                -- Register a buffer-local command so users can reload Cargo without leaving nvim
                vim.api.nvim_buf_create_user_command(0, "LspCargoReload", function()
                    reload_workspace(0)
                end, { desc = "Reload current cargo workspace" })
            end,
        },
    },
    dap = {
        -- DAP: reuse the cpptools adapter (same binary as C/C++ debugging).
        adapters = {
            cppdbg = {
                id = "cppdbg",
                type = "executable",
                command = vim.fn.stdpath("data")
                    .. "/mason"
                    .. "/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
            },
        },
        configurations = {
            rust = {
                {
                    name = "Launch file",
                    type = "cppdbg",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = true, -- break at entry so variables can be inspected before main logic
                },
            },
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
