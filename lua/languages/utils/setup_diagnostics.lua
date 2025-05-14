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

M.get_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- capabilities["offsetEncoding"] = "utf-8"
    return require("blink.cmp").get_lsp_capabilities(capabilities)
end

M.get_cpp_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    return require("blink.cmp").get_lsp_capabilities(capabilities)
end

M.keymaps = function(_, bufnr)
    local function create_safe_command(capability_name, command)
        return function()
            local clients = vim.lsp.get_clients({ bufnr = bufnr })
            local has_capability = false
            for _, client in ipairs(clients) do
                if client.server_capabilities and client.server_capabilities[capability_name] then
                    has_capability = true
                    break
                end
            end
            if has_capability then
                pcall(command)
            end
        end
    end

    local _border = {
        { "🭽", "FloatBorder" },
        { "▔", "FloatBorder" },
        { "🭾", "FloatBorder" },
        { "▕", "FloatBorder" },
        { "🭿", "FloatBorder" },
        { "▁", "FloatBorder" },
        { "🭼", "FloatBorder" },
        { "▏", "FloatBorder" },
    }

    local function bordered_hover(_opts)
        _opts = _opts or {}
        return vim.lsp.buf.hover(vim.tbl_deep_extend("force", _opts, {
            border = _border,
        }))
    end
    local function bordered_signature_help(_opts)
        _opts = _opts or {}
        return vim.lsp.buf.signature_help(vim.tbl_deep_extend("force", _opts, {
            border = _border,
        }))
    end

    local mappings = {
        {
            mode = "n",
            lhs = "gd",
            capability = "definitionProvider",
            command = vim.lsp.buf.definition,
            desc = "LspDefinition",
        },
        {
            mode = "n",
            lhs = "gD",
            capability = "declarationProvider",
            command = vim.lsp.buf.declaration,
            desc = "LspDeclaration",
        },
        {
            mode = "n",
            lhs = "gt",
            capability = "typeDefinitionProvider",
            command = vim.lsp.buf.type_definition,
            desc = "LspTypeDefinition",
        },
        {
            mode = "n",
            lhs = "gr",
            capability = "referencesProvider",
            command = vim.lsp.buf.references,
            desc = "LspReferences",
        },
        {
            mode = "n",
            lhs = "gi",
            capability = "implementationProvider",
            command = vim.lsp.buf.implementation,
            desc = "LspImplementation",
        },
        {
            mode = "n",
            lhs = "ge",
            capability = "renameProvider",
            command = vim.lsp.buf.rename,
            desc = "LspRename",
        },
        {
            mode = "n",
            lhs = "ga",
            capability = "codeActionProvider",
            command = vim.lsp.buf.code_action,
            desc = "LspCodeAction",
        },
        {
            mode = "n",
            lhs = "gs",
            capability = "signatureHelpProvider",
            command = bordered_signature_help,
            desc = "LspSignatureHelp",
        },
        {
            mode = "n",
            lhs = "gL",
            capability = "codeLensProvider",
            command = vim.lsp.codelens.refresh,
            desc = "LspCodeLensRefresh",
        },
        {
            mode = "n",
            lhs = "gl",
            capability = "codeLensProvider",
            command = vim.lsp.codelens.run,
            desc = "LspCodeLensRun",
        },
        {
            mode = "n",
            lhs = "gh",
            capability = "hoverProvider",
            command = vim.lsp.buf.hover,
            desc = "LspHover",
        },
        {
            mode = "n",
            lhs = "K",
            capability = "hoverProvider",
            command = bordered_hover,
            desc = "LspHover",
        },
    }

    local function setup_format_mappings()
        local has_format_capability = false
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        for _, client in ipairs(clients) do
            if client.server_capabilities and client.server_capabilities["documentFormattingProvider"] then
                has_format_capability = true
                break
            end
        end
        if has_format_capability then
            vim.keymap.set("n", "gf", function()
                vim.cmd("LspFormat")
            end, { noremap = true, silent = true, buffer = bufnr, desc = "LspFormat" })
            vim.keymap.set(
                "v",
                "gF",
                vim.cmd("LspFormatRange")
                { noremap = true, silent = true, buffer = bufnr, desc = "LspFormatRange" }
            )
        end
    end

    for _, mapping in ipairs(mappings) do
        vim.keymap.set(mapping.mode, mapping.lhs, create_safe_command(mapping.capability, mapping.command), {
            noremap = true,
            silent = true,
            buffer = bufnr,
            desc = mapping.desc,
        })
    end

    setup_format_mappings()
end

return M
