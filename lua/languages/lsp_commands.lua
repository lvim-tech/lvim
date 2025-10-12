local lsp_manager = require("languages.lsp_manager")

local function lvim_toggle_lsp_server()
    local servers_info = {}
    local running_servers = {}
    local disabled_servers = _G.lsp_disabled_servers or {}
    for _, client in ipairs(vim.lsp.get_clients()) do
        running_servers[client.name] = client.id
    end
    if _G.file_types then
        for server_name, _ in pairs(_G.file_types) do
            servers_info[server_name] = {
                name = server_name,
                status = disabled_servers[server_name] and "Disabled"
                    or running_servers[server_name] and "Running"
                    or "Not Running",
            }
        end
    end
    local has_efm = false
    if _G.global and _G.global.efm and _G.global.efm.filetypes and #_G.global.efm.filetypes > 0 then
        has_efm = true
    end
    if has_efm or running_servers["efm"] or disabled_servers["efm"] then
        servers_info["efm"] = {
            name = "efm",
            status = disabled_servers["efm"] and "Disabled" or running_servers["efm"] and "Running" or "Not Running",
        }
    end
    local has_not_running = false
    local has_disabled = false
    for _, info in pairs(servers_info) do
        if info.status == "Not Running" then
            has_not_running = true
        elseif info.status == "Disabled" then
            has_disabled = true
        end
    end
    local menu_items = {}
    local menu_map = {}
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
    for _, info in pairs(servers_info) do
        local item = {
            text = string.format("%s (%s)", info.name, info.status),
            server = info.name,
            status = info.status,
        }
        table.insert(menu_items, item)
        menu_map[item.text] = item
    end
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

local function lvim_toggle_lsp_for_buffer(bufnr)
    local current_bufnr = bufnr or vim.api.nvim_get_current_buf()
    local ft = vim.bo[current_bufnr].filetype
    if not ft or ft == "" then
        vim.notify("Current buffer has no filetype", vim.log.levels.WARN)
        return
    end

    local compatible_servers = lsp_manager.get_compatible_lsp_for_ft(ft)
    if #compatible_servers == 0 then
        vim.notify("No compatible LSP servers for filetype: " .. ft, vim.log.levels.WARN)
        return
    end

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

    local menu_items = {}
    local has_detachable = false
    local has_attachable = false

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

    local display_items = {}
    for _, item in ipairs(menu_items) do
        table.insert(display_items, item.text)
    end

    vim.ui.select(display_items, { prompt = "LSP for Buffer (" .. ft .. ")" }, function(choice)
        if not choice or choice == "Cancel" then
            return
        end

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

        if action_type == "attach_all" then
            for _, info in pairs(servers_status) do
                if info.status == "buffer_disabled" then
                    lsp_manager.enable_lsp_server_for_buffer(info.name, current_bufnr)
                end
                if info.status == "running" then
                    for _, client in ipairs(vim.lsp.get_clients()) do
                        if client.name == info.name then
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

        if action_type == "detach" then
            lsp_manager.disable_lsp_server_for_buffer(server_name, current_bufnr)
            local _ = vim.notify("Detached " .. server_name .. " from buffer", vim.log.levels.INFO)
        elseif action_type == "enable_buffer" then
            lsp_manager.enable_lsp_server_for_buffer(server_name, current_bufnr)
            local _ = vim.notify("Enabled " .. server_name .. " for buffer", vim.log.levels.INFO)
        elseif action_type == "attach" then
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

local function lvim_lsp_restart()
    local running_clients = vim.lsp.get_clients()
    if #running_clients == 0 then
        vim.notify("No LSP servers are running.", vim.log.levels.INFO)
        return
    end
    local running_servers = {}
    for _, client in ipairs(running_clients) do
        running_servers[client.name] = true
    end
    local menu_items = {}
    local menu_map = {}
    for server_name in pairs(running_servers) do
        local text = string.format("Restart: %s", server_name)
        local item = { text = text, server = server_name, action = "restart" }
        table.insert(menu_items, item)
        menu_map[text] = item
    end
    table.sort(menu_items, function(a, b)
        return a.server < b.server
    end)
    local cancel_item = { text = "Cancel", action = "cancel" }
    table.insert(menu_items, cancel_item)
    menu_map["Cancel"] = cancel_item
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
                vim.lsp.stop_client(client.id, true)
            end
        end
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

local function setup_lsp_error_filter()
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
        if
            type(msg) == "string"
            and msg:match("method [%w%p]+ is not supported by any of the servers registered for the current buffer")
        then
            return
        end
        original_notify(msg, level, opts)
    end
end

setup_lsp_error_filter()

local function lvim_lsp_info()
    local api = vim.api
    local lsp_icons = {
        shape_square = "■",
        shape_diamond = "◆",
        shape_circle = "●",
        arrow = "➤",
        bracket = "[+]",
        cross = "✗",
        check = "✓",
    }
    local INDENT_L0 = ""
    local INDENT_L1 = "  "
    local INDENT_L2 = "    "
    local INDENT_L3 = "      "
    local INDENT_L4 = "        "
    api.nvim_set_hl(0, "LspIcon", { fg = _G.LVIM_COLORS.blue, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoBG", { bg = _G.LVIM_COLORS.bg_float })
    api.nvim_set_hl(0, "LspInfoTitle", { fg = _G.LVIM_COLORS.red, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoServerName", { fg = _G.LVIM_COLORS.orange, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoSection", { fg = _G.LVIM_COLORS.blue, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoKey", { fg = _G.LVIM_COLORS.green, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoValue", { fg = _G.LVIM_COLORS.fg, bg = "NONE" })
    api.nvim_set_hl(0, "LspInfoSeparator", { fg = _G.LVIM_COLORS.blue, bg = "NONE" })
    api.nvim_set_hl(0, "LspInfoLinter", { fg = _G.LVIM_COLORS.purple, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoFormatter", { fg = _G.LVIM_COLORS.purple, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoToolName", { fg = _G.LVIM_COLORS.green, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoBuffer", { fg = _G.LVIM_COLORS.cyan, bg = "NONE", italic = true })
    api.nvim_set_hl(0, "LspInfoDate", { fg = _G.LVIM_COLORS.fg, bg = "NONE", italic = true })
    api.nvim_set_hl(0, "LspInfoConfig", { fg = _G.LVIM_COLORS.fg, bg = "NONE" })
    api.nvim_set_hl(0, "LspInfoConfigKey", { fg = _G.LVIM_COLORS.cyan, bg = "NONE", italic = true })
    api.nvim_set_hl(0, "LspInfoFold", { fg = _G.LVIM_COLORS.yellow, bg = "NONE", bold = true })
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
        vim.notify("No active LSP clients found", vim.log.levels.INFO)
        return
    end
    local popup_width = math.floor(vim.o.columns * 0.8)
    local function center_text(text, width)
        local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
        return string.rep(" ", pad) .. text
    end
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
    local function is_array(t)
        if type(t) ~= "table" then
            return false
        end
        local max, n = 0, 0
        for k, _ in pairs(t) do
            if type(k) == "number" and k > 0 and math.floor(k) == k then
                if k > max then
                    max = k
                end
                n = n + 1
            else
                return false
            end
        end
        return n == max and n > 0
    end
    local lines = {}
    local ns = api.nvim_create_namespace("lsp_info_popup")
    local highlights = {}
    local folds = {}
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
    local function add_separator(hl_group)
        local separator = string.rep("─", popup_width)
        table.insert(lines, separator)
        hl_group = hl_group or "LspInfoSeparator"
        table.insert(highlights, {
            line = #lines - 1,
            col_start = 0,
            col_end = -1,
            hl_group = hl_group,
        })
    end
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
    local title = "LSP SERVERS INFORMATION"
    local centered_title = center_text(title, popup_width)
    table.insert(lines, centered_title)
    add_highlight(#lines - 1, title, "LspInfoTitle")
    add_separator("LspInfoTitle")
    local efm_client, other_clients = nil, {}
    for _, client in ipairs(clients) do
        if client.name == "efm" then
            efm_client = client
        else
            table.insert(other_clients, client)
        end
    end
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
            local linter_by_name = {}
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
            if client.config and client.config.filetypes and #client.config.filetypes > 0 then
                local filetypes = table.concat(client.config.filetypes, ", ")
                local filetype_line = INDENT_L1 .. "Filetypes: " .. filetypes
                table.insert(lines, filetype_line)
                add_highlight(#lines - 1, "Filetypes:", "LspInfoKey")
            end
            if client.cmd and #client.cmd > 0 then
                local cmd_str = table.concat(client.cmd, " ")
                if #cmd_str > popup_width - 10 then
                    cmd_str = cmd_str:sub(1, popup_width - 13) .. "..."
                end
                local cmd_line = INDENT_L1 .. "Command: " .. cmd_str
                table.insert(lines, cmd_line)
                add_highlight(#lines - 1, "Command:", "LspInfoKey")
            end
        end
        if client.config then
            table.insert(lines, "")
            table.insert(lines, INDENT_L1 .. lsp_icons.shape_diamond .. " Server Configuration")
            add_highlight(#lines - 1, "Server Configuration", "LspInfoSection")
            add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
            local has_config = false
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
        table.insert(lines, "")
        table.insert(lines, INDENT_L1 .. lsp_icons.shape_diamond .. " Capabilities")
        add_highlight(#lines - 1, "Capabilities", "LspInfoSection")
        add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
        local has_capabilities = false
        if client.server_capabilities then
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
        table.insert(lines, "")
        table.insert(lines, INDENT_L1 .. lsp_icons.shape_diamond .. " Attached Buffers")
        add_highlight(#lines - 1, "Attached Buffers", "LspInfoSection")
        add_icon_highlight(#lines - 1, lsp_icons.shape_diamond)
        local has_buffers = false
        if client.attached_buffers then
            for bufnr, _ in pairs(client.attached_buffers) do
                has_buffers = true
                local buf_name = vim.api.nvim_buf_get_name(bufnr)
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
    local bufnr = api.nvim_create_buf(false, true)
    vim.bo[bufnr].bufhidden = "wipe"
    api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    local width = popup_width
    local height = math.min(#lines, math.floor(vim.o.lines * 0.8))
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
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
    vim.wo[win].winhighlight = "Normal:LspInfoBG,NormalNC:LspInfoBG"
    for _, hl in ipairs(highlights) do
        pcall(function()
            if hl.col_end == -1 then
                vim.highlight.range(bufnr, ns, hl.hl_group, { hl.line, 0 }, { hl.line, -1 }, {})
            else
                vim.highlight.range(bufnr, ns, hl.hl_group, { hl.line, hl.col_start }, { hl.line, hl.col_end }, {})
            end
        end)
    end
    vim.wo[win].foldenable = true
    vim.wo[win].foldmethod = "manual"
    for _, fold in ipairs(folds) do
        if fold.start_line and fold.end_line then
            pcall(function()
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd(string.format([[%d,%dfold]], fold.start_line + 1, fold.end_line + 1))
                end)
            end)
        end
    end
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
        close = function()
            if api.nvim_win_is_valid(win) then
                api.nvim_win_close(win, true)
            end
        end,
    }
end

-- BASE
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

vim.api.nvim_create_user_command("LspRangeFormat", function()
    local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/rangeFormatting",
    })
    if #clients > 0 then
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

vim.api.nvim_create_user_command("LspListWorkspaceFolders", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    else
        vim.notify("No active LSP client found", vim.log.levels.WARN)
    end
end, {})

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

vim.api.nvim_create_user_command("LspShowDiagnosticCurrent", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        require("languages.utils.show_diagnostics").line()
    else
        vim.notify("No active LSP client found", vim.log.levels.WARN)
    end
end, {})

vim.api.nvim_create_user_command("LspShowDiagnosticNext", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        require("languages.utils.show_diagnostics").goto_next()
    else
        vim.notify("No active LSP client found", vim.log.levels.WARN)
    end
end, {})

vim.api.nvim_create_user_command("LspShowDiagnosticPrev", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        require("languages.utils.show_diagnostics").goto_prev()
    else
        vim.notify("No active LSP client found", vim.log.levels.WARN)
    end
end, {})
vim.api.nvim_create_user_command("DAPLocal", function()
    local dap_utils = require("languages.utils.dap_fn")
    dap_utils.dap_local()
end, {})

-- EXTRA
vim.api.nvim_create_user_command("LvimLspToggleServers", lvim_toggle_lsp_server, {})
vim.api.nvim_create_user_command("LvimLspToggleServersForBuffer", function(opts)
    local bufnr = tonumber(opts.args)
    lvim_toggle_lsp_for_buffer(bufnr)
end, {
    nargs = "?",
    desc = "Toggle LSP servers for buffer (optionally specify buffer number)",
})
vim.api.nvim_create_user_command("LvimLspRestart", lvim_lsp_restart, {})
vim.api.nvim_create_user_command("LvimLspInfo", lvim_lsp_info, {})

-- KeyMaps
vim.keymap.set("n", "<Leader>ls", lvim_toggle_lsp_server, { desc = "Lvim Toggle LSP servers globally" })
vim.keymap.set("n", "<Leader>lb", lvim_toggle_lsp_for_buffer, { desc = "Lvim Toggle LSP servers for buffer" })
vim.keymap.set("n", "<Leader>lr", lvim_lsp_restart, { desc = "Lvim LSP restart" })
vim.keymap.set("n", "<Leader>li", lvim_lsp_info, { desc = "Lvim LSP info" })
