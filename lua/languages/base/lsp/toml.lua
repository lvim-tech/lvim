-- LSP configuration for TOML
-- Uses taplo (a TOML toolkit) as the language server via its "lsp stdio" sub-command.
-- Taplo provides schema-validated completions, hover docs, and formatting.
---@module "languages.base.lsp.toml"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "taplo",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for TOML-based projects
local root_markers = {
    ".taplo.toml",  -- hidden taplo config
    "taplo.toml",   -- non-hidden taplo config
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "toml",
        -- taplo uses "lsp stdio" (two separate args) rather than a --stdio flag
        cmd = { "taplo", "lsp", "stdio" },
        filetypes = _G.LVIM.file_types.toml,
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
