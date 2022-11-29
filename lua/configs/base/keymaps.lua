local keymaps = {}

keymaps["normal"] = {
    { "<Esc>", "<Esc>:noh<CR>" }, -- Remove highlight after search
    { "j", "gj" }, -- Re-map j
    { "k", "gk" }, -- Re-map k
    { "<C-c>n", ":enew<CR>" }, -- Create empty buffer
    { "<C-c>s", ":Save<CR>" }, -- Save
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
    { "gP", ":hardcopy<CR>" }, -- Print file
    { "tn", ":tabn<CR>" }, -- Tab next
    { "tp", ":tabp<CR>" }, -- Tab prev
    { "tf", ":CloseFloatWindows<CR>" }, -- Tab prev
}

keymaps["visual"] = {
    { "j", "gj" }, -- Re-map j
    { "k", "gk" }, -- Re-map k
    { "*", "<Esc>/\\%V" }, -- Visual search /
    { "#", "<Esc>?\\%V" }, -- Visual search ?
}

return keymaps
