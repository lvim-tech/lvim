local keymaps = {}

keymaps['normal'] = {
    {'<Esc>', '<Esc>:noh<CR>'}, -- Remove highlight after search
    {'<Tab>', ':BufferNext<CR>'}, -- Barbar - Tab navigation next
    {'<S-Tab>', ':BufferPrevious<CR>'}, -- Barbar - Tab navigation prev
    {'<F5>', ':UndotreeToggle<CR>'}, -- UndoTree toggle
    {'<C-n>', ':e %:h/filename<CR>'}, -- Create new file in current directory
    {'<C-s>', ':w<CR>'}, -- Save
    {'<C-a>', ':wa<CR>'}, -- Save all
    {'<C-e>', ':qa!<CR>'}, -- Close all, exit nvim
    {'<C-x>', ':BufferClose<CR>'}, -- Buffer close
    {'<C-q>', ':BufferClose!<CR>'}, -- Buffer Close whitout saving
    {'<C-d>', ':bdelete<CR>'}, -- BDelete
    {'<C-h>', '<C-w>h'}, -- Move to window left
    {'<C-l>', '<C-w>l'}, -- Move to window right
    {'<C-j>', '<C-w>j'}, -- Move to window down
    {'<C-k>', '<C-w>k'}, -- Move to window up
    {'<C-Left>', ':vertical resize -2<CR>'}, -- Resize width -
    {'<C-Right>', ':vertical resize +2<CR>'}, -- Resize width +
    {'<C-Up>', ':resize -2<CR>'}, -- Resize height -
    {'<C-Down>', ':resize +2<CR>'}, -- Resize height +
    {'<S-r>', '<C-W>v'}, -- Split right
    {'<S-b>', '<C-W>s'}, -- Split bottom
    {'<S-e>', ':NvimTreeToggle<CR>'}, -- NvimTree explorer toggle
    {'<S-h>', ':RnvimrToggle<CR>'}, -- Ranger explorer toggle
    {'<S-u>', ':Vifm<CR>'}, -- Vifm explorer
    {'<S-f>', ':Telescope find_files<CR>'}, -- File search
    {'<S-w>', ':Telescope live_grep<CR>'}, -- Text search
    {'<S-p>', ':Telescope project<CR>'}, -- Projects
    {'<S-l>', ':FloatermNew lazygit<CR>'}, -- Lazygit
    {'<S-m>', ':MarkdownPreviewToggle<CR>'}, -- Markdown preview toggle
    {'<A-j>', ':AnyJump<CR>'}, -- Any jump
    {'<A-v>', ':SymbolsOutline<CR>'}, -- Symbols outline
    {'<A-[>', ':foldopen<CR>'}, -- Fold open
    {'<A-]>', ':foldclose<CR>'}, -- Fold close
    {'<A-.>', ':BookmarkToggle<CR>'}, -- Bookmark toggle
    {'<A-,>', ':Neoformat<CR>'}, -- Format code
    {'<A-/>', ':CommentToggle<CR>'}, -- Comment toggle
    {'<A-f>', ':LspFormatting<CR>'}, -- Lsp format code
    {'<A-g>', ':LspReferences<CR>'}, -- Lsp references
    {'<A-d>', ':LspDeclaration<CR>'}, -- Lsp declaration
    {'<A-p>', ':LspDefinition<CR>'}, -- Lsp definition
    {'<A-h>', ':LspHover<CR>'}, -- Lsp hover
    {'<A-r>', ':LspRename<CR>'}, -- Lsp rename
    {'<A-n>', ':LspGoToNext<CR>'}, -- Lsp go to next
    {'<A-p>', ':LspGoToPrev<CR>'}, -- Lsp go to prev
    {'<A-e>', ':LspTroubleToggle<CR>'} -- Lsp trouble toggle
}

keymaps['visual'] = {
    {'<', '<gv'}, -- Tab left
    {'>', '>gv'}, -- Tab right
    {
        '*',
        ':<C-u>lua require("core.funcs.search").visual_selection("/")<CR>/<C-r>=@/<CR><CR>'
    }, -- Visual search /
    {
        '#',
        ':<C-u>lua require("core.funcs.search").visual_selection("?")<CR>?<C-r>=@/<CR><CR>'
    }, -- Visual search ?
    {'K', ":move '<-2<CR>gv-gv"}, -- Move up
    {'J', ":move '>+1<CR>gv-gv"}, -- Move down
    {'<A-j>', ':AnyJumpVisual<CR>'}, -- Any jump visual
    {'<A-/>', ':CommentToggle<CR>'} -- Comment toggle
}

return keymaps
