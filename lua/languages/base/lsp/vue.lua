-- LSP configuration for Vue.js
-- Uses vue-language-server (Volar) with the TypeScript SDK bundled inside
-- the Mason-installed vue-language-server package, ensuring the Volar TS
-- plugin and the compiler are always version-compatible.
---@module "languages.base.lsp.vue"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "vue-language-server",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for Vue / Vite projects
local root_markers = {
    "package.json",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "vue",
        cmd = { "vue-language-server", "--stdio" },
        filetypes = _G.LVIM.file_types.vue,
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
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = setup_diagnostics.get_capabilities(),
    }
end)

return setmetatable({}, {
    ---@param _ table
    ---@param key string
    ---@return table|nil
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
