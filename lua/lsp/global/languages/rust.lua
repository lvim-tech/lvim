local global = require('core.global')

require'lspconfig'.rust_analyzer.setup {
    cmd = {global.lsp_path .. 'lspinstall/rust/rust-analyzer'},
    root_dir = require('lspconfig/util').root_pattern('.'),
    settings = {
        ['rust-analyzer'] = {
            ['rust-analyzer.diagnostics.disabled'] = {'unresolved-import'}
        }
    },
    on_attach = function(client, bufnr)
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
