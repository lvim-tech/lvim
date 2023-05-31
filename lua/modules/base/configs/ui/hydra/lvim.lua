local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local lvim_hint = [[
                            LVIM

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Help                        _p_ │ _t_                      Theme
Auto format                 _f_ │ _I_  Install lang dependencies

Lazy                        _z_ │ _m_                      Mason

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]
Hydra({
    name = "LVIM",
    hint = lvim_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";l",
    heads = {
        {
            "p",
            keymap.cmd("LvimHelper"),
            { nowait = true, silent = true, desc = "Help" },
        },
        {
            "t",
            keymap.cmd("LvimTheme"),
            { nowait = true, silent = true, desc = "Theme" },
        },
        {
            "f",
            keymap.cmd("LvimAutoFormat"),
            { nowait = true, silent = true, desc = "Auto format" },
        },
        {
            "I",
            keymap.cmd("LvimInstallLangDependencies"),
            { nowait = true, silent = true, desc = "Install lang dependencies" },
        },
        {
            "z",
            keymap.cmd("Lazy"),
            { nowait = true, silent = true, desc = "Lazy" },
        },
        {
            "m",
            keymap.cmd("Mason"),
            { nowait = true, silent = true, desc = "Mason" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
