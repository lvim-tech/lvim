local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local lsp_hint = [[
                             LSP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Hover                       _K_ │ _r_                     Rename
Format                      _f_ │ _A_                Code action

Show diagnostic current     _v_ │
Show diagnostic next        _n_ │ _p_       Show diagnostic prev

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
                         exit _<Esc>_
]]

Hydra({
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
    body = "<leader>d",
    heads = {
        {
            "K",
            keymap.cmd("LspHover"),
            { silent = true, desc = "Hover" },
        },
        {
            "r",
            keymap.cmd("LspRename"),
            { silent = true, desc = "Rename" },
        },
        {
            "f",
            keymap.cmd("LspFormat"),
            { silent = true, desc = "Format" },
        },
        {
            "A",
            keymap.cmd("LspCodeAction"),
            { silent = true, desc = "Code action" },
        },
        {
            "v",
            keymap.cmd("LspShowDiagnosticCurrent"),
            { silent = true, desc = "Show diagnostic current" },
        },
        {
            "n",
            keymap.cmd("LspShowDiagnosticNext"),
            { silent = true, desc = "Show diagnostic next" },
        },
        {
            "p",
            keymap.cmd("LspShowDiagnosticPrev"),
            { silent = true, desc = "Show diagnostic prev" },
        },
        {
            "d",
            keymap.cmd("LspDefinition"),
            { silent = true, desc = "Definition" },
        },
        {
            "t",
            keymap.cmd("LspTypeDefinition"),
            { silent = true, desc = "Type definition" },
        },
        {
            "D",
            keymap.cmd("LspDeclaration"),
            { silent = true, desc = "Declaration" },
        },
        {
            "R",
            keymap.cmd("LspReferences"),
            { silent = true, desc = "References" },
        },
        {
            "i",
            keymap.cmd("LspImplementation"),
            { silent = true, desc = "Implementation" },
        },
        {
            "H",
            keymap.cmd("LspSignatureHelp"),
            { silent = true, desc = "Signature help" },
        },
        {
            "s",
            keymap.cmd("LspDocumentSymbol"),
            { silent = true, desc = "Document symbol" },
        },
        {
            "S",
            keymap.cmd("LspWorkspaceSymbol"),
            { silent = true, desc = "Workspace symbol" },
        },
        {
            "F",
            keymap.cmd("LspCodeLensRefresh"),
            { silent = true, desc = "Code lens refresh" },
        },
        {
            "L",
            keymap.cmd("LspCodeLensRun"),
            { silent = true, desc = "Code lens run" },
        },
        {
            "x",
            keymap.cmd("LspAddToWorkspaceFolder"),
            { silent = true, desc = "Add to workspace folder" },
        },
        {
            "X",
            keymap.cmd("LspRemoveWorkspaceFolder"),
            { silent = true, desc = "Remove workspace folder" },
        },
        {
            "W",
            keymap.cmd("LspListWorkspaceFolders"),
            { silent = true, desc = "List workspace folders" },
        },
        {
            "I",
            keymap.cmd("LspIncomingCalls"),
            { silent = true, desc = "Incoming calls" },
        },
        {
            "O",
            keymap.cmd("LspOutgoingCalls"),
            { silent = true, desc = "Outgoing calls" },
        },
        {
            "J",
            keymap.cmd("AnyJump"),
            { silent = true, desc = "Any jump" },
        },
        {
            "N",
            keymap.cmd("Navbuddy"),
            { silent = true, desc = "Navbuddy" },
        },
        {
            "U",
            keymap.cmd("SymbolsOutline"),
            { silent = true, desc = "Symbols outline" },
        },
        {
            "<C-c>",
            keymap.cmd("LvimDiagnostics"),
            { silent = true, desc = "Lvim diagnostics" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
