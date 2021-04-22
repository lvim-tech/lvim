if vim.fn.has("mac") or vim.fn.has("unix") == 1 then
    JAVA_LS_EXECUTABLE = 'launch_jdtls'
else
    print("Unsupported system")
end
local on_attach = function(client, bufr)
    require('jdtls').setup_dap()
    require'lsp.global'.common_on_attach(client, bufr)
end
local global = require('core.global')
require'lspconfig'.jdtls.setup {
    on_attach = on_attach,
    cmd = {JAVA_LS_EXECUTABLE},
    root_dir = require('jdtls.setup').find_root(
        {'build.gradle', 'pom.xml', '.git'}),
    handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
                virtual_text = false,
                signs = true,
                underline = false,
                update_in_insert = true
            })
    }
}
