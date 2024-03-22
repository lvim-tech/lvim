local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local linguistics_hint = [[
                                      LINGUISTICS

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Insert mode status             _<C-c><C-c>is_ │ _<C-c><C-c>il_           Insert mode language
Insert mode toggle             _<C-c><C-c>it_ │

Spelling status                _<C-c><C-c>ss_ │ _<C-c><C-c>sl_             Spelling languages
Spelling toggle                _<C-c><C-c>st_ │

Save config as local            _<C-c><C-c>l_ │ _<C-c><C-c>u_                   Update config
Delete config                   _<C-c><C-c>d_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.linguistics = Hydra({
    name = "LINGUISTICS",
    hint = linguistics_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
        },
    },
    mode = { "n", "x", "v" },
    body = ";u",
    heads = {
        {
            "<C-c><C-c>is",
            keymap.cmd("LvimLinguisticsMENUInsertModeStatus"),
            { nowait = true, silent = true, desc = "Insert mode status" },
        },
        {
            "<C-c><C-c>il",
            keymap.cmd("LvimLinguisticsMENUInsertModeLanguage"),
            { nowait = true, silent = true, desc = "Insert mode language" },
        },
        {
            "<C-c><C-c>it",
            keymap.cmd("LvimLinguisticsTOGGLEInsertModeLanguage"),
            { nowait = true, silent = true, desc = "Insert mode toggle" },
        },
        {
            "<C-c><C-c>ss",
            keymap.cmd("LvimLinguisticsMENUSpellingStatus"),
            { nowait = true, silent = true, desc = "Spelling status" },
        },
        {
            "<C-c><C-c>sl",
            keymap.cmd("LvimLinguisticsMENUSpellLanguages"),
            { nowait = true, silent = true, desc = "Spelling languages" },
        },
        {
            "<C-c><C-c>st",
            keymap.cmd("LvimLinguisticsTOGGLESpelling"),
            { nowait = true, silent = true, desc = "Spelling toggle" },
        },
        {
            "<C-c><C-c>l",
            keymap.cmd("LvimLinguisticsMENUSaveCurrentConfigAsLocal"),
            { nowait = true, silent = true, desc = "Save config as local" },
        },
        {
            "<C-c><C-c>u",
            keymap.cmd("LvimLinguisticsMENUUpdateLocalConfig"),
            { nowait = true, silent = true, desc = "Update config" },
        },
        {
            "<C-c><C-c>d",
            keymap.cmd("LvimLinguisticsMENUDeleteLocalConfig"),
            { nowait = true, silent = true, desc = "Delete config" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
