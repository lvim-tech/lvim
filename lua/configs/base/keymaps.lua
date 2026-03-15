-- Global keymaps applied at startup across all buffers.
-- Format: LvimKeymap tuples { lhs, rhs, desc?, extra_opts? }
-- Registered via funcs.keymaps() in configs/base/init.lua.
---@type table<string, LvimKeymap[]>
local keymaps = {}

keymaps["normal"] = {
    { "<Esc>",    "<Esc>:noh<CR>",                             "Clear search highlight" },
    -- expr = true allows count-aware movement: 5j jumps 5 real lines,
    -- plain j moves by visual/wrapped lines
    { "j",        "v:count == 0 ? 'gj' : 'j'",                "Move down (visual-line aware)", { expr = true } },
    { "k",        "v:count == 0 ? 'gk' : 'k'",                "Move up (visual-line aware)",   { expr = true } },
    { "<C-c>N",   ":enew<CR>",                                 "Create empty buffer" },
    { "<C-c>s",   ":Save<CR>",                                 "Save" },
    { "<C-c>a",   ":wa<CR>",                                   "Save all" },
    { "<C-c>e",   ":Quit<CR>",                                 "Close LvimIDE" },
    { "<C-c>x",   "<C-w>c",                                    "Close current window" },
    { "<C-c>o",   "<C-w>o",                                    "Close other windows" },
    { "<C-c>d",   ":enew | bdelete #<CR>",                     "Delete buffer" },
    { "<C-c>=",   ":wincmd=<CR>",                              "Equalise window sizes" },
    { "<C-h>",    "<C-w>h",                                    "Focus window left" },
    { "<C-l>",    "<C-w>l",                                    "Focus window right" },
    { "<C-j>",    "<C-w>j",                                    "Focus window down" },
    { "<C-k>",    "<C-w>k",                                    "Focus window up" },
    { "<C-Left>",  ":vertical resize -2<CR>",                  "Shrink window width" },
    { "<C-Right>", ":vertical resize +2<CR>",                  "Grow window width" },
    { "<C-Up>",    ":resize -2<CR>",                           "Shrink window height" },
    { "<C-Down>",  ":resize +2<CR>",                           "Grow window height" },
    { "<C-c>n",   ":tabn<CR>",                                 "Next tab" },
    { "<C-c>p",   ":tabp<CR>",                                 "Previous tab" },
    { "Q",        ":CloseFloatWindows<CR>",                    "Close all floats" },
    { "<C-c>fc",  ":CloseFloatWindows<CR>",                    "Close all floats" },
    { "<C-c>ff",  ":FocusFloatWindow<CR>",                     "Cycle focus to next float" },
    { "<C-c>c",   ":Inspect<CR>",                              "Inspect highlight under cursor" },
    { "<C-c>O",   ":lua vim.ui.open(vim.fn.expand('%'))<CR>",  "Open current file in OS handler" },
    { "<Leader>m", ":messages<CR>",                            "Show message history" },
    { "<Leader>N", ":ene | startinsert<CR>",                   "New file in insert mode" },
    {
        "<Leader>ta",
        function()
            local input = vim.fn.input("New tab name (optional): ")
            vim.cmd("LvimSpaceTabNew " .. input)
        end,
        "New tab",
    },
    { "<Leader>tc",  ":LvimSpaceTabClose<CR>",  "Close tab" },
    {
        "<Leader>te",
        function()
            local input = vim.fn.input("New tab name: ")
            if input ~= "" then
                vim.cmd("LvimSpaceTabRename " .. input)
            end
        end,
        "Rename tab",
    },
    { "<Leader>tn",  ":LvimSpaceTabNext<CR>",      "Next tab" },
    { "<Leader>tp",  ":LvimSpaceTabPrev<CR>",      "Previous tab" },
    {
        "<Leader>to",
        function()
            local input = vim.fn.input("Tab index: ")
            if input ~= "" then
                vim.cmd("LvimSpaceTab " .. input)
            end
        end,
        "Jump to tab by index",
    },
    { "<Leader>tmn", ":LvimSpaceTabMoveNext<CR>", "Move tab right" },
    { "<Leader>tmp", ":LvimSpaceTabMovePrev<CR>", "Move tab left" },
}

keymaps["visual"] = {
    -- Search only within the visual selection using \%V atom
    { "*", "<Esc>/\\%V",  "Search forward in selection" },
    { "#", "<Esc>?\\%V",  "Search backward in selection" },
}

keymaps["insert"] = {
    { "<C-j>", "<C-o>gj", "Move down by visual line" },
    { "<C-k>", "<C-o>gk", "Move up by visual line" },
}

return keymaps
