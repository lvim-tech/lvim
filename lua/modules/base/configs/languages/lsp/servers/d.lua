-- LSP configuration for D (dlang)
-- Uses serve-d as the language server with codeLens capability enabled.
---@module "modules.base.configs.languages.lsp.servers.d"

---@type string[]  Root-directory markers for D / DUB projects
local root_markers = {
    "dub.json", -- DUB package manifest (JSON format)
    "dub.sdl", -- DUB package manifest (SDL format)
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "d",
            cmd = { "serve-d" },
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
