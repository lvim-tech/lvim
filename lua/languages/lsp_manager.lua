--[[
  LSP Utilities Module
  Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-04 13:37:17
  Current User's Login: lvim-tech
]]--

local efm = require("languages.efm")
local M = {}

local function init_globals()
    if _G.lsp_buffer_status == nil then
        _G.lsp_buffer_status = {}
    end
    if _G.lsp_activation_locks == nil then
        _G.lsp_activation_locks = {}
    end
    if _G.active_lsp_clients == nil then
        _G.active_lsp_clients = {}
    end
    if _G.lsp_installation_in_progress == nil then
        _G.lsp_installation_in_progress = false
    end
end

init_globals()

M.is_lsp_compatible_with_ft = function(server_name, ft)
    if not ft or ft == "" then
        return false
    end
    if server_name == "efm" and _G.global and _G.global.efm and _G.global.efm.filetypes then
        return vim.tbl_contains(_G.global.efm.filetypes, ft)
    end
    if not _G.file_types or not _G.file_types[server_name] then
        return false
    end
    return vim.tbl_contains(_G.file_types[server_name], ft)
end

M.get_compatible_lsp_for_ft = function(ft)
    if not ft or ft == "" then
        return {}
    end
    local compatible_servers = {}
    for server_name, filetypes in pairs(_G.file_types or {}) do
        if vim.tbl_contains(filetypes, ft) then
            table.insert(compatible_servers, server_name)
        end
    end
    if _G.global and _G.global.efm and _G.global.efm.filetypes and vim.tbl_contains(_G.global.efm.filetypes, ft) then
        table.insert(compatible_servers, "efm")
    end
    return compatible_servers
end

local function is_client_attached_to_buffer(client_id, bufnr)
    if not client_id or not bufnr then
        return false
    end
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
        return false
    end
    local attached_buffers = {}
    pcall(function()
        for _, buf_id in ipairs(vim.lsp.get_buffers_by_client_id(client_id) or {}) do
            attached_buffers[buf_id] = true
        end
    end)
    return attached_buffers[bufnr] or false
end

M.safe_detach_client = function(bufnr, client_id)
    if not bufnr or bufnr <= 0 or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
        return false
    end
    if is_client_attached_to_buffer(client_id, bufnr) then
        pcall(vim.lsp.buf_detach_client, bufnr, client_id)
        return true
    end
    return false
end

M.deep_copy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deep_copy(orig_key)] = M.deep_copy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

M.is_lsp_server_running = function(server_name)
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == server_name then
            return true
        end
    end
    return false
end

M.lsp_enable = function(server_name, force)
    if _G.lsp_installation_in_progress then
        return nil
    end
    if server_name == "efm" then
        if M.is_lsp_server_running("efm") and not force then
            return true
        end
        local efm_id = efm.start(force)
        if efm_id then
            return efm_id
        else
            return nil
        end
    end
    if _G.lsp_activation_locks[server_name] and not force then
        return nil
    end
    _G.lsp_activation_locks[server_name] = true
    if not force then
        for _, client in ipairs(vim.lsp.get_clients()) do
            if client.name == server_name then
                _G.lsp_activation_locks[server_name] = false
                return client.id
            end
        end
    end
    local compatible_buffers = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
            local ft = vim.bo[bufnr].filetype
            if ft and ft ~= "" and M.is_lsp_compatible_with_ft(server_name, ft) then
                table.insert(compatible_buffers, bufnr)
            end
        end
    end
    if #compatible_buffers == 0 then
        _G.lsp_activation_locks[server_name] = false
        return nil
    end
    local config
    local global_config_name = server_name .. "_lsp_config"
    if _G[global_config_name] then
        config = _G[global_config_name]
    else
        local success, result
        success, result = pcall(require, "languages.user.lsp." .. server_name)
        if not success then
            success, result = pcall(require, "languages.base.lsp." .. server_name)
        end
        if success and type(result) == "table" then
            config = result
        else
            _G.lsp_activation_locks[server_name] = false
            return nil
        end
    end
    if not config.filetypes and _G.file_types and _G.file_types[server_name] then
        config.filetypes = _G.file_types[server_name]
    end
    local original_on_attach = config.on_attach
    config.on_attach = function(client, bufnr)
        if not bufnr or bufnr <= 0 or not vim.api.nvim_buf_is_valid(bufnr) then
            return
        end
        local ft = vim.bo[bufnr].filetype
        if not ft or ft == "" or not M.is_lsp_compatible_with_ft(client.name, ft) then
            vim.schedule(function()
                M.safe_detach_client(bufnr, client.id)
            end)
            return
        end
        if not _G.lsp_buffer_status[bufnr] then
            _G.lsp_buffer_status[bufnr] = {}
        end
        _G.lsp_buffer_status[bufnr][client.name] = true
        if original_on_attach then
            pcall(original_on_attach, client, bufnr)
        end
        if
            client.name ~= "efm"
            and _G.global
            and _G.global.efm
            and _G.global.efm.filetypes
            and vim.tbl_contains(_G.global.efm.filetypes, ft)
        then
            vim.defer_fn(function()
                M.lsp_enable("efm", false)
            end, 300)
        end
    end
    local primary_bufnr = compatible_buffers[1]
    local client_id
    local success = pcall(function()
        client_id = vim.lsp.start(config, {
            bufnr = primary_bufnr,
            reuse_client = function(client)
                return client.name == server_name
            end,
        })
    end)
    if success and client_id then
        _G.active_lsp_clients[server_name] = client_id
        if #compatible_buffers > 1 then
            for i = 2, #compatible_buffers do
                local bufnr = compatible_buffers[i]
                if vim.api.nvim_buf_is_valid(bufnr) then
                    pcall(vim.lsp.buf_attach_client, bufnr, client_id)
                    if not _G.lsp_buffer_status[bufnr] then
                        _G.lsp_buffer_status[bufnr] = {}
                    end
                    _G.lsp_buffer_status[bufnr][server_name] = true
                end
            end
        end
        _G.lsp_activation_locks[server_name] = false
        return client_id
    else
        for _, client in ipairs(vim.lsp.get_clients()) do
            if client.name == server_name then
                _G.active_lsp_clients[server_name] = client.id
                _G.lsp_activation_locks[server_name] = false
                return client.id
            end
        end
    end
    _G.lsp_activation_locks[server_name] = false
    return nil
end

M.activate_lsp_for_buffer = function(bufnr)
    if not bufnr or bufnr <= 0 or not vim.api.nvim_buf_is_valid(bufnr) or _G.lsp_installation_in_progress then
        return
    end
    local ft = vim.bo[bufnr].filetype
    if not ft or ft == "" then
        return
    end
    local compatible_servers = M.get_compatible_lsp_for_ft(ft)
    if not _G.lsp_buffer_status[bufnr] then
        _G.lsp_buffer_status[bufnr] = {}
    end
    for _, server_name in ipairs(compatible_servers) do
        _G.lsp_buffer_status[bufnr][server_name] = true
        local already_attached = false
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if client.name == server_name then
                already_attached = true
                break
            end
        end
        if not already_attached then
            local client_id = M.lsp_enable(server_name, false)
            if client_id and vim.api.nvim_buf_is_valid(bufnr) then
                pcall(vim.lsp.buf_attach_client, bufnr, client_id)
            end
        end
    end
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if not vim.tbl_contains(compatible_servers, client.name) then
            M.safe_detach_client(bufnr, client.id)
        end
    end
end

M.setup_efm = function(filetypes, configs)
    init_globals()
    local ft_list = type(filetypes) == "string" and { filetypes } or filetypes
    local need_restart = false
    if not _G.global.efm then
        _G.global.efm = {
            filetypes = {},
            settings = { languages = {} },
        }
    end
    if not _G.global.efm.filetypes then
        _G.global.efm.filetypes = {}
    end
    if not _G.global.efm.settings then
        _G.global.efm.settings = { languages = {} }
    end
    if not _G.global.efm.settings.languages then
        _G.global.efm.settings.languages = {}
    end
    for _, config in ipairs(configs) do
        local server_name = config.server_name or config.fPrefix
        if server_name then
            for _, ft in ipairs(ft_list) do
                if not vim.tbl_contains(_G.global.efm.filetypes, ft) then
                    table.insert(_G.global.efm.filetypes, ft)
                    need_restart = true
                end
                if not _G.global.efm.settings.languages[ft] then
                    _G.global.efm.settings.languages[ft] = {}
                end
                local config_copy = M.deep_copy(config)
                table.insert(_G.global.efm.settings.languages[ft], config_copy)
            end
        end
    end
    local efm_id = efm.start(need_restart, _G.global.efm.filetypes, _G.global.efm.settings)
    return efm_id ~= nil
end

M.start_language_server = function(server_name, force)
    if _G.lsp_installation_in_progress then
        return nil
    end
    local client_id = M.lsp_enable(server_name, force)
    if client_id and server_name ~= "efm" then
        local cmd_name = "Format" .. server_name:gsub("^%l", string.upper)
        vim.api.nvim_create_user_command(cmd_name, function()
            pcall(vim.lsp.buf.format, {
                timeout_ms = 5000,
                filter = function(client)
                    return client.name == "efm"
                end,
            })
        end, { desc = "Format " .. server_name .. " file with EFM" })
        vim.defer_fn(function()
            local need_efm = false
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                local ft = vim.bo[bufnr].filetype
                if
                    ft
                    and ft ~= ""
                    and _G.global
                    and _G.global.efm
                    and _G.global.efm.filetypes
                    and vim.tbl_contains(_G.global.efm.filetypes, ft)
                then
                    need_efm = true
                    break
                end
            end
            if need_efm then
                M.lsp_enable("efm", false)
            end
        end, 200)
    end
    return client_id
end

M.set_installation_status = function(status)
    _G.lsp_installation_in_progress = status
    if not status then
        vim.schedule(function()
            M.ensure_lsp_for_all_buffers()
        end)
    end
end

local function setup_diagnostic_filter()
    local original_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
    vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if not client then
            return original_publish_diagnostics(err, result, ctx, config)
        end
        local uri = result.uri
        local bufnr = vim.uri_to_bufnr(uri)
        local filetype = vim.bo[bufnr].filetype
        if not M.is_lsp_compatible_with_ft(client.name, filetype) then
            return
        end
        return original_publish_diagnostics(err, result, ctx, config)
    end
end

M.ensure_lsp_for_all_buffers = function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
            M.activate_lsp_for_buffer(bufnr)
        end
    end
    return true
end

M.setup_session_lsp_autoload = function()
    init_globals()
    local group = vim.api.nvim_create_augroup("LvimSessionLSPLoad", { clear = true })
    vim.api.nvim_create_autocmd({ "SessionLoadPost" }, {
        group = group,
        callback = function()
            _G.lsp_activation_locks = {}
            M.ensure_lsp_for_all_buffers()
        end,
    })
    vim.api.nvim_create_autocmd({ "VimEnter" }, {
        group = group,
        once = true,
        callback = function()
            vim.defer_fn(function()
                _G.lsp_activation_locks = {}
                M.ensure_lsp_for_all_buffers()
            end, 500)
        end,
    })
    vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "BufAdd", "BufNew" }, {
        group = group,
        callback = function(args)
            local bufnr = args.buf
            if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
                        M.activate_lsp_for_buffer(bufnr)
                    end
                end, 100)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "LspAttach" }, {
        group = group,
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            local bufnr = args.buf
            if not client or not bufnr or bufnr <= 0 or not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end
            local ft = vim.bo[bufnr].filetype
            if not ft or ft == "" or not M.is_lsp_compatible_with_ft(client.name, ft) then
                vim.schedule(function()
                    M.safe_detach_client(bufnr, client.id)
                end)
                return
            end
            if not _G.lsp_buffer_status[bufnr] then
                _G.lsp_buffer_status[bufnr] = {}
            end
            _G.lsp_buffer_status[bufnr][client.name] = true
        end,
    })
    setup_diagnostic_filter()
end

vim.api.nvim_create_user_command("LvimEFMStart", function()
    local efm_id = efm.start(true)
    if efm_id then
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(bufnr) then
                local ft = vim.bo[bufnr].filetype
                if
                    ft
                    and ft ~= ""
                    and _G.global
                    and _G.global.efm
                    and _G.global.efm.filetypes
                    and vim.tbl_contains(_G.global.efm.filetypes, ft)
                then
                    vim.lsp.buf_attach_client(bufnr, efm_id)
                end
            end
        end
    else
        print("Failed to start EFM!")
        if _G.global and _G.global.efm then
            print("EFM filetypes: " .. vim.inspect(_G.global.efm.filetypes or {}))
            if _G.global.efm.settings and _G.global.efm.settings.languages then
                print("EFM languages: " .. vim.inspect(vim.tbl_keys(_G.global.efm.settings.languages)))
            else
                print("EFM settings not properly initialized!")
            end
        else
            print("_G.global.efm not available!")
        end
    end
end, {})

return M
