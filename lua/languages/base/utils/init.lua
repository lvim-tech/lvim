local global = require("core.global")
local funcs = require("core.funcs")
local lspconfig = require("lspconfig")
local mason_registry = require("mason-registry")
local select = require("configs.base.ui.select")

local M = {}

M.dependencies_ready = true
M.current_language = ""

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

M.null_ls = {
    cpplint = diagnostics.cpplint,
    flake8 = diagnostics.flake8,
    golangci_lint = diagnostics.golangci_lint,
    luacheck = diagnostics.luacheck,
    rubocop = diagnostics.rubocop,
    shellcheck = diagnostics.shellcheck,
    vint = diagnostics.vint,
    yamllint = diagnostics.yamllint,
    black = formatting.black,
    cbfmt = formatting.cbfmt,
    prettierd = formatting.prettierd,
    shfmt = formatting.shfmt,
    stylua = formatting.stylua,
}

M.setup_languages = function(packages_data)
    local packages_to_install, lsp_to_start, ordered_keys

    local function lsp_start()
        vim.defer_fn(function()
            for i = 1, #lsp_to_start do
                lspconfig[lsp_to_start[i][1]].setup(lsp_to_start[i][2])
            end
        end, 3000)
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
                    end, 2000)
                    vim.defer_fn(function()
                        global.install_proccess = false
                        M.dependencies_ready = true
                    end, 200)
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
                end, 100)
            else
                local index = {}
                vim.defer_fn(function()
                    for key, v in pairs(packages_to_install) do
                        index[v] = key
                        if index[v] ~= nil then
                            null_ls.register({
                                M.null_ls[v],
                            })
                        end
                    end
                    packages_to_install[index[k]] = nil
                end, 3000)
            end
        end, 200)
    end

    local function install_package()
        if next(packages_to_install) ~= nil then
            if global.lvim_packages == false then
                vim.defer_fn(function()
                    select({
                        "Install packages for " .. M.current_language,
                        "Don't ask me again",
                        "Cancel",
                    }, { prompt = "LVIM IDE need to install some packages" }, function(choice)
                        if choice == "Install packages for " .. M.current_language then
                            vim.defer_fn(function()
                                for i = 1, #packages_to_install do
                                    vim.cmd("MasonInstall " .. packages_to_install[i])
                                    check_proccess(packages_to_install[i])
                                end
                            end, 100)
                            vim.defer_fn(function()
                                if global.install_proccess then
                                    check_finish()
                                end
                            end, 100)
                        elseif choice == "Don't ask me again" then
                            funcs.write_file(global.cache_path .. "/.lvim_packages", "")
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
                    end, "editor")
                end, 100)
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
            M.current_language = ""
            for k in pairs(packages) do
                table.insert(ordered_keys, k)
            end
            table.sort(ordered_keys)
            for i = 1, #ordered_keys do
                local k, v = ordered_keys[i], packages[ordered_keys[i]]
                if k == "language" then
                    M.current_language = v
                elseif k == "dependencies" then
                    for a = 1, #v do
                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            M.dependencies_ready = false
                            table.insert(packages_to_install, v[a])
                        else
                            if v[a] ~= nil then
                                null_ls.register({
                                    -- M.null_ls[v[a]],
                                })
                            end
                        end
                    end
                elseif k == "dap" then
                    for a = 1, #v do
                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            table.insert(packages_to_install, v[a])
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
                vim.defer_fn(function()
                    install_package()
                end, 3000)
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

M.setup_diagnostic = function()
    vim.diagnostic.config(M.config_diagnostic)
    vim.fn.sign_define("DiagnosticSignError", {
        text = M.icons.error,
        texthl = "DiagnosticError",
        numhl = "DiagnosticError",
    })
    vim.fn.sign_define("DiagnosticSignWarn", {
        text = M.icons.warn,
        texthl = "DiagnosticWarn",
        numhl = "DiagnosticWarn",
    })
    vim.fn.sign_define("DiagnosticSignHint", {
        text = M.icons.hint,
        texthl = "DiagnosticHint",
        numhl = "DiagnosticHint",
    })
    vim.fn.sign_define("DiagnosticSignInfo", {
        text = M.icons.info,
        texthl = "DiagnosticInfo",
        numhl = "DiagnosticInfo",
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

M.document_formatting = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "lua vim.lsp.buf.format()",
            group = "LvimIDE",
        })
    end
end

M.get_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.offsetEncoding = { "utf-16" }
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
