-- LSP configuration for Vue.js
-- Uses vue-language-server (Volar) with the TypeScript SDK bundled inside
-- the Mason-installed vue-language-server package, ensuring the Volar TS
-- plugin and the compiler are always version-compatible.
---@module "modules.base.configs.languages.lsp.servers.vue"

---@type string[]  Root-directory markers for Vue / Vite projects
local root_markers = {
    "package.json",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "vue",
            cmd = { "vue-language-server", "--stdio" },
            init_options = {
                typescript = {
                    -- Volar requires a TypeScript SDK path to activate its TS integration.
                    -- Using the SDK bundled with vue-language-server avoids version mismatches
                    -- that occur when pointing at a project-local node_modules/typescript.
                    tsdk = vim.fs.normalize(
                        "~/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib"
                    ),
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
