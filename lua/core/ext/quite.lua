local icons = require("configs.base.ui.icons")

local M = {}

M.quit = function()
    local unsaved_buffers = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[b].modified and vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) ~= "" then
            table.insert(unsaved_buffers, b)
        end
    end
    if #unsaved_buffers == 0 then
        vim.cmd("qa")
        return
    end

    local selections = {}
    for _, b in ipairs(unsaved_buffers) do
        selections[b] = true
    end

    local actions = {
        { id = "save", text = "💾 Save Selected & Quit", hl = "QuitActionSave" },
        { id = "discard", text = "💣 Quit without Saving", hl = "QuitActionDiscard" },
        { id = "cancel", text = "🚫 Cancel", hl = "QuitActionCancel" },
    }

    local KEY_HINT = " j/k: Move  <CR>/<Space>: Toggle File  Tab/S-Tab: Cycle  Enter(on action): Execute  q/Esc: Close"

    local MAX_HEIGHT = math.floor(vim.o.lines * 0.6)
    if MAX_HEIGHT < 12 then
        MAX_HEIGHT = 12
    end

    local function define_hl()
        local set = vim.api.nvim_set_hl
        pcall(function()
            set(0, "QuitIconTrue", { fg = _G.LVIM_COLORS.green })
            set(0, "QuitIconFalse", { fg = _G.LVIM_COLORS.red })
            set(0, "QuitFilePath", { fg = _G.LVIM_COLORS.blue })
            set(0, "QuitActionSave", { fg = _G.LVIM_COLORS.blue })
            set(0, "QuitActionDiscard", { fg = _G.LVIM_COLORS.blue })
            set(0, "QuitActionCancel", { fg = _G.LVIM_COLORS.blue })
            set(0, "QuitCursorLine", { bg = _G.LVIM_COLORS.blue_bh, bold = true })
            set(0, "QuitFooter", { fg = _G.LVIM_COLORS.blue, bold = true })
            set(0, "QuitHLine", { fg = "#5c6370" })
            set(0, "QuitMoreIndicator", { fg = "#5c6370" })
            set(0, "QuitBorder", { fg = _G.LVIM_COLORS.bg_float })
            set(0, "QuitTitleText", { bg = _G.LVIM_COLORS.blue_bh, fg = _G.LVIM_COLORS.blue, bold = true })
        end)
    end
    define_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("QuitPopupReHL", { clear = true }),
        callback = define_hl,
    })

    local Popup = require("nui.popup")
    local Text = require("nui.text")
    local event = require("nui.utils.autocmd").event

    local TITLE_TEXT = Text(" Unsaved Files ", "QuitTitleText")

    local function fixed_block_height()
        return 1 + #actions + 1 + 1
    end

    local function calc_width()
        local max_len = #KEY_HINT
        for _, b in ipairs(unsaved_buffers) do
            local icon = selections[b] and icons.common.is_true or icons.common.is_false
            local fp = vim.api.nvim_buf_get_name(b)
            local len = #icon + 1 + #fp
            if len > max_len then
                max_len = len
            end
        end
        for _, a in ipairs(actions) do
            if #a.text > max_len then
                max_len = #a.text
            end
        end
        if max_len < 52 then
            max_len = 52
        end
        return max_len + 4
    end

    local function desired_total_height()
        return fixed_block_height() + #unsaved_buffers
    end

    local function compute_effective_height()
        local want = desired_total_height()
        local capped = math.min(want, MAX_HEIGHT)
        local min_needed = fixed_block_height() + 1
        if capped < min_needed then
            capped = min_needed
        end
        return capped
    end

    local popup = Popup({
        enter = true,
        focusable = true,
        zindex = 60,
        border = {
            style = "rounded",
            highlight = "QuitBorder",
            text = { top = TITLE_TEXT, top_align = "center" },
        },
        position = "50%",
        size = {
            width = calc_width(),
            height = compute_effective_height(),
        },
        win_options = {
            winblend = 0,
            cursorline = false,
            winhighlight = "FloatBorder:QuitBorder",
        },
    })

    local current_index = 1
    local lines_meta = {}
    local scroll_offset = 0
    local visible_file_count = 0

    local function total_selectable()
        return #unsaved_buffers + #actions
    end

    local function effective_height()
        if popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
            return vim.api.nvim_win_get_height(popup.winid)
        end
        return compute_effective_height()
    end

    local function recompute_visible_file_window()
        local h = effective_height()
        local slots_for_files = h - fixed_block_height()
        if slots_for_files < 1 then
            slots_for_files = 1
        end
        visible_file_count = math.min(#unsaved_buffers, slots_for_files)

        local file_count = #unsaved_buffers
        if current_index <= file_count then
            local file_idx = current_index
            if file_idx < scroll_offset + 1 then
                scroll_offset = file_idx - 1
            elseif file_idx > scroll_offset + visible_file_count then
                scroll_offset = file_idx - visible_file_count
            end
        else
            local last_needed_offset = math.max(0, file_count - visible_file_count)
            if scroll_offset > last_needed_offset then
                scroll_offset = last_needed_offset
            end
        end
        if scroll_offset < 0 then
            scroll_offset = 0
        end
        local max_scroll = math.max(0, #unsaved_buffers - visible_file_count)
        if scroll_offset > max_scroll then
            scroll_offset = max_scroll
        end
    end

    local function rebuild_size()
        popup:update_layout({
            size = {
                width = calc_width(),
                height = compute_effective_height(),
            },
        })
        recompute_visible_file_window()
    end

    local function make_hline()
        local w = popup.winid and vim.api.nvim_win_is_valid(popup.winid) and vim.api.nvim_win_get_width(popup.winid)
            or calc_width()
        return string.rep("─", w)
    end

    local function index_to_linenr(idx)
        local file_count = #unsaved_buffers
        local showing = visible_file_count
        if idx <= file_count then
            if idx < scroll_offset + 1 or idx > scroll_offset + showing then
                return nil
            end
            return idx - scroll_offset
        else
            local hline1 = showing + 1
            local actions_start = hline1 + 1
            local action_idx = idx - file_count
            return actions_start + (action_idx - 1)
        end
    end

    local function render()
        if not popup.bufnr then
            return
        end
        recompute_visible_file_window()

        vim.api.nvim_set_option_value("modifiable", true, { buf = popup.bufnr })
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {})
        lines_meta = {}

        local lines = {}
        local file_count = #unsaved_buffers
        local showing = visible_file_count
        local from_i = scroll_offset + 1
        local to_i = scroll_offset + showing
        local has_above = (from_i > 1)
        local has_below = (to_i < file_count)

        for file_i = from_i, to_i do
            local buf = unsaved_buffers[file_i]
            local icon = selections[buf] and icons.common.is_true or icons.common.is_false
            local fp = vim.api.nvim_buf_get_name(buf)
            local line = icon .. " " .. (fp ~= "" and fp or ("[No Name #" .. buf .. "]"))
            table.insert(lines, line)
            lines_meta[#lines] = {
                kind = "file",
                bufnr = buf,
                icon_len = #icon,
                file_index = file_i,
            }
        end

        if has_above and #lines > 0 then
            lines[1] = "… " .. lines[1]
            local m = lines_meta[1]
            if m then
                m.more_above = true
                m.icon_len = m.icon_len + 2
            end
        end
        if has_below and #lines > 0 then
            lines[#lines] = lines[#lines] .. " …"
            local m = lines_meta[#lines]
            if m then
                m.more_below = true
            end
        end

        table.insert(lines, make_hline())
        lines_meta[#lines] = { kind = "hline" }

        for _, a in ipairs(actions) do
            table.insert(lines, a.text)
            lines_meta[#lines] = { kind = "action", action = a.id, hl = a.hl }
        end

        table.insert(lines, make_hline())
        lines_meta[#lines] = { kind = "hline" }

        table.insert(lines, KEY_HINT)
        lines_meta[#lines] = { kind = "footer" }

        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

        local ns = vim.api.nvim_create_namespace("quit_dialog_ns")
        vim.api.nvim_buf_clear_namespace(popup.bufnr, ns, 0, -1)

        local function extmark(lnum, col_start, col_end, group, prio)
            if col_end < 0 then
                local txt = vim.api.nvim_buf_get_text(popup.bufnr, lnum, 0, lnum, -1, {})[1] or ""
                col_end = #txt
            end
            vim.api.nvim_buf_set_extmark(popup.bufnr, ns, lnum, col_start, {
                end_col = col_end,
                hl_group = group,
                priority = prio or 100,
            })
        end

        for i, meta in ipairs(lines_meta) do
            local lnum = i - 1
            if meta.kind == "file" then
                local line_txt = vim.api.nvim_buf_get_text(popup.bufnr, lnum, 0, lnum, -1, {})[1] or ""
                local start_col = 0
                if meta.more_above then
                    extmark(lnum, 0, 1, "QuitMoreIndicator", 190)
                    start_col = 2
                end
                local icon_end = start_col + meta.icon_len
                local icon_hl = selections[meta.bufnr] and "QuitIconTrue" or "QuitIconFalse"
                extmark(lnum, start_col, icon_end, icon_hl, 180)
                extmark(lnum, icon_end + 1, -1, "QuitFilePath", 170)
                if meta.more_below and #line_txt > 0 then
                    extmark(lnum, #line_txt - 1, #line_txt, "QuitMoreIndicator", 190)
                end
            elseif meta.kind == "action" then
                extmark(lnum, 0, -1, meta.hl or "QuitActionSave", 160)
            elseif meta.kind == "footer" then
                extmark(lnum, 0, -1, "QuitFooter", 150)
            elseif meta.kind == "hline" then
                extmark(lnum, 0, -1, "QuitHLine", 140)
            end
        end

        local target_lnum = index_to_linenr(current_index)
        if target_lnum then
            pcall(vim.api.nvim_win_set_cursor, popup.winid, { target_lnum, 0 })
            extmark(target_lnum - 1, 0, -1, "QuitCursorLine", 300)
        end

        vim.api.nvim_set_option_value("modifiable", false, { buf = popup.bufnr })
    end

    local function move(delta)
        local max = total_selectable()
        current_index = current_index + delta
        if current_index < 1 then
            current_index = max
        end
        if current_index > max then
            current_index = 1
        end
        render()
    end

    local function toggle_current()
        local file_count = #unsaved_buffers
        if current_index > file_count then
            return
        end
        local bufnr = unsaved_buffers[current_index]
        selections[bufnr] = not selections[bufnr]
        render()
    end

    local function execute_action(id)
        if id == "save" then
            for b, want in pairs(selections) do
                if want and vim.api.nvim_buf_is_valid(b) and vim.bo[b].modified then
                    vim.api.nvim_buf_call(b, function()
                        vim.cmd("silent write")
                    end)
                end
            end
            popup:unmount()
            vim.cmd("qa")
        elseif id == "discard" then
            popup:unmount()
            vim.cmd("qa!")
        elseif id == "cancel" then
            popup:unmount()
        end
    end

    local function handle_enter()
        local file_count = #unsaved_buffers
        if current_index <= file_count then
            toggle_current()
        else
            local action_idx = current_index - file_count
            local action = actions[action_idx]
            if action then
                execute_action(action.id)
            end
        end
    end

    popup:mount()

    local function apply_cursor_blending(win)
        if not win or not vim.api.nvim_win_is_valid(win) then
            return
        end
        local augroup = vim.api.nvim_create_augroup("QuitPopupCursorBlend", { clear = true })
        vim.cmd("hi Cursor blend=100")
        vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
            group = augroup,
            callback = function()
                local current = vim.api.nvim_get_current_win()
                if current == win then
                    vim.cmd("hi Cursor blend=100")
                else
                    vim.cmd("hi Cursor blend=0")
                end
            end,
        })
        vim.api.nvim_create_autocmd("WinClosed", {
            group = augroup,
            pattern = tostring(win),
            callback = function()
                vim.schedule(function()
                    pcall(vim.cmd, "hi Cursor blend=0")
                end)
            end,
        })
    end
    apply_cursor_blending(popup.winid)

    popup:on(event.BufLeave, function() end)

    local function map(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, { buffer = popup.bufnr, nowait = true, silent = true })
    end
    map("j", function()
        move(1)
    end)
    map("<Down>", function()
        move(1)
    end)
    map("k", function()
        move(-1)
    end)
    map("<Up>", function()
        move(-1)
    end)
    map("<Tab>", function()
        move(1)
    end)
    map("<S-Tab>", function()
        move(-1)
    end)
    map("<Space>", toggle_current)
    map("<CR>", handle_enter)
    map("q", function()
        popup:unmount()
    end)
    map("<Esc>", function()
        popup:unmount()
    end)

    rebuild_size()
    render()
end

return M
