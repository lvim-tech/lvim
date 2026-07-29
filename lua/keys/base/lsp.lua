-- keys/base/lsp.lua — the LSP verbs, applied buffer-local on LspAttach.
--
-- Each entry may carry `cap`: the server capability it needs (a `server_capabilities` key, or a
-- predicate for a nested one). A key whose capability the attached server lacks is never bound —
-- that is what stops `g*` firing on a server that cannot answer it.
---@module "keys.base.lsp"

--- Guard for the workspace-folder maps (a nested capability, not a top-level key).
---@param caps table  client.server_capabilities
---@return boolean
local function has_ws(caps)
    return caps.workspace ~= nil and caps.workspace.workspaceFolders ~= nil
end

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- LSP  (applied buffer-local on LspAttach; each key TESTS the server capability via `cap`,
-- so it is NEVER bound where the server has no such action — the g* interface, centralised here).
-- Entry opts: { mode? = "n"|"i"|"v", cap? = "<serverCapabilityKey>" | fun(caps): boolean }.
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
return {
    -- Navigation
    { "gd", "<Cmd>LvimLsp definition<CR>", "Go to definition", { cap = "definitionProvider" } },
    { "gD", "<Cmd>LvimLsp declaration<CR>", "Go to declaration", { cap = "declarationProvider" } },
    { "gt", "<Cmd>LvimLsp type_definition<CR>", "Go to type definition", { cap = "typeDefinitionProvider" } },
    { "gi", "<Cmd>LvimLsp implementation<CR>", "Go to implementation", { cap = "implementationProvider" } },
    { "gr", "<Cmd>LvimLsp references<CR>", "Find references", { cap = "referencesProvider" } },
    -- Information
    { "K", "<Cmd>LvimLsp hover<CR>", "Hover information", { cap = "hoverProvider" } },
    { "<C-k>", "<Cmd>LvimLsp signature_help<CR>", "Signature help", { mode = "i", cap = "signatureHelpProvider" } },
    -- Edit
    { "ge", "<Cmd>LvimLsp rename<CR>", "Rename symbol", { cap = "renameProvider" } },
    {
        "ga",
        function()
            vim.lsp.buf.code_action()
        end,
        "Code action",
        { cap = "codeActionProvider" },
    },
    { "gf", "<Cmd>LvimLsp format<CR>", "Format document", { cap = "documentFormattingProvider" } },
    {
        "gF",
        "<Cmd>LvimLsp range_format<CR>",
        "Format selection",
        { mode = "v", cap = "documentRangeFormattingProvider" },
    },
    -- Symbols
    { "gs", "<Cmd>LvimLsp document_symbol<CR>", "Document symbols", { cap = "documentSymbolProvider" } },
    { "gS", "<Cmd>LvimLsp workspace_symbol<CR>", "Workspace symbols", { cap = "workspaceSymbolProvider" } },
    -- Diagnostics (no capability required). NOT on `d*`: a buffer-local `dn`/`dp`/`dc` makes the
    -- DELETE OPERATOR wait out `timeoutlen` on every LSP buffer and shadows `dp` (diffput) in a
    -- diff view. `]d`/`[d` are the motions Neovim itself defines for this, and the float joins the
    -- `gl` (LSP list/lens) prefix.
    { "gld", "<Cmd>LvimLsp diagnostic_current<CR>", "Show line diagnostics" },
    { "]d", "<Cmd>LvimLsp diagnostic_next<CR>", "Next diagnostic" },
    { "[d", "<Cmd>LvimLsp diagnostic_prev<CR>", "Previous diagnostic" },
    -- CodeLens
    { "gL", "<Cmd>LspCodeLensRun<CR>", "Run CodeLens", { cap = "codeLensProvider" } },
    -- Call hierarchy
    { "glc", "<Cmd>LvimLsp incoming_calls<CR>", "Incoming calls", { cap = "callHierarchyProvider" } },
    { "glC", "<Cmd>LvimLsp outgoing_calls<CR>", "Outgoing calls", { cap = "callHierarchyProvider" } },
    -- Document highlight
    { "ghr", "<Cmd>LvimLsp document_highlight<CR>", "Highlight references", { cap = "documentHighlightProvider" } },
    { "ghc", "<Cmd>LvimLsp clear_references<CR>", "Clear highlights", { cap = "documentHighlightProvider" } },
    -- Workspace folders (nested capability)
    { "goa", "<Cmd>LvimLsp add_workspace_folder<CR>", "Add workspace folder", { cap = has_ws } },
    { "gor", "<Cmd>LvimLsp remove_workspace_folder<CR>", "Remove workspace folder", { cap = has_ws } },
    { "gol", "<Cmd>LvimLsp list_workspace_folders<CR>", "List workspace folders", { cap = has_ws } },
}

