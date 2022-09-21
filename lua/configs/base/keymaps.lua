local keymaps = {}

keymaps["normal"] = {
    { "<space><space>", ":CtrlSpace<CR>" }, -- CtrlSpace
    { "<F1>", ":TTOne<CR>" }, -- Toggleterm one open
    { "<F2>", ":TTTwo<CR>" }, -- Toggleterm two open
    { "<F3>", ":TTThree<CR>" }, -- Toggleterm three open
    { "<F4>", ":TTFloat<CR>" }, -- Toggleterm float open
    { "<F5>", ":UndotreeToggle<CR>" }, -- UndoTree toggle
    { "<F11>", ":LvimHelper<CR>" }, -- LvimHelper
    { ":q<CR>", ":Quit<CR>" }, -- Quit
    { ":qa<CR>", ":Quit<CR>" }, -- Quit
    { ":qa!<CR>", ":Quit<CR>" }, -- Quit
    { "<Esc>", "<Esc>:noh<CR>:SnipClose<CR>" }, -- Remove highlight after search
    { "<C-c>n", ":enew<CR>" }, -- Create empty buffer
    { "<C-c>s", ":w<CR>" }, -- Save
    { "<C-c>a", ":wa<CR>" }, -- Save all
    { "<C-c>e", ":Quit<CR>" }, -- Close all, exit nvim
    { "<C-c>x", "<C-w>c" }, -- Close current window
    { "<C-c>o", "<C-w>o" }, -- Close other windows
    { "<C-c>d", ":bdelete<CR>" }, -- BDelete
    { "<C-c>p", ":PickColor<CR>" }, -- Pick color
    { "<C-c>P", ":PickColorInsert<CR>" }, -- Pick color insert
    { "<C-n>", ":BufSurfForward<CR>" }, -- Next buffer
    { "<C-p>", ":BufSurfBack<CR>" }, -- Previews buffer
    { "<C-c>b", ":GitBlameToggle<CR>" }, -- Git blame toggle
    { "<C-c>z", ":NeoZoomToggle<CR>" }, -- NeoZoom toggle
    { "<C-c>f", ":Vifm<CR>" }, -- Vifm file explorer
    { "<C-b>", ":b " }, -- Move to window left
    { "<C-h>", "<C-w>h" }, -- Move to window left
    { "<C-l>", "<C-w>l" }, -- Move to window right
    { "<C-j>", "<C-w>j" }, -- Move to window down
    { "<C-k>", "<C-w>k" }, -- Move to window up
    { "<C-Left>", ":vertical resize -2<CR>" }, -- Resize width -
    { "<C-Right>", ":vertical resize +2<CR>" }, -- Resize width +
    { "<C-Up>", ":resize -2<CR>" }, -- Resize height -
    { "<C-Down>", ":resize +2<CR>" }, -- Resize height +
    { "<S-x>", ":Neotree left<CR>" }, -- Neotree explorer
    { "<S-m>", ":MarkdownPreview<CR>" }, -- Markdown preview
    { "<A-,>", ":Telescope find_files<CR>" }, -- Search files with Telescope
    { "<A-.>", ":Telescope live_grep<CR>" }, -- Search word with Telescope
    { "<A-b>", ":Telescope buffers<CR>" }, -- All buffers
    { "<A-/>", ":Telescope file_browser<CR>" }, -- Telescope browser
    { "<A-u>", ":AnyJump<CR>" }, -- Any jump
    { "<A-v>", ":SymbolsOutline<CR>" }, -- Symbols outline
    { "<A-]>", ":GitSignsNextHunk<CR>" }, -- Git signs next hunk
    { "<A-[>", ":GitSignsPrevHunk<CR>" }, -- Git signs prev hunk
    { "<A-;>", ":GitSignsPreviewHunk<CR>" }, -- Git signs preview hunk
    { "<A-s>", ":Spectre<CR>" }, -- Replace in multiple files
    { "gw", ":WindowPicker<CR>" }, -- Window picker
    { "gd", ":LspDefinition<CR>" }, -- Lsp definition
    { "gt", ":LspTypeDefinition<CR>" }, -- Lsp type definition
    { "gr", ":LspReferences<CR>" }, -- Lsp references
    { "gi", ":LspImplementation<CR>" }, -- Lsp implementation
    { "ge", ":LspRename<CR>" }, -- Lsp rename
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
    { "gS", ":SnipRun<CR>" }, -- Snip run
    { "gP", ":hardcopy<CR>" }, -- Print file
    { "tn", ":tabn<CR>" }, -- Tab next
    { "tp", ":tabp<CR>" }, -- Tab prev
    { "tc", ":CalendarVR<CR>" }, -- Calendar
    { "to", ":e ~/Org/notes/notes.org<CR>" }, -- Open org notes
    { "th", ":Telescope howdoi<CR>" }, -- Telescope howdoi
    { "tt", ":Telescope tmux sessions<CR>" }, -- Telescope tmux session
    { "trr", "<Plug>RestNvim<CR>" }, -- Rest nvim
    { "trp", "<Plug>RestNvimPreview<CR>" }, -- Rest nvim preview
    { "trl", "<Plug>RestNvimLast<CR>" }, -- Rest nvim last
    { "<A-c>", ":LspLine<CR>" }, -- Lsp current line
    { "<A-e>", ":Neotree diagnostics reveal bottom<CR>" }, -- Neotree diagnostics
    { "<A-1>", "<Cmd>DapToggleBreakpoint<CR>" }, -- Toggle breakpoint
    { "<A-2>", "<Cmd>DapStartContinue<CR>" }, -- Start / continue
    { "<A-3>", "<Cmd>DapStepInto<CR>" }, -- Step into
    { "<A-4>", "<Cmd>DapStepOver<CR>" }, -- Step over
    { "<A-5>", "<Cmd>DapStepOut<CR>" }, -- Step out
    { "<A-6>", "<Cmd>DapUp<CR>" }, -- Up
    { "<A-7>", "<Cmd>DapDown<CR>" }, -- Down
    { "<A-8>", "<Cmd>DapUIClose<CR>" }, -- UI close
    { "<A-9>", "<Cmd>DapRestart<CR>" }, -- Restart
    { "<A-0>", "<Cmd>DapToggleRepl<CR>" }, -- Toggle Repl
    { "zp", "<Cmd>FoldPreview<CR>" }, -- Fix indent + fold lines
    { "zo", "zo:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zO", "zO:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zc", "zc:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zC", "zC:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "za", "za:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zA", "zA:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zv", "zv:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zx", "zx:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zX", "zX:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zm", "zm:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zM", "zM:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zr", "zr:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
    { "zR", "zR:IndentBlanklineRefresh<CR>" }, -- Fix indent + fold lines
}

keymaps["visual"] = {
    { "*", "<Esc>/\\%V" }, -- Visual search /
    { "#", "<Esc>?\\%V" }, -- Visual search ?
    { "<A-u>", ":AnyJumpVisual<CR>" }, -- Any jump visual
    { "gs", ":SnipRun<CR>" }, -- Snip run
}

return keymaps
