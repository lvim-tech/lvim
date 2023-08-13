local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local spectre_hint = [[
                                         SPECTRE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Open                            _<C-c><C-c>o_ │ _<C-c><C-c>p_                     Show option
Toggle line                     _<C-c><C-c>l_ │ _<C-c><C-c>c_             Run current replace
Select entry                    _<C-c><C-c>e_ │ _<C-c><C-c>r_                     Run replace
Send to quickfix                _<C-c><C-c>q_ │ _<C-c><C-c>u_              Toggle live update
Replace command                 _<C-c><C-c>m_ │ _<C-c><C-c>v_                     Change view
Toggle ignore case              _<C-c><C-c>i_ │ _<C-c><C-c>s_              Resume last search
Toggle hidden                   _<C-c><C-c>h_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.replace = Hydra({
    name = "SPECTRE",
    hint = spectre_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-left",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";r",
    heads = {
        {
            "<C-c><C-c>o",
            keymap.cmd("Spectre"),
            { nowait = true, silent = true, desc = "Open" },
        },
        {
            "<C-c><C-c>l",
            keymap.cmd("SpectreToggleLine"),
            { nowait = true, silent = true, desc = "Toggle line" },
        },
        {
            "<C-c><C-c>e",
            keymap.cmd("SpectreSelectEntry"),
            { nowait = true, silent = true, desc = "Select entry" },
        },
        {
            "<C-c><C-c>q",
            keymap.cmd("SpectreSendToQF"),
            { nowait = true, silent = true, desc = "Send to quickfix" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("SpectreReplaceCommand"),
            { nowait = true, silent = true, desc = "Replace command" },
        },
        {
            "<C-c><C-c>c",
            keymap.cmd("SpectreRunCurrentReplace"),
            { nowait = true, silent = true, desc = "Run current replace" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("SpectreRunReplace"),
            { nowait = true, silent = true, desc = "Run replace" },
        },
        {
            "<C-c><C-c>i",
            keymap.cmd("SpectreIgnoreCase"),
            { nowait = true, silent = true, desc = "Toggle ignore case" },
        },
        {
            "<C-c><C-c>h",
            keymap.cmd("SpectreHidden"),
            { nowait = true, silent = true, desc = "Toggle hidden" },
        },
        {
            "<C-c><C-c>u",
            keymap.cmd("SpectreToggleLiveUpdate"),
            { nowait = true, silent = true, desc = "Toggle live update" },
        },
        {
            "<C-c><C-c>v",
            keymap.cmd("SpectreChangeView"),
            { nowait = true, silent = true, desc = "Change view" },
        },
        {
            "<C-c><C-c>s",
            keymap.cmd("SpectreResumeLastSearch"),
            { nowait = true, silent = true, desc = "Resume last search" },
        },
        {
            "<C-c><C-c>p",
            keymap.cmd("SpectreShowOptions"),
            { nowait = true, silent = true, desc = "Show option" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
