local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "taplo",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    local lsp_server_config = {
        name = "toml",
        cmd = { "taplo", "lsp", "stdio" },
        filetypes = _G.file_types.toml,
        root_markers = { ".git" },
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

    _G.toml_lsp_config = lsp_server_config
    lsp_manager.start_language_server("toml", true)

    return lsp_server_config

end)

-- vim: foldmethod=indent foldlevel=1
