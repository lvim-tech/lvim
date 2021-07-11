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
    {"<S-x>", ":NvimTreeToggle<CR>"}, -- Nvim tree explorer
    {"<S-u>", ":Vifm<CR>"}, -- Vifm explorer
    {"<S-l>", ":FloatermNew lazygit<CR>"}, -- Lazygit
    {"<S-m>", ":MarkdownPreviewToggle<CR>"}, -- Markdown preview toggle
    {"<S-f>", ":SnapFiles<CR>"}, -- Search files with Snap
    {"<S-t>", ":SnapGrep<CR>"}, -- Search word in files with Snap
    {"<A-j>", ":AnyJump<CR>"}, -- Any jump
    {"<A-v>", ":SymbolsOutline<CR>"}, -- Symbols outline
    {"<A-[>", ":foldopen<CR>"}, -- Fold open
    {"<A-]>", ":foldclose<CR>"}, -- Fold close
    {"<A-.>", ":BookmarkToggle<CR>"}, -- Bookmark toggle
    {"<A-,>", ":Neoformat<CR>"}, -- Format code
    {"<A-s>", ":Spectre<CR>"}, -- Replace in multiple files
    {"<A-/>", ":CommentToggle<CR>"}, -- Comment toggle
    {"<A-f>", ":LspFormatting<CR>"}, -- Lsp format code
    {"<A-t>", ":LspCodeAction<CR>"}, -- Lsp action
    {"<A-g>", ":LspReferences<CR>"}, -- Lsp references
    {"<A-d>", ":LspDeclaration<CR>"}, -- Lsp declaration
    {"<A-p>", ":LspDefinition<CR>"}, -- Lsp definition
    {"<A-h>", ":LspHover<CR>"}, -- Lsp hover
    {"<A-r>", ":LspRename<CR>"}, -- Lsp rename
    {"<A-n>", ":LspGoToNext<CR>"}, -- Lsp go to next
    {"<A-p>", ":LspGoToPrev<CR>"}, -- Lsp go to prev
    {"<A-e>", ":LspTroubleToggle<CR>"} -- Lsp trouble toggle
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
