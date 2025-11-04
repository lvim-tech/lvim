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
    { "<C-c>d", ":enew | bdelete #<CR>", "Delete buffer" }, -- BDelete
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
    { "<C-c>fc", ":CloseFloatWindows<CR>", "Close float windows" }, -- Close float windows
    { "<C-c>ff", ":FocusFloatWindow<CR>", "Focus float window" }, -- Focus float window
    { "<C-c>c", ":Inspect<CR>", "Inspect" }, -- Inspect
    { "<C-c>O", ":lua vim.ui.open(vim.fn.expand('%'))<CR>", "Open in browser" }, -- Open in browser
    { "<Leader>m", ":messages<CR>", "Messages" }, -- Messages
    { "<Leader>N", ":ene | startinsert<CR>", "New file" }, -- New file
    {
        "<Leader>ta",
        function()
            local input = vim.fn.input("New tab name (optional): ")
            vim.cmd("LvimSpaceTabNew " .. input)
        end,
        "New tab",
    }, -- Tab new
    { "<Leader>tc", ":LvimSpaceTabClose<CR>", "Tab close" }, -- Tab close
    {
        "<Leader>te",
        function()
            local input = vim.fn.input("New tab name: ")
            if input ~= "" then
                vim.cmd("LvimSpaceTabRename " .. input)
            end
        end,
        "Rename tab",
    }, -- Tab rename
    { "<Leader>tn", ":LvimSpaceTabNext<CR>", "Tab next" }, -- Tab next
    { "<Leader>tp", ":LvimSpaceTabPrev<CR>", "Tab prev" }, -- Tab prev
    {
        "<Leader>to",
        function()
            local input = vim.fn.input("Tab index: ")
            if input ~= "" then
                vim.cmd("LvimSpaceTab " .. input)
            end
        end,
        "Tab index",
    }, -- Tab index
    { "<Leader>tmn", ":LvimSpaceTabMoveNext<CR>", "Tab move next" }, -- Tab move next
    { "<Leader>tmp", ":LvimSpaceTabMovePrev<CR>", "Tab move prev" }, -- Tab move prev
}

keymaps["visual"] = {
    { "*", "<Esc>/\\%V" }, -- Visual search /
    { "#", "<Esc>?\\%V" }, -- Visual search ?
}

keymaps["insert"] = {
    { "<C-j>", "<C-o>gj", "Move down by visual line in insert mode" },
    { "<C-k>", "<C-o>gk", "Move up by visual line in insert mode" },
}

return keymaps
