local global = require("core.global")

if vim.fn.has("mac") or vim.fn.has("unix") == 1 then
    JAVA_LS_EXECUTABLE = "launch_jdtls"
else
    print("Unsupported system")
end

local bundles = {
    vim.fn.glob(
        global.home .. "/sdk/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"
    )
}

require "lspconfig".jdtls.setup {
    cmd = {JAVA_LS_EXECUTABLE},
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
