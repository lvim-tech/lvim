local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local lsp_hint = [[
                                           LSP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Hover                                     _K_ │ _ge_                                   Rename
Format                                   _gf_ │ _ga_                              Code action

Show diagnostic current                  _dc_ │
Show diagnostic next                     _dn_ │ _dp_                     Show diagnostic prev

Definition                               _gd_ │ _gt_                          Type definition
Declaration                              _gD_ │ _gr_                               References
Implementation                           _gi_ │ _gs_                           Signature help

Code lens refresh                        _gL_ │ _gl_                            Code lens run

Document symbol                 _<C-c><C-c>d_ │ _<C-c><C-c>w_                Workspace symbol

Add to workspace folder         _<C-c><C-c>a_ │ _<C-c><C-c>r_         Remove workspace folder
List workspace folder           _<C-c><C-c>l_ │

Incoming calls                  _<C-c><C-c>i_ │ _<C-c><C-c>o_                  Outgoing calls

Navbuddy                             _<C-c>v_ │ _<A-v>_                       Symbols outline
Lvim diagnostics                 _<C-c><C-h>_ │ _<C-c><C-v>_                          Trouble

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.diagnostics = Hydra({
    name = "LSP",
    hint = lsp_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            float_opts = {
                border = "single",
            },
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
            "ge",
            keymap.cmd("LspRename"),
            { nowait = true, silent = true, desc = "Rename" },
        },
        {
            "gf",
            keymap.cmd("LspFormat"),
            { nowait = true, silent = true, desc = "Format" },
        },
        {
            "ga",
            keymap.cmd("LspCodeAction"),
            { nowait = true, silent = true, desc = "Code action" },
        },
        {
            "dc",
            keymap.cmd("LspShowDiagnosticCurrent"),
            { nowait = true, silent = true, desc = "Show diagnostic current" },
        },
        {
            "dn",
            keymap.cmd("LspShowDiagnosticNext"),
            { nowait = true, silent = true, desc = "Show diagnostic next" },
        },
        {
            "dp",
            keymap.cmd("LspShowDiagnosticPrev"),
            { nowait = true, silent = true, desc = "Show diagnostic prev" },
        },
        {
            "gd",
            keymap.cmd("LspDefinition"),
            { nowait = true, silent = true, desc = "Definition" },
        },
        {
            "gt",
            keymap.cmd("LspTypeDefinition"),
            { nowait = true, silent = true, desc = "Type definition" },
        },
        {
            "gD",
            keymap.cmd("LspDeclaration"),
            { nowait = true, silent = true, desc = "Declaration" },
        },
        {
            "gr",
            keymap.cmd("LspReferences"),
            { nowait = true, silent = true, desc = "References" },
        },
        {
            "gi",
            keymap.cmd("LspImplementation"),
            { nowait = true, silent = true, desc = "Implementation" },
        },
        {
            "gs",
            keymap.cmd("LspSignatureHelp"),
            { nowait = true, silent = true, desc = "Signature help" },
        },
        {
            "gL",
            keymap.cmd("LspCodeLensRefresh"),
            { nowait = true, silent = true, desc = "Code lens refresh" },
        },
        {
            "gl",
            keymap.cmd("LspCodeLensRun"),
            { nowait = true, silent = true, desc = "Code lens run" },
        },
        {
            "<C-c><C-c>d",
            keymap.cmd("LspDocumentSymbol"),
            { nowait = true, silent = true, desc = "Document symbol" },
        },
        {
            "<C-c><C-c>w",
            keymap.cmd("LspWorkspaceSymbol"),
            { nowait = true, silent = true, desc = "Workspace symbol" },
        },
        {
            "<C-c><C-c>a",
            keymap.cmd("LspAddToWorkspaceFolder"),
            { nowait = true, silent = true, desc = "Add to workspace folder" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("LspRemoveWorkspaceFolder"),
            { nowait = true, silent = true, desc = "Remove workspace folder" },
        },
        {
            "<C-c><C-c>l",
            keymap.cmd("LspListWorkspaceFolders"),
            { nowait = true, silent = true, desc = "List workspace folders" },
        },
        {
            "<C-c><C-c>i",
            keymap.cmd("LspIncomingCalls"),
            { nowait = true, silent = true, desc = "Incoming calls" },
        },
        {
            "<C-c><C-c>o",
            keymap.cmd("LspOutgoingCalls"),
            { nowait = true, silent = true, desc = "Outgoing calls" },
        },
        {
            "<C-c>v",
            keymap.cmd("Navbuddy"),
            { nowait = true, silent = true, desc = "Navbuddy" },
        },
        {
            "<A-v>",
            keymap.cmd("SymbolsOutline"),
            { nowait = true, silent = true, desc = "Symbols outline" },
        },
        {
            "<C-c><C-h>",
            keymap.cmd("LvimDiagnostics"),
            { nowait = true, silent = true, desc = "Lvim diagnostics" },
        },
        {
            "<C-c><C-v>",
            keymap.cmd("Trouble"),
            { nowait = true, silent = true, desc = "Trouble" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
