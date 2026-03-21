-- LSP configuration for Helm (Kubernetes chart templating)
-- Uses helm-ls (helm_ls) which understands Helm template syntax and
-- provides completions, hover, and diagnostics for chart files.
---@module "modules.base.configs.languages.lsp.servers.helm"

---@type string[]  Root-directory markers; Chart.yaml is required for any valid Helm chart
local root_markers = {
    "Chart.yaml",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "helm",
            -- helm_ls uses "serve" sub-command (unlike most LSPs that use --stdio directly)
            cmd = { "helm_ls", "serve" },
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
