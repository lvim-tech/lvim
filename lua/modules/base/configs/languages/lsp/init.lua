-- LSP integration helpers for lvim-lsp.
-- Single entry-point used by:
--   • modules/user/init.lua      — on_attach keymaps + diagnostics/dap callbacks
--   • modules/base/configs/languages/init.lua  — flutter-tools on_attach + get_capabilities
--   • modules/base/configs/editor/control_center/lsp.lua — progress toggle
--   • individual language server configs  — get_capabilities()
--
---@module "modules.base.configs.languages.lsp"

local M = {}

-- ── Buffer keymaps ────────────────────────────────────────────────────────────

--- Registers all LSP-related buffer-local keymaps for `bufnr`.
---@param client any     The attached LSP client (used for capability checks)
---@param bufnr  integer Buffer handle to apply keymaps to
M.keymaps = function(client, bufnr)
    local caps = client.server_capabilities

    --- Sets a buffer-local keymap, optionally guarded by a capability predicate.
    ---@param mode  string
    ---@param lhs   string
    ---@param cmd   string
    ---@param desc  string
    ---@param check (fun(): boolean)|nil
    local function map(mode, lhs, cmd, desc, check)
        if not check or check() then
            vim.keymap.set(mode, lhs, cmd, { buffer = bufnr, desc = desc })
        end
    end

    -- Navigation
    map("n", "gd", "<cmd>LvimLsp definition<CR>", "Go to definition", function()
        return caps.definitionProvider
    end)
    map("n", "gD", "<cmd>LvimLsp declaration<CR>", "Go to declaration", function()
        return caps.declarationProvider
    end)
    map("n", "gt", "<cmd>LvimLsp type_definition<CR>", "Go to type definition", function()
        return caps.typeDefinitionProvider
    end)
    map("n", "gi", "<cmd>LvimLsp implementation<CR>", "Go to implementation", function()
        return caps.implementationProvider
    end)
    map("n", "gr", "<cmd>LvimLsp references<CR>", "Find references", function()
        return caps.referencesProvider
    end)

    -- Information
    map("n", "K", "<cmd>LvimLsp hover<CR>", "Hover information", function()
        return caps.hoverProvider
    end)
    map("i", "<C-k>", "<cmd>LvimLsp signature_help<CR>", "Signature help", function()
        return caps.signatureHelpProvider
    end)

    -- Edit
    map("n", "ge", "<cmd>LvimLsp rename<CR>", "Rename symbol", function()
        return caps.renameProvider
    end)
    map("n", "ga", function() vim.lsp.buf.code_action() end, "Code action", function()
        return caps.codeActionProvider
    end)
    map("n", "gf", "<cmd>LvimLsp format<CR>", "Format document", function()
        return caps.documentFormattingProvider
    end)
    map("v", "gF", "<cmd>LvimLsp range_format<CR>", "Format selection", function()
        return caps.documentRangeFormattingProvider
    end)

    -- Symbols
    map("n", "gs", "<cmd>LvimLsp document_symbol<CR>", "Document symbols", function()
        return caps.documentSymbolProvider
    end)
    map("n", "gS", "<cmd>LvimLsp workspace_symbol<CR>", "Workspace symbols", function()
        return caps.workspaceSymbolProvider
    end)

    -- Diagnostics (no capability required)
    map("n", "dc", "<cmd>LvimLsp diagnostic_current<CR>", "Show line diagnostics")
    map("n", "dn", "<cmd>LvimLsp diagnostic_next<CR>", "Next diagnostic")
    map("n", "dp", "<cmd>LvimLsp diagnostic_prev<CR>", "Previous diagnostic")

    -- CodeLens (registered by lvim-lsp features.setup_code_lens)
    map("n", "gL", "<cmd>LspCodeLensRun<CR>", "Run CodeLens", function()
        return caps.codeLensProvider
    end)

    -- Call Hierarchy
    map("n", "glc", "<cmd>LvimLsp incoming_calls<CR>", "Incoming calls", function()
        return caps.callHierarchyProvider
    end)
    map("n", "glC", "<cmd>LvimLsp outgoing_calls<CR>", "Outgoing calls", function()
        return caps.callHierarchyProvider
    end)

    -- Document Highlight
    map("n", "ghr", "<cmd>LvimLsp document_highlight<CR>", "Highlight references", function()
        return caps.documentHighlightProvider
    end)
    map("n", "ghc", "<cmd>LvimLsp clear_references<CR>", "Clear highlights", function()
        return caps.documentHighlightProvider
    end)

    -- Workspace Folders
    local has_ws = caps.workspace and caps.workspace.workspaceFolders
    map("n", "goa", "<cmd>LvimLsp add_workspace_folder<CR>", "Add workspace folder", function()
        return has_ws
    end)
    map("n", "gor", "<cmd>LvimLsp remove_workspace_folder<CR>", "Remove workspace folder", function()
        return has_ws
    end)
    map("n", "gol", "<cmd>LvimLsp list_workspace_folders<CR>", "List workspace folders", function()
        return has_ws
    end)

    -- DAP
    map("n", "<Leader>dp", "<cmd>LvimLsp dap<CR>", "Start local debugging")
end

-- ── Capabilities ──────────────────────────────────────────────────────────────

--- Lazily-computed merged capabilities (built once and reused for all clients).
--- Merges blink.cmp completion capabilities when that plugin is available.
---@return table
local _cached_capabilities = nil
M.get_capabilities = function()
    if _cached_capabilities then
        return _cached_capabilities
    end
    local caps = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    if ok and blink and type(blink.get_lsp_capabilities) == "function" then
        caps = blink.get_lsp_capabilities(caps)
    end
    _cached_capabilities = caps
    return caps
end

-- ── Diagnostics callbacks (passed to lvim-lsp diagnostics config) ─────────────

--- Custom floating diagnostic popup — passed to lvim-lsp as
--- diagnostics.show_line / goto_next / goto_prev so LvimLsp subcommands
--- use the custom renderer instead of vim.diagnostic defaults.
M.diagnostics = require("modules.base.configs.languages.lsp.diagnostics")

return M
