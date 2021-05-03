local global = require('core.global')
local lspconfig = require 'lspconfig'
local configs = require 'lspconfig/configs'
if not lspconfig.tailwindls then configs['tailwindls'] = {default_config = {}} end
lspconfig.tailwindls.setup {
    cmd = {
        'node', global.lsp_path ..
            'lspinstall/tailwindcss/tailwindcss-intellisense/extension/dist/server/index.js',
        '--stdio'
    },
    filetypes = {
        'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript',
        'typescriptreact'
    },
    root_dir = require('lspconfig/util').root_pattern('.'),
    handlers = {
        ['tailwindcss/getConfiguration'] = function(_, _, params, _, bufnr, _)
            vim.lsp.buf_notify(bufnr, 'tailwindcss/getConfigurationResponse',
                               {_id = params._id})
        end,
        ['textDocument/publishDiagnostics'] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
                virtual_text = false,
                signs = true,
                underline = false,
                update_in_insert = true
            })
    },
    on_attach = require'lsp.global'.common_on_attach
}
