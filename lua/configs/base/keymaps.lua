local keymaps = {}

keymaps["normal"] = {
    { "<space><space>", ":CtrlSpace<CR>" }, -- CtrlSpace
    { "<F11>", ":LvimHelper<CR>" }, -- LvimHelper
    { "<Esc>", "<Esc>:noh<CR>:SnipClose<CR>" }, -- Remove highlight after search
    { "<C-c>n", ":enew<CR>" }, -- Create empty buffer
    { "<C-c>s", ":w<CR>" }, -- Save
    { "<C-c>a", ":wa<CR>" }, -- Save all
    { "<C-c>e", ":Quit<CR>" }, -- Close all, exit nvim
    { "<C-c>x", "<C-w>c" }, -- Close current window
    { "<C-c>o", "<C-w>o" }, -- Close other windows
    { "<C-c>d", ":bdelete<CR>" }, -- BDelete
    { "<C-h>", "<C-w>h" }, -- Move to window left
    { "<C-l>", "<C-w>l" }, -- Move to window right
    { "<C-j>", "<C-w>j" }, -- Move to window down
    { "<C-k>", "<C-w>k" }, -- Move to window up
    { "<C-Left>", ":vertical resize -2<CR>" }, -- Resize width -
    { "<C-Right>", ":vertical resize +2<CR>" }, -- Resize width +
    { "<C-Up>", ":resize -2<CR>" }, -- Resize height -
    { "<C-Down>", ":resize +2<CR>" }, -- Resize height +
    { "gd", ":LspDefinition<CR>" }, -- Lsp definition
    { "gt", ":LspTypeDefinition<CR>" }, -- Lsp type definition
    { "gr", ":LspReferences<CR>" }, -- Lsp references
    { "gi", ":LspImplementation<CR>" }, -- Lsp implementation
    { "gE", ":LspRename" }, -- Lsp rename
    { "gf", ":LspFormatting<CR>" }, -- Lsp format code
    { "ga", ":LspCodeAction<CR>" }, -- Lsp code action
    { "gs", ":LspSignatureHelp<CR>" }, -- Lsp signsture help
    { "gL", ":LspCodeLensRefresh<CR>" }, -- Lsp code lens refresh
    { "gl", ":LspCodeLensRun<CR>" }, -- Lsp code lens run
    { "gpd", ":LspPreviewDefinition<CR>" }, -- Lsp definition
    { "gpt", ":LspPreviewTypeDefinition<CR>" }, -- Lsp type definition
    { "gpr", ":LspPreviewReferences<CR>" }, -- Lsp references
    { "gpi", ":LspPreviewImplementation<CR>" }, -- Lsp implementation
    { "gpp", ":LspPreviewCloseAll<CR>" }, -- Lsp close all
    { "gh", ":LspHover<CR>" }, -- Lsp hover
    { "K", ":LspHover<CR>" }, -- Lsp hover
    { "gP", ":hardcopy<CR>" }, -- Print file
    { "tn", ":tabn<CR>" }, -- Tab next
    { "tp", ":tabp<CR>" }, -- Tab prev
    { "dc", ":LspShowDiagnosticCurrent<CR>" }, -- Lsp show diagnostic current line
    { "dn", ":LspShowDiagnosticNext<CR>" }, -- Lsp show diagnostic next line
    { "dp", ":LspShowDiagnostigPrev<CR>" }, -- Lsp show diagnostic prev line
}

keymaps["visual"] = {
    { "*", "<Esc>/\\%V" }, -- Visual search /
    { "#", "<Esc>?\\%V" }, -- Visual search ?
    { "<A-u>", ":AnyJumpVisual<CR>" }, -- Any jump visual
    { "ts", ":SnipRun<CR>" }, -- Snip run
}

return keymaps
