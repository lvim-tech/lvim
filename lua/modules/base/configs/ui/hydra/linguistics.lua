local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local linguistics_hint = [[
                        LINGUISTICS

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Insert mode status          _i_ │ _<C-i>_   Insert mode language
Insert mode toggle      _<C-o>_ │

Spelling status             _p_ │ _<A-p>_     Spelling languages
Spelling toggle         _<A-o>_ │

Save config as local        _s_ │ _u_              Update config
Delete config               _d_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

Hydra({
    name = "LINGUISTICS",
    hint = linguistics_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
        on_enter = function()
            vim.bo.modifiable = false
        end,
    },
    mode = { "n", "x", "v" },
    body = "<leader>u",
    heads = {
        {
            "i",
            keymap.cmd("LvimLinguisticsMENUInsertModeStatus"),
            { silent = true, desc = "Insert mode status" },
        },
        {
            "<C-i>",
            keymap.cmd("LvimLinguisticsMENUInsertModeLanguage"),
            { silent = true, desc = "Insert mode language" },
        },
        {
            "<C-o>",
            keymap.cmd("LvimLinguisticsTOGGLEInsertModeLanguage"),
            { silent = true, desc = "Insert mode toggle" },
        },
        {
            "p",
            keymap.cmd("LvimLinguisticsMENUSpellingStatus"),
            { silent = true, desc = "Spelling status" },
        },
        {
            "<A-p>",
            keymap.cmd("LvimLinguisticsMENUSpellLanguages"),
            { silent = true, desc = "Spelling languages" },
        },
        {
            "<A-o>",
            keymap.cmd("LvimLinguisticsTOGGLESpelling"),
            { silent = true, desc = "Spelling toggle" },
        },
        {
            "s",
            keymap.cmd("LvimLinguisticsMENUSaveCurrentConfigAsLocal"),
            { silent = true, desc = "Save config as local" },
        },
        {
            "u",
            keymap.cmd("LvimLinguisticsMENUUpdateLocalConfig"),
            { silent = true, desc = "Update config" },
        },
        {
            "d",
            keymap.cmd("LvimLinguisticsMENUDeleteLocalConfig"),
            { silent = true, desc = "Delete config" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
