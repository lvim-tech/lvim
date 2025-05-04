local funcs = require("core.funcs")
local ui_config = require("lvim-ui-config.config")
local select = require("lvim-ui-config.select")
local icons = require("configs.base.ui.icons")

local M = {}

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
    local function lvim_auto_format()
        local status
        if _G.LVIM_SETTINGS.autoformat == true then
            status = "Enabled"
        else
            status = "Disabled"
        end
        local opts = ui_config.select({
            "Enable",
            "Disable",
            "Cancel",
        }, { prompt = "AutoFormat (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Enable" then
                _G.LVIM_SETTINGS["autoformat"] = true
                funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            elseif choice == "Disable" then
                _G.LVIM_SETTINGS["autoformat"] = false
                funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimAutoFormat", lvim_auto_format, {})
    local function lvim_inlay_hint()
        local status
        if _G.LVIM_SETTINGS.inlayhint == true then
            status = "Enabled"
        else
            status = "Disabled"
        end
        local opts = ui_config.select({
            "Enable",
            "Disable",
            "Cancel",
        }, { prompt = "InlayHint (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Enable" then
                local buffers = vim.api.nvim_list_bufs()
                for _, bufnr in ipairs(buffers) do
                    if vim.lsp.inlay_hint ~= nil then
                        vim.lsp.inlay_hint.enable(true, { bufnr })
                    end
                end
                _G.LVIM_SETTINGS["inlayhint"] = true
                funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            elseif choice == "Disable" then
                local buffers = vim.api.nvim_list_bufs()
                for _, bufnr in ipairs(buffers) do
                    if vim.lsp.inlay_hint ~= nil then
                        vim.lsp.inlay_hint.enable(false, { bufnr })
                    end
                end
                _G.LVIM_SETTINGS["inlayhint"] = false
                funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimInlayHint", lvim_inlay_hint, {})
    vim.diagnostic.config(config_diagnostic)
    local function lvim_virtual_diagnostic()
        virtualdiagnostic = _G.LVIM_SETTINGS.virtualdiagnostic
        local status
        if not virtualdiagnostic or next(virtualdiagnostic) == nil then
            status = "Disable"
        elseif virtualdiagnostic.lines == true and virtualdiagnostic.text == true then
            status = "Text and Lines"
        elseif virtualdiagnostic.text then
            status = "Only Text"
        elseif virtualdiagnostic.lines then
            status = "Only Lines"
        else
            status = "Disable"
        end
        local opts = ui_config.select({
            "Text And Lines",
            "Only Text",
            "Only Lines",
            "Disable",
            "Cancel",
        }, { prompt = "VirtualDiagnostic (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Text And Lines" then
                _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                    text = true,
                    lines = true,
                }
            elseif choice == "Only Text" then
                _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                    text = true,
                    lines = false,
                }
            elseif choice == "Only Lines" then
                _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                    text = false,
                    lines = true,
                }
            elseif choice == "Disable" then
                _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                    text = false,
                    lines = false,
                }
            end
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            virtualdiagnostic = _G.LVIM_SETTINGS.virtualdiagnostic
            local config = vim.diagnostic.config
            config({
                virtual_text = (not is_empty and virtualdiagnostic.text) and { prefix = icons.common.dot } or false,
                virtual_lines = not is_empty and virtualdiagnostic.lines or false,
            })
        end)
    end
    vim.api.nvim_create_user_command("LvimVirtualDiagnostic", lvim_virtual_diagnostic, {})
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
        vim.lsp.inlay_hint.enable(true, { bufnr })
    end
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
            if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
                has_format_capability = true
                break
            end
        end
        if has_format_capability then
            vim.keymap.set("n", "gf", function()
                vim.cmd("LspFormat")
            end, { noremap = true, silent = true, buffer = bufnr, desc = "LspFormat" })
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
