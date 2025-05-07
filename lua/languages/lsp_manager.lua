local uv = vim.loop

_G.lsp_clients_by_root = _G.lsp_clients_by_root or {}
_G.lsp_disabled_servers = _G.lsp_disabled_servers or {}
_G.lsp_disabled_for_buffer = _G.lsp_disabled_for_buffer or {}
_G.efm_configs = _G.efm_configs or {}

local M = {}

local function root_pattern(...)
    local markers = { ... }
    return function(startpath)
        if not startpath or #startpath == 0 then
            return nil
        end
        local path = uv.fs_realpath(startpath) or startpath
        local stat = uv.fs_stat(path)
        if stat and stat.type == "file" then
            path = vim.fn.fnamemodify(path, ":h")
        end
        while path and #path > 0 do
            for _, marker in ipairs(markers) do
                if uv.fs_stat(path .. "/" .. marker) then
                    return path
                end
            end
            local parent = vim.fn.fnamemodify(path, ":h")
            if parent == path then
                break
            end
            path = parent
        end
        return nil
    end
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

M.is_server_disabled_globally = function(server_name)
    return _G.lsp_disabled_servers[server_name] == true
end

M.is_server_disabled_for_buffer = function(server_name, bufnr)
    return _G.lsp_disabled_for_buffer[bufnr] and _G.lsp_disabled_for_buffer[bufnr][server_name] == true
end

M.is_lsp_compatible_with_ft = function(server_name, ft)
    if not ft or ft == "" then
        return false
    end
    if server_name == "efm" and _G.efm_configs and _G.efm_configs[ft] then
        return true
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
    if
        (_G.global and _G.global.efm and _G.global.efm.filetypes and vim.tbl_contains(_G.global.efm.filetypes, ft))
        or (_G.efm_configs and _G.efm_configs[ft])
    then
        table.insert(compatible_servers, "efm")
    end
    return compatible_servers
end

M.ensure_lsp_for_buffer = function(server_name, bufnr)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return nil
    end
    if M.is_server_disabled_globally(server_name) or M.is_server_disabled_for_buffer(server_name, bufnr) then
        return nil
    end
    local ft = vim.bo[bufnr].filetype
    if not M.is_lsp_compatible_with_ft(server_name, ft) then
        return nil
    end
    local ok, mod
    if server_name == "efm" then
        ok, mod = pcall(require, "languages.user.lsp.efm")
        if not ok or type(mod) ~= "table" or not mod.config then
            ok, mod = pcall(require, "languages.base.lsp.efm")
            if not ok or type(mod) ~= "table" or not mod.config then
                return nil
            end
        end
    else
        ok, mod = pcall(require, "languages.user.lsp." .. server_name)
        if not ok or type(mod) ~= "table" or not mod.config then
            ok, mod = pcall(require, "languages.base.lsp." .. server_name)
            if not ok or type(mod) ~= "table" or not mod.config then
                return nil
            end
        end
    end
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local patterns = mod.root_patterns or { ".git" }
    local finder = root_pattern(unpack(patterns))
    local root_dir = finder(fname) or vim.loop.cwd()
    _G.lsp_clients_by_root[server_name] = _G.lsp_clients_by_root[server_name] or {}
    local client_id = _G.lsp_clients_by_root[server_name][root_dir]
    if client_id then
        local client = vim.lsp.get_client_by_id(client_id)
        if client then
            if not is_client_attached_to_buffer(client_id, bufnr) then
                vim.lsp.buf_attach_client(bufnr, client_id)
                if type(mod.config) == "table" and type(mod.config.on_attach) == "function" then
                    pcall(mod.config.on_attach, client, bufnr)
                end
            end
            return client_id
        end
    end
    local config = (type(mod.config) == "function") and mod.config() or vim.deepcopy(mod.config)
    if not config then
        return nil
    end
    config.root_dir = root_dir
    local new_client_id
    new_client_id = vim.lsp.start({
        name = config.name or server_name,
        cmd = config.cmd,
        root_dir = config.root_dir,
        settings = config.settings,
        init_options = config.init_options,
        capabilities = config.capabilities,
        on_attach = function(client, attached_bufnr)
            if attached_bufnr == bufnr and config.on_attach then
                pcall(config.on_attach, client, attached_bufnr)
            end
        end,
    }, {
        bufnr = bufnr,
    })
    -- INFO: old - need check nil
    -- if new_client_id then
    --     _G.lsp_clients_by_root[server_name][root_dir] = new_client_id
    --     return new_client_id
    -- end
    if new_client_id then
        if _G.lsp_clients_by_root == nil then
            _G.lsp_clients_by_root = {}
        end
        if _G.lsp_clients_by_root[server_name] == nil then
            _G.lsp_clients_by_root[server_name] = {}
        end
        if root_dir ~= nil then
            _G.lsp_clients_by_root[server_name][root_dir] = new_client_id
        else
            _G.lsp_clients_by_root[server_name]["default"] = new_client_id
        end
        return new_client_id
    end
    return nil
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
        pcall(function()
            vim.lsp.buf.clear_references()
        end)
        pcall(vim.lsp.buf_detach_client, bufnr, client_id)
        return true
    end
    return false
end

M.disable_lsp_server_globally = function(server_name)
    _G.lsp_disabled_servers[server_name] = true
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == server_name then
            for _, bufnr in ipairs(vim.lsp.get_buffers_by_client_id(client.id) or {}) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                    M.safe_detach_client(bufnr, client.id)
                end
            end
            vim.lsp.stop_client(client.id, true)
        end
    end
    return true
end

M.disable_lsp_server_for_buffer = function(server_name, bufnr)
    if not _G.lsp_disabled_for_buffer[bufnr] then
        _G.lsp_disabled_for_buffer[bufnr] = {}
    end
    _G.lsp_disabled_for_buffer[bufnr][server_name] = true
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client.name == server_name then
            M.safe_detach_client(bufnr, client.id)
            break
        end
    end
    return true
end

M.enable_lsp_server_globally = function(server_name)
    _G.lsp_disabled_servers[server_name] = nil
    return true
end

M.enable_lsp_server_for_buffer = function(server_name, bufnr)
    if _G.lsp_disabled_for_buffer[bufnr] then
        _G.lsp_disabled_for_buffer[bufnr][server_name] = nil
    end
    if M.is_server_disabled_globally(server_name) then
        return false
    end
    local ft = vim.bo[bufnr].filetype
    if ft and ft ~= "" and M.is_lsp_compatible_with_ft(server_name, ft) then
        local already_attached = false
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if client.name == server_name then
                already_attached = true
                break
            end
        end
        if not already_attached then
            local client_id
            for _, client in ipairs(vim.lsp.get_clients()) do
                if client.name == server_name then
                    client_id = client.id
                    break
                end
            end
            if client_id then
                pcall(vim.lsp.buf_attach_client, bufnr, client_id)
            else
                client_id = M.ensure_lsp_for_buffer(server_name, bufnr)
            end
        end
    end
    return true
end

M.start_language_server = function(server_name, force)
    if _G.lsp_installation_in_progress then
        return nil
    end
    if not force and M.is_server_disabled_globally(server_name) then
        return nil
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    if not force and ft ~= "" and not M.is_lsp_compatible_with_ft(server_name, ft) then
        local found_compatible_buffer = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) then
                local buf_ft = vim.bo[buf].filetype
                if buf_ft ~= "" and M.is_lsp_compatible_with_ft(server_name, buf_ft) then
                    bufnr = buf
                    found_compatible_buffer = true
                    break
                end
            end
        end
        if not found_compatible_buffer and not force then
            return nil
        end
    end
    local client_id = M.ensure_lsp_for_buffer(server_name, bufnr)
    if force and client_id then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if buf ~= bufnr and vim.api.nvim_buf_is_valid(buf) then
                local buf_ft = vim.bo[buf].filetype
                if buf_ft ~= "" and M.is_lsp_compatible_with_ft(server_name, buf_ft) then
                    if not M.is_server_disabled_for_buffer(server_name, buf) then
                        vim.lsp.buf_attach_client(buf, client_id)
                    end
                end
            end
        end
    end
    return client_id
end

M.lsp_enable = function(server_name, _)
    local bufnr = vim.api.nvim_get_current_buf()
    return M.ensure_lsp_for_buffer(server_name, bufnr)
end

M.stop_servers_for_old_project = function()
    local current_dir = vim.fn.getcwd()
    local clients = vim.lsp.get_clients()
    local stopped_count = 0
    for _, client in ipairs(clients) do
        if client.config and client.config.root_dir then
            local client_root
            if type(client.config.root_dir) == "function" then
                goto continue
            else
                client_root = tostring(client.config.root_dir)
            end
            if client_root ~= current_dir and not vim.startswith(client_root, current_dir) then
                vim.schedule(function()
                    vim.lsp.stop_client(client.id, true)
                end)
                stopped_count = stopped_count + 1
            end
        end
        ::continue::
    end
    if stopped_count > 0 then
        vim.schedule(function()
            vim.notify(string.format("Stopped %d LSP servers from other projects.", stopped_count), vim.log.levels.INFO)
        end)
    end
    return stopped_count
end

local efm_restart_timer = nil
local efm_restart_delay = 100
local efm_setup_in_progress = false

M.setup_efm = function(filetypes, tools_config)
    if efm_setup_in_progress then
        vim.schedule(function()
            vim.defer_fn(function()
                M.setup_efm(filetypes, tools_config)
            end, 100)
        end)
        return
    end
    efm_setup_in_progress = true
    _G.efm_configs = _G.efm_configs or {}
    for _, ft in ipairs(filetypes) do
        _G.efm_configs[ft] = _G.efm_configs[ft] or {}
        local existing_tools = {}
        for _, tool in ipairs(_G.efm_configs[ft]) do
            if tool.server_name then
                existing_tools[tool.server_name] = true
            end
        end
        for _, tool in ipairs(tools_config) do
            if tool.server_name and not existing_tools[tool.server_name] then
                table.insert(_G.efm_configs[ft], tool)
                existing_tools[tool.server_name] = true
            end
        end
    end
    vim.schedule(function()
        local configured_fts = {}
        for ft, _ in pairs(_G.efm_configs) do
            table.insert(configured_fts, ft)
        end
        if efm_restart_timer then
            efm_restart_timer:stop()
        end
        efm_restart_timer = vim.defer_fn(function()
            local efm_running = false
            for _, client in ipairs(vim.lsp.get_clients()) do
                if client.name == "efm" then
                    efm_running = true
                    vim.lsp.stop_client(client.id, true)
                    break
                end
            end
            vim.defer_fn(function()
                M.start_language_server("efm", true)
                efm_setup_in_progress = false
            end, efm_running and 200 or 0)
        end, efm_restart_delay)
    end)

    if not vim.defer_fn then
        efm_setup_in_progress = false
    end
end

-- M.set_installation_status = function(_, _) end
M.set_installation_status = function(status)
    local previous_status = _G.lsp_installation_in_progress
    _G.lsp_installation_in_progress = status
    if status == false and previous_status == true then
        vim.defer_fn(function()
            local installed_servers = {}
            for server_name, _ in pairs(_G.file_types or {}) do
                if
                    vim.fn.executable(server_name) == 1
                    or (server_name == "efm" and vim.fn.executable("efm-langserver") == 1)
                then
                    table.insert(installed_servers, server_name)
                end
            end
            for _, server_name in ipairs(installed_servers) do
                vim.schedule(function()
                    M.start_language_server(server_name, true)
                end)
            end
            vim.defer_fn(function()
                for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        local ft = vim.bo[bufnr].filetype
                        if ft and ft ~= "" then
                            local servers = M.get_compatible_lsp_for_ft(ft)
                            for _, server_name in ipairs(servers) do
                                if not M.is_server_disabled_globally(server_name) then
                                    vim.schedule(function()
                                        M.ensure_lsp_for_buffer(server_name, bufnr)
                                    end)
                                end
                            end
                        end
                    end
                end
            end, 500)
        end, 1000)
    end
end

return M
