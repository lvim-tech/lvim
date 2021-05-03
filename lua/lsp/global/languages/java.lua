local global = require('core.global')

if vim.fn.has('mac') or vim.fn.has('unix') == 1 then
    JAVA_LS_EXECUTABLE = 'launch_jdtls'
else
    print('Unsupported system')
end
local on_attach = function(client, bufr)
    require('jdtls').setup_dap()
    require'lsp.global'.common_on_attach(client, bufr)
end

local bundles = {
    vim.fn.glob(global.home ..
                    '/sdk/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar')
};

require'lspconfig'.jdtls.setup {
    cmd = {JAVA_LS_EXECUTABLE},
    on_attach = on_attach,
    root_dir = require('lspconfig/util').root_pattern('.'),
    init_options = {bundles = bundles},
    handlers = {
        ['textDocument/publishDiagnostics'] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
                virtual_text = false,
                signs = true,
                underline = false,
                update_in_insert = true
            })
    }
}
