local global = require('core.global')
require'lspconfig'.clangd.setup {
    cmd = {global.lsp_path .. "lspinstall/cpp/clangd/bin/clangd"},
    on_attach = require'lsp.global'.common_on_attach,
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
