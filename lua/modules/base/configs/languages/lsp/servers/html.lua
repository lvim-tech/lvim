-- LSP configuration for HTML
-- Uses the VS Code HTML language server and prettierd via EFM for formatting.
---@module "modules.base.configs.languages.lsp.servers.html"
local ft = require("modules.base.configs.languages.lsp.file_types")

---@type string[]  Root-directory markers for web projects
local root_markers = {
    "package.json",
    ".git",
}

-- Use prettierd (daemon-mode prettier) for fast, consistent HTML formatting.
-- Tab width of 4 matches the project-wide default; .prettierrc overrides this.
local efm_config = {
    {
        server_name = "prettierd",
        formatCommand = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
        formatStdin = true,
        rootMarkers = { ".prettierrc" },
    },
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "html",
            cmd = { "vscode-html-language-server", "--stdio" },
            settings = {
                html = {
                    -- Enable the server's built-in formatter as a fallback when prettierd is absent
                    format = true,
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
    efm = {
        filetypes = ft.html.filetypes,
        tools = efm_config,
    },
}

-- vim: foldmethod=indent foldlevel=1
