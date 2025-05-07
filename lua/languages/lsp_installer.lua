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
local SPINNER_INTERVAL = 80

local ICON_OK = ""
local ICON_ERROR = ""
local ICON_WARN = ""

-- Константни значения за статуса на инсталацията
local STATUS = {
    PENDING = "pending",
    OK = "ok",
    FAIL = "fail",
    TIMEOUT = "timeout",
}

-- Константни текстове за статуса
local STATUS_TEXT = {
    [STATUS.PENDING] = "Installing",
    [STATUS.OK] = "Installed",
    [STATUS.FAIL] = "Error",
    [STATUS.TIMEOUT] = "Timeout",
}

-- Общ таймер за обновяване на UI
local refresh_timer = nil

-- Лимит за инсталация (2 минути)
local INSTALLATION_TIMEOUT = 120000

local allin1 = {
    tools = {},
    win = nil,
    bufnr = nil,
    states = {},
    ns = api.nvim_create_namespace("custom_mason_progress"),
    callbacks = {},
    closed = false,
    start_time = nil,
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
        if not s then
            goto continue
        end

        table.insert(lines, tool)
        table.insert(line_meta, { pkg_name = true })

        local bar, n_fill, n_total = make_bar(s.percent or 0)
        table.insert(lines, bar)
        table.insert(line_meta, { bar = { n_fill = n_fill, n_total = n_total } })
        table.insert(bar_infos, { n_fill = n_fill, n_total = n_total })

        local status_text, icon_str, icon_hl
        local spinner_frame = (s.spinner_frame or 1) % #SPINNER_FRAMES

        if s.status == STATUS.PENDING then
            icon_str = SPINNER_FRAMES[spinner_frame + 1]
            status_text = s.message or STATUS_TEXT[s.status]
            icon_hl = HL_ICON_PROGRESS
        elseif s.status == STATUS.OK then
            icon_str = ICON_OK
            status_text = STATUS_TEXT[s.status]
            icon_hl = HL_ICON_OK
        elseif s.status == STATUS.FAIL then
            icon_str = ICON_ERROR
            status_text = STATUS_TEXT[s.status]
            icon_hl = HL_ICON_ERROR
        elseif s.status == STATUS.TIMEOUT then
            icon_str = ICON_WARN
            status_text = STATUS_TEXT[s.status]
            icon_hl = HL_ICON_WARN
        else
            icon_str = ""
            status_text = ""
            icon_hl = nil
        end

        table.insert(lines, icon_str .. " " .. status_text)
        table.insert(line_meta, {
            icon_len = vim.str_utfindex(icon_str, "utf-8", #icon_str),
            icon_hl = icon_hl,
        })

        ::continue::
    end
    return lines, bar_infos, line_meta
end

local function update_popup()
    if allin1.closed then
        return
    end

    if not allin1.tools or #allin1.tools == 0 then
        if allin1.win and api.nvim_win_is_valid(allin1.win) then
            api.nvim_win_close(allin1.win, true)
        end
        allin1.win = nil
        allin1.bufnr = nil
        return
    end

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
        pcall(api.nvim_win_set_config, allin1.win, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
        })
        pcall(api.nvim_buf_set_lines, allin1.bufnr, 0, -1, false, lines)
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
        pcall(api.nvim_buf_clear_namespace, allin1.bufnr, allin1.ns, 0, -1)
        pcall(vim.highlight.range, allin1.bufnr, allin1.ns, HL_TITLE, { 0, 0 }, { 0, -1 })
        for i, _ in ipairs(tools) do
            local name_line = 1 + (i - 1) * 3
            local bar_line = name_line + 1
            local status_line = name_line + 2
            local barinfo = bar_infos[i]
            if not barinfo then
                goto continue
            end

            pcall(vim.highlight.range, allin1.bufnr, allin1.ns, HL_PKG_NAME, { name_line, 0 }, { name_line, -1 })
            if barinfo.n_fill > 0 then
                pcall(
                    vim.highlight.range,
                    allin1.bufnr,
                    allin1.ns,
                    HL_BAR_PROGRESS,
                    { bar_line, 0 },
                    { bar_line, barinfo.n_fill }
                )
            end
            if barinfo.n_total > barinfo.n_fill then
                pcall(
                    vim.highlight.range,
                    allin1.bufnr,
                    allin1.ns,
                    HL_BAR_BG,
                    { bar_line, barinfo.n_fill },
                    { bar_line, barinfo.n_total }
                )
            end
            local meta = line_meta[status_line + 1]
            if meta and meta.icon_hl and meta.icon_len > 0 then
                pcall(
                    vim.highlight.range,
                    allin1.bufnr,
                    allin1.ns,
                    meta.icon_hl,
                    { status_line, 0 },
                    { status_line, meta.icon_len }
                )
            end

            ::continue::
        end
    end
end

local function close_popup()
    if refresh_timer and not refresh_timer:is_closing() then
        refresh_timer:stop()
        refresh_timer:close()
        refresh_timer = nil
    end

    allin1.closed = true

    if allin1.win and api.nvim_win_is_valid(allin1.win) then
        api.nvim_win_close(allin1.win, true)
    end
    allin1.win = nil
    allin1.bufnr = nil

    vim.defer_fn(function()
        allin1.tools = {}
        allin1.states = {}
        allin1.callbacks = {}
        allin1.closed = false
    end, 200)
end

local function add_tools(new_tools)
    local added = false
    local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
    if not mason_registry_ok then
        vim.notify("Грешка при зареждане на mason-registry", vim.log.levels.ERROR)
        return false
    end

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
                allin1.states[name] = {
                    status = STATUS.PENDING,
                    percent = 0,
                    spinner_frame = 0,
                    message = "Preparing...",
                    start_time = os.time(),
                }
                added = true
            end
        end
    end
    return added
end

local function are_tools_completed(tools)
    for _, tool in ipairs(tools) do
        if allin1.states[tool] and allin1.states[tool].status == STATUS.PENDING then
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
            if s.status == STATUS.PENDING then
                all_done = false
                break
            end
        end
        if all_done then
            local lsp_manager_ok, lsp_manager = pcall(require, "languages.lsp_manager")
            if lsp_manager_ok and lsp_manager then
                pcall(lsp_manager.set_installation_status, false)
            end
            vim.defer_fn(close_popup, 10000)
        end
    end
end

-- Глобален таймер за обновяване на UI и прогрес
local function start_ui_refresh_timer()
    if refresh_timer and not refresh_timer:is_closing() then
        refresh_timer:stop()
        refresh_timer:close()
    end

    refresh_timer = vim.loop.new_timer()
    refresh_timer:start(
        0,
        50,
        vim.schedule_wrap(function()
            if allin1.closed then
                if refresh_timer and not refresh_timer:is_closing() then
                    refresh_timer:stop()
                    refresh_timer:close()
                    refresh_timer = nil
                end
                return
            end

            local now = os.time()
            local elapsed_total = now - (allin1.start_time or now)

            -- Обновяваме прогрес индикатори за всеки инструмент
            for _, tool in ipairs(allin1.tools) do
                local state = allin1.states[tool]
                if state and state.status == STATUS.PENDING then
                    -- Увеличаваме spinner frame индекса за анимацията
                    state.spinner_frame = (state.spinner_frame or 0) + 1

                    -- Изчисляваме прогреса на базата на времето
                    local elapsed = now - (state.start_time or now)
                    local estimated_duration = 45 -- прибл. продължителност на инсталация в секунди

                    -- Максимум 95% за автоматичен прогрес (последните 5% са reserved за финализиране)
                    local auto_progress = math.min(95, (elapsed / estimated_duration) * 100)

                    -- Ако нямаме real progress и auto_progress е по-голям от текущия, обновяваме
                    if not state.has_real_progress and auto_progress > state.percent then
                        state.percent = auto_progress

                        -- Актуализираме и съобщението според прогреса
                        if state.percent < 20 then
                            state.message = "Downloading..."
                        elseif state.percent < 50 then
                            state.message = "Extracting files..."
                        elseif state.percent < 80 then
                            state.message = "Installing components..."
                        else
                            state.message = "Finalizing..."
                        end
                    end
                end
            end

            -- Обновяваме интерфейса
            pcall(update_popup)
        end)
    )
end

local M = {}
M.ensure_mason_tools = function(tools, cb)
    local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
    if not mason_registry_ok then
        vim.notify("Грешка при зареждане на mason-registry", vim.log.levels.ERROR)
        if cb then
            cb()
        end
        return
    end

    local lsp_manager_ok, lsp_manager = pcall(require, "languages.lsp_manager")
    if not lsp_manager_ok then
        vim.notify("Грешка при зареждане на lsp_manager", vim.log.levels.ERROR)
        if cb then
            cb()
        end
        return
    end

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

    allin1.start_time = os.time()

    local some_added = add_tools(tools)
    if not some_added then
        if lsp_manager then
            lsp_manager.set_installation_status(false)
        end
        check_callbacks()
        return
    end

    allin1.closed = false

    -- Стартираме глобалния таймер за обновяване на прогрес
    start_ui_refresh_timer()

    update_popup()

    for _, tool in ipairs(tools) do
        if allin1.states[tool] and allin1.states[tool].status == STATUS.PENDING then
            local pkg = mason_registry.get_package(tool)
            local handle = pkg:install()

            -- Слушаме за real-time прогрес събития
            handle:on(
                "progress",
                vim.schedule_wrap(function(progress)
                    if allin1.closed or not allin1.states or not allin1.states[tool] then
                        return
                    end

                    -- Бележим, че имаме реален прогрес
                    allin1.states[tool].has_real_progress = true

                    -- Актуализираме съобщението ако имаме
                    if progress.message then
                        allin1.states[tool].message = progress.message
                    end

                    -- Актуализираме процента ако имаме
                    if progress.percent then
                        allin1.states[tool].percent = math.min(95, math.floor(progress.percent))
                    end

                    -- Не е нужно да викаме update_popup тук, тъй като глобалният таймер ще го направи
                end)
            )

            -- Handle за завършване на инсталацията
            handle:once(
                "closed",
                vim.schedule_wrap(function()
                    vim.defer_fn(function()
                        if not allin1 or not allin1.states or not allin1.states[tool] then
                            return
                        end

                        -- Проверяваме дали инсталацията е успешна
                        local installed = false
                        pcall(function()
                            if pkg and pkg.is_installed then
                                installed = pkg:is_installed()
                            end
                        end)

                        -- Актуализираме състоянието
                        if allin1.states and allin1.states[tool] then
                            if installed then
                                allin1.states[tool].status = STATUS.OK
                                allin1.states[tool].percent = 100
                                allin1.states[tool].message = "Installation complete"
                            else
                                allin1.states[tool].status = STATUS.FAIL
                                allin1.states[tool].percent = 0
                                allin1.states[tool].message = "Installation failed"
                            end
                        end

                        -- Не е нужно да викаме update_popup, тъй като глобалният таймер ще го направи
                        pcall(check_callbacks)
                    end, 500)
                end)
            )
        end
    end

    -- Таймаут за инсталацията
    vim.defer_fn(function()
        if allin1.closed then
            return
        end
        for _, tool in ipairs(tools) do
            if allin1.states[tool] and allin1.states[tool].status == STATUS.PENDING then
                allin1.states[tool].status = STATUS.TIMEOUT
                allin1.states[tool].percent = 0
                allin1.states[tool].message = "Installation timed out"
            end
        end

        local manager_ok, manager = pcall(require, "languages.lsp_manager")
        if manager_ok and manager then
            manager.set_installation_status(false)
        end

        pcall(check_callbacks)
    end, INSTALLATION_TIMEOUT)
end

return M
