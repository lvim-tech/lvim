local ui_config = require("lvim-ui-config.config")
local select = require("lvim-ui-config.select")
local funcs = require("core.funcs")
local icons = require("configs.base.ui.icons")
local lsp_manager = require("languages.lsp_manager")

local function lvim_auto_format()
    local status
    if _G.LVIM_SETTINGS.autoformat == true then
        status = "Enabled"
    else
        status = "Disabled"
    end
    local opts = ui_config.select({
        "Enable",
        "Disable",
        "Cancel",
    }, { prompt = "AutoFormat (" .. status .. ")" }, {})
    select(opts, function(choice)
        if choice == "Enable" then
            _G.LVIM_SETTINGS["autoformat"] = true
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        elseif choice == "Disable" then
            _G.LVIM_SETTINGS["autoformat"] = false
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        end
    end)
end

local function lvim_inlay_hint()
    local status
    if _G.LVIM_SETTINGS.inlayhint == true then
        status = "Enabled"
    else
        status = "Disabled"
    end
    local opts = ui_config.select({
        "Enable",
        "Disable",
        "Cancel",
    }, { prompt = "InlayHint (" .. status .. ")" }, {})
    select(opts, function(choice)
        if choice == "Enable" then
            local buffers = vim.api.nvim_list_bufs()
            for _, bufnr in ipairs(buffers) do
                if vim.lsp.inlay_hint ~= nil then
                    vim.lsp.inlay_hint.enable(true, { bufnr })
                end
            end
            _G.LVIM_SETTINGS["inlayhint"] = true
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        elseif choice == "Disable" then
            local buffers = vim.api.nvim_list_bufs()
            for _, bufnr in ipairs(buffers) do
                if vim.lsp.inlay_hint ~= nil then
                    vim.lsp.inlay_hint.enable(false, { bufnr })
                end
            end
            _G.LVIM_SETTINGS["inlayhint"] = false
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        end
    end)
end

local function lvim_virtual_diagnostic()
    local virtualdiagnostic = _G.LVIM_SETTINGS.virtualdiagnostic
    local is_empty = not virtualdiagnostic or next(virtualdiagnostic) == nil
    local status
    if not virtualdiagnostic or next(virtualdiagnostic) == nil then
        status = "Disable"
    elseif virtualdiagnostic.lines == true and virtualdiagnostic.text == true then
        status = "Text and Lines"
    elseif virtualdiagnostic.text then
        status = "Only Text"
    elseif virtualdiagnostic.lines then
        status = "Only Lines"
    else
        status = "Disable"
    end
    local opts = ui_config.select({
        "Text And Lines",
        "Only Text",
        "Only Lines",
        "Disable",
        "Cancel",
    }, { prompt = "VirtualDiagnostic (" .. status .. ")" }, {})
    select(opts, function(choice)
        if choice == "Text And Lines" then
            _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                text = true,
                lines = true,
            }
        elseif choice == "Only Text" then
            _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                text = true,
                lines = false,
            }
        elseif choice == "Only Lines" then
            _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                text = false,
                lines = true,
            }
        elseif choice == "Disable" then
            _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                text = false,
                lines = false,
            }
        end
        funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        virtualdiagnostic = _G.LVIM_SETTINGS.virtualdiagnostic
        local config = vim.diagnostic.config
        config({
            virtual_text = (not is_empty and virtualdiagnostic.text) and { prefix = icons.common.dot } or false,
            virtual_lines = not is_empty and virtualdiagnostic.lines or false,
        })
    end)
end

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
    if _G.global and _G.global.efm and _G.global.efm.filetypes and #_G.global.efm.filetypes > 0 then
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
    if has_not_running then
        table.insert(menu_items, { text = "Start All Not Running Servers", action = "start_not_running" })
    end
    if next(running_servers) ~= nil then
        table.insert(menu_items, { text = "Disable All Running Servers", action = "disable_all" })
    end
    if has_disabled then
        table.insert(menu_items, { text = "Enable All Disabled Servers", action = "enable_all" })
    end
    for _, info in pairs(servers_info) do
        table.insert(menu_items, {
            text = string.format("%s (%s)", info.name, info.status),
            server = info.name,
            status = info.status,
        })
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
            local order_a = order[a.action] or 999
            local order_b = order[b.action] or 999
            return order_a < order_b
        end
        if a.status ~= b.status then
            if a.status == "Running" then
                return true
            end
            if b.status == "Running" then
                return false
            end
            if a.status == "Not Running" then
                return true
            end
            if b.status == "Not Running" then
                return false
            end
        end
        local server_a = a.server or ""
        local server_b = b.server or ""
        return server_a < server_b
    end)
    table.insert(menu_items, { text = "Cancel", action = "cancel" })
    local display_items = {}
    for _, item in ipairs(menu_items) do
        table.insert(display_items, item.text)
    end
    local opts = ui_config.select(display_items, { prompt = "LSP Servers Management" }, {})
    select(opts, function(choice)
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

local function lvim_toggle_lsp_for_buffer()
    local current_bufnr = vim.api.nvim_get_current_buf()
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
        table.insert(menu_items, {
            text = "Attach All Compatible Servers",
            action = "attach_all",
        })
    end
    if has_detachable then
        table.insert(menu_items, {
            text = "Detach All Servers",
            action = "detach_all",
        })
    end
    for _, info in pairs(servers_status) do
        local text
        local action_type
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
        if a.action and not b.action then
            return true
        end
        if b.action and not a.action then
            return false
        end
        if (a.action_type or "") ~= (b.action_type or "") then
            local order = {
                detach = 1,
                enable_buffer = 2,
                attach = 3,
                start_attach = 4,
                enable_global = 5,
            }
            local order_a = order[a.action_type] or 999
            local order_b = order[b.action_type] or 999
            return order_a < order_b
        end
        local server_a = a.server or ""
        local server_b = b.server or ""
        return server_a < server_b
    end)
    table.insert(menu_items, { text = "Cancel", action = "cancel" })
    local display_items = {}
    for _, item in ipairs(menu_items) do
        table.insert(display_items, item.text)
    end
    local opts = ui_config.select(display_items, { prompt = "LSP for Buffer (" .. ft .. ")" }, {})
    select(opts, function(choice)
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
        if selected_item.action == "attach_all" then
            for _, info in pairs(servers_status) do
                if info.status == "buffer_disabled" then
                    lsp_manager.enable_lsp_server_for_buffer(info.name, current_bufnr)
                end
                if info.status == "running" then
                    for _, client in ipairs(vim.lsp.get_clients()) do
                        if client.name == info.name then
                            pcall(vim.lsp.buf_attach_client, current_bufnr, client.id)
                            break
                        end
                    end
                elseif info.status == "not_started" then
                    local client_id = lsp_manager.start_language_server(info.name, true)
                    if client_id then
                        pcall(vim.lsp.buf_attach_client, current_bufnr, client_id)
                    end
                end
            end
            vim.notify("Attached all compatible LSP servers to buffer", vim.log.levels.INFO)
            return
        elseif selected_item.action == "detach_all" then
            for _, info in pairs(servers_status) do
                if info.status == "attached" then
                    lsp_manager.disable_lsp_server_for_buffer(info.name, current_bufnr)
                end
            end
            vim.notify("Detached all LSP servers from buffer", vim.log.levels.INFO)
            return
        elseif selected_item.action == "cancel" then
            return
        end
        local action_type = selected_item.action_type
        local server_name = selected_item.server
        if action_type == "detach" then
            lsp_manager.disable_lsp_server_for_buffer(server_name, current_bufnr)
            vim.notify("Detached " .. server_name .. " from buffer", vim.log.levels.INFO)
        elseif action_type == "enable_buffer" then
            lsp_manager.enable_lsp_server_for_buffer(server_name, current_bufnr)
            vim.notify("Enabled " .. server_name .. " for buffer", vim.log.levels.INFO)
        elseif action_type == "attach" then
            for _, client in ipairs(vim.lsp.get_clients()) do
                if client.name == server_name then
                    local success = pcall(vim.lsp.buf_attach_client, current_bufnr, client.id)
                    if success then
                        vim.notify("Attached " .. server_name .. " to buffer", vim.log.levels.INFO)
                    else
                        vim.notify("Failed to attach " .. server_name, vim.log.levels.ERROR)
                    end
                    break
                end
            end
        elseif action_type == "start_attach" then
            local client_id = lsp_manager.start_language_server(server_name, true)
            if client_id then
                local success = pcall(vim.lsp.buf_attach_client, current_bufnr, client_id)
                if success then
                    vim.notify("Started " .. server_name .. " and attached to buffer", vim.log.levels.INFO)
                else
                    vim.notify("Started " .. server_name .. " but failed to attach", vim.log.levels.WARN)
                end
            else
                vim.notify("Failed to start " .. server_name, vim.log.levels.ERROR)
            end
        elseif action_type == "enable_global" then
            lsp_manager.enable_lsp_server_globally(server_name)
            local client_id = lsp_manager.start_language_server(server_name, true)
            if client_id then
                pcall(vim.lsp.buf_attach_client, current_bufnr, client_id)
                vim.notify("Enabled and attached " .. server_name, vim.log.levels.INFO)
            else
                vim.notify("Enabled " .. server_name .. " but failed to start", vim.log.levels.WARN)
            end
        end
    end)
end

local function setup_lsp_error_filter()
    local original_notify = vim.notify
    --- @diagnostic disable-next-line: duplicate-set-field
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

    local preview_icons = {
        server = "■",
        section = "◆",
        bullet = "•",
        triangle = "▶",
        fold = "[+]",
        cross = "✗",
        check = "✓",
    }

    api.nvim_set_hl(0, "LspInfoBG", { bg = _G.LVIM_COLORS.bg_float })
    api.nvim_set_hl(0, "LspInfoTitle", { fg = _G.LVIM_COLORS.red, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoServerName", { fg = _G.LVIM_COLORS.orange, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoSection", { fg = _G.LVIM_COLORS.blue, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoKey", { fg = _G.LVIM_COLORS.green, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoValue", { fg = _G.LVIM_COLORS.fg, bg = "NONE" })
    api.nvim_set_hl(0, "LspInfoSeparator", { fg = _G.LVIM_COLORS.blue, bg = "NONE" })
    api.nvim_set_hl(0, "LspInfoLinter", { fg = _G.LVIM_COLORS.yellow, bg = "NONE", bold = true })
    api.nvim_set_hl(0, "LspInfoFormatter", { fg = _G.LVIM_COLORS.purple, bg = "NONE", bold = true })
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
        local count = 0
        for _ in pairs(t) do
            count = count + 1
        end
        return count > 0 and t[1] ~= nil
    end

    local lines = {}
    local ns = api.nvim_create_namespace("lsp_info_popup")
    local highlights = {}
    local folds = {}

    local function add_highlight(line_idx, substr, hl_group)
        local line_text = lines[line_idx + 1]
        local s, e = string.find(line_text, vim.pesc(substr), 1, true)
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
        indent = indent or 0
        local indent_str = string.rep(" ", indent)
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
                local key_str
                if type(k) == "number" then
                    key_str = "[" .. k .. "]"
                else
                    key_str = k
                end

                if type(v) == "table" then
                    if vim.tbl_isempty(v) then
                        table.insert(line_list, indent_str .. "  " .. key_str .. ": {}")
                        add_highlight(#line_list - 1, key_str, "LspInfoConfigKey")
                    else
                        if is_array(v) and #v <= 5 then
                            local is_simple_array = true
                            for _, item in ipairs(v) do
                                if type(item) == "table" then
                                    is_simple_array = false
                                    break
                                end
                            end
                            if is_simple_array then
                                local items = {}
                                for _, item in ipairs(v) do
                                    table.insert(items, format_value(item))
                                end
                                local items_str = table.concat(items, ", ")
                                table.insert(line_list, indent_str .. "  " .. key_str .. ": [" .. items_str .. "]")
                                add_highlight(#line_list - 1, key_str, "LspInfoConfigKey")
                            else
                                table.insert(line_list, indent_str .. "  " .. key_str .. ": {")
                                add_highlight(#line_list - 1, key_str, "LspInfoConfigKey")
                                display_table(v, line_list, highlight_list, indent + 4)
                                table.insert(line_list, indent_str .. "  }")
                            end
                        else
                            table.insert(line_list, indent_str .. "  " .. key_str .. ": {")
                            add_highlight(#line_list - 1, key_str, "LspInfoConfigKey")
                            display_table(v, line_list, highlight_list, indent + 4)
                            table.insert(line_list, indent_str .. "  }")
                        end
                    end
                else
                    table.insert(line_list, indent_str .. "  " .. key_str .. ": " .. format_value(v))
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

    for _, client in ipairs(clients) do
        table.insert(lines, "")
        local server_line = preview_icons.server .. " " .. client.name .. " (ID: " .. client.id .. ")"
        table.insert(lines, server_line)
        add_highlight(#lines - 1, client.name, "LspInfoServerName")
        if client.name == "efm" then
            -- МОДИФИЦИРАНА ЧАСТ: Използваме _G.efm_configs вместо _G.global.efm
            if _G.efm_configs then
                table.insert(lines, "")
                table.insert(lines, "  " .. preview_icons.section .. " EFM Tools by Filetype")
                add_highlight(#lines - 1, "EFM Tools by Filetype", "LspInfoSection")
                local buffers_by_filetype = {}
                if client.attached_buffers then
                    for bufnr, _ in pairs(client.attached_buffers) do
                        local buf_name = vim.api.nvim_buf_get_name(bufnr)
                        local display_name = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":~:.") or "[No Name]"
                        local filetype = vim.bo[bufnr].filetype
                        if not buffers_by_filetype[filetype] then
                            buffers_by_filetype[filetype] = {}
                        end
                        table.insert(buffers_by_filetype[filetype], {
                            bufnr = bufnr,
                            name = display_name,
                        })
                    end
                end
                local has_tools = false
                for filetype, configs in pairs(_G.efm_configs) do
                    local formatters, linters = {}, {}
                    for _, config in ipairs(configs) do
                        local tool_name = config.server_name or config.fPrefix or config.lPrefix or "Unknown"
                        if config.fPrefix or (config.formatCommand and config.formatCommand ~= "") then
                            table.insert(formatters, { name = tool_name, config = config })
                        elseif config.lPrefix or (config.lintCommand and config.lintCommand ~= "") then
                            table.insert(linters, { name = tool_name, config = config })
                        end
                    end
                    if #formatters > 0 or #linters > 0 then
                        has_tools = true
                        table.insert(lines, "")
                        local filetype_line = "    " .. preview_icons.bullet .. " Filetype: " .. filetype
                        table.insert(lines, filetype_line)
                        add_highlight(#lines - 1, "Filetype: " .. filetype, "LspInfoKey")
                        if #linters > 0 then
                            local linter_line = "      " .. preview_icons.triangle .. " Linters: " .. preview_icons.fold
                            table.insert(lines, linter_line)
                            add_highlight(#lines - 1, "Linters:", "LspInfoLinter")
                            add_highlight(#lines - 1, preview_icons.fold, "LspInfoFold")
                            for i, linter in ipairs(linters) do
                                local fold_info = { id = "linter_" .. filetype .. "_" .. i }
                                table.insert(folds, fold_info)
                                table.insert(lines, "        - " .. linter.name)
                                display_table(linter.config, lines, highlights, 10, fold_info)
                            end
                        end
                        if #formatters > 0 then
                            local formatter_line = "      "
                                .. preview_icons.triangle
                                .. " Formatters: "
                                .. preview_icons.fold
                            table.insert(lines, formatter_line)
                            add_highlight(#lines - 1, "Formatters:", "LspInfoFormatter")
                            add_highlight(#lines - 1, preview_icons.fold, "LspInfoFold")
                            for i, formatter in ipairs(formatters) do
                                local fold_info = { id = "formatter_" .. filetype .. "_" .. i }
                                table.insert(folds, fold_info)
                                table.insert(lines, "        - " .. formatter.name)
                                display_table(formatter.config, lines, highlights, 10, fold_info)
                            end
                        end
                        if buffers_by_filetype[filetype] and #buffers_by_filetype[filetype] > 0 then
                            local buffer_line = "      "
                                .. preview_icons.triangle
                                .. " Active Buffers: "
                                .. preview_icons.fold
                            table.insert(lines, buffer_line)
                            add_highlight(#lines - 1, "Active Buffers:", "LspInfoFormatter")
                            add_highlight(#lines - 1, preview_icons.fold, "LspInfoFold")
                            local fold_info = { id = "buffers_" .. filetype }
                            table.insert(folds, fold_info)
                            fold_info.start_line = #lines
                            for _, buf in ipairs(buffers_by_filetype[filetype]) do
                                table.insert(lines, "        - Buffer " .. buf.bufnr .. ": " .. buf.name)
                            end
                            fold_info.end_line = #lines - 1
                        end
                    end
                end
                if not has_tools then
                    table.insert(lines, "    " .. preview_icons.cross .. " No tools configured for EFM")
                    add_highlight(#lines - 1, preview_icons.cross, "LspInfoKey")
                end
            end
            -- Получаваме поддържаните filetypes от клиента
            local filetypes = client.config and client.config.filetypes or {}
            if #filetypes > 0 then
                table.insert(lines, "")
                table.insert(lines, "  " .. preview_icons.section .. " Supported Filetypes")
                add_highlight(#lines - 1, "Supported Filetypes", "LspInfoSection")
                local filetypes_str = table.concat(filetypes, ", ")
                table.insert(lines, "    " .. filetypes_str)
            end
        else
            if client.config and client.config.filetypes and #client.config.filetypes > 0 then
                local filetypes = table.concat(client.config.filetypes, ", ")
                local filetype_line = "  Filetypes: " .. filetypes
                table.insert(lines, filetype_line)
                add_highlight(#lines - 1, "Filetypes:", "LspInfoKey")
            end
            if client.cmd and #client.cmd > 0 then
                local cmd_str = table.concat(client.cmd, " ")
                if #cmd_str > popup_width - 10 then
                    cmd_str = cmd_str:sub(1, popup_width - 13) .. "..."
                end
                local cmd_line = "  Command: " .. cmd_str
                table.insert(lines, cmd_line)
                add_highlight(#lines - 1, "Command:", "LspInfoKey")
            end
        end
        if client.config then
            table.insert(lines, "")
            table.insert(lines, "  " .. preview_icons.section .. " Server Configuration")
            add_highlight(#lines - 1, "Server Configuration", "LspInfoSection")
            local has_config = false
            local expanded_settings = deep_copy_table(client.config.settings or {})
            local expanded_init_options = deep_copy_table(client.config.init_options or {})
            local expanded_capabilities = deep_copy_table(client.config.capabilities or {})
            if client.config.settings and not vim.tbl_isempty(client.config.settings) then
                has_config = true
                local settings_line = "    " .. preview_icons.bullet .. " Settings: " .. preview_icons.fold
                table.insert(lines, settings_line)
                add_highlight(#lines - 1, "Settings:", "LspInfoKey")
                add_highlight(#lines - 1, preview_icons.fold, "LspInfoFold")
                local fold_info = { id = "settings_" .. client.name }
                table.insert(folds, fold_info)
                display_table(expanded_settings, lines, highlights, 6, fold_info)
            end
            if client.config.init_options and not vim.tbl_isempty(client.config.init_options) then
                has_config = true
                local init_options_line = "    "
                    .. preview_icons.bullet
                    .. " Initialization Options: "
                    .. preview_icons.fold
                table.insert(lines, init_options_line)
                add_highlight(#lines - 1, "Initialization Options:", "LspInfoKey")
                add_highlight(#lines - 1, preview_icons.fold, "LspInfoFold")
                local fold_info = { id = "init_options_" .. client.name }
                table.insert(folds, fold_info)
                display_table(expanded_init_options, lines, highlights, 6, fold_info)
            end
            if client.config.root_dir then
                has_config = true
                local root_dir_line = "    " .. preview_icons.bullet .. " Root Dir:"
                table.insert(lines, root_dir_line)
                add_highlight(#lines - 1, "Root Dir:", "LspInfoKey")
                if type(client.config.root_dir) == "function" then
                    table.insert(lines, "      <function>")
                else
                    table.insert(lines, "      " .. tostring(client.config.root_dir))
                end
            end
            if client.config.capabilities and not vim.tbl_isempty(client.config.capabilities) then
                has_config = true
                local capabilities_line = "    " .. preview_icons.bullet .. " Capabilities: " .. preview_icons.fold
                table.insert(lines, capabilities_line)
                add_highlight(#lines - 1, "Capabilities:", "LspInfoKey")
                add_highlight(#lines - 1, preview_icons.fold, "LspInfoFold")
                local fold_info = { id = "capabilities_" .. client.name }
                table.insert(folds, fold_info)
                display_table(expanded_capabilities, lines, highlights, 6, fold_info)
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
                local other_options_line = "    " .. preview_icons.bullet .. " Other Options: " .. preview_icons.fold
                table.insert(lines, other_options_line)
                add_highlight(#lines - 1, "Other Options:", "LspInfoKey")
                add_highlight(#lines - 1, preview_icons.fold, "LspInfoFold")
                local fold_info = { id = "other_options_" .. client.name }
                table.insert(folds, fold_info)
                display_table(other_config, lines, highlights, 6, fold_info)
            end
            if not has_config then
                table.insert(lines, "    " .. preview_icons.cross .. " No detailed configuration available")
                add_highlight(#lines - 1, preview_icons.cross, "LspInfoKey")
            end
        end
        table.insert(lines, "")
        table.insert(lines, "  " .. preview_icons.section .. " Capabilities")
        add_highlight(#lines - 1, "Capabilities", "LspInfoSection")
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
                    local cap_line = "    " .. preview_icons.check .. " " .. cap.name
                    table.insert(lines, cap_line)
                    add_highlight(#lines - 1, preview_icons.check, "LspInfoKey")
                end
            end
        end
        if not has_capabilities then
            table.insert(lines, "    " .. preview_icons.cross .. " No specific capabilities detected")
            add_highlight(#lines - 1, preview_icons.cross, "LspInfoKey")
        end
        table.insert(lines, "")
        table.insert(lines, "  " .. preview_icons.section .. " Attached Buffers")
        add_highlight(#lines - 1, "Attached Buffers", "LspInfoSection")
        local has_buffers = false
        if client.attached_buffers then
            for bufnr, _ in pairs(client.attached_buffers) do
                has_buffers = true
                local buf_name = vim.api.nvim_buf_get_name(bufnr)
                local display_name = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":~:.") or "[No Name]"
                local filetype = vim.bo[bufnr].filetype
                local buffer_info = "    " .. preview_icons.bullet .. " Buffer " .. bufnr .. ": " .. display_name
                if filetype and filetype ~= "" then
                    buffer_info = buffer_info .. " (" .. filetype .. ")"
                end
                table.insert(lines, buffer_info)
                add_highlight(#lines - 1, preview_icons.bullet, "LspInfoKey")
            end
        end
        if not has_buffers then
            table.insert(lines, "    " .. preview_icons.cross .. " No buffers attached")
            add_highlight(#lines - 1, preview_icons.cross, "LspInfoKey")
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

    -- Add key mapping to close the window
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

vim.api.nvim_create_user_command("LvimVirtualDiagnostic", lvim_virtual_diagnostic, {})
vim.api.nvim_create_user_command("LvimAutoFormat", lvim_auto_format, {})
vim.api.nvim_create_user_command("LvimInlayHint", lvim_inlay_hint, {})
vim.api.nvim_create_user_command("LvimLspToggleServers", lvim_toggle_lsp_server, {})
vim.api.nvim_create_user_command("LvimLspToggleServersForBuffer", lvim_toggle_lsp_for_buffer, {})
vim.api.nvim_create_user_command("LvimLspInfo", lvim_lsp_info, {})

local keymap = vim.keymap.set

keymap("n", "<Leader>ld", "<cmd>LvimVirtualDiagnostic<CR>", { desc = "Lvim Toggle virtual diagnostics" })
keymap("n", "<Leader>lf", "<cmd>LvimAutoFormat<CR>", { desc = "Lvim Toggle auto format" })
keymap("n", "<Leader>lh", "<cmd>LvimInlayHint<CR>", { desc = "Lvim Toggle inlay hints" })
keymap("n", "<Leader>ls", "<cmd>LvimLspToggleServers<CR>", { desc = "Lvim Toggle LSP servers globally" })
keymap("n", "<Leader>lb", "<cmd>LvimLspToggleServersForBuffer<CR>", { desc = "Lvim Toggle LSP servers for buffer" })
keymap("n", "<Leader>li", "<cmd>LvimLspInfo<CR>", { desc = "Lvim LSP info" })
