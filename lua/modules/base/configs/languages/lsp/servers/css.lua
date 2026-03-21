-- LSP configuration for CSS / SCSS / Less
-- Uses the VS Code CSS language server (part of vscode-langservers-extracted).
---@module "modules.base.configs.languages.lsp.servers.css"

---@type string[]  Root-directory markers for CSS/JS projects
local root_markers = {
    "package.json",
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "css",
            cmd = { "vscode-css-language-server", "--stdio" },
            settings = {
                -- Enable built-in validation for each dialect independently
                css = { validate = true },
                scss = { validate = true },
                less = { validate = true },
            },
            -- provideFormatter = true lets the server respond to formatting requests
            -- without needing an external tool (EFM/prettierd) for basic cases.
            init_options = { provideFormatter = true },
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
