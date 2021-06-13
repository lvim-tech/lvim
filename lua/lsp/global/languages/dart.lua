local global = require('core.global')

require'lspconfig'.dartls.setup {
    cmd = {
        'dart',
        global.home ..
            '/sdk/dart-sdk/bin/snapshots/analysis_server.dart.snapshot', '--lsp'
    },
    on_attach = function(client, buf)
        require'lsp.global'.documentHighlight(client)
    end,
    root_dir = require('lspconfig/util').root_pattern('.'),
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
