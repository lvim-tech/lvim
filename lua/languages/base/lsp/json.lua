-- LSP configuration for JSON / JSONC
-- Uses the VS Code JSON language server which provides schema-driven
-- completions, hover documentation, and formatting.
---@module "languages.base.lsp.json"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "json-lsp",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers (JSON files can appear anywhere; .git is sufficient)
local root_markers = {
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "json",
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = _G.LVIM.file_types.json,
        root_markers = { ".git" },  -- redundant with the module-level root_markers but kept explicit
        init_options = {
            -- Let the server handle formatting requests directly (no external formatter needed)
            provideFormatter = true,
        },
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
