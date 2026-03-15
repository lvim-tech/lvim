-- LSP configuration for XML / XSD / XSLT / SVG
-- Uses LemMinX (Eclipse XML Language Server) which provides schema-driven
-- completions, hover documentation, and validation for XML dialects.
---@module "languages.base.lsp.xml"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "lemminx",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers (XML files are generic; .git is the safest anchor)
local root_markers = {
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "xml",
        cmd = { "lemminx" },
        filetypes = _G.LVIM.file_types.xml,
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---@param client any
        ---@param bufnr  integer
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
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
