-- LSP command layer for LVIM IDE.
-- Registers Neovim user-commands and keymaps that wrap vim.lsp.buf.* calls,
-- and provides interactive menus (via vim.ui.select) for toggling, restarting,
-- and inspecting LSP servers both globally and per-buffer.
-- Also patches vim.notify to suppress noisy "method not supported" LSP messages.
---@module "languages.lsp_commands"

local lsp_manager = require("languages.lsp_manager")

-- ---------------------------------------------------------------------------
-- lvim_toggle_lsp_server
-- ---------------------------------------------------------------------------

-- Interactive menu to start, disable, enable, or toggle individual LSP servers
-- across the whole editor session (not scoped to a specific buffer).
local function lvim_toggle_lsp_server()
    ---@type table<string, { name: string, status: "Running"|"Disabled"|"Not Running" }>
    local servers_info = {}

    -- Map of server name → client id for every currently running LSP client.
    ---@type table<string, integer>
    local running_servers = {}

    -- Globally disabled servers are persisted in the _G.lsp_disabled_servers table.
    ---@type table<string, boolean>
    local disabled_servers = _G.lsp_disabled_servers or {}

    for _, client in ipairs(vim.lsp.get_clients()) do
        running_servers[client.name] = client.id
    end

    -- Build a status entry for every server that LVIM knows about via file_types.
    if _G.LVIM.file_types then
        for server_name, _ in pairs(_G.LVIM.file_types) do
            servers_info[server_name] = {
                name = server_name,
                -- Precedence: explicitly disabled > currently running > not running.
                status = disabled_servers[server_name] and "Disabled"
                    or running_servers[server_name] and "Running"
                    or "Not Running",
            }
        end
    end

    -- EFM is a special aggregator server; include it if it has filetypes configured
    -- or if it is already running/disabled, even if not listed in file_types.
    ---@type boolean
    local has_efm = false
    if _G.LVIM.global and _G.LVIM.global.efm and _G.LVIM.global.efm.filetypes and #_G.LVIM.global.efm.filetypes > 0 then
        has_efm = true
    end
    if has_efm or running_servers["efm"] or disabled_servers["efm"] then
        servers_info["efm"] = {
            name = "efm",
            status = disabled_servers["efm"] and "Disabled" or running_servers["efm"] and "Running" or "Not Running",
        }
    end

    -- Determine which bulk-action entries are relevant before building the menu.
    ---@type boolean
    local has_not_running = false
    ---@type boolean
    local has_disabled = false
    for _, info in pairs(servers_info) do
        if info.status == "Not Running" then
            has_not_running = true
        elseif info.status == "Disabled" then
            has_disabled = true
        end
    end

    -- Each menu item has a display text, an optional bulk `action`, and optional
    -- per-server `server` / `status` fields for individual toggle entries.
    ---@type { text: string, action?: string, server?: string, status?: string }[]
    local menu_items = {}
    ---@type table<string, { text: string, action?: string, server?: string, status?: string }>
    local menu_map = {}

    -- Add bulk-action entries only when they are applicable.
    if has_not_running then
        table.insert(menu_items, { text = "Start All Not Running Servers", action = "start_not_running" })
        menu_map["Start All Not Running Servers"] = menu_items[#menu_items]
    end
    if next(running_servers) ~= nil then
        table.insert(menu_items, { text = "Disable All Running Servers", action = "disable_all" })
        menu_map["Disable All Running Servers"] = menu_items[#menu_items]
    end
    if has_disabled then
        table.insert(menu_items, { text = "Enable All Disabled Servers", action = "enable_all" })
        menu_map["Enable All Disabled Servers"] = menu_items[#menu_items]
    end

    -- Add one entry per individual server.
    for _, info in pairs(servers_info) do
        local item = {
            text = string.format("%s (%s)", info.name, info.status),
            server = info.name,
            status = info.status,
        }
        table.insert(menu_items, item)
        menu_map[item.text] = item
    end

    -- Sort: bulk actions first (in a fixed order), then individual servers
    -- grouped by status (Running → Not Running → Disabled) and alphabetically.
    table.sort(menu_items, function(a, b)
        if a.action and not b.action then
            return true
        end
        if b.action and not a.action then
            return false
        end
        if a.action and b.action then
            local order = { start_not_running = 1, disable_all = 2, enable_all = 3 }
            return (order[a.action] or 999) < (order[b.action] or 999)
        end
        local status_order = { Running = 1, ["Not Running"] = 2, Disabled = 3 }
        if a.status ~= b.status then
            return (status_order[a.status] or 999) < (status_order[b.status] or 999)
        end
        return (a.server or "") < (b.server or "")
    end)

    table.insert(menu_items, { text = "Cancel", action = "cancel" })
    menu_map["Cancel"] = menu_items[#menu_items]

    -- Flatten to plain strings for vim.ui.select.
    ---@type string[]
    local display_items = {}
    for _, item in ipairs(menu_items) do
        table.insert(display_items, item.text)
    end

    vim.ui.select(display_items, { prompt = "LSP Servers Management" }, function(choice)
        if not choice or choice == "Cancel" then
            return
        end
        local selected_item = menu_map[choice]
        if not selected_item then
            return
        end

        -- Handle bulk actions first.
        if selected_item.action == "start_not_running" then
            local started_count = 0
            for server_name, info in pairs(servers_info) do
                if info.status == "Not Running" then
                    if lsp_manager.start_language_server(server_name, true) then
                        started_count = started_count + 1
                    end
                end
            end
            vim.notify("Started " .. started_count .. " LSP servers", vim.log.levels.INFO)
            return
        elseif selected_item.action == "disable_all" then
            local disabled_count = 0
            for server_name in pairs(running_servers) do
                lsp_manager.disable_lsp_server_globally(server_name)
                disabled_count = disabled_count + 1
            end
            vim.notify("Disabled " .. disabled_count .. " LSP servers", vim.log.levels.INFO)
            return
        elseif selected_item.action == "enable_all" then
            local enabled_count = 0
            for server_name, _ in pairs(disabled_servers) do
                lsp_manager.enable_lsp_server_globally(server_name)
                lsp_manager.start_language_server(server_name, true)
                enabled_count = enabled_count + 1
            end
            vim.notify("Enabled and started " .. enabled_count .. " LSP servers", vim.log.levels.INFO)
            return
        elseif selected_item.action == "cancel" then
            return
        end

        -- Individual server toggle: cycle Running → Disabled → Running, or start "Not Running".
        local server_name = selected_item.server
        local status = selected_item.status
        if status == "Running" then
            lsp_manager.disable_lsp_server_globally(server_name)
            vim.notify("Disabled LSP server: " .. server_name, vim.log.levels.INFO)
        elseif status == "Disabled" then
            lsp_manager.enable_lsp_server_globally(server_name)
            local client_id = lsp_manager.start_language_server(server_name, true)
            if client_id then
                vim.notify("Enabled and started LSP server: " .. server_name, vim.log.levels.INFO)
            else
                vim.notify("Enabled LSP server, but failed to start: " .. server_name, vim.log.levels.WARN)
            end
        elseif status == "Not Running" then
            local client_id = lsp_manager.start_language_server(server_name, true)
            if client_id then
                vim.notify("Started LSP server: " .. server_name, vim.log.levels.INFO)
            else
                vim.notify("Failed to start LSP server: " .. server_name, vim.log.levels.ERROR)
            end
        end
    end)
end

-- ---------------------------------------------------------------------------
-- lvim_toggle_lsp_for_buffer
-- ---------------------------------------------------------------------------

-- Interactive menu to attach, detach, start, enable, or disable individual LSP
-- servers relative to a single buffer (defaults to the current buffer).
---@param bufnr? integer Buffer number to operate on; defaults to current buffer.
local function lvim_toggle_lsp_for_buffer(bufnr)
    ---@type integer
    local current_bufnr = bufnr or vim.api.nvim_get_current_buf()
    ---@type string
    local ft = vim.bo[current_bufnr].filetype
    if not ft or ft == "" then
        vim.notify("Current buffer has no filetype", vim.log.levels.WARN)
        return
    end

    -- Ask lsp_manager which servers can handle this filetype.
    ---@type string[]
    local compatible_servers = lsp_manager.get_compatible_lsp_for_ft(ft)
    if #compatible_servers == 0 then
        vim.notify("No compatible LSP servers for filetype: " .. ft, vim.log.levels.WARN)
        return
    end

    -- Classify each compatible server into one of five states:
    --   "globally_disabled" – in _G.lsp_disabled_servers
    --   "buffer_disabled"   – in _G.lsp_disabled_for_buffer for this buffer
    --   "attached"          – already providing LSP features for this buffer
    --   "running"           – running but not attached to this buffer
    --   "not_started"       – not running at all
    ---@type table<string, { name: string, status: string, client_id: integer|nil }>
    local servers_status = {}
    for _, server_name in ipairs(compatible_servers) do
        local status = "unknown"
        local client_id = nil

        if _G.lsp_disabled_servers and _G.lsp_disabled_servers[server_name] then
            status = "globally_disabled"
        elseif
            _G.lsp_disabled_for_buffer
            and _G.lsp_disabled_for_buffer[current_bufnr]
            and _G.lsp_disabled_for_buffer[current_bufnr][server_name]
        then
            status = "buffer_disabled"
        else
            local attached = false
            -- Check if a client with this name is attached to the target buffer.
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = current_bufnr })) do
                if client.name == server_name then
                    attached = true
                    client_id = client.id
                    break
                end
            end
            if attached then
                status = "attached"
            else
                -- Not attached to this buffer — check if it is running globally.
                for _, client in ipairs(vim.lsp.get_clients()) do
                    if client.name == server_name then
                        status = "running"
                        client_id = client.id
                        break
                    end
                end
                if status == "unknown" then
                    status = "not_started"
                end
            end
        end

        servers_status[server_name] = {
            name = server_name,
            status = status,
            client_id = client_id,
        }
    end

    ---@type { text: string, action_type: string, server?: string, status?: string, client_id?: integer }[]
    local menu_items = {}
    ---@type boolean
    local has_detachable = false
    ---@type boolean
    local has_attachable = false

    -- Decide which bulk-action entries to show.
    for _, info in pairs(servers_status) do
        if info.status == "attached" then
            has_detachable = true
        elseif info.status == "running" or info.status == "not_started" or info.status == "buffer_disabled" then
            has_attachable = true
        end
    end

    if has_attachable then
        table.insert(menu_items, { text = "Attach All Compatible Servers", action_type = "attach_all" })
    end
    if has_detachable then
        table.insert(menu_items, { text = "Detach All Servers", action_type = "detach_all" })
    end

    -- Build one entry per server; label and action depend on its current state.
    for _, info in pairs(servers_status) do
        local text, action_type
        if info.status == "attached" then
            text = "Detach: " .. info.name
            action_type = "detach"
        elseif info.status == "buffer_disabled" then
            text = "Enable for Buffer: " .. info.name
            action_type = "enable_buffer"
        elseif info.status == "running" then
            text = "Attach: " .. info.name
            action_type = "attach"
        elseif info.status == "not_started" then
            text = "Start & Attach: " .. info.name
            action_type = "start_attach"
        elseif info.status == "globally_disabled" then
            text = "Globally Disabled: " .. info.name
            action_type = "enable_global"
        end
        table.insert(menu_items, {
            text = text,
            server = info.name,
            status = info.status,
            action_type = action_type,
            client_id = info.client_id,
        })
    end

    -- Sort individual entries by a priority that reflects the most useful action first.
    table.sort(menu_items, function(a, b)
        local order = {
            detach = 1,
            enable_buffer = 2,
            attach = 3,
            start_attach = 4,
            enable_global = 5,
        }
        local order_a = order[a.action_type] or 999
        local order_b = order[b.action_type] or 999
        if order_a ~= order_b then
            return order_a < order_b
        end
        return (a.server or "") < (b.server or "")
    end)

    table.insert(menu_items, { text = "Cancel", action_type = "cancel" })

    ---@type string[]
    local display_items = {}
    for _, item in ipairs(menu_items) do
        table.insert(display_items, item.text)
    end

    vim.ui.select(display_items, { prompt = "LSP for Buffer (" .. ft .. ")" }, function(choice)
        if not choice or choice == "Cancel" then
            return
        end

        -- Resolve the display string back to the full item (menu_items is ordered,
        -- so a linear scan is deterministic even with duplicate server names).
        local selected_item
        for _, item in ipairs(menu_items) do
            if item.text == choice then
                selected_item = item
                break
            end
        end
        if not selected_item then
            return
        end

        local action_type = selected_item.action_type
        local server_name = selected_item.server

        -- Bulk: attach every non-attached compatible server to this buffer.
        if action_type == "attach_all" then
            for _, info in pairs(servers_status) do
                if info.status == "buffer_disabled" then
                    lsp_manager.enable_lsp_server_for_buffer(info.name, current_bufnr)
                end
                if info.status == "running" then
                    for _, client in ipairs(vim.lsp.get_clients()) do
                        if client.name == info.name then
                            -- pcall guards against attach errors (e.g. filetype mismatch).
                            local _ = pcall(vim.lsp.buf_attach_client, current_bufnr, client.id)
                            break
                        end
                    end
                elseif info.status == "not_started" then
                    local client_id = lsp_manager.start_language_server(info.name, true)
                    if client_id then
                        local _ = pcall(vim.lsp.buf_attach_client, current_bufnr, client_id)
                    end
                end
            end
            local _ = vim.notify("Attached all compatible LSP servers to buffer", vim.log.levels.INFO)
            return
        elseif action_type == "detach_all" then
            -- Bulk: mark every attached server as buffer-disabled (detach).
            for _, info in pairs(servers_status) do
                if info.status == "attached" then
                    lsp_manager.disable_lsp_server_for_buffer(info.name, current_bufnr)
                end
            end
            local _ = vim.notify("Detached all LSP servers from buffer", vim.log.levels.INFO)
            return
        elseif action_type == "cancel" then
            return
        end

        -- Individual server actions.
        if action_type == "detach" then
            lsp_manager.disable_lsp_server_for_buffer(server_name, current_bufnr)
            local _ = vim.notify("Detached " .. server_name .. " from buffer", vim.log.levels.INFO)
        elseif action_type == "enable_buffer" then
            lsp_manager.enable_lsp_server_for_buffer(server_name, current_bufnr)
            local _ = vim.notify("Enabled " .. server_name .. " for buffer", vim.log.levels.INFO)
        elseif action_type == "attach" then
            -- The server is already running; just wire it to this buffer.
            for _, client in ipairs(vim.lsp.get_clients()) do
                if client.name == server_name then
                    local success = pcall(vim.lsp.buf_attach_client, current_bufnr, client.id)
                    if success then
                        local _ = vim.notify("Attached " .. server_name .. " to buffer", vim.log.levels.INFO)
                    else
                        local _ = vim.notify("Failed to attach " .. server_name, vim.log.levels.ERROR)
                    end
                    break
                end
            end
        elseif action_type == "start_attach" then
            -- Start the server from scratch, then immediately attach it.
            local client_id = lsp_manager.start_language_server(server_name, true)
            if client_id then
                local success = pcall(vim.lsp.buf_attach_client, current_bufnr, client_id)
                if success then
                    local _ = vim.notify("Started " .. server_name .. " and attached to buffer", vim.log.levels.INFO)
                else
                    local _ = vim.notify("Started " .. server_name .. " but failed to attach", vim.log.levels.WARN)
                end
            else
                local _ = vim.notify("Failed to start " .. server_name, vim.log.levels.ERROR)
            end
        elseif action_type == "enable_global" then
            -- Lift the global disable flag, then start and attach.
            lsp_manager.enable_lsp_server_globally(server_name)
            local client_id = lsp_manager.start_language_server(server_name, true)
            if client_id then
                local _ = pcall(vim.lsp.buf_attach_client, current_bufnr, client_id)
                local _ = vim.notify("Enabled and attached " .. server_name, vim.log.levels.INFO)
            else
                local _ = vim.notify("Enabled " .. server_name .. " but failed to start", vim.log.levels.WARN)
            end
        end
    end)
end

-- ---------------------------------------------------------------------------
-- lvim_lsp_restart
-- ---------------------------------------------------------------------------

-- Presents a picker of running LSP servers and restarts the chosen one,
-- re-attaching it to all buffers it was previously attached to.
local function lvim_lsp_restart()
    ---@type any[]
    local running_clients = vim.lsp.get_clients()
    if #running_clients == 0 then
        vim.notify("No LSP servers are running.", vim.log.levels.INFO)
        return
    end

    -- Deduplicate: only one restart entry per server name.
    ---@type table<string, boolean>
    local running_servers = {}
    for _, client in ipairs(running_clients) do
        running_servers[client.name] = true
    end

    ---@type { text: string, server: string, action: string }[]
    local menu_items = {}
    ---@type table<string, { text: string, server: string, action: string }>
    local menu_map = {}
    for server_name in pairs(running_servers) do
        local text = string.format("Restart: %s", server_name)
        local item = { text = text, server = server_name, action = "restart" }
        table.insert(menu_items, item)
        menu_map[text] = item
    end

    -- Alphabetical ordering for a predictable list.
    table.sort(menu_items, function(a, b)
        return a.server < b.server
    end)

    local cancel_item = { text = "Cancel", action = "cancel" }
    table.insert(menu_items, cancel_item)
    menu_map["Cancel"] = cancel_item

    ---@type string[]
    local display_items = {}
    for _, item in ipairs(menu_items) do
        table.insert(display_items, item.text)
    end

    vim.ui.select(display_items, { prompt = "Restart LSP Server..." }, function(choice)
        if not choice or choice == "Cancel" then
            return
        end
        local selected_item = menu_map[choice]
        if not selected_item or not selected_item.server then
            return
        end

        local server_name = selected_item.server

        -- Collect all buffer numbers the server was attached to before stopping it,
        -- so we can re-attach after the new instance starts.
        ---@type integer[]
        local attached_bufs = {}
        for _, client in ipairs(running_clients) do
            if client.name == server_name then
                for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                    for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                        if c.id == client.id then
                            table.insert(attached_bufs, bufnr)
                        end
                    end
                end
                client:stop()
            end
        end

        -- Defer the restart to allow the old process to exit cleanly before
        -- spawning a new one (500 ms is a safe margin for most servers).
        vim.defer_fn(function()
            local ok, new_client_id = pcall(function()
                return lsp_manager.start_language_server(server_name, true)
            end)
            if ok and new_client_id then
                for _, bufnr in ipairs(attached_bufs) do
                    pcall(vim.lsp.buf_attach_client, bufnr, new_client_id)
                end
                vim.notify("Restarted and re-attached LSP server: " .. server_name, vim.log.levels.INFO)
            else
                vim.notify(
                    "Restarted LSP server: " .. server_name .. " (auto-attach may not be possible)",
                    vim.log.levels.INFO
                )
            end
        end, 500)
    end)
end

-- ---------------------------------------------------------------------------
-- setup_lsp_error_filter
-- ---------------------------------------------------------------------------

-- Patches the global vim.notify to silently drop the common "method X is not
-- supported by any of the servers registered for the current buffer" message.
-- This keeps the UI quiet when a key is pressed in a buffer that has no matching
-- LSP capability (e.g. running LspHover in a plain-text buffer).
local function setup_lsp_error_filter()
    ---@type function  Capture the original notify so we can delegate to it.
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
        -- Swallow LSP "method not supported" noise.
        if
            type(msg) == "string"
            and msg:match("method [%w%p]+ is not supported by any of the servers registered for the current buffer")
        then
            return
        end
        original_notify(msg, level, opts)
    end
end

-- Install the notify filter immediately when this module is loaded.
setup_lsp_error_filter()

-- ---------------------------------------------------------------------------
-- lvim_lsp_info
-- ---------------------------------------------------------------------------

-- Opens a rich, read-only floating window that displays detailed information
-- about every active LSP client: capabilities, attached buffers, server
-- configuration, and — for EFM — the full linter/formatter tool list.
-- Sections with large tables are collapsed into folds (<CR> / za to toggle).
---@return { bufnr: integer, win: integer, close: fun() }|nil
local function lvim_lsp_info()
    local api = vim.api

    -- Unicode glyphs used as section / item decorators throughout the popup.
    ---@type table<string, string>
    local lsp_icons = {
        shape_square = "■",
        shape_diamond = "◆",
        shape_circle = "●",
        arrow = "➤",
        bracket = "[+]",
        cross = "✗",
        check = "✓",
    }

    -- Indentation strings for each nesting level (0–4).
    local INDENT_L0 = ""
    local INDENT_L1 = "  "
    local INDENT_L2 = "    "
    local INDENT_L3 = "      "
    local INDENT_L4 = "        "

    -- Define highlight groups for the popup using the active LVIM color palette.
    api.nvim_set_hl(0, "LspIcon", { fg = _G.LVIM.colors.blue, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoBG", { bg = _G.LVIM.colors.bg_float })
    api.nvim_set_hl(0, "LspInfoTitle", { fg = _G.LVIM.colors.red, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoServerName", { fg = _G.LVIM.colors.orange, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoSection", { fg = _G.LVIM.colors.blue, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoKey", { fg = _G.LVIM.colors.green, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoValue", { fg = _G.LVIM.colors.fg, bg = "NONE" })
    api.nvim_set_hl(0, "LspInfoSeparator", { fg = _G.LVIM.colors.blue, bg = "NONE" })
    api.nvim_set_hl(0, "LspInfoLinter", { fg = _G.LVIM.colors.purple, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoFormatter", { fg = _G.LVIM.colors.purple, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoToolName", { fg = _G.LVIM.colors.green, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoBuffer", { fg = _G.LVIM.colors.cyan, bg = "NONE", italic = true })
    api.nvim_set_hl(0, "LspInfoDate", { fg = _G.LVIM.colors.fg, bg = "NONE", italic = true })
    api.nvim_set_hl(0, "LspInfoConfig", { fg = _G.LVIM.colors.fg, bg = "NONE" })
    api.nvim_set_hl(0, "LspInfoConfigKey", { fg = _G.LVIM.colors.cyan, bg = "NONE", italic = true })
    api.nvim_set_hl(0, "LspInfoFold", { fg = _G.LVIM.colors.yellow, bg = "NONE", bold = true })

    ---@type any[]
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
        vim.notify("No active LSP clients found", vim.log.levels.INFO)
        return
    end

    -- The popup takes 80 % of the editor width so it stays readable on narrow terminals.
    ---@type integer
    local popup_width = math.floor(vim.o.columns * 0.8)

    -- Center `text` within `width` columns by padding with spaces on the left.
    ---@param text  string  Text to center.
    ---@param width integer Target column width.
    ---@return string
    local function center_text(text, width)
        local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
        return string.rep(" ", pad) .. text
    end

    -- Convert a scalar Lua value to a display-friendly string for the info popup.
    ---@param val any  Value to format (string, function, nil, or anything else).
    ---@return string
    local function format_value(val)
        if type(val) == "string" then
            return '"' .. val .. '"'
        elseif type(val) == "function" then
            return "<function>"
        elseif val == nil then
            return "nil"
        else
            return tostring(val)
        end
    end

    -- Recursively copy a table, skipping function values so display_table does not
    -- need to worry about them polluting the rendered output.
    ---@param t any  Value to copy (non-tables are returned as-is).
    ---@return any
    local function deep_copy_table(t)
        if type(t) ~= "table" then
            return t
        end
        local result = {}
        for k, v in pairs(t) do
            if type(v) == "table" then
                result[k] = deep_copy_table(v)
            else
                result[k] = v
            end
        end
        return result
    end

    -- Return true when `t` is a sequence (consecutive integer keys starting at 1).
    ---@param t any  Value to test.
    ---@return boolean
    local function is_array(t)
        if type(t) ~= "table" then
            return false
        end
        local max, n = 0, 0
        for k, _ in pairs(t) do
            -- Only count positive integer keys.
            if type(k) == "number" and k > 0 and math.floor(k) == k then
                if k > max then
                    max = k
                end
                n = n + 1
            else
                return false
            end
        end
        -- A valid sequence has no gaps: element count equals the highest key.
        return n == max and n > 0
    end

    -- Accumulates all display lines for the popup buffer.
    ---@type string[]
    local lines = {}
    -- Namespace for all extmark-based highlights applied after buffer population.
    local ns = api.nvim_create_namespace("lsp_info_popup")
    -- List of pending highlight regions to apply once all lines are collected.
    ---@type { line: integer, col_start: integer, col_end: integer, hl_group: string }[]
    local highlights = {}
    -- List of fold regions (start/end line pairs) to create after buffer population.
    ---@type { id: string, start_line?: integer, end_line?: integer }[]
    local folds = {}

    -- Append a highlight entry that targets the tool name within a tool-list line.
    -- The prefix is reconstructed to calculate the exact byte offset.
    ---@param line_idx  integer  0-based line index in the popup buffer.
    ---@param tool_name string   Name of the tool to highlight.
    ---@param indent    string?  Indentation prefix used on this line.
    local function add_tool_highlight(line_idx, tool_name, indent)
        local prefix = (indent or INDENT_L2) .. lsp_icons.shape_circle .. " "
        local col_start = #prefix
        local col_end = col_start + #tool_name
        table.insert(highlights, {
            line = line_idx,
            col_start = col_start,
            col_end = col_end,
            hl_group = "LspInfoToolName",
        })
    end

    -- Append a highlight entry for a decorative icon on a given line by searching
    -- for the icon string with a plain (non-regex) find to get its byte span.
    ---@param line_idx integer  0-based line index.
    ---@param icon     string   Icon character to highlight.
    local function add_icon_highlight(line_idx, icon)
        local line_text = lines[line_idx + 1]
        local s, e = string.find(line_text, vim.pesc(icon), 1, true)
        if s and e then
            table.insert(highlights, {
                line = line_idx,
                col_start = s - 1,
                col_end = e,
                hl_group = "LspIcon",
            })
        end
    end

    -- Append a highlight entry for the first occurrence of `substr` on `line_idx`.
    ---@param line_idx integer  0-based line index.
    ---@param substr   string   Plain substring to locate and highlight.
    ---@param hl_group string   Highlight group name to apply.
    local function add_highlight(line_idx, substr, hl_group)
        local line_text = lines[line_idx + 1]
        local s, e = string.find(line_text, substr, 1, true)
        if s and e then
            table.insert(highlights, {
                line = line_idx,
                col_start = s - 1,
                col_end = e,
                hl_group = hl_group,
            })
        end
    end

    -- Append a full-width horizontal rule using the box-drawing dash character.
    ---@param hl_group? string  Highlight group for the separator line (default: LspInfoSeparator).
    local function add_separator(hl_group)
        local separator = string.rep("─", popup_width)
        table.insert(lines, separator)
        hl_group = hl_group or "LspInfoSeparator"
        -- col_end = -1 signals that the highlight should cover the whole line.
        table.insert(highlights, {
            line = #lines - 1,
            col_start = 0,
            col_end = -1,
            hl_group = hl_group,
        })
    end

    -- Recursively render a Lua table into `line_list` as indented key: value pairs.
    -- Function-valued keys are skipped. Nested tables are rendered inline with
    -- deeper indentation. When `fold_info` is provided its start/end fields are
    -- populated so the caller can later create a fold over this block.
    ---@param tbl            table?                                                       Table to render.
    ---@param line_list      string[]                                                     Accumulator for output lines.
    ---@param highlight_list { line: integer, col_start: integer, col_end: integer, hl_group: string }[]  Highlight accumulator.
    ---@param indent         string?                                                      Current indentation prefix.
    ---@param fold_info      { id: string, start_line?: integer, end_line?: integer }?   Fold boundary output; mutated in place.
    local function display_table(tbl, line_list, highlight_list, indent, fold_info)
        if not tbl or type(tbl) ~= "table" then
            return
        end
        indent = indent or INDENT_L4
        local indent_str = indent
        table.insert(line_list, indent_str .. "{")
        if fold_info then
            fold_info.start_line = #line_list - 1
        end
        -- Sort keys: strings before numbers, then lexicographically within each type.
        local keys = vim.tbl_keys(tbl)
        table.sort(keys, function(a, b)
            if type(a) == type(b) then
                return tostring(a) < tostring(b)
            else
                return type(a) == "string"
            end
        end)
        for _, k in ipairs(keys) do
            local v = tbl[k]
            if type(v) ~= "function" then
                local key_str = tostring(k)
                if type(v) == "table" then
                    if vim.tbl_isempty(v) then
                        table.insert(line_list, indent_str .. INDENT_L1 .. key_str .. ": {}")
                        add_highlight(#line_list - 1, key_str, "LspInfoConfigKey")
                    elseif is_array(v) then
                        -- Render sequences by iterating items in order.
                        table.insert(line_list, indent_str .. INDENT_L1 .. key_str .. ": {")
                        add_highlight(#line_list - 1, key_str, "LspInfoConfigKey")
                        for _, item in ipairs(v) do
                            if type(item) == "table" then
                                display_table(item, line_list, highlight_list, indent .. INDENT_L2)
                            else
                                table.insert(line_list, indent .. INDENT_L2 .. format_value(item))
                            end
                        end
                        table.insert(line_list, indent_str .. INDENT_L1 .. "}")
                    else
                        -- Nested map: recurse with one extra indent level.
                        table.insert(line_list, indent_str .. INDENT_L1 .. key_str .. ": {")
                        add_highlight(#line_list - 1, key_str, "LspInfoConfigKey")
                        display_table(v, line_list, highlight_list, indent .. INDENT_L2)
                        table.insert(line_list, indent_str .. INDENT_L1 .. "}")
                    end
                else
                    table.insert(line_list, indent_str .. INDENT_L1 .. key_str .. ": " .. format_value(v))
                    add_highlight(#line_list - 1, key_str, "LspInfoConfigKey")
                end
            end
        end
        table.insert(line_list, indent_str .. "}")
        if fold_info then
            fold_info.end_line = #line_list - 1
        end
    end

    -- -----------------------------------------------------------------------
    -- Build popup content
    -- -----------------------------------------------------------------------

    local title = "LSP SERVERS INFORMATION"
    local centered_title = center_text(title, popup_width)
    table.insert(lines, centered_title)
    add_highlight(#lines - 1, title, "LspInfoTitle")
    add_separator("LspInfoTitle")

    -- EFM is rendered first (if present) because it needs a special layout that
    -- expands its linter/formatter tool list rather than raw server capabilities.
    ---@type any|nil
    local efm_client, other_clients = nil, {}
    for _, client in ipairs(clients) do
        if client.name == "efm" then
            efm_client = client
        else
            table.insert(other_clients, client)
        end
    end

    -- Reconstruct a sorted list: EFM first, then all other clients.
    ---@type any[]
    local sorted_clients = {}
    if efm_client then
        table.insert(sorted_clients, efm_client)
    end
    for _, c in ipairs(other_clients) do
        table.insert(sorted_clients, c)
    end

    for _, client in ipairs(sorted_clients) do
        table.insert(lines, "")
        local server_line = INDENT_L0 .. lsp_icons.shape_square .. " " .. client.name .. " (ID: " .. client.id .. ")"
        table.insert(lines, server_line)
        add_highlight(#lines - 1, client.name, "LspInfoServerName")
        add_icon_highlight(#lines - 1, lsp_icons.shape_square)

        if client.name == "efm" then
            -- EFM section: group attached buffers by filetype, then list linters
            -- and formatters sourced from the global _G.efm_configs registry.

            -- Map filetype → list of { bufnr, name } for EFM-attached buffers.
            ---@type table<string, { bufnr: integer, name: string }[]>
            local buffers_by_filetype = {}
            if client.attached_buffers then
                for bufnr, _ in pairs(client.attached_buffers) do
                    local buf_name = vim.api.nvim_buf_get_name(bufnr)
                    local display_name = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":~:.") or "[No Name]"
                    local filetype = vim.bo[bufnr].filetype
                    if filetype and filetype ~= "" then
                        buffers_by_filetype[filetype] = buffers_by_filetype[filetype] or {}
                        table.insert(buffers_by_filetype[filetype], {
                            bufnr = bufnr,
                            name = display_name,
                        })
                    end
                end
            end

            -- Deduplicate linters and formatters by their canonical name, merging
            -- filetypes from all configs that share the same name.
            ---@type table<string, { config: table, filetypes: string[], filetype_to_buffers: table<string, { bufnr: integer, name: string }[]> }>
            local linter_by_name = {}
            ---@type table<string, { config: table, filetypes: string[], filetype_to_buffers: table<string, { bufnr: integer, name: string }[]> }>
            local formatter_by_name = {}
            for filetype, configs in pairs(_G.efm_configs or {}) do
                for _, config in ipairs(configs) do
                    if config.lPrefix or (config.lintCommand and config.lintCommand ~= "") then
                        local name = config.server_name or config.lPrefix or "Unknown"
                        if not linter_by_name[name] then
                            linter_by_name[name] = { config = config, filetypes = {}, filetype_to_buffers = {} }
                        end
                        table.insert(linter_by_name[name].filetypes, filetype)
                        linter_by_name[name].filetype_to_buffers[filetype] = buffers_by_filetype[filetype]
                    end
                    if config.fPrefix or (config.formatCommand and config.formatCommand ~= "") then
                        local name = config.server_name or config.fPrefix or "Unknown"
                        if not formatter_by_name[name] then
                            formatter_by_name[name] = { config = config, filetypes = {}, filetype_to_buffers = {} }
                        end
                        table.insert(formatter_by_name[name].filetypes, filetype)
                        formatter_by_name[name].filetype_to_buffers[filetype] = buffers_by_filetype[filetype]
                    end
                end
            end

            -- Render linter entries (sorted alphabetically).
            if next(linter_by_name) then
                local linter_line = INDENT_L1 .. lsp_icons.shape_diamond .. " Linters: " .. lsp_icons.bracket
                table.insert(lines, linter_line)
                add_highlight(#lines - 1, "Linters:", "LspInfoLinter")
                add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
                add_icon_highlight(#lines - 1, lsp_icons.bracket)
                local linter_names = {}
                for k in pairs(linter_by_name) do
                    table.insert(linter_names, k)
                end
                table.sort(linter_names)
                for _, linter_name in ipairs(linter_names) do
                    local linter_info = linter_by_name[linter_name]
                    local ft_str = table.concat(linter_info.filetypes, ", ")
                    local tool_line = INDENT_L2
                        .. lsp_icons.shape_circle
                        .. " "
                        .. linter_name
                        .. " (Filetypes: "
                        .. ft_str
                        .. ")"
                    table.insert(lines, tool_line)
                    add_tool_highlight(#lines - 1, linter_name, INDENT_L2)
                    add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                    -- Each linter's config table becomes a foldable block.
                    local fold_info = { id = "linter_" .. linter_name }
                    table.insert(folds, fold_info)
                    display_table(linter_info.config, lines, highlights, INDENT_L3, fold_info)
                    for _, ft in ipairs(linter_info.filetypes) do
                        if linter_info.filetype_to_buffers[ft] and #linter_info.filetype_to_buffers[ft] > 0 then
                            local buffer_line = INDENT_L3 .. lsp_icons.shape_diamond .. " Buffers"
                            table.insert(lines, buffer_line)
                            add_highlight(#lines - 1, "Buffers", "LspInfoSection")
                            add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
                            for _, buf in ipairs(linter_info.filetype_to_buffers[ft]) do
                                local buffer_info = INDENT_L4
                                    .. lsp_icons.shape_circle
                                    .. " Buffer "
                                    .. buf.bufnr
                                    .. ": "
                                    .. buf.name
                                    .. " ("
                                    .. ft
                                    .. ")"
                                table.insert(lines, buffer_info)
                                add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                                add_highlight(#lines - 1, "Buffer", "LspInfoBuffer")
                            end
                        end
                    end
                end
            end

            -- Render formatter entries (sorted alphabetically).
            if next(formatter_by_name) then
                local formatter_line = INDENT_L1 .. lsp_icons.shape_diamond .. " Formatters: " .. lsp_icons.bracket
                table.insert(lines, formatter_line)
                add_highlight(#lines - 1, "Formatters:", "LspInfoFormatter")
                add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
                add_icon_highlight(#lines - 1, lsp_icons.bracket)
                local formatter_names = {}
                for k in pairs(formatter_by_name) do
                    table.insert(formatter_names, k)
                end
                table.sort(formatter_names)
                for _, formatter_name in ipairs(formatter_names) do
                    local formatter_info = formatter_by_name[formatter_name]
                    local ft_str = table.concat(formatter_info.filetypes, ", ")
                    local tool_line = INDENT_L2
                        .. lsp_icons.shape_circle
                        .. " "
                        .. formatter_name
                        .. " (Filetypes: "
                        .. ft_str
                        .. ")"
                    table.insert(lines, tool_line)
                    add_tool_highlight(#lines - 1, formatter_name, INDENT_L2)
                    add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                    -- Each formatter's config table becomes a foldable block.
                    local fold_info = { id = "formatter_" .. formatter_name }
                    table.insert(folds, fold_info)
                    display_table(formatter_info.config, lines, highlights, INDENT_L3, fold_info)
                    for _, ft in ipairs(formatter_info.filetypes) do
                        if formatter_info.filetype_to_buffers[ft] and #formatter_info.filetype_to_buffers[ft] > 0 then
                            local buffer_line = INDENT_L3 .. lsp_icons.shape_diamond .. " Buffers"
                            table.insert(lines, buffer_line)
                            add_highlight(#lines - 1, "Buffers", "LspInfoSection")
                            add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
                            for _, buf in ipairs(formatter_info.filetype_to_buffers[ft]) do
                                local buffer_info = INDENT_L4
                                    .. lsp_icons.shape_circle
                                    .. " Buffer "
                                    .. buf.bufnr
                                    .. ": "
                                    .. buf.name
                                    .. " ("
                                    .. ft
                                    .. ")"
                                table.insert(lines, buffer_info)
                                add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                                add_highlight(#lines - 1, "Buffer", "LspInfoBuffer")
                            end
                        end
                    end
                end
            end

            -- EFM's supported filetypes (from its server config, not from efm_configs).
            local filetypes = client.config and client.config.filetypes or {}
            if #filetypes > 0 then
                table.insert(lines, "")
                table.insert(lines, INDENT_L1 .. lsp_icons.shape_diamond .. " Supported Filetypes")
                add_highlight(#lines - 1, "Supported Filetypes", "LspInfoSection")
                add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
                local filetypes_str = table.concat(filetypes, ", ")
                table.insert(lines, INDENT_L2 .. filetypes_str)
            end
        else
            -- Non-EFM server: show filetypes and command in a compact format.
            if client.config and client.config.filetypes and #client.config.filetypes > 0 then
                local filetypes = table.concat(client.config.filetypes, ", ")
                local filetype_line = INDENT_L1 .. "Filetypes: " .. filetypes
                table.insert(lines, filetype_line)
                add_highlight(#lines - 1, "Filetypes:", "LspInfoKey")
            end
            if client.cmd and #client.cmd > 0 then
                local cmd_str = table.concat(client.cmd, " ")
                -- Truncate very long command strings to keep the popup within its width.
                if #cmd_str > popup_width - 10 then
                    cmd_str = cmd_str:sub(1, popup_width - 13) .. "..."
                end
                local cmd_line = INDENT_L1 .. "Command: " .. cmd_str
                table.insert(lines, cmd_line)
                add_highlight(#lines - 1, "Command:", "LspInfoKey")
            end
        end

        -- Server configuration section: settings, init_options, root_dir, capabilities,
        -- and any remaining config keys not handled above.
        if client.config then
            table.insert(lines, "")
            table.insert(lines, INDENT_L1 .. lsp_icons.shape_diamond .. " Server Configuration")
            add_highlight(#lines - 1, "Server Configuration", "LspInfoSection")
            add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
            ---@type boolean  Tracks whether at least one config sub-section was shown.
            local has_config = false

            -- Deep-copy the config sub-tables to avoid mutating the live client config.
            local expanded_settings = deep_copy_table(client.config.settings or {})
            local expanded_init_options = deep_copy_table(client.config.init_options or {})
            local expanded_capabilities = deep_copy_table(client.config.capabilities or {})

            if client.config.settings and not vim.tbl_isempty(client.config.settings) then
                has_config = true
                local settings_line = INDENT_L2 .. lsp_icons.shape_circle .. " Settings: " .. lsp_icons.bracket
                table.insert(lines, settings_line)
                add_highlight(#lines - 1, "Settings:", "LspInfoKey")
                add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                add_icon_highlight(#lines - 1, lsp_icons.bracket)
                local fold_info = { id = "settings_" .. client.name }
                table.insert(folds, fold_info)
                display_table(expanded_settings, lines, highlights, INDENT_L3, fold_info)
            end
            if client.config.init_options and not vim.tbl_isempty(client.config.init_options) then
                has_config = true
                local init_options_line = INDENT_L2
                    .. lsp_icons.shape_circle
                    .. " Initialization Options: "
                    .. lsp_icons.bracket
                table.insert(lines, init_options_line)
                add_highlight(#lines - 1, "Initialization Options:", "LspInfoKey")
                add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                add_icon_highlight(#lines - 1, lsp_icons.bracket)
                local fold_info = { id = "init_options_" .. client.name }
                table.insert(folds, fold_info)
                display_table(expanded_init_options, lines, highlights, INDENT_L3, fold_info)
            end
            if client.config.root_dir then
                has_config = true
                local root_dir_line = INDENT_L2 .. lsp_icons.shape_circle .. " Root Dir:"
                table.insert(lines, root_dir_line)
                add_highlight(#lines - 1, "Root Dir:", "LspInfoKey")
                add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                if type(client.config.root_dir) == "function" then
                    table.insert(lines, INDENT_L3 .. "<function>")
                else
                    table.insert(lines, INDENT_L3 .. tostring(client.config.root_dir))
                end
            end
            if client.config.capabilities and not vim.tbl_isempty(client.config.capabilities) then
                has_config = true
                local capabilities_line = INDENT_L2 .. lsp_icons.shape_circle .. " Capabilities: " .. lsp_icons.bracket
                table.insert(lines, capabilities_line)
                add_highlight(#lines - 1, "Capabilities:", "LspInfoKey")
                add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                add_icon_highlight(#lines - 1, lsp_icons.bracket)
                local fold_info = { id = "capabilities_" .. client.name }
                table.insert(folds, fold_info)
                display_table(expanded_capabilities, lines, highlights, INDENT_L3, fold_info)
            end

            -- Collect any config keys that were not already rendered above (excluding
            -- function values, which are not human-readable in a display buffer).
            ---@type table<string, any>
            local other_config = {}
            for k, v in pairs(client.config) do
                if
                    k ~= "settings"
                    and k ~= "init_options"
                    and k ~= "root_dir"
                    and k ~= "capabilities"
                    and k ~= "name"
                    and k ~= "cmd"
                    and k ~= "filetypes"
                    and type(v) ~= "function"
                then
                    other_config[k] = deep_copy_table(v)
                end
            end
            if not vim.tbl_isempty(other_config) then
                has_config = true
                local other_options_line = INDENT_L2
                    .. lsp_icons.shape_circle
                    .. " Other Options: "
                    .. lsp_icons.bracket
                table.insert(lines, other_options_line)
                add_highlight(#lines - 1, "Other Options:", "LspInfoKey")
                add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                add_icon_highlight(#lines - 1, lsp_icons.bracket)
                local fold_info = { id = "other_options_" .. client.name }
                table.insert(folds, fold_info)
                display_table(other_config, lines, highlights, INDENT_L3, fold_info)
            end
            if not has_config then
                table.insert(lines, INDENT_L2 .. lsp_icons.cross .. " No detailed configuration available")
                add_icon_highlight(#lines - 1, lsp_icons.cross)
                add_highlight(#lines - 1, lsp_icons.cross, "LspInfoKey")
            end
        end

        -- Capabilities section: tick-list of server_capabilities flags.
        table.insert(lines, "")
        table.insert(lines, INDENT_L1 .. lsp_icons.shape_diamond .. " Capabilities")
        add_highlight(#lines - 1, "Capabilities", "LspInfoSection")
        add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
        ---@type boolean
        local has_capabilities = false
        if client.server_capabilities then
            -- Only the capabilities most relevant to everyday editing are checked.
            local capabilities = {
                { name = "Completion", check = client.server_capabilities.completionProvider },
                { name = "Hover", check = client.server_capabilities.hoverProvider },
                { name = "Go to Definition", check = client.server_capabilities.definitionProvider },
                { name = "Find References", check = client.server_capabilities.referencesProvider },
                { name = "Document Formatting", check = client.server_capabilities.documentFormattingProvider },
                { name = "Document Symbols", check = client.server_capabilities.documentSymbolProvider },
                { name = "Workspace Symbols", check = client.server_capabilities.workspaceSymbolProvider },
                { name = "Rename", check = client.server_capabilities.renameProvider },
                { name = "Code Action", check = client.server_capabilities.codeActionProvider },
                { name = "Signature Help", check = client.server_capabilities.signatureHelpProvider },
                { name = "Document Highlight", check = client.server_capabilities.documentHighlightProvider },
            }
            for _, cap in ipairs(capabilities) do
                if cap.check then
                    has_capabilities = true
                    local cap_line = INDENT_L2 .. lsp_icons.check .. " " .. cap.name
                    table.insert(lines, cap_line)
                    add_icon_highlight(#lines - 1, lsp_icons.check)
                    add_highlight(#lines - 1, lsp_icons.check, "LspInfoKey")
                end
            end
        end
        if not has_capabilities then
            table.insert(lines, INDENT_L2 .. lsp_icons.cross .. " No specific capabilities detected")
            add_icon_highlight(#lines - 1, lsp_icons.cross)
            add_highlight(#lines - 1, lsp_icons.cross, "LspInfoKey")
        end

        -- Attached buffers section.
        table.insert(lines, "")
        table.insert(lines, INDENT_L1 .. lsp_icons.shape_diamond .. " Attached Buffers")
        add_highlight(#lines - 1, "Attached Buffers", "LspInfoSection")
        add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
        ---@type boolean
        local has_buffers = false
        if client.attached_buffers then
            for bufnr, _ in pairs(client.attached_buffers) do
                has_buffers = true
                local buf_name = vim.api.nvim_buf_get_name(bufnr)
                -- Use ":~:." to display the path relative to home / cwd for brevity.
                local display_name = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":~:.") or "[No Name]"
                local filetype = vim.bo[bufnr].filetype
                local buffer_info = INDENT_L2 .. lsp_icons.shape_circle .. " Buffer " .. bufnr .. ": " .. display_name
                if filetype and filetype ~= "" then
                    buffer_info = buffer_info .. " (" .. filetype .. ")"
                end
                table.insert(lines, buffer_info)
                add_icon_highlight(#lines - 1, lsp_icons.shape_circle)
                add_highlight(#lines - 1, "Buffer", "LspInfoBuffer")
            end
        end
        if not has_buffers then
            table.insert(lines, INDENT_L2 .. lsp_icons.cross .. " No buffers attached")
            add_icon_highlight(#lines - 1, lsp_icons.cross)
            add_highlight(#lines - 1, lsp_icons.cross, "LspInfoKey")
        end

        table.insert(lines, "")
        add_separator()
    end

    -- -----------------------------------------------------------------------
    -- Create the floating window
    -- -----------------------------------------------------------------------

    -- Use a scratch buffer (unlisted, wiped on close) to hold the popup content.
    ---@type integer
    local bufnr = api.nvim_create_buf(false, true)
    vim.bo[bufnr].bufhidden = "wipe"
    api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    ---@type integer
    local width = popup_width
    -- Cap height at 80 % of the terminal height so the popup never overflows.
    ---@type integer
    local height = math.min(#lines, math.floor(vim.o.lines * 0.8))
    ---@type integer
    local col = math.floor((vim.o.columns - width) / 2)
    ---@type integer
    local row = math.floor((vim.o.lines - height) / 2)

    ---@type integer
    local win = api.nvim_open_win(bufnr, true, {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded",
        zindex = 250,
    })

    -- Override window-local highlights so the float uses the configured bg_float color.
    vim.wo[win].winhighlight = "Normal:LspInfoBG,NormalNC:LspInfoBG"

    -- Apply all accumulated highlights using vim.highlight.range; pcall guards
    -- against stale line indices if lines was shorter than expected.
    for _, hl in ipairs(highlights) do
        pcall(function()
            if hl.col_end == -1 then
                -- col_end == -1 means highlight the entire line.
                vim.highlight.range(bufnr, ns, hl.hl_group, { hl.line, 0 }, { hl.line, -1 }, {})
            else
                vim.highlight.range(bufnr, ns, hl.hl_group, { hl.line, hl.col_start }, { hl.line, hl.col_end }, {})
            end
        end)
    end

    -- Enable manual folds and create one fold per config/tool table block.
    vim.wo[win].foldenable = true
    vim.wo[win].foldmethod = "manual"
    for _, fold in ipairs(folds) do
        if fold.start_line and fold.end_line then
            -- nvim_buf_call is required because :fold operates on the current window.
            pcall(function()
                vim.api.nvim_buf_call(bufnr, function()
                    -- :fold uses 1-based line numbers; our indices are 0-based.
                    vim.cmd(string.format([[%d,%dfold]], fold.start_line + 1, fold.end_line + 1))
                end)
            end)
        end
    end

    -- Buffer-local keymaps for fold navigation and closing the popup.
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "<cmd>normal! za<CR>", {
        noremap = true,
        silent = true,
    })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "za", "<cmd>normal! za<CR>", {
        noremap = true,
        silent = true,
    })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "zo", "<cmd>normal! zo<CR>", {
        noremap = true,
        silent = true,
    })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "zc", "<cmd>normal! zc<CR>", {
        noremap = true,
        silent = true,
    })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "zR", "<cmd>normal! zR<CR>", {
        noremap = true,
        silent = true,
    })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "zM", "<cmd>normal! zM<CR>", {
        noremap = true,
        silent = true,
    })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>close<CR>", {
        noremap = true,
        silent = true,
        nowait = true,
    })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<cmd>close<CR>", {
        noremap = true,
        silent = true,
        nowait = true,
    })

    return {
        bufnr = bufnr,
        win = win,
        -- Convenience close helper for callers that hold the return value.
        close = function()
            if api.nvim_win_is_valid(win) then
                api.nvim_win_close(win, true)
            end
        end,
    }
end

-- ---------------------------------------------------------------------------
-- BASE: invisible float border definition
-- ---------------------------------------------------------------------------

-- An all-space border effectively removes the visible border while still
-- keeping the float padding so content is not flush with the editor edge.
---@type { [1]: string, [2]: string }[]
local _border = {
    { " ", "FloatBorder" },
    { " ", "FloatBorder" },
    { " ", "FloatBorder" },
    { " ", "FloatBorder" },
    { " ", "FloatBorder" },
    { " ", "FloatBorder" },
    { " ", "FloatBorder" },
    { " ", "FloatBorder" },
}

-- ---------------------------------------------------------------------------
-- User commands: standard LSP actions (capability-guarded)
-- Each command first checks that at least one attached client supports the
-- required LSP method before dispatching to vim.lsp.buf.*. This prevents
-- noisy "method not supported" notifications for buffers without LSP.
-- ---------------------------------------------------------------------------

-- Show hover documentation for the symbol under the cursor.
vim.api.nvim_create_user_command("LspHover", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/hover",
    })
    if #clients > 0 then
        vim.lsp.buf.hover({ border = _border })
    else
        vim.notify("No active LSP client supporting hover found", vim.log.levels.WARN)
    end
end, {})

-- Rename the symbol under the cursor across the project.
vim.api.nvim_create_user_command("LspRename", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/rename",
    })
    if #clients > 0 then
        vim.lsp.buf.rename(nil, { border = _border })
    else
        vim.notify("No active LSP client supporting rename found", vim.log.levels.WARN)
    end
end, {})

-- Format the entire current buffer synchronously.
vim.api.nvim_create_user_command("LspFormat", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/formatting",
    })
    if #clients > 0 then
        vim.lsp.buf.format({ async = false })
    else
        vim.notify("No active LSP client supporting formatting found", vim.log.levels.WARN)
    end
end, {})

-- Format only the visually selected range synchronously.
vim.api.nvim_create_user_command("LspRangeFormat", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/rangeFormatting",
    })
    if #clients > 0 then
        -- Read the visual selection marks to derive the line range for formatting.
        local start_row, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
        local end_row, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
        vim.lsp.buf.format({
            range = {
                ["start"] = { start_row, 0 },
                ["end"] = { end_row, 0 },
            },
            async = false,
        })
    else
        vim.notify("No active LSP client supporting range formatting found", vim.log.levels.WARN)
    end
end, { range = true })

-- Show available code actions for the current cursor position or selection.
vim.api.nvim_create_user_command("LspCodeAction", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/codeAction",
    })
    if #clients > 0 then
        vim.lsp.buf.code_action({ border = _border })
    else
        vim.notify("No active LSP client supporting code actions found", vim.log.levels.WARN)
    end
end, {})

-- Jump to the definition of the symbol under the cursor.
vim.api.nvim_create_user_command("LspDefinition", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/definition",
    })
    if #clients > 0 then
        vim.lsp.buf.definition()
    else
        vim.notify("No active LSP client supporting definition found", vim.log.levels.WARN)
    end
end, {})

-- Jump to the type definition of the symbol under the cursor.
vim.api.nvim_create_user_command("LspTypeDefinition", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/typeDefinition",
    })
    if #clients > 0 then
        vim.lsp.buf.type_definition()
    else
        vim.notify("No active LSP client supporting type definition found", vim.log.levels.WARN)
    end
end, {})

-- Jump to the declaration of the symbol under the cursor.
vim.api.nvim_create_user_command("LspDeclaration", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/declaration",
    })
    if #clients > 0 then
        vim.lsp.buf.declaration()
    else
        vim.notify("No active LSP client supporting declaration found", vim.log.levels.WARN)
    end
end, {})

-- List all references to the symbol under the cursor.
vim.api.nvim_create_user_command("LspReferences", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/references",
    })
    if #clients > 0 then
        vim.lsp.buf.references(nil, { border = _border })
    else
        vim.notify("No active LSP client supporting references found", vim.log.levels.WARN)
    end
end, {})

-- List all implementations of the symbol under the cursor.
vim.api.nvim_create_user_command("LspImplementation", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/implementation",
    })
    if #clients > 0 then
        vim.lsp.buf.implementation()
    else
        vim.notify("No active LSP client supporting implementation found", vim.log.levels.WARN)
    end
end, {})

-- Show signature help (parameter hints) for the call under the cursor.
vim.api.nvim_create_user_command("LspSignatureHelp", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/signatureHelp",
    })
    if #clients > 0 then
        vim.lsp.buf.signature_help({ border = _border })
    else
        vim.notify("No active LSP client supporting signature help found", vim.log.levels.WARN)
    end
end, {})

-- List all symbols in the current document.
vim.api.nvim_create_user_command("LspDocumentSymbol", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/documentSymbol",
    })
    if #clients > 0 then
        vim.lsp.buf.document_symbol()
    else
        vim.notify("No active LSP client supporting document symbols found", vim.log.levels.WARN)
    end
end, {})

-- Search symbols across the entire workspace.
vim.api.nvim_create_user_command("LspWorkspaceSymbol", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "workspace/symbol",
    })
    if #clients > 0 then
        vim.lsp.buf.workspace_symbol()
    else
        vim.notify("No active LSP client supporting workspace symbols found", vim.log.levels.WARN)
    end
end, {})

-- Interactively add a directory to the LSP workspace.
vim.api.nvim_create_user_command("LspAddToWorkspaceFolder", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "workspace/didChangeWorkspaceFolders",
    })
    if #clients > 0 then
        vim.lsp.buf.add_workspace_folder()
    else
        vim.notify("No active LSP client supporting workspace folders found", vim.log.levels.WARN)
    end
end, {})

-- Remove a directory from the LSP workspace.
vim.api.nvim_create_user_command("LspRemoveWorkspaceFolder", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "workspace/didChangeWorkspaceFolders",
    })
    if #clients > 0 then
        vim.lsp.buf.remove_workspace_folder()
    else
        vim.notify("No active LSP client supporting workspace folders found", vim.log.levels.WARN)
    end
end, {})

-- Print the list of current LSP workspace folders to the command line.
vim.api.nvim_create_user_command("LspListWorkspaceFolders", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    else
        vim.notify("No active LSP client found", vim.log.levels.WARN)
    end
end, {})

-- Show incoming call hierarchy for the symbol under the cursor.
vim.api.nvim_create_user_command("LspIncomingCalls", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "callHierarchy/incomingCalls",
    })
    if #clients > 0 then
        vim.lsp.buf.incoming_calls()
    else
        vim.notify("No active LSP client supporting incoming calls found", vim.log.levels.WARN)
    end
end, {})

-- Show outgoing call hierarchy for the symbol under the cursor.
vim.api.nvim_create_user_command("LspOutgoingCalls", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "callHierarchy/outgoingCalls",
    })
    if #clients > 0 then
        vim.lsp.buf.outgoing_calls()
    else
        vim.notify("No active LSP client supporting outgoing calls found", vim.log.levels.WARN)
    end
end, {})

-- Clear document highlight marks left by LspDocumentHighlight.
vim.api.nvim_create_user_command("LspClearReferences", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/documentHighlight",
    })
    if #clients > 0 then
        vim.lsp.buf.clear_references()
    else
        vim.notify("No active LSP client supporting document highlights found", vim.log.levels.WARN)
    end
end, {})

-- Highlight all occurrences of the symbol under the cursor in the buffer.
vim.api.nvim_create_user_command("LspDocumentHighlight", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/documentHighlight",
    })
    if #clients > 0 then
        vim.lsp.buf.document_highlight()
    else
        vim.notify("No active LSP client supporting document highlights found", vim.log.levels.WARN)
    end
end, {})

-- Show the diagnostic message for the current line in a float.
vim.api.nvim_create_user_command("LspShowDiagnosticCurrent", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        require("languages.utils.show_diagnostics").line()
    else
        vim.notify("No active LSP client found", vim.log.levels.WARN)
    end
end, {})

-- Jump to the next diagnostic in the current buffer.
vim.api.nvim_create_user_command("LspShowDiagnosticNext", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        require("languages.utils.show_diagnostics").goto_next()
    else
        vim.notify("No active LSP client found", vim.log.levels.WARN)
    end
end, {})

-- Jump to the previous diagnostic in the current buffer.
vim.api.nvim_create_user_command("LspShowDiagnosticPrev", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        require("languages.utils.show_diagnostics").goto_prev()
    else
        vim.notify("No active LSP client found", vim.log.levels.WARN)
    end
end, {})

-- Launch the DAP local debug session using the project-local configuration.
vim.api.nvim_create_user_command("DAPLocal", function()
    local dap_utils = require("languages.utils.dap_fn")
    dap_utils.dap_local()
end, {})

-- ---------------------------------------------------------------------------
-- EXTRA: LVIM-specific management commands
-- ---------------------------------------------------------------------------

-- Open the global LSP server toggle menu (start / disable / enable servers).
vim.api.nvim_create_user_command("LvimLspToggleServers", lvim_toggle_lsp_server, {})

-- Open the per-buffer LSP server toggle menu.
-- Optional argument: buffer number (defaults to current buffer when omitted).
vim.api.nvim_create_user_command("LvimLspToggleServersForBuffer", function(opts)
    local bufnr = tonumber(opts.args)
    lvim_toggle_lsp_for_buffer(bufnr)
end, {
    nargs = "?",
    desc = "Toggle LSP servers for buffer (optionally specify buffer number)",
})

-- Restart a running LSP server and re-attach it to all previously attached buffers.
vim.api.nvim_create_user_command("LvimLspRestart", lvim_lsp_restart, {})

-- Open the rich LSP information floating window.
vim.api.nvim_create_user_command("LvimLspInfo", lvim_lsp_info, {})

-- ---------------------------------------------------------------------------
-- KeyMaps
-- ---------------------------------------------------------------------------

vim.keymap.set("n", "<Leader>ls", lvim_toggle_lsp_server, { desc = "Lvim Toggle LSP servers globally" })
vim.keymap.set("n", "<Leader>lb", lvim_toggle_lsp_for_buffer, { desc = "Lvim Toggle LSP servers for buffer" })
vim.keymap.set("n", "<Leader>lr", lvim_lsp_restart, { desc = "Lvim LSP restart" })
vim.keymap.set("n", "<Leader>li", lvim_lsp_info, { desc = "Lvim LSP info" })
