local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_utils = require("languages.utils")

local lsp_server_name = "html-lsp"

-- EFM
local efm_config = {
    {
        server_name = "prettierd",
        fPrefix = "prettierd",
        formatCommand = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
        formatStdin = true,
        rootMarkers = { ".prettierrc" },
    },
}

lsp_utils.setup_efm(_G.file_types.html, efm_config)
-- EFM

-- LSP
local lsp_server_config = {
    name = "html",
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = _G.file_types.html,
    root_markers = { "package.json", ".git" },
    settings = {
        html = {
            format = true,
        },
    },
    on_attach = function(client, bufnr)
        setup_diagnostics.keymaps(client, bufnr)
        setup_diagnostics.document_highlight(client, bufnr)
        setup_diagnostics.inlay_hint(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
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

_G.html_lsp_config = lsp_server_config

if lsp_server_result then
    return lsp_server_config
else
    vim.notify("An error occurred while setting up the LSP (" .. lsp_server_name .. ")!", vim.log.levels.ERROR)
end
-- LSP

-- vim: foldmethod=indent foldlevel=0
