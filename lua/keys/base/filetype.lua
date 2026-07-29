-- keys/base/filetype.lua — the per-filetype leaves, applied buffer-local on FileType.
--
-- The same lhs means the language's own action: `<Leader>rr` runs a Go file with lvim-build and a
-- Rust one with cargo. This is what makes the hint panel accurate per buffer.
---@module "keys.base.filetype"

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- FILETYPE  (applied buffer-local on FileType — makes <Leader>r ADAPT per ft)
-- Same lhs, different action per language → the group menu is ft-accurate automatically.
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
return {
    dart = {
        -- <Leader>r run group (new taxonomy)
        { "<Leader>rr", "<Cmd>LvimLang run<CR>", "Run (Flutter)" },
        { "<Leader>rR", "<Cmd>LvimLang restart<CR>", "Hot restart" },
        { "<Leader>rl", "<Cmd>LvimLang reload<CR>", "Hot reload" },
        { "<Leader>rA", "<Cmd>LvimLang attach<CR>", "Attach" },
        -- <C-c><C-c> Flutter chords (preserved muscle memory), driven by lvim-lang / lvim-lsp
        { "<C-c><C-c>f", "<Cmd>LvimLang run<CR>", "Run" },
        { "<C-c><C-c>A", "<Cmd>LvimLang attach<CR>", "Attach" },
        { "<C-c><C-c>r", "<Cmd>LvimLang reload<CR>", "Hot reload" },
        { "<C-c><C-c>R", "<Cmd>LvimLang restart<CR>", "Hot restart" },
        { "<C-c><C-c>q", "<Cmd>LvimLang quit<CR>", "Quit" },
        { "<C-c><C-c>D", "<Cmd>LvimLang detach<CR>", "Detach" },
        { "<C-c><C-c>m", "<Cmd>LvimLang emulators<CR>", "Emulators" },
        { "<C-c><C-c>g", "<Cmd>LvimLang log toggle<CR>", "Dev log" },
        { "<C-c><C-c>c", "<Cmd>LvimLang config<CR>", "Run config" },
        { "<C-c><C-c>t", "<Cmd>LvimLang devtools<CR>", "DevTools" },
        { "<C-c><C-c>i", "<Cmd>LvimLang inspect<CR>", "Inspect widget" },
        { "<C-c><C-c>p", "<Cmd>LvimLang paint<CR>", "Debug paint" },
        { "<C-c><C-c>b", "<Cmd>LvimLang brightness<CR>", "Brightness" },
        { "<C-c><C-c>P", "<Cmd>LvimLang platform<CR>", "Target platform" },
        { "<C-c><C-c>L", "<Cmd>LvimLang labels<CR>", "Closing labels" },
        { "<C-c><C-c>u", "<Cmd>LvimLang pub get<CR>", "Pub get" },
        { "<C-c><C-c>U", "<Cmd>LvimLang pub upgrade<CR>", "Pub upgrade" },
        { "<C-c><C-c>s", "<Cmd>LvimLang super<CR>", "Go to super" },
        { "<C-c><C-c>a", "<Cmd>LvimLang reanalyze<CR>", "Reanalyze" },
        { "<C-c><C-c>l", "<Cmd>LvimLang lsp restart<CR>", "Restart dartls" },
        { "<C-c><C-c>I", "<Cmd>LvimLang install<CR>", "Install SDK" },
        { "<C-c><C-c>o", "<Cmd>LvimLsp outline<CR>", "Outline" },
        { "<C-c><C-c>e", "<Cmd>LvimLsp rename<CR>", "Rename" },
    },
    rust = {
        { "<Leader>rr", "<Cmd>LvimBuild run<CR>", "Run (cargo)" },
    },
    go = {
        { "<Leader>rr", "<Cmd>LvimBuild run<CR>", "Run (go)" },
    },
    -- tex has NO section here on purpose: lvim-tex owns its own `,l*` localleader set, and a
    -- plugin's internal keys live in the plugin. (This used to hold 25 `<C-c><C-c>*` chords calling
    -- `Vimtex*` commands — vimtex was replaced by lvim-tex, so every one of them was an E492.)
}

