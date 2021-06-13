local global = require('core.global')

require'lspconfig'.clangd.setup {
    cmd = {global.lsp_path .. 'lspinstall/cpp/clangd/bin/clangd'},
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
