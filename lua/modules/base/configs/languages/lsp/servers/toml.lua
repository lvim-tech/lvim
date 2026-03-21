-- LSP configuration for TOML
-- Uses taplo (a TOML toolkit) as the language server via its "lsp stdio" sub-command.
-- Taplo provides schema-validated completions, hover docs, and formatting.
---@module "modules.base.configs.languages.lsp.servers.toml"

---@type string[]  Root-directory markers for TOML-based projects
local root_markers = {
    ".taplo.toml", -- hidden taplo config
    "taplo.toml", -- non-hidden taplo config
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "toml",
            -- taplo uses "lsp stdio" (two separate args) rather than a --stdio flag
            cmd = { "taplo", "lsp", "stdio" },
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
