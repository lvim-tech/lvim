local global = require("core.global")
local lsp_settings = require("lsp.global")

require"lspconfig".dartls.setup {
    cmd = {
        "dart",
        global.home ..
            "/sdk/dart-sdk/bin/snapshots/analysis_server.dart.snapshot", "--lsp"
    },
    on_attach = function(client)
        if not packer_plugins["lsp_signature.nvim"].loaded then
            vim.cmd [[packadd lsp_signature.nvim]]
        end
        require"lsp_signature".on_attach(lsp_settings.signature_cfg)
        lsp_settings.documentHighlight(client)
    end,
    root_dir = require("lspconfig/util").root_pattern("."),
    handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic
                                                               .on_publish_diagnostics,
                                                           lsp_settings.diagnostics_cfg)
    }
}
