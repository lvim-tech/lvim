local global = require("core.global")
local funcs = require("core.funcs")
local lspconfig = require("lspconfig")
local mason_registry = require("mason-registry")
local ui_config = require("lvim-ui-config.config")
local select = require("lvim-ui-config.select")
local icons = require("configs.base.ui.icons")

local M = {}

M.dependencies_ready = true
M.current_language = ""
M.packages_to_install = {}
M.lsp_to_start = {}
M.ordered_keys = {}

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local null_ls_builtins = {
    cpplint = diagnostics.cpplint,
    flake8 = diagnostics.flake8,
    golangci_lint = diagnostics.golangci_lint,
    rubocop = diagnostics.rubocop,
    vint = diagnostics.vint,
    yamllint = diagnostics.yamllint,
    black = formatting.black,
    cbfmt = formatting.cbfmt,
    prettierd = formatting.prettierd.with({
        filetypes = {
            "vue",
            "css",
            "scss",
            "less",
            "html",
            "yaml",
            "markdown",
            "markdown.mdx",
            "graphql",
            "handlebars",
        },
        env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("$HOME/.config/nvim/.configs/formatters/.prettierrc.json"),
        },
        options = {
            args = { "$FILENAME", "--no-progress" },
        },
    }),
    shfmt = formatting.shfmt,
    stylua = formatting.stylua,
    yamlfmt = formatting.yamlfmt,
}

M.install_all_packages = function()
    local file_types = require("languages.base.init").file_types
    local packages = {}
    local function has_value(val)
        for _, value in ipairs(packages) do
            if value == val then
                return true
            end
        end
        return false
    end
    for k, _ in pairs(file_types) do
        local file = require("languages.base.languages." .. k)
        if file.dependencies ~= nil then
            for _, dependency in pairs(file.dependencies) do
                if not has_value(dependency) then
                    table.insert(packages, dependency)
                end
            end
        end
    end
    M.packages_to_install = {}
    local packages_to_install = 0
    for i = 1, #packages do
        if not mason_registry.is_installed(packages[i]) then
            packages_to_install = packages_to_install + 1
            table.insert(M.packages_to_install, packages[i])
        end
    end
    if packages_to_install == 0 then
        local notify = require("lvim-ui-config.notify")
        notify.info("All packages are installed", {
            title = "LVIM IDE",
        })
    else
        vim.defer_fn(function()
            for i = 1, #M.packages_to_install do
                vim.cmd("MasonInstall " .. M.packages_to_install[i])
                M.check_proccess(M.packages_to_install[i])
            end
        end, 100)
        vim.defer_fn(function()
            if global.install_proccess then
                M.check_finish()
            end
        end, 100)
    end
end

M.lsp_start = function()
    vim.defer_fn(function()
        for i = 1, #M.lsp_to_start do
            lspconfig[M.lsp_to_start[i][1]].setup(M.lsp_to_start[i][2])
        end
    end, 3000)
end

M.check_finish = function()
    if next(M.packages_to_install) == nil then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
                vim.api.nvim_win_close(win, false)
            end
            vim.defer_fn(function()
                vim.defer_fn(function()
                    M.lsp_start()
                end, 2000)
                vim.defer_fn(function()
                    global.install_proccess = false
                    M.dependencies_ready = true
                end, 200)
            end, 100)
        end
    else
        vim.defer_fn(function()
            M.check_finish()
        end, 100)
    end
end

M.check_proccess = function(k)
    vim.defer_fn(function()
        if not mason_registry.is_installed(k) then
            vim.defer_fn(function()
                M.check_proccess(k)
            end, 100)
        else
            local index = {}
            vim.defer_fn(function()
                for key, v in pairs(M.packages_to_install) do
                    index[v] = key
                    if index[v] ~= nil then
                        null_ls.register({
                            null_ls_builtins[v],
                        })
                    end
                end
                M.packages_to_install[index[k]] = nil
            end, 3000)
        end
    end, 200)
end

M.setup_languages = function(packages_data)
    local function install_package()
        if next(M.packages_to_install) ~= nil then
            if global.lvim_packages == false then
                vim.defer_fn(function()
                    local opts = ui_config.select({
                        "Install packages for " .. M.current_language,
                        "Install packages for all languages",
                        "Don't ask me again",
                        "Cancel",
                    }, { prompt = "LVIM IDE need to install some packages" }, {})
                    select(opts, function(choice)
                        if choice == "Install packages for " .. M.current_language then
                            vim.defer_fn(function()
                                for i = 1, #M.packages_to_install do
                                    vim.cmd("MasonInstall " .. M.packages_to_install[i])
                                    M.check_proccess(M.packages_to_install[i])
                                end
                            end, 100)
                            vim.defer_fn(function()
                                if global.install_proccess then
                                    M.check_finish()
                                end
                            end, 100)
                        elseif choice == "Install packages for all languages" then
                            M.install_all_packages()
                        elseif choice == "Don't ask me again" then
                            local notify = require("lvim-ui-config.notify")
                            funcs.write_file(global.cache_path .. "/.lvim_packages", "")
                            notify.error(
                                "To enable ask again run command:\n:AskForPackagesFile\nand restart LVIM IDE",
                                {
                                    timeout = 10000,
                                    title = "LVIM IDE",
                                }
                            )
                        elseif choice == "Cancel" then
                            local notify = require("lvim-ui-config.notify")
                            notify.error("Need restart LVIM IDE to install packages for this filetype", {
                                timeout = 10000,
                                title = "LVIM IDE",
                            })
                        end
                    end)
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
            M.packages_to_install = {}
            M.lsp_to_start = {}
            M.ordered_keys = {}
            M.current_language = ""
            for k in pairs(packages) do
                table.insert(M.ordered_keys, k)
            end
            table.sort(M.ordered_keys)
            for i = 1, #M.ordered_keys do
                local k, v = M.ordered_keys[i], packages[M.ordered_keys[i]]
                if k == "language" then
                    M.current_language = v
                elseif k == "dependencies" then
                    for a = 1, #v do
                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            M.dependencies_ready = false
                            table.insert(M.packages_to_install, v[a])
                        else
                            if v[a] ~= nil then
                                null_ls.register({
                                    null_ls_builtins[v[a]],
                                })
                            end
                        end
                    end
                elseif k == "dap" then
                    for a = 1, #v do
                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            table.insert(M.packages_to_install, v[a])
                        end
                    end
                else
                    if not mason_registry.is_installed(k) then
                        global.install_proccess = true
                        table.insert(M.packages_to_install, k)
                        if v[1] ~= nil and v[2] ~= nil then
                            table.insert(M.lsp_to_start, { v[1], v[2] })
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

M.setup_diagnostic = function()
    vim.diagnostic.config(M.config_diagnostic)
    vim.api.nvim_create_user_command("LspVirtualTextToggle", function()
        local config = vim.diagnostic.config
        local vt = config().virtual_text
        config({
            virtual_text = not vt,
        })
    end, { desc = "LspVirtualTextToggle" })
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
    if client.server_capabilities.inlayHintProvider and _G.LVIM_SETTINGS.inlayhint == true then
        vim.lsp.inlay_hint(bufnr, true)
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
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end
    return capabilities
end

M.get_cpp_capabilities = function()
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
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end
    capabilities.offsetEncoding = "utf-16"
    return capabilities
end

M.keymaps = function(client, bufnr)
    vim.keymap.set("n", "gd", function()
        if client.server_capabilities.definitionProvider then
            vim.lsp.buf.definition()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspDefinition" })
    vim.keymap.set("n", "gD", function()
        if client.server_capabilities.declarationProvider then
            vim.lsp.buf.declaration()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspDeclaration" })
    vim.keymap.set("n", "gt", function()
        if client.server_capabilities.typeDefinitionProvider then
            vim.lsp.buf.type_definition()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspTypeDefinition" })
    vim.keymap.set("n", "gr", function()
        if client.server_capabilities.referencesProvider then
            vim.lsp.buf.references()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspReferences" })
    vim.keymap.set("n", "gi", function()
        if client.server_capabilities.implementationProvider then
            vim.lsp.buf.implementation()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspImplementation" })
    vim.keymap.set("n", "ge", function()
        if client.server_capabilities.renameProvider then
            vim.lsp.buf.rename()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspRename" })
    vim.keymap.set("n", "gf", function()
        if client.server_capabilities.formatProvider then
            vim.lsp.buf.format({ async = true })
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspFormat" })
    vim.keymap.set("v", "g;", function()
        if client.server_capabilities.formatProvider then
            local start_row, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
            local end_row, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
            vim.lsp.buf.format({
                range = {
                    ["start"] = { start_row, 0 },
                    ["end"] = { end_row, 0 },
                },
                async = true,
            })
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspRangeFormat" })
    vim.keymap.set("n", "ga", function()
        if client.server_capabilities.codeActionProvider then
            vim.lsp.buf.code_action()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspCodeAction" })
    vim.keymap.set("n", "gs", function()
        if client.server_capabilities.signatureHelpProvider then
            vim.lsp.buf.signature_help()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspSignatureHelp" })
    vim.keymap.set("n", "gL", function()
        if client.server_capabilities.codeLensProvider then
            vim.lsp.codelens.refresh()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspCodeLensRefresh" })
    vim.keymap.set("n", "gl", function()
        if client.server_capabilities.codeLensProvider then
            vim.lsp.codelens.run()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspCodeLensRun" })
    vim.keymap.set("n", "gh", function()
        if client.server_capabilities.hoverProvider then
            vim.lsp.buf.hover()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspHover" })
    vim.keymap.set("n", "K", function()
        if client.server_capabilities.hoverProvider then
            vim.lsp.buf.hover()
        end
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspHover" })
    vim.keymap.set("n", "gt", function()
        vim.cmd("LspVirtualTextToggle")
    end, { noremap = true, silent = true, buffer = bufnr, desc = "LspVirtualTextToggle" })
end

M.dap_local = function()
    local notify = require("lvim-ui-config.notify")
    local config_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }
    if not pcall(require, "dap") then
        notify.error("Not found DAP plugin!", {
            title = "LVIM IDE",
        })
        return
    end
    local project_config = ""
    for _, p in ipairs(config_paths) do
        local f = io.open(p)
        if f ~= nil then
            f:close()
            project_config = p
            break
        end
    end
    if project_config == "" then
        notify.info(
            "You can define DAP configuration in './.nvim-dap/nvim-dap.lua', './.nvim-dap.lua', './.nvim/nvim-dap.lua'",
            {
                title = "LVIM IDE",
            }
        )
        return
    end
    notify.info("Found DAP configuration at " .. project_config, {
        title = "LVIM IDE",
    })
    require("dap").adapters = (function()
        return {}
    end)()
    require("dap").configurations = (function()
        return {}
    end)()
    vim.cmd(":luafile " .. project_config)
end
return M
