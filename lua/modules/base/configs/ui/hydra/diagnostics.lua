local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local lsp_hint = [[
                             LSP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Hover                       _K_ │ _r_                     Rename
Format                      _f_ │ _A_                Code action

Show diagnostic current     _v_ │
Show diagnostic next        _n_ │ _p_       Show diagnostic prev
Lsp virtual text toggle     _T_ │

Definition                  _d_ │ _t_            Type definition
Declaration                 _D_ │ _R_                 References
Implementation              _i_ │ _H_             Signature help

Document symbol             _s_ │ _S_           Workspace symbol

Code lens refresh           _F_ │ _L_              Code lens run

Add to workspace folder     _x_ │ _X_    Remove workspace folder
List workspace folders      _W_ │

Incoming calls              _I_ │ _O_             Outgoing calls

Any jump                    _J_ │ _N_                   Navbuddy
Symbols outline             _U_ │

Lvim diagnostics        _<C-c>_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<C-q>_
]]

M.diagnostics = Hydra({
    name = "LSP",
    hint = lsp_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";d",
    heads = {
        {
            "K",
            keymap.cmd("LspHover"),
            { nowait = true, silent = true, desc = "Hover" },
        },
        {
            "r",
            keymap.cmd("LspRename"),
            { nowait = true, silent = true, desc = "Rename" },
        },
        {
            "f",
            keymap.cmd("LspFormat"),
            { nowait = true, silent = true, desc = "Format" },
        },
        {
            "A",
            keymap.cmd("LspCodeAction"),
            { nowait = true, silent = true, desc = "Code action" },
        },
        {
            "v",
            keymap.cmd("LspShowDiagnosticCurrent"),
            { nowait = true, silent = true, desc = "Show diagnostic current" },
        },
        {
            "n",
            keymap.cmd("LspShowDiagnosticNext"),
            { nowait = true, silent = true, desc = "Show diagnostic next" },
        },
        {
            "p",
            keymap.cmd("LspShowDiagnosticPrev"),
            { nowait = true, silent = true, desc = "Show diagnostic prev" },
        },
        {
            "T",
            keymap.cmd("LspVirtualTextToggle"),
            { nowait = true, silent = true, desc = "Lsp virtual text toggle" },
        },
        {
            "d",
            keymap.cmd("LspDefinition"),
            { nowait = true, silent = true, desc = "Definition" },
        },
        {
            "t",
            keymap.cmd("LspTypeDefinition"),
            { nowait = true, silent = true, desc = "Type definition" },
        },
        {
            "D",
            keymap.cmd("LspDeclaration"),
            { nowait = true, silent = true, desc = "Declaration" },
        },
        {
            "R",
            keymap.cmd("LspReferences"),
            { nowait = true, silent = true, desc = "References" },
        },
        {
            "i",
            keymap.cmd("LspImplementation"),
            { nowait = true, silent = true, desc = "Implementation" },
        },
        {
            "H",
            keymap.cmd("LspSignatureHelp"),
            { nowait = true, silent = true, desc = "Signature help" },
        },
        {
            "s",
            keymap.cmd("LspDocumentSymbol"),
            { nowait = true, silent = true, desc = "Document symbol" },
        },
        {
            "S",
            keymap.cmd("LspWorkspaceSymbol"),
            { nowait = true, silent = true, desc = "Workspace symbol" },
        },
        {
            "F",
            keymap.cmd("LspCodeLensRefresh"),
            { nowait = true, silent = true, desc = "Code lens refresh" },
        },
        {
            "L",
            keymap.cmd("LspCodeLensRun"),
            { nowait = true, silent = true, desc = "Code lens run" },
        },
        {
            "x",
            keymap.cmd("LspAddToWorkspaceFolder"),
            { nowait = true, silent = true, desc = "Add to workspace folder" },
        },
        {
            "X",
            keymap.cmd("LspRemoveWorkspaceFolder"),
            { nowait = true, silent = true, desc = "Remove workspace folder" },
        },
        {
            "W",
            keymap.cmd("LspListWorkspaceFolders"),
            { nowait = true, silent = true, desc = "List workspace folders" },
        },
        {
            "I",
            keymap.cmd("LspIncomingCalls"),
            { nowait = true, silent = true, desc = "Incoming calls" },
        },
        {
            "O",
            keymap.cmd("LspOutgoingCalls"),
            { nowait = true, silent = true, desc = "Outgoing calls" },
        },
        {
            "J",
            keymap.cmd("AnyJump"),
            { nowait = true, silent = true, desc = "Any jump" },
        },
        {
            "N",
            keymap.cmd("Navbuddy"),
            { nowait = true, silent = true, desc = "Navbuddy" },
        },
        {
            "U",
            keymap.cmd("SymbolsOutline"),
            { nowait = true, silent = true, desc = "Symbols outline" },
        },
        {
            "<C-c>",
            keymap.cmd("LvimDiagnostics"),
            { nowait = true, silent = true, desc = "Lvim diagnostics" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
