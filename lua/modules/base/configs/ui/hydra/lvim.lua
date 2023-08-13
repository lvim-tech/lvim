local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local lvim_hint = [[
                                        LVIM IDE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Help                                 _<C-c>h_ │ _<C-c><C-c>t_                           Theme
Auto format                     _<C-c><C-c>f_ │ _<C-c><C-c>d_       Install lang dependencies
Float heignt                    _<C-c><C-c>g_ │ _<C-c><C-c>k_                     Key helpers
                                            │ _<C-c><C-c>K_               Key helpers delay

Vertical resize -2                        _H_ │ _L_                        Vertical resize +2
Resize -2                                 _J_ │ _K_                                 Resize +2

Lazy                            _<C-c><C-c>l_ │ _<C-c><C-c>m_                           Mason

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.lvim = Hydra({
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
            "<C-c>h",
            keymap.cmd("LvimHelper"),
            { nowait = true, silent = true, desc = "Help" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("LvimTheme"),
            { nowait = true, silent = true, desc = "Theme" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("LvimAutoFormat"),
            { nowait = true, silent = true, desc = "Auto format" },
        },
        {
            "<C-c><C-c>d",
            keymap.cmd("LvimInstallLangDependencies"),
            { nowait = true, silent = true, desc = "Install lang dependencies" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("LvimFloatHeight"),
            { nowait = true, silent = true, desc = "Float height" },
        },
        {
            "<C-c><C-c>k",
            keymap.cmd("LvimKeysHelper"),
            { nowait = true, silent = true, desc = "Keys helper" },
        },
        {
            "<C-c><C-c>K",
            keymap.cmd("LvimKeysHelperDelay"),
            { nowait = true, silent = true, desc = "Keys helper delay" },
        },
        {
            "H",
            keymap.cmd("vertical resize -2"),
            { nowait = true, silent = true, desc = "Vertical resize -2" },
        },
        {
            "L",
            keymap.cmd("vertical resize +2"),
            { nowait = true, silent = true, desc = "Vertical resize +2" },
        },
        {
            "J",
            keymap.cmd("resize -2"),
            { nowait = true, silent = true, desc = "Resize -2" },
        },
        {
            "K",
            keymap.cmd("resize +2"),
            { nowait = true, silent = true, desc = "Resize +2" },
        },
        {
            "<C-c><C-c>l",
            keymap.cmd("Lazy"),
            { nowait = true, silent = true, desc = "Lazy" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("Mason"),
            { nowait = true, silent = true, desc = "Mason" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
