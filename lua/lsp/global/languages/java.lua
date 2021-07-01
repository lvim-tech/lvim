local global = require("core.global")

require "lspconfig".jdtls.setup {
    cmd = {global.lsp_path .. "lspinstall/java/jdtls.sh"},
    on_attach = function(client)
        require("jdtls").setup_dap()
        require "lsp.global".documentHighlight(client)
    end,
    root_dir = require("lspconfig/util").root_pattern("."),
    init_options = {bundles = bundles},
    handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics,
            {
                virtual_text = false,
                signs = true,
                underline = false,
                update_in_insert = true
            }
        )
    }
}
