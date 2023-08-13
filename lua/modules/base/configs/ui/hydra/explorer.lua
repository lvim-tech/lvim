local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local explorer_hint = [[
                                        EXPLORER

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Neotree left                     _<C-c><C-f>_ │ _<C-c><C-b>_            Neotree buffers left
Neotree git status left          _<C-c><C-g>_ │

Neotree float                   _<C-c><C-c>f_ │ _<C-c><C-c>b_           Neotree buffers float
Neotree git status float        _<C-c><C-c>g_ │

Ranger                                _<A-r>_ │ _<A-f>_                                  Vifm
LVIM file manager                 _<Leader>=_ │ _<Leader>i_                        Mini files

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.explorer = Hydra({
    name = "EXPLORER",
    hint = explorer_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";e",
    heads = {
        {
            "<C-c><C-f>",
            keymap.cmd("Neotree left"),
            { nowait = true, silent = true, desc = "Neotree left" },
        },
        {
            "<C-c><C-b>",
            keymap.cmd("Neotree buffers left"),
            { nowait = true, silent = true, desc = "Neotree buffers left" },
        },
        {
            "<C-c><C-g>",
            keymap.cmd("Neotree git_status left"),
            { nowait = true, silent = true, desc = "Neotree git status left" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("Neotree float"),
            { nowait = true, silent = true, desc = "Neotree float" },
        },
        {
            "<C-c><C-c>b",
            keymap.cmd("Neotree buffers float"),
            { nowait = true, silent = true, desc = "Neotree buffers float" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("Neotree git_status float"),
            { nowait = true, silent = true, desc = "Neotree git status float" },
        },
        {
            "<A-r>",
            keymap.cmd("Ranger"),
            { nowait = true, silent = true, desc = "Ranger" },
        },
        {
            "<A-f>",
            keymap.cmd("Vifm"),
            { nowait = true, silent = true, desc = "Vifm" },
        },
        {
            "<Leader>=",
            keymap.cmd("LvimFileManager"),
            { nowait = true, silent = true, desc = "LVIM file manager" },
        },
        {
            "<Leader>i",
            function()
                require("mini.files").open()
            end,
            { nowait = true, silent = true, desc = "Mini files" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
