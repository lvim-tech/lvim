local global = require('core.global')

require'lspconfig'.html.setup {
    cmd = {
        'node', global.lsp_path ..
            'lspinstall/html/vscode-html/html-language-features/server/dist/node/htmlServerMain.js',
        '--stdio'
    },
    root_dir = require('lspconfig/util').root_pattern('.'),
    on_attach = function(client, buf)
        require'lsp.global'.documentHighlight(client)
    end,
    handlers = {
        ['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic
                                                               .on_publish_diagnostics,
                                                           {
            virtual_text = false,
            signs = true,
            underline = false,
            update_in_insert = true
        })
    }
}
