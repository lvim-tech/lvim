local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "serve-d",
}

local lsp_config = nil
local root_markers = {
    "dub.json",
    "dub.sdl",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "d",
        cmd = { "serve-d" },
        filetypes = _G.file_types.d,
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = (function()
            local capabilities = setup_diagnostics.get_capabilities()
            capabilities.textDocument.codeLens = {
                dynamicRegistration = true,
                resolveProvider = true,
            }
            return capabilities
        end)(),
    }
end)

return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
