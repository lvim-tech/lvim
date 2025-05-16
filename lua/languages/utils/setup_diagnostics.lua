local fidget = require("fidget")
local icons = require("configs.base.ui.icons")

local M = {}

local group = vim.api.nvim_create_augroup("LspProgressNotify", { clear = false })
local virtualdiagnostic = _G.LVIM_SETTINGS.virtualdiagnostic
local is_empty = not virtualdiagnostic or next(virtualdiagnostic) == nil

local config_diagnostic = {
    virtual_text = (not is_empty and virtualdiagnostic.text) and { prefix = icons.common.dot } or false,
    virtual_lines = not is_empty and virtualdiagnostic.lines or false,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
        },
    },
}

M.init_diagnostics = function()
    vim.diagnostic.config(config_diagnostic)
    vim.fn.sign_define("DiagnosticSignError", {
        text = icons.diagnostics.error,
        texthl = "DiagnosticError",
    })
    vim.fn.sign_define("DiagnosticSignWarn", {
        text = icons.diagnostics.warn,
        texthl = "DiagnosticWarn",
    })
    vim.fn.sign_define("DiagnosticSignHint", {
        text = icons.diagnostics.hint,
        texthl = "DiagnosticHint",
    })
    vim.fn.sign_define("DiagnosticSignInfo", {
        text = icons.diagnostics.info,
        texthl = "DiagnosticInfo",
    })
    if _G.LVIM_SETTINGS.lspprogress == "fidget" then
        fidget.progress.suppress(false)
        fidget.notification.suppress(false)
        M.disable_lsp_progress()
    elseif _G.LVIM_SETTINGS.lspprogress == "notify" then
        fidget.progress.suppress(true)
        fidget.notification.suppress(true)
        M.enable_lsp_progress()
    else
        fidget.progress.suppress(true)
        fidget.notification.suppress(true)
        M.disable_lsp_progress()
    end
end

M.document_highlight = function(client, bufnr)
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            command = "lua vim.lsp.buf.document_highlight()",
            group = "LvimIDE",
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            command = "lua vim.lsp.buf.clear_references()",
            group = "LvimIDE",
        })
    end
end

M.document_auto_format = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                if _G.LVIM_SETTINGS.autoformat == true then
                    vim.lsp.buf.format()
                end
            end,
            group = "LvimIDE",
        })
    end
end

M.inlay_hint = function(client, bufnr)
    if
        vim.lsp.inlay_hint ~= nil
        and client.server_capabilities.inlayHintProvider
        and _G.LVIM_SETTINGS.inlayhint == true
    then
        vim.schedule(function()
            vim.lsp.inlay_hint.enable(true, { bufnr })
        end)
    end
end

M.enable_lsp_progress = function()
    vim.api.nvim_clear_autocmds({ group = group })

    ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
    local progress = vim.defaulttable()
    vim.api.nvim_create_autocmd("LspProgress", {
        group = group,
        ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
            if not client or type(value) ~= "table" then
                return
            end
            local p = progress[client.id]
            for i = 1, #p + 1 do
                if i == #p + 1 or p[i].token == ev.data.params.token then
                    p[i] = {
                        token = ev.data.params.token,
                        msg = ("[%3d%%] %s%s"):format(
                            value.kind == "end" and 100 or value.percentage or 100,
                            value.title or "",
                            value.message and (" **%s**"):format(value.message) or ""
                        ),
                        done = value.kind == "end",
                    }
                    break
                end
            end
            local msg = {} ---@type string[]
            progress[client.id] = vim.tbl_filter(function(v)
                return table.insert(msg, v.msg) or not v.done
            end, p)
            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            vim.notify(table.concat(msg, "\n"), "info", {
                id = "lsp_progress",
                title = client.name,
                opts = function(notif)
                    notif.icon = #progress[client.id] == 0 and " "
                        or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                end,
            })
        end,
    })
end

M.disable_lsp_progress = function()
    vim.api.nvim_clear_autocmds({ group = group })
end

local cached_capabilities = nil

M.get_capabilities = function()
    if cached_capabilities then
        return cached_capabilities
    end
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, enhanced_capabilities = pcall(require, "blink.cmp")
    if ok and enhanced_capabilities and type(enhanced_capabilities.get_lsp_capabilities) == "function" then
        enhanced_capabilities = enhanced_capabilities.get_lsp_capabilities(capabilities)
        cached_capabilities = enhanced_capabilities
        return enhanced_capabilities
    end
    return capabilities
end

M.keymaps = function(client, bufnr)
    local function buf_set_keymap(mode, lhs, command, desc, capability_check)
        if not capability_check or capability_check(client) then
            vim.keymap.set(mode, lhs, command, {
                buffer = bufnr,
                desc = desc,
            })
        end
    end

    -- Basic LSP navigation functions
    buf_set_keymap("n", "gd", "<cmd>LspDefinition<CR>", "Go to definition", function(c)
        return c.server_capabilities.definitionProvider
    end)

    buf_set_keymap("n", "gD", "<cmd>LspDeclaration<CR>", "Go to declaration", function(c)
        return c.server_capabilities.declarationProvider
    end)

    buf_set_keymap("n", "gt", "<cmd>LspTypeDefinition<CR>", "Go to type definition", function(c)
        return c.server_capabilities.typeDefinitionProvider
    end)

    buf_set_keymap("n", "gi", "<cmd>LspImplementation<CR>", "Go to implementation", function(c)
        return c.server_capabilities.implementationProvider
    end)

    buf_set_keymap("n", "gr", "<cmd>LspReferences<CR>", "Find references", function(c)
        return c.server_capabilities.referencesProvider
    end)

    -- Informational functions
    buf_set_keymap("n", "K", "<cmd>LspHover<CR>", "Show hover information", function(c)
        return c.server_capabilities.hoverProvider
    end)

    buf_set_keymap("i", "<C-k>", "<cmd>LspSignatureHelp<CR>", "Show signature help", function(c)
        return c.server_capabilities.signatureHelpProvider
    end)

    -- Formatting and code actions
    buf_set_keymap("n", "ge", "<cmd>LspRename<CR>", "Rename symbol", function(c)
        return c.server_capabilities.renameProvider
    end)

    buf_set_keymap("n", "ga", "<cmd>LspCodeAction<CR>", "Code action", function(c)
        return c.server_capabilities.codeActionProvider
    end)

    buf_set_keymap("n", "gf", "<cmd>LspFormat<CR>", "Format document", function(c)
        return c.server_capabilities.documentFormattingProvider
    end)

    buf_set_keymap("v", "gF", "<cmd>LspRangeFormat<CR>", "Format selection", function(c)
        return c.server_capabilities.documentRangeFormattingProvider
    end)

    -- Symbols and structure
    buf_set_keymap("n", "gs", "<cmd>LspDocumentSymbol<CR>", "Document symbols", function(c)
        return c.server_capabilities.documentSymbolProvider
    end)

    buf_set_keymap("n", "gS", "<cmd>LspWorkspaceSymbol<CR>", "Workspace symbols", function(c)
        return c.server_capabilities.workspaceSymbolProvider
    end)

    -- Diagnostics - не изискват специфични capabilities
    buf_set_keymap("n", "dc", "<cmd>LspShowDiagnosticCurrent<CR>", "Show line diagnostics")
    buf_set_keymap("n", "dn", "<cmd>LspShowDiagnosticPrev<CR>", "Previous diagnostic")
    buf_set_keymap("n", "dp", "<cmd>LspShowDiagnosticNext<CR>", "Next diagnostic")

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
    buf_set_keymap("n", "goa", "<cmd>LspAddToWorkspaceFolder<CR>", "Add folder to workspace", function(c)
        return c.server_capabilities.workspace and c.server_capabilities.workspace.workspaceFolders
    end)

    buf_set_keymap("n", "gor", "<cmd>LspRemoveWorkspaceFolder<CR>", "Remove folder from workspace", function(c)
        return c.server_capabilities.workspace and c.server_capabilities.workspace.workspaceFolders
    end)

    buf_set_keymap("n", "gol", "<cmd>LspListWorkspaceFolders<CR>", "List workspace folders", function(c)
        return c.server_capabilities.workspace and c.server_capabilities.workspace.workspaceFolders
    end)

    buf_set_keymap("n", "<Leader>dp", "<cmd>DAPLocal<CR>", "Start local debugging")
end

return M
