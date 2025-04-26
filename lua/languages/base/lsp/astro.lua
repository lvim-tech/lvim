local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_utils = require("languages.utils")

local lsp_server_name = "astro-language-server"

-- EFM
local efm_server_config = {
    {
        server_name = "prettierd",
        fPrefix = "prettier",
        formatCommand = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
        formatStdin = true,
        rootMarkers = { ".prettierrc" },
    },
}

lsp_utils.setup_efm(_G.file_types.astro, efm_server_config)
-- EFM

-- LSP
local lsp_server_config = {
    name = "astro",
    cmd = { "astro-ls", "--stdio" },
    filetypes = _G.file_types.astro,
    init_options = {
        typescript = {
            tsdk = vim.fs.normalize(
                "~/.local/share/nvim/mason/packages/astro-language-server/node_modules/typescript/lib"
            ),
        },
    },
    on_attach = function(client, bufnr)
        setup_diagnostics.keymaps(client, bufnr)
        setup_diagnostics.inlay_hint(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end
    end,
    settings = {
        gopls = {
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
        opts = {
            inlay_hints = { enabled = true },
        },
    },
    capabilities = setup_diagnostics.get_capabilities(),
}

local lsp_server_async = lsp_utils.is_lsp_server_installed(lsp_server_name)

local lsp_server_result
while not lsp_server_result do
    lsp_server_result = lsp_server_async()
    vim.wait(100)
end

_G.astro_lsp_config = lsp_server_config

if lsp_server_result then
    return lsp_server_config
else
    vim.notify("An error occurred while setting up the LSP (" .. lsp_server_name .. ")!", vim.log.levels.ERROR)
end
-- LSP

-- vim: foldmethod=indent foldlevel=0
