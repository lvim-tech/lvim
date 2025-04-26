local mason_registry = require("mason-registry")

local efm = require("languages.efm")
local global = require("core.global")

_G.lsp_session_loaded = false
_G.lsp_activation_attempts = {}
_G.lsp_buffer_status = {}
_G.lsp_activation_locks = {}

local M = { path = {} }

local function escape_wildcards(path)
    return path:gsub("([%[%]%?%*])", "\\%1")
end

function M.root_pattern(...)
    local patterns = M.tbl_flatten({ ... })
    return function(startpath)
        startpath = M.strip_archive_subpath(startpath)
        for _, pattern in ipairs(patterns) do
            local match = M.search_ancestors(startpath, function(path)
                for _, p in ipairs(vim.fn.glob(table.concat({ escape_wildcards(path), pattern }, "/"), true, true)) do
                    if vim.uv.fs_stat(p) then
                        return path
                    end
                end
            end)
            if match ~= nil then
                return match
            end
        end
    end
end

function M.insert_package_json(config_files, field, fname)
    local path = vim.fn.fnamemodify(fname, ":h")
    local root_with_package = vim.fs.dirname(vim.fs.find("package.json", { path = path, upward = true })[1])

    if root_with_package then
        local path_sep = "/"
        for line in io.lines(root_with_package .. path_sep .. "package.json") do
            if line:find(field) then
                config_files[#config_files + 1] = "package.json"
                break
            end
        end
    end
    return config_files
end

function M.strip_archive_subpath(path)
    path = vim.fn.substitute(path, "zipfile://\\(.\\{-}\\)::[^\\\\].*$", "\\1", "")
    path = vim.fn.substitute(path, "tarfile:\\(.\\{-}\\)::.*$", "\\1", "")
    return path
end

function M.tbl_flatten(t)
    return vim.iter(t):flatten(math.huge):totable()
end

M.is_lsp_server_running = function(server_name)
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == server_name then
            return true
        end
    end
    return false
end

M.is_lsp_server_installed = function(server_name)
    return coroutine.wrap(function()
        local package = mason_registry.get_package(server_name)
        if not package then
            return false
        end
        if package:is_installed() then
            return true
        end
        if package:is_installing() then
            while package:is_installing() do
                coroutine.yield()
            end
            if package:is_installed() then
                return true
            else
                return false
            end
        end
        local done = false
        package:install():once("closed", function()
            done = true
        end)
        while not done do
            coroutine.yield()
        end
        if package:is_installed() then
            return true
        else
            return false
        end
    end)
end

M.setup_efm = function(file_types, configs)
    local efm_async = M.is_lsp_server_installed("efm")
    local efm_installed = false
    while not efm_installed do
        efm_installed = efm_async()
        vim.wait(100)
    end
    if not efm_installed then
        vim.notify("EFM server not installed", vim.log.levels.ERROR)
        return
    end
    local ft_list = type(file_types) == "string" and { file_types } or file_types
    local need_restart = false
    for _, config in ipairs(configs) do
        local server_name = config.server_name
        if server_name then
            local server_async = M.is_lsp_server_installed(server_name)
            local server_installed = false
            while not server_installed do
                server_installed = server_async()
                vim.wait(100)
            end
            if server_installed then
                for _, ft in ipairs(ft_list) do
                    if not vim.tbl_contains(global.efm.filetypes, ft) then
                        table.insert(global.efm.filetypes, ft)
                        need_restart = true
                    end
                    if not global.efm.settings.languages[ft] then
                        global.efm.settings.languages[ft] = {}
                    end
                    table.insert(global.efm.settings.languages[ft], M.deep_copy(config))
                end
            else
                vim.notify("Server " .. server_name .. " not installed, skipping configuration", vim.log.levels.WARN)
            end
        end
    end
    if need_restart then
        efm.start()
    end
end

local function debug_clients()
    local clients = vim.lsp.get_clients()
    if #clients > 0 then
        local client_names = {}
        for _, client in ipairs(clients) do
            table.insert(client_names, client.name)
        end
        print("Active LSP clients: " .. table.concat(client_names, ", "))
    end
end

M.check_duplicate_lsp = function(bufnr, auto_fix)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    auto_fix = auto_fix or false
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local client_names = {}
    local duplicates = {}
    local client_ids = {}
    for _, client in ipairs(clients) do
        if client_names[client.name] then
            if not duplicates[client.name] then
                duplicates[client.name] = {
                    first_id = client_names[client.name],
                    others = {},
                }
            end
            table.insert(duplicates[client.name].others, client.id)
        else
            client_names[client.name] = client.id
        end
        table.insert(client_ids, {
            id = client.id,
            name = client.name,
        })
    end
    local has_duplicates = false
    for _, _ in pairs(duplicates) do
        has_duplicates = true
        break
    end
    if has_duplicates then
        local message = "Found duplicate LSP clients for buffer " .. bufnr .. ":\n"
        for name, info in pairs(duplicates) do
            message = message .. "- " .. name .. ": primary ID " .. info.first_id .. ", duplicate IDs: "
            message = message .. table.concat(info.others, ", ") .. "\n"
            if auto_fix then
                for _, client_id in ipairs(info.others) do
                    pcall(vim.lsp.buf_detach_client, bufnr, client_id)
                end
            end
        end
        if auto_fix then
            message = message .. "\nDuplicate clients were automatically removed."
        else
            message = message .. "\nTo automatically remove duplicates, execute ':FixLSP'"
        end
        print(message)
        return duplicates, client_ids
    else
        return {}, client_ids
    end
end

M.track_buffer_lsp = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    if ft and ft ~= "" then
        _G.lsp_buffer_status[bufnr] = {}
        for lang, lang_filetypes in pairs(_G.file_types) do
            if vim.tbl_contains(lang_filetypes, ft) then
                _G.lsp_buffer_status[bufnr][lang] = true
                local client_attached = false
                for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                    if client.name == lang then
                        client_attached = true
                        break
                    end
                end
                if not client_attached then
                    vim.defer_fn(function()
                        M.lsp_enable(lang, false)
                    end, 10 * (bufnr % 10))
                end
            end
        end
    end
end

M.restore_buffer_lsp = function(bufnr)
    if not _G.lsp_buffer_status[bufnr] then
        return
    end
    for lang, _ in pairs(_G.lsp_buffer_status[bufnr]) do
        local client_attached = false
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if client.name == lang then
                client_attached = true
                break
            end
        end
        if not client_attached then
            M.lsp_enable(lang, false)
        end
    end
end

M.lsp_enable = function(lang, attach_all_buffers)
    if attach_all_buffers == nil then
        attach_all_buffers = true
    end
    if _G.lsp_activation_locks[lang] then
        return
    end
    _G.lsp_activation_locks[lang] = true
    local current_bufnr = vim.api.nvim_get_current_buf()
    if not lang or type(lang) ~= "string" or lang == "" then
        _G.lsp_activation_locks[lang] = false
        return
    end
    if not attach_all_buffers then
        local current_ft = vim.bo[current_bufnr].filetype
        if
            current_ft
            and current_ft ~= ""
            and _G.file_types[lang]
            and not vim.tbl_contains(_G.file_types[lang], current_ft)
        then
            _G.lsp_activation_locks[lang] = false
            return
        end
    end
    local lang_buffers = {}
    if attach_all_buffers then
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
                local ft = vim.bo[bufnr].filetype
                if _G.file_types[lang] and vim.tbl_contains(_G.file_types[lang], ft) then
                    local already_has_client = false
                    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                        if client.name == lang then
                            already_has_client = true
                            break
                        end
                    end
                    if not already_has_client then
                        table.insert(lang_buffers, bufnr)
                        if not _G.lsp_buffer_status[bufnr] then
                            _G.lsp_buffer_status[bufnr] = {}
                        end
                        _G.lsp_buffer_status[bufnr][lang] = true
                    end
                end
            end
        end
    else
        local already_has_client = false
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = current_bufnr })) do
            if client.name == lang then
                already_has_client = true
                break
            end
        end
        if not already_has_client then
            table.insert(lang_buffers, current_bufnr)
            if not _G.lsp_buffer_status[current_bufnr] then
                _G.lsp_buffer_status[current_bufnr] = {}
            end
            _G.lsp_buffer_status[current_bufnr][lang] = true
        end
    end
    if #lang_buffers == 0 then
        _G.lsp_activation_locks[lang] = false
        return
    end
    local existing_clients = {}
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == lang then
            table.insert(existing_clients, client)
        end
    end
    if #existing_clients > 0 then
        local primary_client = existing_clients[1]
        if #existing_clients > 1 then
            print("Found " .. #existing_clients .. " duplicate clients for " .. lang .. ". Removing...")
            for i = 2, #existing_clients do
                pcall(existing_clients[i].stop)
            end
            vim.wait(300)
        end
        for _, bufnr in ipairs(lang_buffers) do
            local is_attached = false
            for _, attached_buf in ipairs(vim.lsp.get_buffers_by_client_id(primary_client.id)) do
                if attached_buf == bufnr then
                    is_attached = true
                    break
                end
            end
            if not is_attached then
                pcall(vim.lsp.buf_attach_client, bufnr, primary_client.id)
                if not _G.lsp_servers_enabled_for_buf then
                    _G.lsp_servers_enabled_for_buf = {}
                end
                if not _G.lsp_servers_enabled_for_buf[bufnr] then
                    _G.lsp_servers_enabled_for_buf[bufnr] = {}
                end
                _G.lsp_servers_enabled_for_buf[bufnr][lang] = true
            end
        end
        _G.lsp_activation_locks[lang] = false
        return
    end
    if _G["_" .. lang .. "_lsp_initializing"] then
        _G.lsp_activation_locks[lang] = false
        return
    end
    _G["_" .. lang .. "_lsp_initializing"] = true
    local config = _G[lang .. "_lsp_config"]
    if not config then
        local success, result = pcall(require, "languages.user.lsp." .. lang)
        if not success then
            success, result = pcall(require, "languages.base.lsp." .. lang)
        end
        if success and type(result) == "table" then
            config = result
        end
    end
    if config and type(config) == "table" then
        local root_dir = vim.fn.getcwd()
        local enhanced_config = vim.deepcopy(config)
        enhanced_config.root_dir = root_dir
        enhanced_config.before_init = enhanced_config.before_init
            or function(params)
                params.workspaceFolders = {
                    {
                        uri = vim.uri_from_fname(root_dir),
                        name = vim.fn.fnamemodify(root_dir, ":t"),
                    },
                }
            end
        if M.is_lsp_server_running(lang) then
            _G["_" .. lang .. "_lsp_initializing"] = false
            _G.lsp_activation_locks[lang] = false
            vim.defer_fn(function()
                M.lsp_enable(lang, attach_all_buffers)
            end, 100)
            return
        end
        local success, client_id_or_err = pcall(vim.lsp.start, enhanced_config, {
            bufnr = lang_buffers[1],
            reuse_client = function(client)
                return client.name == lang
            end,
        })
        if success and client_id_or_err then
            if not _G.lsp_servers_enabled_for_buf then
                _G.lsp_servers_enabled_for_buf = {}
            end
            if not _G.lsp_servers_enabled_for_buf[lang_buffers[1]] then
                _G.lsp_servers_enabled_for_buf[lang_buffers[1]] = {}
            end
            _G.lsp_servers_enabled_for_buf[lang_buffers[1]][lang] = true
            if attach_all_buffers and #lang_buffers > 1 then
                vim.defer_fn(function()
                    local client_exists = false
                    for _, client in ipairs(vim.lsp.get_clients()) do
                        if client.id == client_id_or_err then
                            client_exists = true
                            break
                        end
                    end
                    if client_exists then
                        for i = 2, #lang_buffers do
                            pcall(vim.lsp.buf_attach_client, lang_buffers[i], client_id_or_err)
                            if not _G.lsp_servers_enabled_for_buf[lang_buffers[i]] then
                                _G.lsp_servers_enabled_for_buf[lang_buffers[i]] = {}
                            end
                            _G.lsp_servers_enabled_for_buf[lang_buffers[i]][lang] = true
                        end
                    end
                end, 300)
            end
        end
    end
    vim.defer_fn(function()
        _G["_" .. lang .. "_lsp_initializing"] = false
        _G.lsp_activation_locks[lang] = false
    end, 500)
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

M.ensure_lsp_for_all_buffers = function()
    local filetypes = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
            local ft = vim.bo[bufnr].filetype
            if ft and ft ~= "" then
                if not filetypes[ft] then
                    filetypes[ft] = true
                end
                M.track_buffer_lsp(bufnr)
            end
        end
    end
    local processed_langs = {}
    local languages_to_activate = {}
    for ft, _ in pairs(filetypes) do
        for lang, lang_filetypes in pairs(_G.file_types) do
            if vim.tbl_contains(lang_filetypes, ft) and not processed_langs[lang] then
                processed_langs[lang] = true
                table.insert(languages_to_activate, lang)
            end
        end
    end
    if #languages_to_activate > 0 then
        local current_index = 1
        local function process_next_language()
            if current_index <= #languages_to_activate then
                local lang = languages_to_activate[current_index]
                M.lsp_enable(lang, true)
                current_index = current_index + 1
                vim.defer_fn(process_next_language, 300)
            end
        end
        process_next_language()
    end
    return processed_langs
end

M.setup_session_lsp_autoload = function()
    pcall(vim.api.nvim_del_augroup_by_name, "LvimSessionLSPLoad")
    local group = vim.api.nvim_create_augroup("LvimSessionLSPLoad", { clear = true })
    vim.api.nvim_create_autocmd({ "SessionLoadPost" }, {
        group = group,
        callback = function()
            vim.defer_fn(function()
                _G.lsp_activation_locks = {}
                _G.lsp_session_loaded = false
                _G.lsp_servers_enabled_for_buf = {}
                _G.lsp_buffer_status = {}
                M.ensure_lsp_for_all_buffers()
                _G.lsp_session_loaded = true
                vim.defer_fn(debug_clients, 2000)
            end, 800)
        end,
    })
    vim.api.nvim_create_autocmd({ "VimEnter" }, {
        group = group,
        once = true,
        callback = function()
            if not _G.lsp_session_loaded then
                vim.defer_fn(function()
                    _G.lsp_activation_locks = {}
                    M.ensure_lsp_for_all_buffers()
                    _G.lsp_session_loaded = true
                    vim.defer_fn(debug_clients, 2000)
                end, 500)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
        group = group,
        callback = function(args)
            local bufnr = args.buf
            if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
                M.track_buffer_lsp(bufnr)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
        group = group,
        callback = function(args)
            local bufnr = args.buf
            if vim.api.nvim_buf_is_valid(bufnr) then
                vim.defer_fn(function()
                    local ft = vim.bo[bufnr].filetype
                    if ft and ft ~= "" then
                        M.track_buffer_lsp(bufnr)
                        M.restore_buffer_lsp(bufnr)
                    end
                end, 100)
            end
        end,
    })
end

M.restart_all_lsp = function()
    _G.lsp_activation_locks = {}
    local active_clients = vim.lsp.get_clients()
    local active_client_names = {}
    for _, client in ipairs(active_clients) do
        if client.name ~= "efm" then
            table.insert(active_client_names, client.name)
            client:stop()
        else
            table.insert(active_client_names, client.name)
        end
    end
    local buffer_info = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
            local ft = vim.bo[bufnr].filetype
            if ft and ft ~= "" then
                table.insert(buffer_info, { bufnr = bufnr, filetype = ft })
            end
        end
    end
    local efm_buffers = {}
    if _G.lsp_servers_enabled_for_buf then
        for bufnr, servers in pairs(_G.lsp_servers_enabled_for_buf) do
            if servers.efm then
                if not efm_buffers[bufnr] then
                    efm_buffers[bufnr] = {}
                end
                efm_buffers[bufnr].efm = true
            end
        end
    end
    _G.lsp_servers_enabled_for_buf = efm_buffers
    _G.lsp_session_loaded = false
    _G.lsp_activation_attempts = {}
    local efm_status = {}
    if _G.lsp_buffer_status then
        for bufnr, langs in pairs(_G.lsp_buffer_status) do
            if langs.efm then
                if not efm_status[bufnr] then
                    efm_status[bufnr] = {}
                end
                efm_status[bufnr].efm = true
            end
        end
    end
    _G.lsp_buffer_status = efm_status
    vim.defer_fn(function()
        M.ensure_lsp_for_all_buffers()
        _G.lsp_session_loaded = true
        vim.defer_fn(function()
            debug_clients()
            print("LSP restart completed (without affecting efm)")
        end, 2000)
    end, 800)
end

M.fzf_process_picker = function()
    local process_list = require("dap.utils").get_processes()
    local items = {}
    local processes = {}
    for _, p in pairs(process_list) do
        local display = string.format("%d: %s", p.pid, p.name)
        table.insert(items, display)
        processes[display] = p.pid
    end
    local co = coroutine.running()
    if co then
        require("fzf-lua").fzf_exec(items, {
            prompt = "Select process> ",
            actions = {
                ["default"] = function(selected)
                    if #selected > 0 then
                        local pid = processes[selected[1]]
                        coroutine.resume(co, pid)
                    else
                        coroutine.resume(co, nil)
                    end
                end,
            },
        })
        return coroutine.yield()
    else
        print("Error: Failed to create coroutine")
        return nil
    end
end

M.dap_local = function()
    local config_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }
    if not pcall(require, "dap") then
        vim.notify("Not found DAP plugin!", vim.log.levels.ERROR, {
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
        vim.notify(
            "You can define DAP configuration in './.nvim-dap/nvim-dap.lua', './.nvim-dap.lua', './.nvim/nvim-dap.lua'",
            vim.log.levels.INFO,
            {
                title = "LVIM IDE",
            }
        )
        return
    end
    vim.notify("Found DAP configuration at " .. project_config, vim.log.levels.INFO, {
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

vim.api.nvim_create_user_command("LvimLSPCheck", function()
    M.check_duplicate_lsp()
end, {})

vim.api.nvim_create_user_command("LvimLSPFix", function()
    M.check_duplicate_lsp(nil, true)
end, {})

vim.api.nvim_create_user_command("LvimLSPEnsure", function()
    _G.lsp_session_loaded = false
    _G.lsp_activation_attempts = {}
    _G.lsp_activation_locks = {}
    M.ensure_lsp_for_all_buffers()
    vim.defer_fn(debug_clients, 2000)
    _G.lsp_session_loaded = true
end, {})

vim.api.nvim_create_user_command("LvimLSPRestart", function()
    print("Restarting LSP clients (skipping efm)...")
    M.restart_all_lsp()
end, {})

vim.api.nvim_create_user_command("LvimLSPCheckCurrentFileType", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    print("Current file type is: " .. ft)

    local associated_langs = {}
    for lang, ft_list in pairs(_G.file_types) do
        if vim.tbl_contains(ft_list, ft) then
            table.insert(associated_langs, lang)
        end
    end

    if #associated_langs == 0 then
        print("This file type is not associated with any LSP servers.")
    else
        print("Associated with LSP servers: " .. table.concat(associated_langs, ", "))
    end
end, {})

vim.api.nvim_create_user_command("LvimLSPShowFileTypeMappings", function()
    local result = "File types and their LSP servers:\n"
    for lang, ft_list in pairs(_G.file_types) do
        result = result .. "\n" .. lang .. ":\n - " .. table.concat(ft_list, "\n - ") .. "\n"
    end
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
end, {})

return M
