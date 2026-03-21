-- LSP configuration for SQL / MySQL
-- Uses sqls which provides completions and query execution against a configured
-- database connection (configured via config.yml in the project root).
---@module "modules.base.configs.languages.lsp.servers.sql"

---@type string[]  Root-directory markers; config.yml holds the sqls database connection settings
local root_markers = {
    "config.yml",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "sql",
            cmd = { "sqls" },
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
}

-- vim: foldmethod=indent foldlevel=1
