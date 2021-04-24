local virtualtext = {}
virtualtext.show = false
virtualtext.toggle = function()
    virtualtext.show = not virtualtext.show
    vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1, {
        virtual_text = virtualtext.show,
        underline = false
    })
end
return virtualtext
