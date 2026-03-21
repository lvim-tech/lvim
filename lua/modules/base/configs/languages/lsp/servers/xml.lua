-- LSP configuration for XML / XSD / XSLT / SVG
-- Uses LemMinX (Eclipse XML Language Server) which provides schema-driven
-- completions, hover documentation, and validation for XML dialects.
---@module "modules.base.configs.languages.lsp.servers.xml"

---@type string[]  Root-directory markers (XML files are generic; .git is the safest anchor)
local root_markers = {
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "xml",
            cmd = { "lemminx" },
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
