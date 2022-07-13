local global = require("core.global")
local funcs = require("core.funcs")
local lspconfig = require("lspconfig")
local mason_registry = require("mason-registry")
local select = require("languages.base.utils.select")

local M = {}

M.setup_languages = function(packages_data)
    local packages_to_install, lsp_to_start, ordered_keys

    local function lsp_start()
        for i = 1, #lsp_to_start do
            lspconfig[lsp_to_start[i][1]].setup(lsp_to_start[i][2])
        end
    end

    local function check_finish()
        if next(packages_to_install) == nil then
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local config = vim.api.nvim_win_get_config(win)
                if config.relative ~= "" then
                    vim.api.nvim_win_close(win, false)
                end
                vim.defer_fn(function()
                    vim.defer_fn(function()
                        lsp_start()
                    end, 1000)
                    vim.defer_fn(function()
                        global.install_proccess = false
                        global.diagnosticls_ready = true
                    end, 2000)
                end, 100)
            end
        else
            vim.defer_fn(function()
                check_finish()
            end, 100)
        end
    end

    local function check_proccess(k)
        vim.defer_fn(function()
            if not mason_registry.is_installed(k) then
                vim.defer_fn(function()
                    check_proccess(k)
                end, 1000)
            else
                local index = {}
                for key, v in pairs(packages_to_install) do
                    index[v] = key
                end
                packages_to_install[index[k]] = nil
            end
        end, 2000)
    end

    local function install_package()
        if next(packages_to_install) ~= nil then
            if global.lvim_packages == false then
                vim.defer_fn(function()
                    select({
                        "Install for current buffer in stack",
                        "Don't ask again",
                        "Cancel",
                    }, { prompt = "LVIM IDE need to install some packages" }, function(choice)
                        if choice == "Install for current buffer in stack" then
                            vim.defer_fn(function()
                                for i = 1, #packages_to_install do
                                    vim.cmd("MasonInstall " .. packages_to_install[i])
                                    check_proccess(packages_to_install[i])
                                end
                            end, 1000)
                            vim.defer_fn(function()
                                if global.install_proccess then
                                    check_finish()
                                end
                            end, 2000)
                        elseif choice == "Don't ask again" then
                            funcs.write_file(global.cache_path .. ".lvim_packages", "")
                            vim.notify(
                                "To enable ask again run command:\n:AskForPackagesFile\nand restart LVIM IDE",
                                "error",
                                {
                                    timeout = 10000,
                                    title = "LVIM IDE",
                                }
                            )
                        elseif choice == "Cancel" then
                            vim.notify("Need restart LVIM IDE to install packages for this filetype", "error", {
                                timeout = 10000,
                                title = "LVIM IDE",
                            })
                        end
                    end)
                end, 1000)
            end
        end
    end

    local function init(packages)
        if global.install_proccess then
            vim.defer_fn(function()
                init(packages)
            end, 1000)
        else
            packages_to_install = {}
            lsp_to_start = {}
            ordered_keys = {}
            for k in pairs(packages) do
                table.insert(ordered_keys, k)
            end
            table.sort(ordered_keys)
            for i = 1, #ordered_keys do
                local k, v = ordered_keys[i], packages[ordered_keys[i]]
                if k == "dependencies" then
                    for a = 1, #v do
                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            global.diagnosticls_ready = false
                            table.insert(packages_to_install, v[a])
                        end
                    end
                elseif k == "dap" then
                    for a = 1, #v do
                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            table.insert(packages_to_install, v[a])
                        end
                    end
                elseif k == "diagnostic-languageserver" then
                    if not mason_registry.is_installed(k) then
                        global.install_proccess = true
                        table.insert(packages_to_install, k)
                        table.insert(lsp_to_start, { v[1], v[2] })
                    else
                        if global.diagnosticls_ready then
                            lspconfig[v[1]].setup(v[2])
                            vim.cmd("LspStart " .. v[1])
                        else
                            global.install_proccess = true
                            table.insert(lsp_to_start, { v[1], v[2] })
                        end
                    end
                else
                    if not mason_registry.is_installed(k) then
                        global.install_proccess = true
                        table.insert(packages_to_install, k)
                        if v[1] ~= nil and v[2] ~= nil then
                            table.insert(lsp_to_start, { v[1], v[2] })
                        end
                    else
                        if v[1] ~= nil and v[2] ~= nil then
                            lspconfig[v[1]].setup(v[2])
                            vim.cmd("LspStart " .. v[1])
                        end
                    end
                end
            end
            vim.schedule(function()
                install_package()
            end)
        end
    end

    init(packages_data)
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

return M
