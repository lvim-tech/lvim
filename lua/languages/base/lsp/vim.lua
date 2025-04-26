local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_utils = require("languages.utils")

local lsp_server_name = "vim-language-server"

-- EFM
local efm_config = {
    {
        server_name = "vint",
        lPrefix = "vint",
        lintCommand = "vint -",
        lintStdin = true,
        rootMarkers = { ".vintrc.yaml", ".vintrc.yml", ".vintrc" },
    },
}

lsp_utils.setup_efm(_G.file_types.vim, efm_config)
-- EFM

-- LSP
local lsp_server_config = {
    name = "vim",
    cmd = { "vim-language-server", "--stdio" },
    filetypes = _G.file_types.vim,
    root_markers = { ".git" },
    init_options = {
        isNeovim = true,
        iskeyword = "@,48-57,_,192-255,-#",
        vimruntime = "",
        runtimepath = "",
        diagnostic = { enable = true },
        indexes = {
            runtimepath = true,
            gap = 100,
            count = 3,
            projectRootPatterns = { "runtime", "nvim", ".git", "autoload", "plugin" },
        },
        suggest = { fromVimruntime = true, fromRuntimepath = true },
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

local lsp_server_async = lsp_utils.is_lsp_server_installed(lsp_server_name)

local lsp_server_result
while not lsp_server_result do
    lsp_server_result = lsp_server_async()
    vim.wait(100)
end

_G.vim_lsp_config = lsp_server_config

if lsp_server_result then
    return lsp_server_config
else
    vim.notify("An error occurred while setting up the LSP (" .. lsp_server_name .. ")!", vim.log.levels.ERROR)
end
-- LSP

-- vim: foldmethod=indent foldlevel=0
