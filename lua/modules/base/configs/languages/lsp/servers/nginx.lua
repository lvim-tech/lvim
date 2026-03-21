-- LSP configuration for Nginx
-- Uses nginx-language-server which provides completions, hover docs,
-- and diagnostics for nginx.conf and vhost files.
---@module "modules.base.configs.languages.lsp.servers.nginx"

---@type string[]  Root-directory markers for nginx configuration trees
local root_markers = {
    "nginx.conf",
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "nginx",
            cmd = { "nginx-language-server" },
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
