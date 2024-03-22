local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local vimtex_hint = [[
                                         VIMTEX

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Vimtex compile                  _<C-c><C-c>c_ │ _<C-c><C-c>g_               Vimtex compile SS
Vimtex compile selected         _<C-c><C-c>C_ │ _<C-c><C-c>o_           Vimtex compile output
Vimtex stop                     _<C-c><C-c>s_ │ _<C-c><C-c>S_                 Vimtex stop all
Vimtex reload                   _<C-c><C-c>r_ │ _<C-c><C-c>R_             Vimtex reload state
Vimtex count words              _<C-c><C-c>w_ │ _<C-c><C-c>W_            Vimtex count words !
Vimtex count letters            _<C-c><C-c>t_ │ _<C-c><C-c>T_          Vimtex count letters !
Vimtex info                     _<C-c><C-c>f_ │ _<C-c><C-c>F_                   Vimtex info !
Vimtex status                   _<C-c><C-c>u_ │ _<C-c><C-c>U_                 Vimtex status !
Vimtex clean                    _<C-c><C-c>x_ │ _<C-c><C-c>X_                  Vimtex clean !
Vimtex log                      _<C-c><C-c>m_ │ _<C-c><C-c>e_                   Vimtex errors
Vimtex toc toggle               _<C-c><C-c>K_ │ _<C-c><C-c>d_              Vimtex doc package
Vimtex toggle main              _<C-c><C-c>n_ │ _<C-c><C-c>p_               Vimtex imaps list
Vimtex view                     _<C-c><C-c>v_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.vimtex = Hydra({
    name = "VIMTEX",
    hint = vimtex_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
        },
    },
    mode = { "n", "x", "v" },
    -- body = ";pv",
    heads = {
        {
            "<C-c><C-c>c",
            keymap.cmd("VimtexCompile"),
            { nowait = true, silent = true, desc = "Vimtex compile" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("VimtexCompileSS"),
            { nowait = true, silent = true, desc = "Vimtex compile SS" },
        },
        {
            "<C-c><C-c>C",
            keymap.cmd("VimtexCompileSelected"),
            { nowait = true, silent = true, desc = "Vimtex compile selected" },
        },
        {
            "<C-c><C-c>o",
            keymap.cmd("VimtexCompileOutput"),
            { nowait = true, silent = true, desc = "Vimtex compile output" },
        },
        {
            "<C-c><C-c>s",
            keymap.cmd("VimtexStop"),
            { nowait = true, silent = true, desc = "Vimtex stop" },
        },
        {
            "<C-c><C-c>S",
            keymap.cmd("VimtexStopAll"),
            { nowait = true, silent = true, desc = "Vimtex stop all" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("VimtexReload"),
            { nowait = true, silent = true, desc = "Vimtex reload" },
        },
        {
            "<C-c><C-c>R",
            keymap.cmd("VimtexReloadState"),
            { nowait = true, silent = true, desc = "Vimtex reload state" },
        },
        {
            "<C-c><C-c>w",
            keymap.cmd("VimtexCountWords"),
            { nowait = true, silent = true, desc = "Vimtex count words" },
        },
        {
            "<C-c><C-c>W",
            keymap.cmd("VimtexCountWords!"),
            { nowait = true, silent = true, desc = "Vimtex count words !" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("VimtexCountLetters"),
            { nowait = true, silent = true, desc = "Vimtex count letters" },
        },
        {
            "<C-c><C-c>T",
            keymap.cmd("VimtexCountLetters!"),
            { nowait = true, silent = true, desc = "Vimtex count letters !" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("VimtexInfo"),
            { nowait = true, silent = true, desc = "Vimtex info" },
        },
        {
            "<C-c><C-c>F",
            keymap.cmd("VimtexInfo!"),
            { nowait = true, silent = true, desc = "Vimtex info !" },
        },
        {
            "<C-c><C-c>u",
            keymap.cmd("VimtexStatus"),
            { nowait = true, silent = true, desc = "Vimtex status" },
        },
        {
            "<C-c><C-c>U",
            keymap.cmd("VimtexStatus!"),
            { nowait = true, silent = true, desc = "Vimtex status !" },
        },
        {
            "<C-c><C-c>x",
            keymap.cmd("VimtexClean"),
            { nowait = true, silent = true, desc = "Vimtex clean" },
        },
        {
            "<C-c><C-c>X",
            keymap.cmd("VimtexClean!"),
            { nowait = true, silent = true, desc = "Vimtex clean !" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("VimtexLog"),
            { nowait = true, silent = true, desc = "Vimtex log" },
        },
        {
            "<C-c><C-c>e",
            keymap.cmd("VimtexErrors"),
            { nowait = true, silent = true, desc = "Vimtex errors" },
        },
        {
            "<C-c><C-c>K",
            keymap.cmd("VimtexTocToggle"),
            { nowait = true, silent = true, desc = "Vimtex toc toggle" },
        },
        {
            "<C-c><C-c>d",
            keymap.cmd("VimtexDocPackage"),
            { nowait = true, silent = true, desc = "Vimtex doc package" },
        },
        {
            "<C-c><C-c>n",
            keymap.cmd("VimtexToggleMain"),
            { nowait = true, silent = true, desc = "Vimtex toggle main" },
        },
        {
            "<C-c><C-c>p",
            keymap.cmd("VimtexImapsList"),
            { nowait = true, silent = true, desc = "Vimtex imaps list" },
        },
        {
            "<C-c><C-c>v",
            keymap.cmd("VimtexView"),
            { nowait = true, silent = true, desc = "Vimtex view" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
