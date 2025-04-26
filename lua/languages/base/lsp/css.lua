local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_utils = require("languages.utils")

local lsp_server_name = "css-lsp"

-- lsp
local lsp_server_config = {
    name = "css",
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = _G.file_types.css,
    root_markers = { "package.json", ".git" },
    settings = {},
    init_options = { provideFormatter = true },
    on_attach = function(client, bufnr)
        setup_diagnostics.keymaps(client, bufnr)
        setup_diagnostics.document_highlight(client, bufnr)
        setup_diagnostics.inlay_hint(client, bufnr)
        if client.server_capabilities.documentsymbolprovider then
            navic.attach(client, bufnr)
        end
    end,
}

local lsp_server_async = lsp_utils.is_lsp_server_installed(lsp_server_name)

local lsp_server_result
while not lsp_server_result do
    lsp_server_result = lsp_server_async()
    vim.wait(100)
end

_G.css_lsp_config = lsp_server_config

if lsp_server_result then
    return lsp_server_config
else
    vim.notify("an error occurred while setting up the lsp (" .. lsp_server_name .. ")!", vim.log.levels.ERROR)
end
-- lsp

-- vim: foldmethod=indent foldlevel=0
