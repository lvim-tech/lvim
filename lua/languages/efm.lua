local M = {}
local setup_diagnostics = require("languages.utils.setup_diagnostics")

local function find_efm_executable()
    local mason_path = vim.fn.stdpath("data") .. "/mason"
    local possible_paths = {
        mason_path .. "/bin/efm-langserver",
        mason_path .. "/packages/efm-langserver/efm-langserver",
        vim.fn.exepath("efm-langserver"),
    }
    for _, path in ipairs(possible_paths) do
        if vim.fn.executable(path) == 1 then
            return path
        end
    end
    vim.notify("efm-langserver executable not found!", vim.log.levels.ERROR)
    return nil
end

M.get_config_with_params = function(filetypes, settings)
    local efm_bin = find_efm_executable()
    if not efm_bin then
        return nil
    end
    if not filetypes or #filetypes == 0 then
        return nil
    end
    local language_count = 0
    if settings and settings.languages then
        for _, _ in pairs(settings.languages) do
            language_count = language_count + 1
        end
    end
    if language_count == 0 then
        return nil
    end
    local config = {
        name = "efm",
        cmd = { efm_bin },
        filetypes = filetypes,
        single_file_support = true,
        settings = settings,
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
        },
        on_attach = function(client, bufnr)
            if _G.global then
                _G.global._efm_client_id = client.id
            end
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
        end,
    }
    return config
end

M.get_config = function()
    local efm_bin = find_efm_executable()
    if not efm_bin then
        return nil
    end
    local g_efm = nil
    if global and global.efm then
        g_efm = global.efm
    end
    if not g_efm and _G.global and _G.global.efm then
        g_efm = _G.global.efm
    end
    if not g_efm then
        return nil
    end
    if not g_efm.filetypes or #g_efm.filetypes == 0 then
        return nil
    end
    local language_count = 0
    if g_efm.settings and g_efm.settings.languages then
        for _, _ in pairs(g_efm.settings.languages) do
            language_count = language_count + 1
        end
    end
    if language_count == 0 then
        return nil
    end
    local config = {
        name = "efm",
        cmd = { efm_bin },
        filetypes = g_efm.filetypes,
        single_file_support = true,
        settings = g_efm.settings,
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
        },
        on_attach = function(client, bufnr)
            if _G.global then
                _G.global._efm_client_id = client.id
            end
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
        end,
    }
    return config
end

M.get_active_client = function()
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == "efm" then
            return client
        end
    end
    return nil
end

M.start = function(force, direct_filetypes, direct_settings)
    local config
    if direct_filetypes and direct_settings then
        config = M.get_config_with_params(direct_filetypes, direct_settings)
        if not _G.global then
            _G.global = {}
        end
        if not _G.global.efm then
            _G.global.efm = {}
        end
        _G.global.efm.filetypes = direct_filetypes
        _G.global.efm.settings = direct_settings
    else
        config = M.get_config()
    end
    if not config then
        return nil
    end
    local existing_client = M.get_active_client()
    if existing_client and not force then
        return existing_client.id
    end
    if existing_client then
        existing_client:stop()
        vim.wait(500)
    end
    local client_id
    local success, result = pcall(function()
        client_id = vim.lsp.start(config)
        return client_id
    end)
    if success and client_id then
        vim.defer_fn(function()
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
                    local ft = vim.bo[bufnr].filetype
                    if ft and ft ~= "" and vim.tbl_contains(config.filetypes, ft) then
                        vim.lsp.buf_attach_client(bufnr, client_id)
                    end
                end
            end
        end, 500)
        return client_id
    else
        return nil
    end
end

vim.api.nvim_create_user_command("EFMStatus", function()
    local efm_client = M.get_active_client()
    if efm_client then
        local filetypes = {}
        if global and global.efm and global.efm.filetypes then
            filetypes = global.efm.filetypes
        elseif _G.global and _G.global.efm and _G.global.efm.filetypes then
            filetypes = _G.global.efm.filetypes
        end
        vim.notify("Supported filetypes: " .. table.concat(filetypes, ", "))
        local buffers = vim.lsp.get_buffers_by_client_id(efm_client.id)
        vim.notify("Attached to " .. #buffers .. " buffer(s)")
    else
        vim.notify("EFM is NOT running", vim.log.levels.WARN)
    end
end, {})

vim.api.nvim_create_user_command("EFMRestart", function()
    M.start(true)
end, {})

vim.api.nvim_create_user_command("FormatCurrentFile", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    vim.notify("Formatting " .. ft .. " file...", vim.log.levels.INFO)
    vim.lsp.buf.format({
        timeout_ms = 5000,
        bufnr = bufnr,
    })
end, {})

vim.defer_fn(function()
    local filetypes = {}
    local settings = {}
    if global and global.efm then
        if global.efm.filetypes and #global.efm.filetypes > 0 then
            filetypes = global.efm.filetypes
        end
        if global.efm.settings then
            settings = global.efm.settings
        end
    elseif _G.global and _G.global.efm then
        if _G.global.efm.filetypes and #_G.global.efm.filetypes > 0 then
            filetypes = _G.global.efm.filetypes
        end
        if _G.global.efm.settings then
            settings = _G.global.efm.settings
        end
    end
    local has_languages = false
    if settings and settings.languages then
        for _, _ in pairs(settings.languages) do
            has_languages = true
            break
        end
    end
    if #filetypes > 0 and has_languages then
        M.start(false, filetypes, settings)
    end
end, 1000)

return M
