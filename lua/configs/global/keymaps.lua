local keymaps = {}

keymaps["normal"] = {
    {"<F11>", ":LvimHelper<CR>"}, -- LvimHelper
    {"<C-space>", ":CtrlSpace<CR>"}, -- CtrlSpace
    {"<Esc>", "<Esc>:noh<CR>"}, -- Remove highlight after search
    {"<F5>", ":UndotreeToggle<CR>"}, -- UndoTree toggle
    {"<C-n>", ":e %:h/filename<CR>"}, -- Create new file in current directory
    {"<C-s>", ":w<CR>"}, -- Save
    {"<C-a>", ":wa<CR>"}, -- Save all
    {"<C-e>", ":qa!<CR>"}, -- Close all, exit nvim
    {"<C-x>", "<C-w>c"}, -- Close current window
    {"<C-o>", "<C-w>o"}, -- Close other windows
    {"<C-d>", ":bdelete<CR>"}, -- BDelete
    {"<C-h>", "<C-w>h"}, -- Move to window left
    {"<C-l>", "<C-w>l"}, -- Move to window right
    {"<C-j>", "<C-w>j"}, -- Move to window down
    {"<C-k>", "<C-w>k"}, -- Move to window up
    {"<C-Left>", ":vertical resize -2<CR>"}, -- Resize width -
    {"<C-Right>", ":vertical resize +2<CR>"}, -- Resize width +
    {"<C-Up>", ":resize -2<CR>"}, -- Resize height -
    {"<C-Down>", ":resize +2<CR>"}, -- Resize height +
    {"<C-b>", ":GitBlameToggle<CR>"}, -- Git blame toggle
    {"<S-x>", ":NvimTreeToggle<CR>"}, -- Nvim tree explorer
    {"<S-l>", ":FloatermNew lazygit<CR>"}, -- Lazygit
    {"<S-m>", ":MarkdownPreviewToggle<CR>"}, -- Markdown preview toggle
    {"<A-,>", ":Telescope find_files<CR>"}, -- Search files with Telescope
    {"<A-.>", ":Telescope live_grep<CR>"}, -- Search word with Telescope
    {"<A-j>", ":AnyJump<CR>"}, -- Any jump
    {"<A-v>", ":SymbolsOutline<CR>"}, -- Symbols outline
    {"<A-[>", ":foldopen<CR>"}, -- Fold open
    {"<A-]>", ":foldclose<CR>"}, -- Fold close
    {"<A-s>", ":Spectre<CR>"}, -- Replace in multiple files
    {"<A-/>", ":CommentToggle<CR>"}, -- Comment toggle
    {"<A-f>", ":LspFormatting<CR>"}, -- Lsp format code
    {"<A-t>", ":LspCodeAction<CR>"}, -- Lsp action
    {"<A-g>", ":LspReferences<CR>"}, -- Lsp references
    {"<A-d>", ":LspDefinition<CR>"}, -- Lsp definition
    {"<A-h>", ":LspHover<CR>"}, -- Lsp hover
    {"<A-r>", ":LspRename<CR>"}, -- Lsp rename
    {"<A-n>", ":LspGoToNext<CR>"}, -- Lsp go to next
    {"<A-p>", ":LspGoToPrev<CR>"}, -- Lsp go to prev
    {"<A-e>", ":LspTroubleToggle<CR>"}, -- Lsp trouble toggle
    {"<A-/>", ":CommentToggle<CR>"}, -- Comment toggle
    {"<A-*>", ":LspVirtualTextToggle<CR>"}, -- Lsp virtual text toggle
    {"<A-1>", "<Cmd>DapToggleBreakpoint<CR>"}, -- Toggle breakpoint
    {"<A-2>", "<Cmd>DapStartContinue<CR>"}, -- Start / continue
    {"<A-3>", "<Cmd>DapStepInto<CR>"}, -- Step into
    {"<A-4>", "<Cmd>DapStepOver<CR>"}, -- Step over
    {"<A-5>", "<Cmd>DapStepOut<CR>"}, -- Step out
    {"<A-6>", "<Cmd>DapUp<CR>"}, -- Up
    {"<A-7>", "<Cmd>DapDown<CR>"}, -- Down
    {"<A-8>", "<Cmd>DapUIClose<CR>"}, -- UI close
    {"<A-9>", "<Cmd>DapRestart<CR>"}, -- Restart
    {"<A-0>", "<Cmd>DapToggleRepl<CR>"} -- Toggle Repl
}

keymaps["visual"] = {
    {"<", "<gv"}, -- Tab left
    {">", ">gv"}, -- Tab right
    {"*", "<Esc>/\\%V"}, -- Visual search /
    {"#", "<Esc>?\\%V"}, -- Visual search ?
    {"K", ":move '<-2<CR>gv-gv"}, -- Move up
    {"J", ":move '>+1<CR>gv-gv"}, -- Move down
    {"<A-j>", ":AnyJumpVisual<CR>"}, -- Any jump visual
    {"<A-/>", ":CommentToggle<CR>"} -- Comment toggle
}

return keymaps
