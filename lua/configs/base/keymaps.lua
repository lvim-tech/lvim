local keymaps = {}

keymaps["normal"] = {
    { "<Esc>", "<Esc>:noh<CR>", "Esc" }, -- Remove highlight after search
    { "j", "gj", "j" }, -- Re-map j
    { "k", "gk", "k" }, -- Re-map k
    -- { "<C-d>", "<C-d>zz", "C-d" }, -- Re-map C-d
    -- { "<C-u>", "<C-u>zz", "C-u" }, -- Re-map C-u
    -- { "<C-f>", "<C-f>zz", "C-f" }, -- Re-map C-f
    -- { "<C-b>", "<C-b>zz", "C-b" }, -- Re-map C-b
    { "<C-c>N", ":enew<CR>", "Create empty buffer" }, -- Create empty buffer
    { "<C-c>s", ":Save<CR>", "Save" }, -- Save
    { "<C-c>a", ":wa<CR>", "Save all" }, -- Save all
    { "<C-c>e", ":Quit<CR>", "Close LvimIDE" }, -- Close all, exit nvim
    { "<C-c>x", "<C-w>c", "Close current window" }, -- Close current window
    { "<C-c>o", "<C-w>o", "Close other windows" }, -- Close other windows
    { "<C-c>d", ":bdelete<CR>", "Delete buffer" }, -- BDelete
    { "<C-c>=", ":wincmd=<CR>", "Win resize =" }, -- Win resize =
    { "<C-h>", "<C-w>h", "Move to window left" }, -- Move to window left
    { "<C-l>", "<C-w>l", "Move to window right" }, -- Move to window right
    { "<C-j>", "<C-w>j", "Move to window down" }, -- Move to window down
    { "<C-k>", "<C-w>k", "Move to window up" }, -- Move to window up
    { "<C-Left>", ":vertical resize -2<CR>", "Resize width -" }, -- Resize width -
    { "<C-Right>", ":vertical resize +2<CR>", "Resize width +" }, -- Resize width +
    { "<C-Up>", ":resize -2<CR>", "Resize height -" }, -- Resize height -
    { "<C-Down>", ":resize +2<CR>", "Resize height +" }, -- Resize height +
    { "<C-c>n", ":tabn<CR>", "Tab next" }, -- Tab next
    { "<C-c>p", ":tabp<CR>", "Tab prev" }, -- Tab prev
    { "<C-c>ff", ":CloseFloatWindows<CR>", "Close float windows" }, -- Close float windows
    { "<C-c>c", ":Inspect<CR>", "Inspect" }, -- Inspect
    { "<C-c>O", ":lua vim.ui.open(vim.fn.expand('%'))<CR>", "Open in browser" }, -- Open in browser
    { "<Leader>m", ":messages<CR>", "Messages" }, -- Messages
    { "<Leader>N", ":ene | startinsert<CR>", "New file" }, -- New file
    { "<Leader>to", ":$tabnew<CR>", "Tab new" }, -- Tne new
    { "<Leader>tc", ":$tabclose<CR>", "Tab close" }, -- Tne close
    { "<Leader>tn", ":tabn<CR>", "Tab next" }, -- Tab next
    { "<Leader>tp", ":tabp<CR>", "Tab prev" }, -- Tab prev
    { "<Leader>tmn", ":+tabmove<CR>", "Tab move next" }, -- Tab move next
    { "<Leader>tmp", ":-tabmove<CR>", "Tab move prev" }, -- Tab move prev
    { "<C-c><C-p>", "p`[v`]" },
    { "<C-c><C-k>", "P`[v`]" },
}

keymaps["visual"] = {
    { "j", "gj" }, -- Re-map j
    { "k", "gk" }, -- Re-map k
    { "*", "<Esc>/\\%V" }, -- Visual search /
    { "#", "<Esc>?\\%V" }, -- Visual search ?
    { "<C-p>", "p`[v`]" },
}

keymaps["insert"] = {}

return keymaps
