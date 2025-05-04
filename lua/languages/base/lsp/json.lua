local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

local lsp_server_name = "vscode-json-language-server"

lsp_installer.ensure_mason_tools({
    "json-lsp",
}, function()
    local lsp_server_config = {
        name = "json",
        cmd = { lsp_server_name, "--stdio" },
        filetypes = _G.file_types.json,
        root_markers = { ".git" },
        init_options = {
            provideFormatter = true,
        },
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

    _G.json_lsp_config = lsp_server_config
    lsp_manager.start_language_server("json", true, lsp_server_config)

    return lsp_server_config
end)

-- vim: foldmethod=indent foldlevel=1
