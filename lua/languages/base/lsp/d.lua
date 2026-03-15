-- LSP configuration for D (dlang)
-- Uses serve-d as the language server with codeLens capability enabled.
---@module "languages.base.lsp.d"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "serve-d",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for D / DUB projects
local root_markers = {
    "dub.json",   -- DUB package manifest (JSON format)
    "dub.sdl",    -- DUB package manifest (SDL format)
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "d",
        cmd = { "serve-d" },
        filetypes = _G.LVIM.file_types.d,
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
        -- serve-d supports codeLens for references/implementations; advertise
        -- dynamic registration so the server can register/unregister on the fly.
        capabilities = (function()
            local capabilities = setup_diagnostics.get_capabilities()
            capabilities.textDocument.codeLens = { ---@diagnostic disable-line: undefined-field
                dynamicRegistration = true,
                resolveProvider = true,
            }
            return capabilities
        end)(),
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
