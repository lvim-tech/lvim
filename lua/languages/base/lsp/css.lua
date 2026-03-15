-- LSP configuration for CSS / SCSS / Less
-- Uses the VS Code CSS language server (part of vscode-langservers-extracted).
---@module "languages.base.lsp.css"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "css-lsp",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for CSS/JS projects
local root_markers = {
    "package.json",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "css",
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = _G.LVIM.file_types.css,
        settings = {
            -- Enable built-in validation for each dialect independently
            css  = { validate = true },
            scss = { validate = true },
            less = { validate = true },
        },
        -- provideFormatter = true lets the server respond to formatting requests
        -- without needing an external tool (EFM/prettierd) for basic cases.
        init_options = { provideFormatter = true },
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---@param client any
        ---@param bufnr  integer
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentsymbolprovider then
                navic.attach(client, bufnr)
            end
        end,
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
