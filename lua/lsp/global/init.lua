vim.fn.sign_define("LspDiagnosticsSignError", {
    texthl = "LspDiagnosticsSignError",
    text = "",
    numhl = "LspDiagnosticsSignError"
})
vim.fn.sign_define("LspDiagnosticsSignWarning", {
    texthl = "LspDiagnosticsSignWarning",
    text = "",
    numhl = "LspDiagnosticsSignWarning"
})
vim.fn.sign_define("LspDiagnosticsSignHint", {
    texthl = "LspDiagnosticsSignHint",
    text = "",
    numhl = "LspDiagnosticsSignHint"
})
vim.fn.sign_define("LspDiagnosticsSignInformation", {
    texthl = "LspDiagnosticsSignInformation",
    text = "",
    numhl = "LspDiagnosticsSignInformation"
})

local lsp_config = {}

function lsp_config.documentHighlight(client)
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
            hi LspReferenceRead cterm=bold guibg=#41495A
            hi LspReferenceText cterm=bold guibg=#41495A
            hi LspReferenceWrite cterm=bold guibg=#41495A
            augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
        ]], false)
    end
end

lsp_config.signature_cfg = {hint_prefix = " ", handler_opts = {border = "none"}}

lsp_config.diagnostics_cfg = {
    virtual_text = {
      prefix = "",
      spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = true
}

return lsp_config
