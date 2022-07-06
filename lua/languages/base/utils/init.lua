local lspconfig = require("lspconfig")
local navic = require("nvim-navic")

local M = {}

M.setup_lsp = function(server_name, server_config)
    lspconfig[server_name].setup(server_config)
end

M.config_diagnostic = {
    virtual_text = false,
    update_in_insert = true,
    underline = true,
    severity_sort = true,
}

M.icons = {
    error = " ",
    warn = " ",
    hint = " ",
    info = " ",
}

M.setup_diagnostic = function(custom_config_diagnostic)
    local local_config_diagnostic
    if custom_config_diagnostic ~= nil then
        local_config_diagnostic = custom_config_diagnostic
    else
        local_config_diagnostic = M.config_diagnostic
    end
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
            vim.fn.sign_define("DiagnosticSignError", {
                texthl = "DiagnosticSignError",
                text = M.icons.error,
                numhl = "DiagnosticSignError",
            })
            vim.fn.sign_define("DiagnosticSignWarn", {
                texthl = "DiagnosticSignWarn",
                text = M.icons.warn,
                numhl = "DiagnosticSignWarn",
            })
            vim.fn.sign_define("DiagnosticSignHint", {
                texthl = "DiagnosticSignHint",
                text = M.icons.hint,
                numhl = "DiagnosticSignHint",
            })
            vim.fn.sign_define("DiagnosticSignInfo", {
                texthl = "DiagnosticSignInfo",
                text = M.icons.info,
                numhl = "DiagnosticSignInfo",
            })
            vim_diag.show(namespace, bufnr, diagnostics, local_config_diagnostic)
        end
    end
end

M.document_highlight = function(client, bufnr)
    if vim.fn.has("nvim-0.8") == 1 then
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
        else
            return
        end
    else
        if client.resolved_capabilities.document_highlight then
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
end

M.document_formatting = function(client, bufnr)
    -- vim.pretty_print(client.server_capabilities)
    if vim.fn.has("nvim-0.8") == 1 then
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                command = "lua vim.lsp.buf.format()",
                group = "LvimIDE",
            })
        end
    else
        if client.resolved_capabilities.document_formatting then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                command = "lua vim.lsp.buf.formatting_seq_sync()",
                group = "LvimIDE",
            })
        end
    end
end

M.get_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    }
    local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if status_ok then
        capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
    end
    return capabilities
end

M.set_winbar = function(client, bufnr)
    if vim.fn.has("nvim-0.8") == 1 then
        navic.attach(client, bufnr)
        vim.opt_local.winbar = "%{%v:lua.require'languages.base.utils.file_name'.get_file_name()%}  %{%v:lua.require'nvim-navic'.get_location()%}"
    end
end

return M
