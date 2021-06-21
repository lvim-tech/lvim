local global = require("core.global")
local pid = vim.fn.getpid()

require "lspconfig".omnisharp.setup {
    cmd = {
        global.lsp_path .. "lspinstall/csharp/run",
        "--languageserver",
        "--hostPID",
        tostring(pid)
    },
    root_dir = require("lspconfig/util").root_pattern("."),
    on_attach = function(client)
        require "lsp.global".documentHighlight(client)
    end,
    init_options = {},
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
