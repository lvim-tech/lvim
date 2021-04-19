local virtualtext = {}
virtualtext.show = true
virtualtext.toggle = function()
    virtualtext.show = not virtualtext.show
    vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1,
                               {virtual_text = virtualtext.show})
end
return virtualtext
