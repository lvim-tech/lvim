local keymaps = {}

keymaps['normal'] = {
    {'<C-n>', ':e %:h/filename<CR>'}, -- Create new file in current directory
    {'<C-s>', ':w<CR>'}, -- Save buffer
    {'<C-a>', ':wa<CR>'}, -- Save all buffers
    {'<C-q>', ':q!<CR>'}, -- Close buffer
    {'<C-e>', ':qa!<CR>'}, -- Exit nvim
    {'[j', '<C-o>'}, {']j', '<C-i>'}, -- Jump list
    {'<C-h>', '<C-w>h'}, {'<C-l>', '<C-w>l'}, -- Smart way to move between windows horizontal
    {'<C-j>', '<C-w>j'}, {'<C-k>', '<C-w>k'}, -- Smart way to move between windows vertical
    {'[d', '<PageUp>'}, {']d', '<PageDown>'}, -- Page down/up
    {'<Esc>', '<Esc>:noh<CR>'}, -- Remove highlight after search
    {'<S-h>', '<C-W>v'}, -- Split horizontal
    {'<S-b>', '<C-W>s'}, -- Split vertical
    {'<C-Up>', ':resize +2<CR>'}, {'<C-Down>', ':resize -2<CR>'}, -- Resize
    {'<C-Left>', ':vertical resize +2<CR>'},
    {'<C-Right>', ':vertical resize -2<CR>'}, -- Resize
    {'<Tab>', ':BufferNext<CR>'}, {'<S-Tab>', ':BufferPrevious<CR>'}, -- Tab navigation / Barbar
    {'<C-x>', ':BufferClose<CR>'}, -- Buffer Close
    {'<C-d>', ':bdelete<CR>'}, -- BDelete
    {'<C-p>', ':Telescope project<CR>'}, -- Telescope project
    {'<S-e>', ':NvimTreeToggle<CR>'}, -- NvimTree explorer
    {'<S-r>', ':RnvimrToggle<CR>'}, -- Ranger explorer
    {'<C-f>', ':Telescope find_files<CR>'}, -- File search
    {'<C-r>', ':Telescope live_grep<CR>'}, -- Text search
    {'<C-g>', ':FloatermNew lazygit<CR>'}, -- GIT
    {'<F5>', ':UndotreeToggle<CR>'}, -- UndoTree toggle
    {'<S-f>', ':Format<CR>'}, -- Format code
    {'<S-t>', ':FloatermNew --wintype=normal --height=10<CR>'}, -- Terminal
    {'<C-v>', ':Vista<CR>'}, -- Vista
    {'<A-[>', ':foldopen<CR>'}, -- Fold open
    {'<A-]>', ':foldclose<CR>'}, -- Fold close
    {'<A-.>', ':BookmarkToggle<CR>'}, -- Bookmark toggle
    {'<A-/>', ':CommentToggle<CR>'}, -- Comment toggle
    {'<S-m>', ':MarkdownPreviewToggle<CR>'}, -- Markdown preview toggle
    {'<A-f>', ':LspFormatting<CR>'}, -- Lsp Formatting
    {'<A-g>', ':LspReferences<CR>'}, -- Lsp references
    {'<A-d>', ':LspDeclaration<CR>'}, -- Lsp declaration
    {'<A-p>', ':LspDefinition<CR>'}, -- Lsp definition
    {'<A-h>', ':LspHover<CR>'}, -- Lsp hover
    {'<A-r>', ':LspRename<CR>'}, -- Lsp rename
    {'<A-n>', ':LspGoToNext<CR>'}, -- Lsp go to next
    {'<A-p>', ':LspGoToPrev<CR>'}, -- Lsp go to prev
    {'<A-t>', ':LspToggleLineDiagnostics<CR>'} -- Lsp toggle line diagnostics
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
    {'K', ':move \'<-2<CR>gv-gv'}, -- Move up
    {'J', ':move \'>+1<CR>gv-gv'}, -- Move down
    {'<A-/>', ':CommentToggle<CR>'} -- Comment toggle
}

return keymaps
