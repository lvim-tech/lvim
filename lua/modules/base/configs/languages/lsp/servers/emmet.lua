-- LSP configuration for Emmet
-- Provides HTML/CSS abbreviation expansion across a broad set of template
-- and stylesheet filetypes via emmet-language-server.
---@module "modules.base.configs.languages.lsp.servers.emmet"

---@type string[]  Root-directory markers (Emmet works without a project root, so only .git)
local root_markers = {
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "emmet",
            cmd = { "emmet-language-server", "--stdio" },
            -- Emmet is activated for all HTML, CSS, and JSX/TSX filetypes
            -- defined in _G.LVIM.file_types.emmet (see file_types.lua).
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
