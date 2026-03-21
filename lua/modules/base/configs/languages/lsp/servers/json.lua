-- LSP configuration for JSON / JSONC
-- Uses the VS Code JSON language server which provides schema-driven
-- completions, hover documentation, and formatting.
---@module "modules.base.configs.languages.lsp.servers.json"

---@type string[]  Root-directory markers (JSON files can appear anywhere; .git is sufficient)
local root_markers = {
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "json",
            cmd = { "vscode-json-language-server", "--stdio" },
            init_options = {
                -- Let the server handle formatting requests directly (no external formatter needed)
                provideFormatter = true,
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

    schema = {
        {
            section = "Formatting",
            fields = {
                { key = "json.format.enable", type = "bool", label = "Enable" },
                { key = "json.format.keepLines", type = "bool", label = "Keep Lines" },
            },
        },
        {
            section = "Validation",
            fields = {
                { key = "json.validate.enable", type = "bool", label = "Enable" },
            },
        },
        {
            section = "Schema",
            fields = {
                { key = "json.schemaDownload.enable", type = "bool", label = "Allow Schema Downloads" },
                { key = "json.maxItemsComputed", type = "number", label = "Max Items Computed" },
            },
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
