local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local vimtex_hint = [[
                           VIMTEX

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Vimtex compile              _c_ │ _g_          Vimtex compile SS
Vimtex compile selected     _C_ │ _o_      Vimtex compile output
Vimtex stop                 _s_ │ _S_            Vimtex stop all
Vimtex reload               _r_ │ _R_        Vimtex reload state
Vimtex count words          _w_ │ _W_       Vimtex count words !
Vimtex count letters        _t_ │ _T_     Vimtex count letters !
Vimtex info                 _f_ │ _F_              Vimtex info !
Vimtex status               _u_ │ _U_            Vimtex status !
Vimtex clean                _x_ │ _X_             Vimtex clean !
Vimtex log                  _m_ │ _e_              Vimtex errors
Vimtex toc toggle           _K_ │ _d_         Vimtex doc package
Vimtex toggle main          _n_ │ _p_          Vimtex imaps list
Vimtex view                 _v_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]
Hydra({
    name = "VIMTEX",
    hint = vimtex_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";v",
    heads = {
        {
            "c",
            keymap.cmd("VimtexCompile"),
            { silent = true, desc = "Vimtex compile" },
        },
        {
            "g",
            keymap.cmd("VimtexCompileSS"),
            { silent = true, desc = "Vimtex compile SS" },
        },
        {
            "C",
            keymap.cmd("VimtexCompileSelected"),
            { silent = true, desc = "Vimtex compile selected" },
        },
        {
            "o",
            keymap.cmd("VimtexCompileOutput"),
            { silent = true, desc = "Vimtex compile output" },
        },
        {
            "s",
            keymap.cmd("VimtexStop"),
            { silent = true, desc = "Vimtex stop" },
        },
        {
            "S",
            keymap.cmd("VimtexStopAll"),
            { silent = true, desc = "Vimtex stop all" },
        },
        {
            "r",
            keymap.cmd("VimtexReload"),
            { silent = true, desc = "Vimtex reload" },
        },
        {
            "R",
            keymap.cmd("VimtexReloadState"),
            { silent = true, desc = "Vimtex reload state" },
        },
        {
            "w",
            keymap.cmd("VimtexCountWords"),
            { silent = true, desc = "Vimtex count words" },
        },
        {
            "W",
            keymap.cmd("VimtexCountWords!"),
            { silent = true, desc = "Vimtex count words !" },
        },
        {
            "t",
            keymap.cmd("VimtexCountLetters"),
            { silent = true, desc = "Vimtex count letters" },
        },
        {
            "T",
            keymap.cmd("VimtexCountLetters!"),
            { silent = true, desc = "Vimtex count letters !" },
        },
        {
            "f",
            keymap.cmd("VimtexInfo"),
            { silent = true, desc = "Vimtex info" },
        },
        {
            "F",
            keymap.cmd("VimtexInfo!"),
            { silent = true, desc = "Vimtex info !" },
        },
        {
            "u",
            keymap.cmd("VimtexStatus"),
            { silent = true, desc = "Vimtex status" },
        },
        {
            "U",
            keymap.cmd("VimtexStatus!"),
            { silent = true, desc = "Vimtex status !" },
        },
        {
            "x",
            keymap.cmd("VimtexClean"),
            { silent = true, desc = "Vimtex clean" },
        },
        {
            "X",
            keymap.cmd("VimtexClean!"),
            { silent = true, desc = "Vimtex clean !" },
        },
        {
            "m",
            keymap.cmd("VimtexLog"),
            { silent = true, desc = "Vimtex log" },
        },
        {
            "e",
            keymap.cmd("VimtexErrors"),
            { silent = true, desc = "Vimtex errors" },
        },
        {
            "K",
            keymap.cmd("VimtexTocToggle"),
            { silent = true, desc = "Vimtex toc toggle" },
        },
        {
            "d",
            keymap.cmd("VimtexDocPackage"),
            { silent = true, desc = "Vimtex doc package" },
        },
        {
            "n",
            keymap.cmd("VimtexToggleMain"),
            { silent = true, desc = "Vimtex toggle main" },
        },
        {
            "p",
            keymap.cmd("VimtexImapsList"),
            { silent = true, desc = "Vimtex imaps list" },
        },
        {
            "v",
            keymap.cmd("VimtexView"),
            { silent = true, desc = "Vimtex view" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
