-- LSP configuration for R (and R Markdown / Quarto)
-- Uses r-languageserver (the R package "languageserver") for completions,
-- diagnostics, hover, and formatting.
---@module "modules.base.configs.languages.lsp.servers.r"

---@type string[]  Root-directory markers (R projects rarely have standard roots)
local root_markers = {
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "r",
            cmd = { "r-languageserver" },
            settings = {
                r = {
                    lsp = {
                        diagnostics = true,
                        -- rich_documentation: show roxygen2 help pages in hover popups
                        rich_documentation = true,
                    },
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
}

-- vim: foldmethod=indent foldlevel=1
