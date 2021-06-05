local global = require('core.global')

require'lspconfig'.elixirls.setup {
    cmd = {global.lsp_path .. 'lspinstall/elixir/elixir-ls/language_server.sh'},
    root_dir = require('lspconfig/util').root_pattern('.'),
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
