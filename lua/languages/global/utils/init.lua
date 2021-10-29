local global = require("core.global")

local M = {}

M.config_diagnostic = {
    virtual_text = false,
    update_in_insert = true,
    underline = true,
    severity_sort = true
}

M.config_lsp_signature = {
    bind = true,
    handler_opts = {border = "none"},
    hint_prefix = "   ",
    padding = " ",
    zindex = 200,
    transpancy = 0
}

M.icons = {
    error = "",
    warn = "",
    hint = "",
    info = ""
}

M.setup_diagnostic = function(custom_config_diagnostic)
    local local_config_diagnostic
    if custom_config_diagnostic ~= nil then
        local_config_diagnostic = custom_config_diagnostic
    else
        local_config_diagnostic = M.config_diagnostic
    end
    if vim.fn.has "nvim-0.5.1" > 0 then
        vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx)
            local uri = result.uri
            local bufnr = vim.uri_to_bufnr(uri)
            if not bufnr then
                return
            end
            local diagnostics = result.diagnostics
            local ok, vim_diag = pcall(require, "vim.diagnostic")
            if ok then
                for i, diagnostic in ipairs(diagnostics) do
                    local rng = diagnostic.range
                    diagnostics[i].lnum = rng["start"].line
                    diagnostics[i].end_lnum = rng["end"].line
                    diagnostics[i].col = rng["start"].character
                    diagnostics[i].end_col = rng["end"].character
                end
                local namespace = vim.lsp.diagnostic.get_namespace(ctx.client_id)
                vim_diag.set(namespace, bufnr, diagnostics, local_config_diagnostic)
                if not vim.api.nvim_buf_is_loaded(bufnr) then
                    return
                end
                vim.fn.sign_define(
                    "DiagnosticSignError",
                    {
                        texthl = "DiagnosticSignError",
                        text = M.icons.error,
                        numhl = "DiagnosticSignError"
                    }
                )
                vim.fn.sign_define(
                    "DiagnosticSignWarn",
                    {
                        texthl = "DiagnosticSignWarn",
                        text = M.icons.warn,
                        numhl = "DiagnosticSignWarn"
                    }
                )
                vim.fn.sign_define(
                    "DiagnosticSignHint",
                    {
                        texthl = "DiagnosticSignHint",
                        text = M.icons.hint,
                        numhl = "DiagnosticSignHint"
                    }
                )
                vim.fn.sign_define(
                    "DiagnosticSignInfo",
                    {
                        texthl = "DiagnosticSignInfo",
                        text = M.icons.info,
                        numhl = "DiagnosticSignInfo"
                    }
                )
                vim_diag.show(namespace, bufnr, diagnostics, local_config_diagnostic)
            else
                vim.lsp.diagnostic.save(diagnostics, bufnr, ctx.client_id)
                if not vim.api.nvim_buf_is_loaded(bufnr) then
                    return
                end
                vim.fn.sign_define(
                    "LspDiagnosticsSignError",
                    {
                        texthl = "LspDiagnosticsSignError",
                        text = M.icons.error,
                        numhl = "LspDiagnosticsSignError"
                    }
                )
                vim.fn.sign_define(
                    "LspDiagnosticsSignWarning",
                    {
                        texthl = "LspDiagnosticsSignWarning",
                        text = M.icons.warn,
                        numhl = "LspDiagnosticsSignWarning"
                    }
                )
                vim.fn.sign_define(
                    "LspDiagnosticsSignHint",
                    {
                        texthl = "LspDiagnosticsSignHint",
                        text = M.icons.hint,
                        numhl = "LspDiagnosticsSignHint"
                    }
                )
                vim.fn.sign_define(
                    "LspDiagnosticsSignInformation",
                    {
                        texthl = "LspDiagnosticsSignInformation",
                        text = M.icons.info,
                        numhl = "LspDiagnosticsSignInformation"
                    }
                )
                vim.lsp.diagnostic.display(diagnostics, bufnr, ctx.client_id, local_config_diagnostic)
            end
        end
    else
        vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, _, params, client_id, _)
            local uri = params.uri
            local bufnr = vim.uri_to_bufnr(uri)
            if not bufnr then
                return
            end
            local diagnostics = params.diagnostics
            vim.lsp.diagnostic.save(diagnostics, bufnr, client_id)
            if not vim.api.nvim_buf_is_loaded(bufnr) then
                return
            end
            vim.fn.sign_define(
                "LspDiagnosticsSignError",
                {
                    texthl = "LspDiagnosticsSignError",
                    text = M.icons.error,
                    numhl = "LspDiagnosticsSignError"
                }
            )
            vim.fn.sign_define(
                "LspDiagnosticsSignWarning",
                {
                    texthl = "LspDiagnosticsSignWarning",
                    text = M.icons.warn,
                    numhl = "LspDiagnosticsSignWarning"
                }
            )
            vim.fn.sign_define(
                "LspDiagnosticsSignHint",
                {
                    texthl = "LspDiagnosticsSignHint",
                    text = M.icons.hint,
                    numhl = "LspDiagnosticsSignHint"
                }
            )
            vim.fn.sign_define(
                "LspDiagnosticsSignInformation",
                {
                    texthl = "LspDiagnosticsSignInformation",
                    text = M.icons.info,
                    numhl = "LspDiagnosticsSignInformation"
                }
            )
            vim.lsp.diagnostic.display(diagnostics, bufnr, client_id, local_config_diagnostic)
        end
    end
end

M.show_line_diagnostics = function()
    local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
    local severity_highlight = {
        "LspDiagnosticsFloatingError",
        "LspDiagnosticsFloatingWarning",
        "LspDiagnosticsFloatingHint",
        "LspDiagnosticsFloatingInformation"
    }
    local ok, vim_diag = pcall(require, "vim.diagnostic")
    if ok then
        local buf_id = vim.api.nvim_win_get_buf(0)
        local win_id = vim.api.nvim_get_current_win()
        local cursor_position = vim.api.nvim_win_get_cursor(win_id)
        severity_highlight = {
            "DiagnosticFloatingError",
            "DiagnosticFloatingWarn",
            "DiagnosticFloatingInfo",
            "DiagnosticFloatingHint"
        }
        diagnostics = vim_diag.get(buf_id, {lnum = cursor_position[1] - 1})
    end
end

M.document_highlight = function(client)
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec(
            [[
        hi LspReferenceRead cterm=bold guibg=#41495A
        hi LspReferenceText cterm=bold guibg=#41495A
        hi LspReferenceWrite cterm=bold guibg=#41495A
        augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
        ]],
            false
        )
    end
end

M.get_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
    return capabilities
end

M.toggle_virtual_text = function()
    if global.virtual_text == "no" then
        local config_diagnostic = {
            virtual_text = {
                prefix = "",
                spacing = 4
            },
            update_in_insert = true,
            underline = true,
            severity_sort = true
        }
        M.setup_diagnostic(config_diagnostic)
        if vim.api.nvim_buf_get_option(bufnr, "modifiable") then
            vim.cmd("w")
        end
        global.virtual_text = "yes"
    else
        M.setup_diagnostic()
        if vim.api.nvim_buf_get_option(bufnr, "modifiable") then
            vim.cmd("w")
        end
        global.virtual_text = "no"
    end
end

return M
