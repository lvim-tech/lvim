local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local linguistics_hint = [[
                        LINGUISTICS

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Insert mode status          _R_ │ _<C-r>_   Insert mode language
Insert mode toggle      _<C-o>_ │

Spelling status             _P_ │ _<A-p>_     Spelling languages
Spelling toggle         _<A-o>_ │

Save config as local        _s_ │ _u_              Update config
Delete config               _d_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<C-q>_
]]

M.linguistics = Hydra({
    name = "LINGUISTICS",
    hint = linguistics_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";u",
    heads = {
        {
            "R",
            keymap.cmd("LvimLinguisticsMENUInsertModeStatus"),
            { nowait = true, silent = true, desc = "Insert mode status" },
        },
        {
            "<C-r>",
            keymap.cmd("LvimLinguisticsMENUInsertModeLanguage"),
            { nowait = true, silent = true, desc = "Insert mode language" },
        },
        {
            "<C-o>",
            keymap.cmd("LvimLinguisticsTOGGLEInsertModeLanguage"),
            { nowait = true, silent = true, desc = "Insert mode toggle" },
        },
        {
            "P",
            keymap.cmd("LvimLinguisticsMENUSpellingStatus"),
            { nowait = true, silent = true, desc = "Spelling status" },
        },
        {
            "<A-p>",
            keymap.cmd("LvimLinguisticsMENUSpellLanguages"),
            { nowait = true, silent = true, desc = "Spelling languages" },
        },
        {
            "<A-o>",
            keymap.cmd("LvimLinguisticsTOGGLESpelling"),
            { nowait = true, silent = true, desc = "Spelling toggle" },
        },
        {
            "s",
            keymap.cmd("LvimLinguisticsMENUSaveCurrentConfigAsLocal"),
            { nowait = true, silent = true, desc = "Save config as local" },
        },
        {
            "u",
            keymap.cmd("LvimLinguisticsMENUUpdateLocalConfig"),
            { nowait = true, silent = true, desc = "Update config" },
        },
        {
            "d",
            keymap.cmd("LvimLinguisticsMENUDeleteLocalConfig"),
            { nowait = true, silent = true, desc = "Delete config" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
