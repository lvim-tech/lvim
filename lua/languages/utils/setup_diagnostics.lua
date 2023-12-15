local global = require("core.global")
local funcs = require("core.funcs")
local ui_config = require("lvim-ui-config.config")
local select = require("lvim-ui-config.select")
local icons = require("configs.base.ui.icons")

local M = {}

local function get_vt()
    local vt
    if _G.LVIM_SETTINGS.virtualdiagnostic then
        vt = {
            prefix = icons.common.dot,
        }
    else
        vt = false
    end
    return vt
end

local config_diagnostic = {
    virtual_text = get_vt(),
    update_in_insert = true,
    underline = true,
    severity_sort = true,
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
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            elseif choice == "Disable" then
                _G.LVIM_SETTINGS["autoformat"] = false
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
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
                    local clients = vim.lsp.buf_get_clients(bufnr)
                    if #clients > 0 then
                        for _, client in ipairs(clients) do
                            if vim.lsp.inlay_hint ~= nil and client.server_capabilities.inlayHintProvider then
                                vim.lsp.inlay_hint.enable(bufnr, true)
                            end
                        end
                    else
                        print("No LSP client associated with the buffer")
                    end
                end
                _G.LVIM_SETTINGS["inlayhint"] = true
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            elseif choice == "Disable" then
                local buffers = vim.api.nvim_list_bufs()
                for _, bufnr in ipairs(buffers) do
                    local clients = vim.lsp.buf_get_clients(bufnr)
                    if #clients > 0 then
                        for _, client in ipairs(clients) do
                            if vim.lsp.inlay_hint ~= nil and client.server_capabilities.inlayHintProvider then
                                vim.lsp.inlay_hint.enable(bufnr, false)
                            end
                        end
                    else
                        print("No LSP client associated with the buffer")
                    end
                end
                _G.LVIM_SETTINGS["inlayhint"] = false
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimInlayHint", lvim_inlay_hint, {})
    vim.diagnostic.config(config_diagnostic)
    local function lvim_virtual_diagnostic()
        local status
        if _G.LVIM_SETTINGS.virtualdiagnostic == true then
            status = "Enabled"
        else
            status = "Disabled"
        end
        local opts = ui_config.select({
            "Enable",
            "Disable",
            "Cancel",
        }, { prompt = "VirtualDiagnostic (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Enable" then
                _G.LVIM_SETTINGS["virtualdiagnostic"] = true
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            elseif choice == "Disable" then
                _G.LVIM_SETTINGS["virtualdiagnostic"] = false
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            end
            local config = vim.diagnostic.config
            config({
                virtual_text = get_vt(),
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

M.omni = function(client, bufnr)
    if client.server_capabilities.completionProvider then
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    end
end

M.tag = function(client, bufnr)
    if client.server_capabilities.definitionProvider then
        vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
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

M.document_formatting = function(client, bufnr)
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
        -- vim.lsp.inlay_hint(bufnr, true)
        vim.lsp.inlay_hint.enable(bufnr, true)
    end
end

M.get_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem["snippetSupport"] = true
    capabilities.textDocument.completion.completionItem["resolveSupport"] = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    }
    local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if status_ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end
    capabilities.experimental = {
        workspaceWillRename = true,
    }
    return capabilities
end

M.get_cpp_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem["snippetSupport"] = true
    capabilities.textDocument.completion.completionItem["resolveSupport"] = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    }
    local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if status_ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end
    capabilities["offsetEncoding"] = "utf-16"
    capabilities.experimental = {
        workspaceWillRename = true,
    }
    return capabilities
end

M.keymaps = function(_, bufnr)
    vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspDefinition" })
    vim.keymap.set("n", "gD", function()
        vim.lsp.buf.declaration()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspDeclaration" })
    vim.keymap.set("n", "gt", function()
        vim.lsp.buf.type_definition()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspTypeDefinition" })
    vim.keymap.set("n", "gr", function()
        vim.lsp.buf.references()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspReferences" })
    vim.keymap.set("n", "gi", function()
        vim.lsp.buf.implementation()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspImplementation" })
    vim.keymap.set("n", "ge", function()
        vim.lsp.buf.rename()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspRename" })
    vim.keymap.set("n", "gf", function()
        vim.cmd("LspFormat")
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspFormat" })
    -- vim.keymap.set("x", "g;", function()
    --     vim.cmd("LspFormatRange")
    -- end, { noremap = true, silent = true, buffer = bufnr, desc = "LspFormatRange" })
    vim.keymap.set("n", "ga", function()
        vim.lsp.buf.code_action()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspCodeAction" })
    vim.keymap.set("n", "gs", function()
        vim.lsp.buf.signature_help()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspSignatureHelp" })
    vim.keymap.set("n", "gL", function()
        vim.lsp.codelens.refresh()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspCodeLensRefresh" })
    vim.keymap.set("n", "gl", function()
        vim.lsp.codelens.run()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspCodeLensRun" })
    vim.keymap.set("n", "gh", function()
        vim.lsp.buf.hover()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspHover" })
    vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover()
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspHover" })
end

return M
