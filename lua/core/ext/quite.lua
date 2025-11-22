local icons = require("configs.base.ui.icons")

local M = {}

M.quit = function()
    local unsaved_buffers = {}
    for _, info in ipairs(vim.fn.getbufinfo({ bufloaded = 1 })) do
        local b = info.bufnr
        if info.changed == 1 and vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "" then
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
        {
            id = "save",
            text = "Save Selected & Quit",
            hl = "QuitActionSave",
            icon = icons.common.save,
            icon_hl = "QuitActionSaveIcon",
        },
        {
            id = "discard",
            text = "Quit without Saving",
            hl = "QuitActionDiscard",
            icon = icons.common.unsave,
            icon_hl = "QuitActionDiscardIcon",
        },
        {
            id = "cancel",
            text = "Cancel",
            hl = "QuitActionCancel",
            icon = icons.common.unsave,
            icon_hl = "QuitActionCancelIcon",
        },
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
            set(0, "QuitActionSaveIcon", { fg = _G.LVIM_COLORS.green })
            set(0, "QuitActionDiscardIcon", { fg = _G.LVIM_COLORS.red })
            set(0, "QuitActionCancelIcon", { fg = _G.LVIM_COLORS.blue })
            set(0, "QuitCursorLine", { bg = _G.LVIM_COLORS.blue_bh, bold = true })
            set(0, "QuitFooter", { fg = _G.LVIM_COLORS.blue, bold = true })
            set(0, "QuitHLine", { fg = _G.LVIM_COLORS.blue_bh })
            set(0, "QuitMoreIndicator", { fg = _G.LVIM_COLORS.red })
            set(0, "QuitBorder", { fg = _G.LVIM_COLORS.bg_float })
            set(0, "QuitTitleText", { bg = _G.LVIM_COLORS.blue_bh, fg = _G.LVIM_COLORS.blue, bold = true })
            set(0, "QuitActionSegmentSel", { bg = _G.LVIM_COLORS.blue_bh, bold = true })
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

    local popup
    local current_index = 1
    local lines_meta = {}
    local scroll_offset = 0
    local visible_file_count = 0
    local actions_segments = {}
    local cursor_blend_augroup

    local function fixed_block_height()
        return 1 + 1 + 1 + 1 + 1
    end

    local function calc_width()
        local max_len = #KEY_HINT
        for _, b in ipairs(unsaved_buffers) do
            local icon = selections[b] and icons.common.is_true or icons.common.is_false
            local fp = vim.api.nvim_buf_get_name(b)
            if fp == "" then
                fp = "[No Name #" .. b .. "]"
            end
            local len = 1 + #icon + 1 + #fp
            if len > max_len then
                max_len = len
            end
        end
        local act_line_len = 0
        for i, a in ipairs(actions) do
            local seg = " " .. a.icon .. " " .. a.text .. " "
            act_line_len = act_line_len + #seg + (i < #actions and 4 or 0)
        end
        if act_line_len > max_len then
            max_len = act_line_len
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

    local function total_selectable()
        return #unsaved_buffers + #actions
    end

    local function effective_height()
        if popup and popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
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
        if not popup then
            return
        end
        popup:update_layout({
            size = {
                width = calc_width(),
                height = compute_effective_height(),
            },
        })
        recompute_visible_file_window()
    end

    local function make_hline()
        local w = popup
                and popup.winid
                and vim.api.nvim_win_is_valid(popup.winid)
                and vim.api.nvim_win_get_width(popup.winid)
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
            return (idx - scroll_offset) + 1
        else
            local actions_line = showing + 2
            return actions_line
        end
    end

    local function render()
        if not popup or not popup.bufnr then
            return
        end
        recompute_visible_file_window()

        vim.api.nvim_set_option_value("modifiable", true, { buf = popup.bufnr })
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {})
        lines_meta = {}
        actions_segments = {}

        local lines = {}
        local file_count = #unsaved_buffers
        local showing = visible_file_count
        local from_i = scroll_offset + 1
        local to_i = scroll_offset + showing
        local has_above = (from_i > 1)
        local has_below = (to_i < file_count)

        table.insert(lines, "")
        lines_meta[#lines] = { kind = "spacer" }

        for file_i = from_i, to_i do
            local buf = unsaved_buffers[file_i]
            local icon = selections[buf] and icons.common.is_true or icons.common.is_false
            local fp = vim.api.nvim_buf_get_name(buf)
            if fp == "" then
                fp = "[No Name #" .. buf .. "]"
            end
            local line = " " .. icon .. " " .. fp
            table.insert(lines, line)
            lines_meta[#lines] = { kind = "file", bufnr = buf, icon_len = 1 + #icon, file_index = file_i }
        end

        if has_above and showing > 0 then
            local first_file_line = 2
            lines[first_file_line] = "… " .. lines[first_file_line]
            local m = lines_meta[first_file_line]
            if m then
                m.more_above = true
                m.icon_len = m.icon_len + 2
            end
        end
        if has_below and showing > 0 then
            local last_file_line = 1 + showing
            lines[last_file_line] = lines[last_file_line] .. " …"
            local m = lines_meta[last_file_line]
            if m then
                m.more_below = true
            end
        end

        table.insert(lines, make_hline())
        lines_meta[#lines] = { kind = "hline" }

        local action_line = ""
        local spacer = "    "
        local col = 0
        for i, a in ipairs(actions) do
            local seg_full = " " .. a.icon .. " " .. a.text .. " "
            local start_col = col
            local icon_start = start_col + 1
            local icon_end = icon_start + #a.icon
            local end_col = start_col + #seg_full
            table.insert(actions_segments, {
                start_col = start_col,
                icon_start = icon_start,
                icon_end = icon_end,
                end_col = end_col,
                action_idx = i,
                hl = a.hl,
                icon_hl = a.icon_hl,
                id = a.id,
            })
            action_line = action_line .. seg_full
            col = end_col
            if i < #actions then
                action_line = action_line .. spacer
                col = col + #spacer
            end
        end
        table.insert(lines, action_line)
        lines_meta[#lines] = { kind = "actions_line" }

        table.insert(lines, make_hline())
        lines_meta[#lines] = { kind = "hline" }

        table.insert(lines, KEY_HINT)
        lines_meta[#lines] = { kind = "footer" }

        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

        local ns = vim.api.nvim_create_namespace("quit_dialog_ns")
        vim.api.nvim_buf_clear_namespace(popup.bufnr, ns, 0, -1)

        local function extmark(lnum, s, e, group, prio, mode)
            local txt = vim.api.nvim_buf_get_text(popup.bufnr, lnum, 0, lnum, -1, {})[1] or ""
            local line_len = #txt
            if e < 0 or e > line_len then
                e = line_len
            end
            if s < 0 then
                s = 0
            end
            if e <= s then
                e = s + 1
            end
            vim.api.nvim_buf_set_extmark(popup.bufnr, ns, lnum, s, {
                end_col = e,
                hl_group = group,
                priority = prio or 100,
                hl_mode = mode,
            })
        end

        for i, meta in ipairs(lines_meta) do
            local lnum = i - 1
            if meta.kind == "file" then
                local start_col = 0
                if meta.more_above then
                    extmark(lnum, 0, 1, "QuitMoreIndicator", 300, "combine")
                    start_col = 2
                end
                local icon_end = start_col + meta.icon_len
                local icon_hl = selections[meta.bufnr] and "QuitIconTrue" or "QuitIconFalse"
                extmark(lnum, start_col, icon_end, icon_hl, 280, "combine")
                extmark(lnum, icon_end + 1, -1, "QuitFilePath", 270, "combine")
                if meta.more_below then
                    local txt = vim.api.nvim_buf_get_text(popup.bufnr, lnum, 0, lnum, -1, {})[1] or ""
                    local len = #txt
                    if len > 0 then
                        extmark(lnum, len - 1, len, "QuitMoreIndicator", 300, "combine")
                    end
                end
            elseif meta.kind == "hline" then
                extmark(lnum, 0, -1, "QuitHLine", 200, "replace")
            elseif meta.kind == "footer" then
                extmark(lnum, 0, -1, "QuitFooter", 210, "replace")
            elseif meta.kind == "actions_line" then
                local file_count_local = #unsaved_buffers
                local sel_action_idx = (current_index > file_count_local) and (current_index - file_count_local) or nil
                for _, seg in ipairs(actions_segments) do
                    extmark(lnum, seg.icon_start, seg.icon_end, seg.icon_hl or seg.hl, 260, "combine")
                    extmark(lnum, seg.icon_end, seg.end_col, seg.hl, 250, "combine")
                    if sel_action_idx == seg.action_idx then
                        extmark(lnum, seg.start_col, seg.end_col, "QuitCursorLine", 900, "combine")
                    end
                end
            end
        end

        local target_lnum = index_to_linenr(current_index)
        if target_lnum then
            local file_count_local = #unsaved_buffers
            if current_index <= file_count_local then
                pcall(vim.api.nvim_win_set_cursor, popup.winid, { target_lnum, 0 })
                local line_idx = target_lnum - 1
                vim.api.nvim_buf_set_extmark(popup.bufnr, ns, line_idx, 0, {
                    line_hl_group = "QuitCursorLine",
                    priority = 1000,
                })
            else
                local sel_idx = current_index - file_count_local
                local seg = actions_segments[sel_idx]
                if seg then
                    pcall(vim.api.nvim_win_set_cursor, popup.winid, { target_lnum, seg.start_col })
                else
                    pcall(vim.api.nvim_win_set_cursor, popup.winid, { target_lnum, 0 })
                end
            end
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

    local function finalize_and_quit(saved_results)
        local has_unsaved = false

        if saved_results then
            for _, b in ipairs(unsaved_buffers) do
                if vim.api.nvim_buf_is_valid(b) and vim.bo[b].modified then
                    if saved_results[b] == false then
                        has_unsaved = true
                        break
                    end
                    if saved_results[b] == nil and vim.bo[b].modified then
                        has_unsaved = true
                        break
                    end
                end
            end
        else
            for _, info in ipairs(vim.fn.getbufinfo({ bufloaded = 1 })) do
                local b = info.bufnr
                if info.changed == 1 and vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "" then
                    has_unsaved = true
                    break
                end
            end
        end

        if has_unsaved then
            vim.cmd("qa!")
        else
            vim.cmd("qa")
        end
    end

    local function try_write_buffer(bufnr, fname)
        if not vim.api.nvim_buf_is_valid(bufnr) then
            return false
        end

        fname = fname or vim.api.nvim_buf_get_name(bufnr)

        if fname == "" then
            return false
        end

        local dir = vim.fn.fnamemodify(fname, ":h")
        if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local ok = pcall(vim.fn.writefile, lines, fname)

        if not ok then
            return false
        end

        pcall(vim.api.nvim_set_option_value, "modified", false, { buf = bufnr })

        local stat = vim.loop.fs_stat(fname)
        return stat ~= nil
    end

    local function restore_cursor()
        pcall(vim.cmd, "hi Cursor blend=0")
    end

    local function focus_popup()
        if popup and popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
            vim.api.nvim_set_current_win(popup.winid)
            pcall(vim.cmd, "hi Cursor blend=100")
        end
    end

    local function execute_action(id)
        if id == "save" then
            local saved_results = {}

            local unnamed_to_prompt = {}
            for b, want in pairs(selections) do
                if want and vim.api.nvim_buf_is_valid(b) and vim.bo[b].modified then
                    local fname = vim.api.nvim_buf_get_name(b)
                    if fname == "" then
                        table.insert(unnamed_to_prompt, b)
                    else
                        saved_results[b] = try_write_buffer(b)
                    end
                end
            end

            if #unnamed_to_prompt == 0 then
                popup:unmount()
                restore_cursor()
                vim.defer_fn(function()
                    finalize_and_quit(saved_results)
                end, 100)
                return
            end

            local function prompt_save_unnamed(idx)
                if idx > #unnamed_to_prompt then
                    popup:unmount()
                    restore_cursor()
                    vim.defer_fn(function()
                        finalize_and_quit(saved_results)
                    end, 100)
                    return
                end

                local bufnr = unnamed_to_prompt[idx]
                if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].modified then
                    saved_results[bufnr] = true
                    prompt_save_unnamed(idx + 1)
                    return
                end

                restore_cursor()
                vim.fn.inputsave()
                local input = vim.fn.input("Save buffer #" .. bufnr .. " as: ")
                vim.fn.inputrestore()
                vim.cmd("redraw")

                if input == "" then
                    saved_results[bufnr] = false
                    focus_popup()
                    return
                end

                local expanded = vim.fn.expand(input)

                if not vim.startswith(expanded, "/") and not vim.startswith(expanded, vim.fn.expand("~")) then
                    expanded = vim.fn.getcwd() .. "/" .. expanded
                end

                local ok_set = pcall(vim.api.nvim_buf_set_name, bufnr, expanded)

                if ok_set then
                    saved_results[bufnr] = try_write_buffer(bufnr, expanded)

                    if not saved_results[bufnr] then
                        vim.notify("Failed to write file: " .. expanded, vim.log.levels.ERROR)
                    end
                else
                    saved_results[bufnr] = false
                    vim.notify("Failed to set buffer name", vim.log.levels.ERROR)
                end

                prompt_save_unnamed(idx + 1)
            end

            prompt_save_unnamed(1)
        elseif id == "discard" then
            popup:unmount()
            restore_cursor()
            vim.cmd("qa!")
        elseif id == "cancel" then
            popup:unmount()
            restore_cursor()
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

    popup = Popup({
        enter = true,
        focusable = true,
        zindex = 60,
        border = {
            style = "rounded",
            highlight = "QuitBorder",
            text = { top = TITLE_TEXT, top_align = "center" },
        },
        relative = "editor",
        position = {
            row = "50%",
            col = "50%",
        },
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

    popup:mount()

    local function apply_cursor_blending(win)
        if not win or not vim.api.nvim_win_is_valid(win) then
            return
        end
        cursor_blend_augroup = vim.api.nvim_create_augroup("QuitPopupCursorBlend", { clear = true })
        vim.cmd("hi Cursor blend=100")
        vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
            group = cursor_blend_augroup,
            callback = function()
                local current = vim.api.nvim_get_current_win()
                if current == win and vim.api.nvim_win_is_valid(win) then
                    vim.cmd("hi Cursor blend=100")
                else
                    vim.cmd("hi Cursor blend=0")
                end
            end,
        })
        vim.api.nvim_create_autocmd("WinClosed", {
            group = cursor_blend_augroup,
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
        restore_cursor()
    end)
    map("<Esc>", function()
        popup:unmount()
        restore_cursor()
    end)

    rebuild_size()
    render()
end

return M
