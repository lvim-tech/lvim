local global = require('core.global')
require'lspconfig'.tsserver.setup {
    cmd = {
        global.lsp_path ..
            "lspinstall/typescript/node_modules/.bin/typescript-language-server",
        "--stdio"
    },
    on_attach = require'lsp.global'.tsserver_on_attach,
    root_dir = require('lspconfig/util').root_pattern("."),
    handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = true
            })
    }
}
