-- Description: Low-level LSP lifecycle manager for LVIM IDE.
-- Responsible for starting, attaching, detaching, enabling, and disabling LSP
-- clients on a per-buffer and per-project-root basis.  Also manages the EFM
-- language server aggregation and handles cleanup of stale servers after a
-- working-directory change.
--
---@module "languages.lsp_manager"
---@diagnostic disable: undefined-doc-name, undefined-field

local uv = vim.loop

-- ── Global state (persists across require() calls) ────────────────────────────

--- Maps  server_name → root_dir → client_id so one client is reused per root
---@type table<string, table<string, integer>>
_G.lsp_clients_by_root = _G.lsp_clients_by_root or {}

--- Set of server names that have been globally disabled by the user
---@type table<string, boolean>
_G.lsp_disabled_servers = _G.lsp_disabled_servers or {}

--- Maps  bufnr → server_name → boolean  for buffer-scoped disable overrides
---@type table<integer, table<string, boolean>>
_G.lsp_disabled_for_buffer = _G.lsp_disabled_for_buffer or {}

--- Per-filetype EFM tool configurations accumulated from language modules
---@type table<string, table[]>
_G.efm_configs = _G.efm_configs or {}

local M = {}

-- ── Private helpers ───────────────────────────────────────────────────────────

--- Returns a function that, given a starting path, walks up the directory tree
--- looking for any of the provided `markers` (file or directory names).
--- Returns the first ancestor directory that contains a marker, or nil.
---@param ... string  Marker file/directory names (e.g. ".git", "package.json")
---@return fun(startpath: string): string|nil  Root-finder function
local function root_pattern(...)
    local markers = { ... }
    return function(startpath)
        if not startpath or #startpath == 0 then
            return nil
        end
        -- Resolve symlinks so comparisons are canonical
        local path = uv.fs_realpath(startpath) or startpath
        local stat = uv.fs_stat(path)
        -- If given a file path, start from its parent directory
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
            -- fnamemodify returns the same path at the filesystem root
            if parent == path then
                break
            end
            path = parent
        end
        return nil
    end
end

--- Returns true when `bufnr` is a valid buffer that corresponds to an actual
--- file on disk (i.e. has a non-empty name).
---@param bufnr integer  Buffer handle to test
---@return boolean
local function is_real_file_buffer(bufnr)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end
    local name = vim.api.nvim_buf_get_name(bufnr)
    if not name or name == "" then
        return false
    end
    return true
end

--- Returns true when the LSP client with id `client_id` is currently attached
--- to `bufnr`.
---@param client_id integer      LSP client id to check
---@param bufnr     integer|nil  Buffer handle; defaults to the current buffer when 0 or nil
---@return boolean
local function is_client_attached_to_buffer(client_id, bufnr)
    if not client_id then
        return false
    end
    if not bufnr or bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end
    local ok, clients = pcall(vim.lsp.get_clients, { bufnr = bufnr })
    if not ok or type(clients) ~= "table" then
        return false
    end
    for _, c in ipairs(clients) do
        if c and c.id == client_id then
            return true
        end
    end
    return false
end

-- ── Public API ─────────────────────────────────────────────────────────────────

--- Returns true when `server_name` has been disabled via `disable_lsp_server_globally`.
---@param server_name string  LSP server identifier
---@return boolean
M.is_server_disabled_globally = function(server_name)
    return _G.lsp_disabled_servers[server_name] == true
end

--- Returns true when `server_name` has been disabled specifically for `bufnr`.
---@param server_name string   LSP server identifier
---@param bufnr       integer  Buffer handle
---@return boolean
M.is_server_disabled_for_buffer = function(server_name, bufnr)
    return _G.lsp_disabled_for_buffer[bufnr] and _G.lsp_disabled_for_buffer[bufnr][server_name] == true
end

--- Returns true when `server_name` supports the given filetype `ft`.
--- For EFM the check consults both `_G.efm_configs` and the global EFM
--- filetypes list; for other servers it consults `_G.LVIM.file_types`.
---@param server_name string  LSP server identifier
---@param ft          string  Filetype string (e.g. `"lua"`)
---@return boolean
M.is_lsp_compatible_with_ft = function(server_name, ft)
    if not ft or ft == "" then
        return false
    end
    -- EFM is compatible if the filetype has an explicit efm_config entry
    if server_name == "efm" and _G.efm_configs and _G.efm_configs[ft] then
        return true
    end
    -- …or if it is listed in the global EFM filetypes table
    if server_name == "efm" and _G.LVIM.global and _G.LVIM.global.efm and _G.LVIM.global.efm.filetypes then
        return vim.tbl_contains(_G.LVIM.global.efm.filetypes, ft)
    end
    if not _G.LVIM.file_types or not _G.LVIM.file_types[server_name] then
        return false
    end
    return vim.tbl_contains(_G.LVIM.file_types[server_name], ft)
end

--- Returns all server names from `_G.LVIM.file_types` (plus EFM when
--- applicable) that declare support for filetype `ft`.
---@param ft string  Filetype string
---@return string[]  Compatible server names
M.get_compatible_lsp_for_ft = function(ft)
    if not ft or ft == "" then
        return {}
    end
    ---@type string[]
    local compatible_servers = {}
    for server_name, filetypes in pairs(_G.LVIM.file_types or {}) do
        if vim.tbl_contains(filetypes, ft) then
            table.insert(compatible_servers, server_name)
        end
    end
    if
        (_G.LVIM.global and _G.LVIM.global.efm and _G.LVIM.global.efm.filetypes and vim.tbl_contains(_G.LVIM.global.efm.filetypes, ft))
        or (_G.efm_configs and _G.efm_configs[ft])
    then
        table.insert(compatible_servers, "efm")
    end
    return compatible_servers
end

--- Attaches (or starts) the LSP server `server_name` for buffer `bufnr`.
---
--- Resolution order:
---   1. If a client for the same root_dir already exists, reuse it (attach only).
---   2. Otherwise load the server config from `languages.user.lsp.<name>` or
---      `languages.base.lsp.<name>`, resolve the project root, and start a new
---      client via `vim.lsp.start`.
---
---@param server_name string   LSP server identifier
---@param bufnr       integer  Buffer handle to attach to
---@return integer|nil  Client id on success, nil on any failure
M.ensure_lsp_for_buffer = function(server_name, bufnr)
    if not is_real_file_buffer(bufnr) then
        return nil
    end
    if M.is_server_disabled_globally(server_name) or M.is_server_disabled_for_buffer(server_name, bufnr) then
        return nil
    end
    local ft = vim.bo[bufnr].filetype
    if not M.is_lsp_compatible_with_ft(server_name, ft) then
        return nil
    end

    -- Load server config, preferring user overrides over the base config
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

    local fname    = vim.api.nvim_buf_get_name(bufnr)
    local patterns = mod.root_patterns or { ".git" }
    local finder   = root_pattern(unpack(patterns))
    -- Fall back to cwd when no root marker is found in the directory tree
    local root_dir = finder(fname) or vim.loop.cwd()

    _G.lsp_clients_by_root[server_name] = _G.lsp_clients_by_root[server_name] or {}
    local client_id = _G.lsp_clients_by_root[server_name][root_dir]

    if client_id then
        local client = vim.lsp.get_client_by_id(client_id)
        if client then
            -- Client exists for this root; attach to buffer if not already attached
            if not is_client_attached_to_buffer(client_id, bufnr) then
                vim.lsp.buf_attach_client(bufnr, client_id)
                if type(mod.config) == "table" and type(mod.config.on_attach) == "function" then
                    pcall(mod.config.on_attach, client, bufnr)
                end
            end
            return client_id
        end
    end

    -- No running client for this root_dir; start a new one
    local config = (type(mod.config) == "function") and mod.config() or vim.deepcopy(mod.config)
    if not config then
        return nil
    end
    config.root_dir = root_dir

    ---@type integer|nil
    local new_client_id
    new_client_id = vim.lsp.start({
        name         = config.name or server_name,
        cmd          = config.cmd,
        root_dir     = config.root_dir,
        settings     = config.settings,
        init_options = config.init_options,
        capabilities = config.capabilities,
        on_attach    = function(client, attached_bufnr)
            -- Only fire on_attach for the buffer that triggered the start
            if attached_bufnr == bufnr and config.on_attach then
                pcall(config.on_attach, client, attached_bufnr)
            end
        end,
    }, {
        bufnr = bufnr,
    })

    if new_client_id then
        -- Guard against nil in the rare case lsp.start races with a reset
        if _G.lsp_clients_by_root == nil then
            _G.lsp_clients_by_root = {}
        end
        if _G.lsp_clients_by_root[server_name] == nil then
            _G.lsp_clients_by_root[server_name] = {}
        end
        if root_dir ~= nil then
            _G.lsp_clients_by_root[server_name][root_dir] = new_client_id
        else
            -- Fallback key when root detection returns nil
            _G.lsp_clients_by_root[server_name]["default"] = new_client_id
        end
        return new_client_id
    end
    return nil
end

--- Detaches `client_id` from `bufnr` after clearing document highlights.
--- Returns false when the client was not attached or the buffer is invalid.
---@param bufnr     integer  Buffer handle
---@param client_id integer  LSP client id to detach
---@return boolean  true on successful detach, false otherwise
M.safe_detach_client = function(bufnr, client_id)
    if not bufnr or bufnr <= 0 or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
        return false
    end
    if is_client_attached_to_buffer(client_id, bufnr) then
        -- Clear reference highlights before detaching to avoid stale extmarks
        pcall(function()
            vim.lsp.buf.clear_references()
        end)
        pcall(vim.lsp.buf_detach_client, bufnr, client_id)
        return true
    end
    return false
end

--- Adds `server_name` to the global disabled list and immediately detaches /
--- stops any running instance of that server across all buffers.
---@param server_name string  LSP server identifier to disable
---@return boolean  Always true
M.disable_lsp_server_globally = function(server_name)
    _G.lsp_disabled_servers[server_name] = true
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == server_name then
            -- Collect all buffers this client is attached to before detaching
            ---@type table<integer, boolean>
            local attached_buffers = {}
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                    local ok, clients_for_buf = pcall(vim.lsp.get_clients, { bufnr = bufnr })
                    if ok and type(clients_for_buf) == "table" then
                        for _, c in ipairs(clients_for_buf) do
                            if c and c.id == client.id then
                                attached_buffers[bufnr] = true
                                break
                            end
                        end
                    end
                end
            end
            for bufnr, _ in pairs(attached_buffers) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                    M.safe_detach_client(bufnr, client.id)
                end
            end
            -- Stop the client process; handle both the new OOP API and the legacy API
            pcall(function()
                if type(client.stop) == "function" then
                    client:stop()
                else
                    local fallback = vim.lsp.get_client_by_id(client.id)
                    if fallback and type(fallback.stop) == "function" then
                        fallback:stop()
                    end
                end
            end)
        end
    end
    return true
end

--- Disables `server_name` for a single buffer and detaches it immediately.
---@param server_name string   LSP server identifier
---@param bufnr       integer  Buffer handle
---@return boolean  Always true
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

--- Re-enables `server_name` globally (removes from the disabled list).
--- Does NOT automatically re-attach clients; callers must trigger that separately.
---@param server_name string  LSP server identifier
---@return boolean  Always true
M.enable_lsp_server_globally = function(server_name)
    _G.lsp_disabled_servers[server_name] = nil
    return true
end

--- Re-enables `server_name` for `bufnr` and immediately re-attaches it if
--- the server is not globally disabled and the filetype matches.
---@param server_name string   LSP server identifier
---@param bufnr       integer  Buffer handle
---@return boolean  true on success, false when globally disabled
M.enable_lsp_server_for_buffer = function(server_name, bufnr)
    if _G.lsp_disabled_for_buffer[bufnr] then
        _G.lsp_disabled_for_buffer[bufnr][server_name] = nil
    end
    if M.is_server_disabled_globally(server_name) then
        return false
    end
    local ft = vim.bo[bufnr].filetype
    if ft and ft ~= "" and M.is_lsp_compatible_with_ft(server_name, ft) and is_real_file_buffer(bufnr) then
        local already_attached = false
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if client.name == server_name then
                already_attached = true
                break
            end
        end
        if not already_attached then
            -- Try to reuse an existing client first; only start a new one if none exists
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

--- Starts `server_name` by finding a compatible open buffer and calling
--- `ensure_lsp_for_buffer`.  When `force` is true, the server is also attached
--- to every other compatible buffer that is not individually disabled.
---@param server_name string   LSP server identifier
---@param force       boolean  When true, skip the global-disabled guard and spread to all buffers
---@return integer|nil  Client id on success, nil when no suitable buffer exists
M.start_language_server = function(server_name, force)
    -- Block new starts while a Mason installation is in progress to avoid
    -- attaching a server whose binaries are still being written to disk
    if _G.lsp_installation_in_progress then
        return nil
    end
    if not force and M.is_server_disabled_globally(server_name) then
        return nil
    end

    --- Scan open buffers for one compatible with `server_name`
    ---@return integer|nil, string|nil  bufnr and filetype, or nil/nil when none found
    local function find_compatible_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if is_real_file_buffer(buf) then
                local buf_ft = vim.bo[buf].filetype
                if buf_ft ~= "" and M.is_lsp_compatible_with_ft(server_name, buf_ft) then
                    return buf, buf_ft
                end
            end
        end
        return nil, nil
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local ft    = vim.bo[bufnr].filetype
    if not is_real_file_buffer(bufnr) or not M.is_lsp_compatible_with_ft(server_name, ft) then
        -- Current buffer doesn't match; search for any compatible buffer
        bufnr, ft = find_compatible_buf()
        if not bufnr or not is_real_file_buffer(bufnr) or not M.is_lsp_compatible_with_ft(server_name, ft) then
            if not force then
                return nil
            end
            bufnr = nil
        end
    end
    if not bufnr or not is_real_file_buffer(bufnr) then
        return nil
    end

    local client_id = M.ensure_lsp_for_buffer(server_name, bufnr)

    -- When force=true, attach the newly-started client to all other matching buffers
    if force and client_id then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if buf ~= bufnr and is_real_file_buffer(buf) then
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

--- Convenience wrapper: starts `server_name` for the current buffer.
---@param server_name string  LSP server identifier
---@param _           any     Unused (kept for API compatibility)
---@return integer|nil  Client id or nil
M.lsp_enable = function(server_name, _)
    local bufnr = vim.api.nvim_get_current_buf()
    return M.ensure_lsp_for_buffer(server_name, bufnr)
end

--- Stops all LSP clients whose `root_dir` is outside the current working
--- directory.  Called after a `DirChanged` event to clean up stale servers
--- that belong to the previous project.
---@return integer  Number of servers that were scheduled to stop
M.stop_servers_for_old_project = function()
    local current_dir  = vim.fn.getcwd()
    local clients      = vim.lsp.get_clients()
    local stopped_count = 0
    for _, client in ipairs(clients) do
        if client.config and client.config.root_dir then
            ---@type string|nil
            local client_root
            if type(client.config.root_dir) == "function" then
                -- Dynamic root functions cannot be compared statically; skip
                goto continue
            else
                client_root = tostring(client.config.root_dir)
            end
            -- Stop the client when its root is not equal to or a sub-path of cwd
            if client_root ~= current_dir and not vim.startswith(client_root, current_dir) then
                local cid = client.id
                vim.schedule(function()
                    local c = vim.lsp.get_client_by_id(cid)
                    if c and type(c.stop) == "function" then
                        pcall(function()
                            c:stop()
                        end)
                    end
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

-- ── EFM management ────────────────────────────────────────────────────────────

--- Debounce timer for EFM restart; prevents multiple rapid calls from each
--- triggering a separate restart
---@type uv_timer_t|nil
local efm_restart_timer = nil

--- Milliseconds to wait after the last `setup_efm` call before restarting EFM
---@type integer
local efm_restart_delay = 100

--- Guard flag to prevent re-entrant calls to `setup_efm`
---@type boolean
local efm_setup_in_progress = false

--- Merges `tools_config` into `_G.efm_configs` for each filetype in
--- `filetypes`, deduplicating by `server_name`, then restarts the EFM language
--- server so it picks up the new configuration.
---@param filetypes    string[]  Filetypes to associate the tools with
---@param tools_config table[]   EFM tool config objects (each must have a `server_name` field)
---@return nil
M.setup_efm = function(filetypes, tools_config)
    -- Prevent concurrent invocations; retry after a short delay
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
        -- Build a set of already-registered tool names for this filetype
        ---@type table<string, boolean>
        local existing_tools = {}
        for _, tool in ipairs(_G.efm_configs[ft]) do
            if tool.server_name then
                existing_tools[tool.server_name] = true
            end
        end
        -- Merge new tools, skipping duplicates
        for _, tool in ipairs(tools_config) do
            if tool.server_name and not existing_tools[tool.server_name] then
                table.insert(_G.efm_configs[ft], tool)
                existing_tools[tool.server_name] = true
            end
        end
    end

    vim.schedule(function()
        -- Build the list of filetypes EFM should now handle
        ---@type string[]
        local configured_fts = {}
        for ft, _ in pairs(_G.efm_configs) do
            table.insert(configured_fts, ft)
        end

        -- Cancel any pending restart so rapid setup_efm calls coalesce
        if efm_restart_timer then
            efm_restart_timer:stop()
        end
        efm_restart_timer = vim.defer_fn(function()
            local efm_running = false
            for _, client in ipairs(vim.lsp.get_clients()) do
                if client.name == "efm" then
                    efm_running = true
                    -- Stop the old EFM instance before starting a fresh one
                    pcall(function()
                        if type(client.stop) == "function" then
                            client:stop()
                        else
                            local fallback = vim.lsp.get_client_by_id(client.id)
                            if fallback and type(fallback.stop) == "function" then
                                fallback:stop()
                            end
                        end
                    end)
                    break
                end
            end
            -- Give the old process 200 ms to exit when it was running, otherwise
            -- start immediately
            vim.defer_fn(function()
                M.start_language_server("efm", true)
                efm_setup_in_progress = false
            end, efm_running and 200 or 0)
        end, efm_restart_delay)
    end)

    -- Safety reset in case vim.defer_fn is somehow unavailable (should not happen)
    if not vim.defer_fn then
        efm_setup_in_progress = false
    end
end

--- Tracks whether a Mason installation is currently in progress.
--- When transitioning from true → false it triggers an automatic re-start of
--- all servers whose executables are now present, then re-attaches them to all
--- open file buffers.
---@param status boolean  true = installation started, false = installation finished
---@return nil
M.set_installation_status = function(status)
    local previous_status = _G.lsp_installation_in_progress
    _G.lsp_installation_in_progress = status

    -- Post-install: start any servers whose executables just became available
    if status == false and previous_status == true then
        vim.defer_fn(function()
            ---@type string[]
            local installed_servers = {}
            for server_name, _ in pairs(_G.LVIM.file_types or {}) do
                -- Check that the server binary is on PATH
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

            -- After an additional delay, attach newly-started clients to all open buffers
            vim.defer_fn(function()
                for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                    if is_real_file_buffer(bufnr) then
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
