local api = vim.api

local POPUP_WIDTH = 40
local BAR_MARGIN = 2

local PROGRESS_CHAR = "="
local REMAIN_CHAR = "="
local BAR_WIDTH_CHARS = POPUP_WIDTH - BAR_MARGIN

api.nvim_set_hl(0, "MasonPopupBG", { bg = _G.LVIM_COLORS.bg_float })
api.nvim_set_hl(0, "MasonBarBG", { fg = _G.LVIM_COLORS.fg, bg = "NONE" })
api.nvim_set_hl(0, "MasonBarFG", { fg = _G.LVIM_COLORS.blue, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonTitle", { fg = _G.LVIM_COLORS.red, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonPkgName", { fg = _G.LVIM_COLORS.orange, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonIconProgress", { fg = _G.LVIM_COLORS.blue, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonIconOk", { fg = _G.LVIM_COLORS.green, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonIconError", { fg = _G.LVIM_COLORS.red, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonIconWarn", { fg = _G.LVIM_COLORS.orange, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonStatusOk", { fg = _G.LVIM_COLORS.green, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonStatusError", { fg = _G.LVIM_COLORS.red, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonStatusWarn", { fg = _G.LVIM_COLORS.orange, bg = "NONE", bold = true })

local HL_BAR_BG = "MasonBarBG"
local HL_BAR_PROGRESS = "MasonBarFG"
local HL_TITLE = "MasonTitle"
local HL_POPUP_BG = "MasonPopupBG"
local HL_PKG_NAME = "MasonPkgName"
local HL_ICON_PROGRESS = "MasonIconProgress"
local HL_ICON_OK = "MasonIconOk"
local HL_ICON_ERROR = "MasonIconError"
local HL_ICON_WARN = "MasonIconWarn"

local SPINNER_FRAMES = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local SPINNER_INTERVAL = 120

local ICON_OK = ""
local ICON_ERROR = ""
local ICON_WARN = ""

local allin1 = {
    tools = {},
    win = nil,
    bufnr = nil,
    states = {},
    timers = {},
    ns = api.nvim_create_namespace("custom_mason_progress"),
    callbacks = {},
}

local function make_bar(percent)
    local n_fill = math.floor(BAR_WIDTH_CHARS * percent / 100 + 0.5)
    local n_empty = BAR_WIDTH_CHARS - n_fill
    local bar = string.rep(PROGRESS_CHAR, n_fill) .. string.rep(REMAIN_CHAR, n_empty)
    return bar, n_fill, BAR_WIDTH_CHARS
end

local function center_text(text, width)
    local pad = math.max(0, math.floor((width - #text) / 2))
    return string.rep(" ", pad) .. text
end

local function build_lines(tools, states)
    local lines = {}
    local line_meta = {}
    local title = center_text("LVIM INSTALLER", POPUP_WIDTH)
    table.insert(lines, title)
    table.insert(line_meta, {})
    local bar_infos = {}
    for _, tool in ipairs(tools) do
        local s = states[tool]
        table.insert(lines, tool)
        table.insert(line_meta, { pkg_name = true })
        local bar, n_fill, n_total = make_bar(s.percent or 0)
        table.insert(lines, bar)
        table.insert(line_meta, { bar = { n_fill = n_fill, n_total = n_total } })
        table.insert(bar_infos, { n_fill = n_fill, n_total = n_total })
        local status_str, icon_str, icon_hl
        if s.status == "pending" then
            local frame = s.spinner_frame or 1
            icon_str = SPINNER_FRAMES[frame]
            status_str = " Installing"
            icon_hl = HL_ICON_PROGRESS
        elseif s.status == "ok" then
            icon_str = ICON_OK
            status_str = " Installed"
            icon_hl = HL_ICON_OK
        elseif s.status == "fail" then
            icon_str = ICON_ERROR
            status_str = " Error"
            icon_hl = HL_ICON_ERROR
        elseif s.status == "timeout" then
            icon_str = ICON_WARN
            status_str = " Timeout"
            icon_hl = HL_ICON_WARN
        else
            icon_str = ""
            status_str = ""
            icon_hl = nil
        end
        table.insert(lines, icon_str .. status_str)
        table.insert(line_meta, {
            icon_len = vim.str_utfindex(icon_str, "utf-8", #icon_str),
            icon_hl = icon_hl,
        })
    end
    return lines, bar_infos, line_meta
end

local function update_popup()
    local tools = allin1.tools
    local states = allin1.states
    local height = #tools * 3 + 1
    local width = POPUP_WIDTH
    local col = vim.o.columns - width
    local row = 1
    local lines, bar_infos, line_meta = build_lines(tools, states)
    while #lines < height do
        table.insert(lines, "")
    end
    if allin1.win and api.nvim_win_is_valid(allin1.win) then
        api.nvim_win_set_config(allin1.win, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
        })
        api.nvim_buf_set_lines(allin1.bufnr, 0, -1, false, lines)
    else
        local bufnr = api.nvim_create_buf(false, true)
        vim.bo[bufnr].bufhidden = "wipe"
        api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        allin1.win = api.nvim_open_win(bufnr, false, {
            style = "minimal",
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            border = "rounded",
            focusable = false,
            zindex = 250,
            noautocmd = true,
        })
        allin1.bufnr = bufnr
        api.nvim_set_option_value(
            "winhighlight",
            "Normal:" .. HL_POPUP_BG .. ",NormalNC:" .. HL_POPUP_BG,
            { win = allin1.win }
        )
    end
    if allin1.bufnr then
        api.nvim_buf_clear_namespace(allin1.bufnr, allin1.ns, 0, -1)
        vim.hl.range(allin1.bufnr, allin1.ns, HL_TITLE, { 0, 0 }, { 0, -1 })
        for i, _ in ipairs(tools) do
            local name_line = 1 + (i - 1) * 3
            local bar_line = name_line + 1
            local status_line = name_line + 2
            local barinfo = bar_infos[i]
            vim.hl.range(allin1.bufnr, allin1.ns, HL_PKG_NAME, { name_line, 0 }, { name_line, -1 })
            if barinfo.n_fill > 0 then
                vim.hl.range(allin1.bufnr, allin1.ns, HL_BAR_PROGRESS, { bar_line, 0 }, { bar_line, barinfo.n_fill })
            end
            if barinfo.n_total > barinfo.n_fill then
                vim.hl.range(
                    allin1.bufnr,
                    allin1.ns,
                    HL_BAR_BG,
                    { bar_line, barinfo.n_fill },
                    { bar_line, barinfo.n_total }
                )
            end
            local meta = line_meta[status_line + 1]
            if meta and meta.icon_hl and meta.icon_len > 0 then
                vim.hl.range(allin1.bufnr, allin1.ns, meta.icon_hl, { status_line, 0 }, { status_line, meta.icon_len })
            end
        end
    end
end

local function close_popup()
    if allin1.win and api.nvim_win_is_valid(allin1.win) then
        api.nvim_win_close(allin1.win, true)
    end
    allin1.win = nil
    allin1.bufnr = nil
    allin1.tools = {}
    allin1.states = {}
    allin1.timers = {}
    allin1.callbacks = {}
end

local function add_tools(new_tools)
    local added = false
    local mason_registry = require("mason-registry")
    for _, tool in ipairs(new_tools) do
        local name = tool
        local already = false
        for _, t in ipairs(allin1.tools) do
            if t == name then
                already = true
                break
            end
        end
        if not already then
            local ok, pkg = pcall(mason_registry.get_package, name)
            if ok and pkg and not pkg:is_installed() then
                table.insert(allin1.tools, name)
                allin1.states[name] = { status = "pending", percent = 0, spinner_frame = 1 }
                added = true
            end
        end
    end
    return added
end

local function are_tools_completed(tools)
    for _, tool in ipairs(tools) do
        if allin1.states[tool] and allin1.states[tool].status == "pending" then
            return false
        end
    end
    return true
end

local function check_callbacks()
    local callbacks_to_remove = {}
    for i, callback_data in ipairs(allin1.callbacks) do
        if are_tools_completed(callback_data.tools) then
            if callback_data.callback then
                callback_data.callback()
            end
            table.insert(callbacks_to_remove, i)
        end
    end
    for i = #callbacks_to_remove, 1, -1 do
        table.remove(allin1.callbacks, callbacks_to_remove[i])
    end
    if #allin1.callbacks == 0 then
        local all_done = true
        for _, s in pairs(allin1.states) do
            if s.status == "pending" then
                all_done = false
                break
            end
        end
        if all_done then
            local lsp_manager = require("languages.lsp_manager")
            lsp_manager.set_installation_status(false)
            vim.defer_fn(close_popup, 10000)
        end
    end
end

local function start_progress(tool)
    local progress = 0
    local step = 2
    allin1.states[tool].spinner_frame = 1
    allin1.timers[tool] = vim.uv.new_timer()
    allin1.timers[tool]:start(
        0,
        SPINNER_INTERVAL,
        vim.schedule_wrap(function()
            if allin1.states[tool].status ~= "pending" then
                allin1.timers[tool]:stop()
                allin1.timers[tool]:close()
                allin1.timers[tool] = nil
                return
            end
            if progress < 100 then
                progress = math.min(progress + step, 100)
                allin1.states[tool].percent = progress
            end
            allin1.states[tool].spinner_frame = (allin1.states[tool].spinner_frame % #SPINNER_FRAMES) + 1
            update_popup()
        end)
    )
end

local M = {}
M.ensure_mason_tools = function(tools, cb)
    local mason_registry = require("mason-registry")
    local lsp_manager = require("languages.lsp_manager")
    tools = tools or {}
    if #tools == 0 then
        if cb then
            cb()
        end
        return
    end
    lsp_manager.set_installation_status(true)
    if cb then
        local original_callback = cb
        local wrapped_callback = function()
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
                    vim.diagnostic.reset(nil, bufnr)
                end
            end
            original_callback()
        end
        table.insert(allin1.callbacks, {
            tools = vim.deepcopy(tools),
            callback = wrapped_callback,
        })
    end
    local some_added = add_tools(tools)
    if not some_added then
        lsp_manager.set_installation_status(false)
        check_callbacks()
        return
    end
    update_popup()
    for _, tool in ipairs(tools) do
        if allin1.states[tool] and allin1.states[tool].status == "pending" and not allin1.timers[tool] then
            start_progress(tool)
            local pkg = mason_registry.get_package(tool)
            pkg:install():once(
                "closed",
                vim.schedule_wrap(function()
                    vim.defer_fn(function()
                        local installed = pkg:is_installed()
                        if allin1.timers[tool] then
                            allin1.timers[tool]:stop()
                            allin1.timers[tool]:close()
                            allin1.timers[tool] = nil
                        end
                        if installed then
                            allin1.states[tool].status = "ok"
                            allin1.states[tool].percent = 100
                        else
                            allin1.states[tool].status = "fail"
                            allin1.states[tool].percent = 0
                        end
                        update_popup()
                        check_callbacks()
                    end, 1000)
                end)
            )
        end
    end
    vim.defer_fn(function()
        for _, tool in ipairs(tools) do
            if allin1.states[tool] and allin1.states[tool].status == "pending" then
                if allin1.timers[tool] then
                    allin1.timers[tool]:stop()
                    allin1.timers[tool]:close()
                    allin1.timers[tool] = nil
                end
                allin1.states[tool].status = "timeout"
                allin1.states[tool].percent = 0
            end
        end
        update_popup()
        lsp_manager.set_installation_status(false)
        check_callbacks()
    end, 8000)
end

return M
