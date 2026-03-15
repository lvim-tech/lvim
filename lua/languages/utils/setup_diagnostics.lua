-- Description: Diagnostic display configuration and LSP on-attach utilities.
-- Sets up vim.diagnostic (virtual text, virtual lines, signs, severity sort),
-- configures Fidget-based or notify-based LSP progress reporting, and provides
-- on-attach helpers for document highlighting, auto-formatting, inlay hints,
-- LSP keymaps, and capability negotiation.
--
---@module "languages.utils.setup_diagnostics"
---@diagnostic disable: undefined-field

local fidget = require("fidget")
local icons  = require("configs.base.ui.icons")

local M = {}

--- Autocommand group shared by all diagnostic/progress autocmds in this module
---@type integer
local group = vim.api.nvim_create_augroup("LspProgressNotify", { clear = false })

-- ── Virtual diagnostic mode resolution ───────────────────────────────────────

--- Resolved virtual-text / virtual-lines flags derived from the setting string.
--- Possible setting values: "text-and-lines", "text", "lines", or anything else
--- (maps to both disabled).
---@type { text: boolean, lines: boolean }
local virtualdiagnostic

if _G.LVIM.settings.virtualdiagnostic == "text-and-lines" then
    virtualdiagnostic = { text = true, lines = true }
elseif _G.LVIM.settings.virtualdiagnostic == "text" then
    virtualdiagnostic = { text = true, lines = false }
elseif _G.LVIM.settings.virtualdiagnostic == "lines" then
    virtualdiagnostic = { text = false, lines = true }
else
    virtualdiagnostic = { text = false, lines = false }
end

--- True when `virtualdiagnostic` is nil or an empty table (both features off)
---@type boolean
local is_empty = not virtualdiagnostic or next(virtualdiagnostic) == nil

--- Full `vim.diagnostic.config` options table built from the resolved settings
---@type table
local config_diagnostic = {
    -- Show inline virtual text only when the "text" flag is enabled
    virtual_text  = (not is_empty and virtualdiagnostic.text) and { prefix = icons.common.dot } or false,
    -- Show virtual lines (rendered below the offending line) when "lines" is set
    virtual_lines = not is_empty and virtualdiagnostic.lines or false,
    update_in_insert = false,
    underline        = true,
    severity_sort    = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
            [vim.diagnostic.severity.WARN]  = icons.diagnostics.warn,
            [vim.diagnostic.severity.INFO]  = icons.diagnostics.info,
            [vim.diagnostic.severity.HINT]  = icons.diagnostics.hint,
        },
    },
}

-- ── Public API ────────────────────────────────────────────────────────────────

--- Applies `config_diagnostic` to Neovim's diagnostic subsystem, registers the
--- four diagnostic sign symbols, and starts the appropriate LSP progress backend
--- (Fidget widget, vim.notify spinner, or silent/off).
---@return nil
M.init_diagnostics = function()
    vim.diagnostic.config(config_diagnostic)

    -- Define legacy sign symbols (used by plugins that read signcolumn signs)
    vim.fn.sign_define("DiagnosticSignError", {
        text   = icons.diagnostics.error,
        texthl = "DiagnosticError",
    })
    vim.fn.sign_define("DiagnosticSignWarn", {
        text   = icons.diagnostics.warn,
        texthl = "DiagnosticWarn",
    })
    vim.fn.sign_define("DiagnosticSignHint", {
        text   = icons.diagnostics.hint,
        texthl = "DiagnosticHint",
    })
    vim.fn.sign_define("DiagnosticSignInfo", {
        text   = icons.diagnostics.info,
        texthl = "DiagnosticInfo",
    })

    if _G.LVIM.settings.lspprogress == "fidget" then
        -- Use Fidget's built-in progress/notification UI
        fidget.progress.suppress(false)
        fidget.notification.suppress(false)
        M.disable_lsp_progress()
    elseif _G.LVIM.settings.lspprogress == "notify" then
        -- Suppress Fidget and use the custom vim.notify spinner instead
        fidget.progress.suppress(true)
        fidget.notification.suppress(true)
        M.enable_lsp_progress()
    else
        -- No progress display; suppress everything
        fidget.progress.suppress(true)
        fidget.notification.suppress(true)
        M.disable_lsp_progress()
    end
end

--- Sets up CursorHold / CursorMoved autocommands for LSP document highlighting
--- when the server advertises `documentHighlightProvider`.
---@param client any  The attached LSP client
---@param bufnr  integer         Buffer handle
---@return nil
M.document_highlight = function(client, bufnr)
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd("CursorHold", {
            buffer   = bufnr,
            group    = group,
            callback = function()
                -- Re-check at callback time in case capabilities changed
                for _, c in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                    if c.server_capabilities.documentHighlightProvider then
                        vim.lsp.buf.document_highlight()
                        break
                    end
                end
            end,
        })

        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer   = bufnr,
            group    = group,
            callback = function()
                for _, c in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                    if c.server_capabilities.documentHighlightProvider then
                        vim.lsp.buf.clear_references()
                        break
                    end
                end
            end,
        })
    end
end

--- Registers a BufWritePre autocommand that formats the buffer on save when
--- `_G.LVIM.settings.autoformat` is true and the server supports formatting.
---@param client any  The attached LSP client
---@param bufnr  integer         Buffer handle
---@return nil
M.document_auto_format = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer   = bufnr,
            callback = function()
                if _G.LVIM.settings.autoformat == true then
                    vim.lsp.buf.format()
                end
            end,
            group = "LvimIDE",
        })
    end
end

--- Enables inlay hints for `bufnr` when all three conditions are met:
--- the Neovim version supports `vim.lsp.inlay_hint`, the server advertises
--- `inlayHintProvider`, and the global setting `inlayhint` is true.
---@param client any  The attached LSP client
---@param bufnr  integer         Buffer handle
---@return nil
M.inlay_hint = function(client, bufnr)
    if
        vim.lsp.inlay_hint ~= nil
        and client.server_capabilities.inlayHintProvider
        and _G.LVIM.settings.inlayhint == true
    then
        -- Defer to ensure the client is fully initialised before enabling
        vim.schedule(function()
            vim.lsp.inlay_hint.enable(true, { bufnr })
        end)
    end
end

--- Registers an `LspProgress` autocommand that renders LSP progress messages
--- as animated `vim.notify` notifications with a braille spinner icon.
--- Clears any pre-existing autocmds in the shared group first.
---@return nil
M.enable_lsp_progress = function()
    vim.api.nvim_clear_autocmds({ group = group })

    --- Tracks active progress tokens per client.
    --- Key: client_id, Value: list of { token, msg, done } entries.
    ---@type table<number, {token:integer|string, msg:string, done:boolean}[]>
    local progress = vim.defaulttable()

    vim.api.nvim_create_autocmd("LspProgress", {
        group = group,
        ---@param ev {data: {client_id: integer, params: {token: integer|string, value: table}}}
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            local value  = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
            if not client or type(value) ~= "table" then
                return
            end
            local p = progress[client.id]
            -- Upsert the entry for this token (linear scan is fine for small lists)
            for i = 1, #p + 1 do
                if i == #p + 1 or p[i].token == ev.data.params.token then
                    p[i] = {
                        token = ev.data.params.token,
                        msg   = ("[%3d%%] %s%s"):format(
                            value.kind == "end" and 100 or value.percentage or 100,
                            value.title or "",
                            value.message and (" **%s**"):format(value.message) or ""
                        ),
                        -- Mark as done when the kind is "end" so it can be filtered out
                        done  = value.kind == "end",
                    }
                    break
                end
            end

            ---@type string[]
            local msg = {}
            -- Filter out completed entries while collecting message strings
            progress[client.id] = vim.tbl_filter(function(v)
                return table.insert(msg, v.msg) or not v.done
            end, p)

            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            vim.notify(table.concat(msg, "\n"), "info", {
                id    = "lsp_progress",
                title = client.name,
                opts  = function(notif)
                    -- Show a space when all tokens are done, otherwise rotate spinner
                    notif.icon = #progress[client.id] == 0 and " "
                        or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                end,
            })
        end,
    })
end

--- Removes all autocmds in the shared group, effectively silencing LSP progress.
---@return nil
M.disable_lsp_progress = function()
    vim.api.nvim_clear_autocmds({ group = group })
end

-- ── Capability negotiation ────────────────────────────────────────────────────

--- Lazily-computed merged capabilities (built once and reused for all clients)
---@type table|nil
local cached_capabilities = nil

--- Returns the LSP client capabilities table, optionally enhanced by
--- blink.cmp when that plugin is available.  The result is cached after the
--- first call.
---@return table
M.get_capabilities = function()
    if cached_capabilities then
        return cached_capabilities
    end
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, enhanced_capabilities = pcall(require, "blink.cmp")
    if ok and enhanced_capabilities and type(enhanced_capabilities.get_lsp_capabilities) == "function" then
        -- Merge blink.cmp completion capabilities into the base table
        enhanced_capabilities  = enhanced_capabilities.get_lsp_capabilities(capabilities)
        cached_capabilities    = enhanced_capabilities
        return enhanced_capabilities
    end
    return capabilities
end

-- ── Buffer keymaps ────────────────────────────────────────────────────────────

--- Registers all LSP-related buffer-local keymaps for `bufnr`.
--- Each keymap is only bound when the server advertises the required capability
--- (passed as `capability_check`).  Diagnostic navigation bindings are always
--- registered since they do not depend on server capabilities.
---@param client any  The attached LSP client (used for capability checks)
---@param bufnr  integer         Buffer handle to apply keymaps to
---@return nil
M.keymaps = function(client, bufnr)
    --- Sets a single buffer-local keymap, guarded by an optional capability check.
    ---@param mode             string    Vim mode (e.g. "n", "v", "i")
    ---@param lhs              string    Key sequence
    ---@param command          string    RHS command string
    ---@param desc             string    Human-readable description
    ---@param capability_check (fun(c: any): boolean)|nil  Optional predicate
    local function buf_set_keymap(mode, lhs, command, desc, capability_check)
        if not capability_check or capability_check(client) then
            vim.keymap.set(mode, lhs, command, {
                buffer = bufnr,
                desc   = desc,
            })
        end
    end

    -- Basic LSP navigation functions
    buf_set_keymap("n", "gd", "<cmd>LspDefinition<CR>",     "Go to definition", function(c)
        return c.server_capabilities.definitionProvider
    end)

    buf_set_keymap("n", "gD", "<cmd>LspDeclaration<CR>",    "Go to declaration", function(c)
        return c.server_capabilities.declarationProvider
    end)

    buf_set_keymap("n", "gt", "<cmd>LspTypeDefinition<CR>", "Go to type definition", function(c)
        return c.server_capabilities.typeDefinitionProvider
    end)

    buf_set_keymap("n", "gi", "<cmd>LspImplementation<CR>", "Go to implementation", function(c)
        return c.server_capabilities.implementationProvider
    end)

    buf_set_keymap("n", "gr", "<cmd>LspReferences<CR>",     "Find references", function(c)
        return c.server_capabilities.referencesProvider
    end)

    -- Informational functions
    buf_set_keymap("n", "K",     "<cmd>LspHover<CR>",          "Show hover information", function(c)
        return c.server_capabilities.hoverProvider
    end)

    buf_set_keymap("i", "<C-k>", "<cmd>LspSignatureHelp<CR>",  "Show signature help", function(c)
        return c.server_capabilities.signatureHelpProvider
    end)

    -- Formatting and code actions
    buf_set_keymap("n", "ge", "<cmd>LspRename<CR>",      "Rename symbol", function(c)
        return c.server_capabilities.renameProvider
    end)

    buf_set_keymap("n", "ga", "<cmd>LspCodeAction<CR>",  "Code action", function(c)
        return c.server_capabilities.codeActionProvider
    end)

    buf_set_keymap("n", "gf", "<cmd>LspFormat<CR>",      "Format document", function(c)
        return c.server_capabilities.documentFormattingProvider
    end)

    buf_set_keymap("v", "gF", "<cmd>LspRangeFormat<CR>", "Format selection", function(c)
        return c.server_capabilities.documentRangeFormattingProvider
    end)

    -- Symbols and structure
    buf_set_keymap("n", "gs", "<cmd>LspDocumentSymbol<CR>",  "Document symbols", function(c)
        return c.server_capabilities.documentSymbolProvider
    end)

    buf_set_keymap("n", "gS", "<cmd>LspWorkspaceSymbol<CR>", "Workspace symbols", function(c)
        return c.server_capabilities.workspaceSymbolProvider
    end)

    -- Diagnostics - не изискват специфични capabilities
    buf_set_keymap("n", "dc", "<cmd>LspShowDiagnosticCurrent<CR>", "Show line diagnostics")
    buf_set_keymap("n", "dn", "<cmd>LspShowDiagnosticNext<CR>",    "Next diagnostic")
    buf_set_keymap("n", "dp", "<cmd>LspShowDiagnosticPrev<CR>",    "Previous diagnostic")

    -- CodeLens
    buf_set_keymap("n", "gL", "<cmd>LspCodeLensRun<CR>", "Run CodeLens", function(c)
        return c.server_capabilities.codeLensProvider
    end)

    -- Call Hierarchy
    buf_set_keymap("n", "glc", "<cmd>LspIncomingCalls<CR>", "Incoming calls", function(c)
        return c.server_capabilities.callHierarchyProvider
    end)

    buf_set_keymap("n", "glC", "<cmd>LspOutgoingCalls<CR>", "Outgoing calls", function(c)
        return c.server_capabilities.callHierarchyProvider
    end)

    -- Document Highlight
    buf_set_keymap("n", "ghr", "<cmd>LspDocumentHighlight<CR>", "Highlight references", function(c)
        return c.server_capabilities.documentHighlightProvider
    end)

    buf_set_keymap("n", "ghc", "<cmd>LspClearReferences<CR>", "Clear highlights", function(c)
        return c.server_capabilities.documentHighlightProvider
    end)

    -- Workspace Folders
    buf_set_keymap("n", "goa", "<cmd>LspAddToWorkspaceFolder<CR>",    "Add folder to workspace", function(c)
        return c.server_capabilities.workspace and c.server_capabilities.workspace.workspaceFolders
    end)

    buf_set_keymap("n", "gor", "<cmd>LspRemoveWorkspaceFolder<CR>",   "Remove folder from workspace", function(c)
        return c.server_capabilities.workspace and c.server_capabilities.workspace.workspaceFolders
    end)

    buf_set_keymap("n", "gol", "<cmd>LspListWorkspaceFolders<CR>",    "List workspace folders", function(c)
        return c.server_capabilities.workspace and c.server_capabilities.workspace.workspaceFolders
    end)

    buf_set_keymap("n", "<Leader>dp", "<cmd>DAPLocal<CR>", "Start local debugging")
end

return M
