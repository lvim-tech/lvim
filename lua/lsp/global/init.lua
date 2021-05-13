vim.fn.sign_define('LspDiagnosticsSignError', {
    texthl = 'LspDiagnosticsSignError',
    text = '',
    numhl = 'LspDiagnosticsSignError'
})
vim.fn.sign_define('LspDiagnosticsSignWarning', {
    texthl = 'LspDiagnosticsSignWarning',
    text = '',
    numhl = 'LspDiagnosticsSignWarning'
})
vim.fn.sign_define('LspDiagnosticsSignHint', {
    texthl = 'LspDiagnosticsSignHint',
    text = '',
    numhl = 'LspDiagnosticsSignHint'
})
vim.fn.sign_define('LspDiagnosticsSignInformation', {
    texthl = 'LspDiagnosticsSignInformation',
    text = '',
    numhl = 'LspDiagnosticsSignInformation'
})

local function documentHighlight(client)
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
            hi LspReferenceRead cterm=bold ctermbg=red guibg=#121212
            hi LspReferenceText cterm=bold ctermbg=red guibg=#121212
            hi LspReferenceWrite cterm=bold ctermbg=red guibg=#121212
            augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
            ]], false)
    end
end

local lsp_config = {}

function lsp_config.common_on_attach(client)
    documentHighlight(client)
    require('folding').on_attach()
end

return lsp_config
