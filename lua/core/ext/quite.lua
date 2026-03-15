-- Interactive quit dialog for LVIM IDE.
-- When :Quit is invoked and there are unsaved normal buffers, opens a
-- nui.nvim floating popup that lists every unsaved file with a toggle
-- checkbox, and offers three actions: "Save Selected & Quit",
-- "Quit without Saving", and "Cancel".
--
-- Navigation inside the popup:
--   j / k  or  Down / Up   – move the cursor
--   Tab / S-Tab             – cycle through items
--   <Space> or <CR>         – toggle a file's save selection (when on a file row)
--   <CR>                    – execute the highlighted action (when on an action row)
--   q / <Esc>               – cancel and close the popup

---@module "core.ext.quite"

local icons = require("configs.base.ui.icons")

local M = {}

--- Check for unsaved buffers and either quit immediately or open the dialog.
-- If no normal buffers have unsaved changes, issues :qa and returns.
-- Otherwise, builds a nui.popup and attaches all navigation keymaps.
---@return nil
M.quit = function()
    ---@type integer[]  Buffer handles that have unsaved changes
    local unsaved_buffers = {}
    for _, info in ipairs(vim.fn.getbufinfo({ bufloaded = 1 })) do
        local b = info.bufnr
        -- Only consider regular file buffers (buftype == "") that are modified.
        if info.changed == 1 and vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "" then
            table.insert(unsaved_buffers, b)
        end
    end

    -- Fast path: no unsaved work → quit immediately.
    if #unsaved_buffers == 0 then
        vim.cmd("qa")
        return
    end

    -- All unsaved buffers start as selected (will be saved on "Save & Quit").
    ---@type table<integer, boolean>  bufnr → selected for saving
    local selections = {}
    for _, b in ipairs(unsaved_buffers) do
        selections[b] = true
    end

    ---@class QuitAction
    ---@field id      string   Unique action identifier ("save"|"discard"|"cancel")
    ---@field text    string   Human-readable label shown in the popup
    ---@field hl      string   Highlight group for the label text
    ---@field icon    string   Nerd Font glyph displayed before the label
    ---@field icon_hl string   Highlight group for the icon

    ---@type QuitAction[]
    local actions = {
        {
            id      = "save",
            text    = "Save Selected & Quit",
            hl      = "QuitActionSave",
            icon    = icons.common.save,
            icon_hl = "QuitActionSaveIcon",
        },
        {
            id      = "discard",
            text    = "Quit without Saving",
            hl      = "QuitActionDiscard",
            icon    = icons.common.unsave,
            icon_hl = "QuitActionDiscardIcon",
        },
        {
            id      = "cancel",
            text    = "Cancel",
            hl      = "QuitActionCancel",
            icon    = icons.common.unsave,
            icon_hl = "QuitActionCancelIcon",
        },
    }

    ---@type string  Key-hint line rendered in the popup footer
    local KEY_HINT = " j/k: Move  <CR>/<Space>: Toggle File  Tab/S-Tab: Cycle  Enter(on action): Execute  q/Esc: Close"

    -- Cap the popup height at 60 % of the editor height, minimum 12 lines.
    ---@type integer
    local MAX_HEIGHT = math.floor(vim.o.lines * 0.6)
    if MAX_HEIGHT < 12 then
        MAX_HEIGHT = 12
    end

    -- Define all custom highlight groups using the current LvimColors palette.
    -- Wrapped in pcall so a missing _G.LVIM.colors does not abort startup.
    local function define_hl()
        local set = vim.api.nvim_set_hl
        pcall(function()
            set(0, "QuitIconTrue",        { fg = _G.LVIM.colors.green    })
            set(0, "QuitIconFalse",       { fg = _G.LVIM.colors.red      })
            set(0, "QuitFilePath",        { fg = _G.LVIM.colors.blue     })
            set(0, "QuitActionSave",      { fg = _G.LVIM.colors.blue     })
            set(0, "QuitActionDiscard",   { fg = _G.LVIM.colors.blue     })
            set(0, "QuitActionCancel",    { fg = _G.LVIM.colors.blue     })
            set(0, "QuitActionSaveIcon",  { fg = _G.LVIM.colors.green    })
            set(0, "QuitActionDiscardIcon",{ fg = _G.LVIM.colors.red     })
            set(0, "QuitActionCancelIcon",{ fg = _G.LVIM.colors.blue     })
            set(0, "QuitCursorLine",      { bg = _G.LVIM.colors.blue_bh, bold = true })
            set(0, "QuitFooter",          { fg = _G.LVIM.colors.blue,    bold = true })
            set(0, "QuitHLine",           { fg = _G.LVIM.colors.blue_bh  })
            set(0, "QuitMoreIndicator",   { fg = _G.LVIM.colors.red      })
            set(0, "QuitBorder",          { fg = _G.LVIM.colors.bg_float })
            set(0, "QuitTitleText",       { bg = _G.LVIM.colors.blue_bh, fg = _G.LVIM.colors.blue, bold = true })
            set(0, "QuitActionSegmentSel",{ bg = _G.LVIM.colors.blue_bh, bold = true })
        end)
    end
    define_hl()
    -- Re-apply highlights whenever the colorscheme changes so colors stay correct.
    vim.api.nvim_create_autocmd("ColorScheme", {
        group    = vim.api.nvim_create_augroup("QuitPopupReHL", { clear = true }),
        callback = define_hl,
    })

    local Popup = require("nui.popup")
    local Text  = require("nui.text")
    local event = require("nui.utils.autocmd").event
    local TITLE_TEXT = Text(" Unsaved Files ", "QuitTitleText")

    -- Popup state variables ----------------------------------------------------
    local popup                             -- nui.popup instance (set after mount)
    ---@type integer  1-based index into the flat list: files first, then actions
    local current_index = 1
    ---@type table[]  Per-line metadata array (parallel to the rendered lines)
    local lines_meta    = {}
    ---@type integer  How many file rows are scrolled off the top
    local scroll_offset = 0
    ---@type integer  How many file rows fit in the current window height
    local visible_file_count = 0
    ---@type table[]  Column-range metadata for each action segment on the actions line
    local actions_segments   = {}
    ---@type integer|nil  Autocommand group handle for cursor-blending autocmds
    local cursor_blend_augroup

    -- Layout helpers -----------------------------------------------------------

    --- Return the number of non-file lines in the popup (spacer + hline + actions + hline + footer).
    ---@return integer  Always 5
    local function fixed_block_height()
        return 1 + 1 + 1 + 1 + 1
    end

    --- Compute the minimum popup width that fits all content.
    ---@return integer
    local function calc_width()
        local max_len = #KEY_HINT
        for _, b in ipairs(unsaved_buffers) do
            local icon = selections[b] and icons.common.is_true or icons.common.is_false
            local fp   = vim.api.nvim_buf_get_name(b)
            if fp == "" then
                fp = "[No Name #" .. b .. "]"
            end
            -- 1 leading space + icon + 1 space + filepath
            local len = 1 + #icon + 1 + #fp
            if len > max_len then
                max_len = len
            end
        end
        -- Measure the actions row including spacers between segments.
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
        return max_len + 4  -- +4 for border padding
    end

    --- Return the uncapped total height needed to show all files.
    ---@return integer
    local function desired_total_height()
        return fixed_block_height() + #unsaved_buffers
    end

    --- Return the actual height capped by MAX_HEIGHT with a guaranteed minimum.
    ---@return integer
    local function compute_effective_height()
        local want      = desired_total_height()
        local capped    = math.min(want, MAX_HEIGHT)
        local min_needed = fixed_block_height() + 1
        if capped < min_needed then
            capped = min_needed
        end
        return capped
    end

    --- Return the total number of selectable items (files + actions).
    ---@return integer
    local function total_selectable()
        return #unsaved_buffers + #actions
    end

    --- Return the actual window height (queries the live window if available).
    ---@return integer
    local function effective_height()
        if popup and popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
            return vim.api.nvim_win_get_height(popup.winid)
        end
        return compute_effective_height()
    end

    --- Recalculate visible_file_count and clamp scroll_offset so the currently
    --- selected file is always visible.
    ---@return nil
    local function recompute_visible_file_window()
        local h              = effective_height()
        local slots_for_files = h - fixed_block_height()
        if slots_for_files < 1 then
            slots_for_files = 1
        end
        visible_file_count = math.min(#unsaved_buffers, slots_for_files)
        local file_count   = #unsaved_buffers
        if current_index <= file_count then
            -- Scroll up if the selection is above the visible window.
            local file_idx = current_index
            if file_idx < scroll_offset + 1 then
                scroll_offset = file_idx - 1
            -- Scroll down if the selection is below the visible window.
            elseif file_idx > scroll_offset + visible_file_count then
                scroll_offset = file_idx - visible_file_count
            end
        else
            -- When an action is selected, keep the scroll at the bottom.
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

    --- Resize the popup and recompute the scroll window.
    ---@return nil
    local function rebuild_size()
        if not popup then
            return
        end
        popup:update_layout({
            size = {
                width  = calc_width(),
                height = compute_effective_height(),
            },
        })
        recompute_visible_file_window()
    end

    --- Build a horizontal separator line as wide as the popup content area.
    ---@return string  String of "─" characters
    local function make_hline()
        local w = popup
                and popup.winid
                and vim.api.nvim_win_is_valid(popup.winid)
                and vim.api.nvim_win_get_width(popup.winid)
            or calc_width()
        return string.rep("─", w)
    end

    --- Translate a logical item index to its 1-based line number in the buffer.
    -- Returns nil when the item is scrolled out of view.
    ---@param idx integer  Logical selection index (1 = first file, …, N+1 = first action)
    ---@return integer|nil  1-based buffer line number, or nil if not visible
    local function index_to_linenr(idx)
        local file_count = #unsaved_buffers
        local showing    = visible_file_count
        if idx <= file_count then
            -- File is outside the visible scroll window.
            if idx < scroll_offset + 1 or idx > scroll_offset + showing then
                return nil
            end
            -- +1 for the spacer line at the top.
            return (idx - scroll_offset) + 1
        else
            -- All actions share a single line below the file list.
            local actions_line = showing + 2  -- spacer + files + hline
            return actions_line
        end
    end

    -- Rendering ----------------------------------------------------------------

    --- Redraw the entire popup buffer with updated content and extmark highlights.
    ---@return nil
    local function render()
        if not popup or not popup.bufnr then
            return
        end
        recompute_visible_file_window()

        vim.api.nvim_set_option_value("modifiable", true, { buf = popup.bufnr })
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {})
        lines_meta     = {}
        actions_segments = {}

        local lines      = {}
        local file_count = #unsaved_buffers
        local showing    = visible_file_count
        local from_i     = scroll_offset + 1
        local to_i       = scroll_offset + showing
        local has_above  = (from_i > 1)    -- more files scrolled above
        local has_below  = (to_i < file_count)  -- more files scrolled below

        -- Spacer line at the top (keeps visual padding above the file list).
        table.insert(lines, "")
        lines_meta[#lines] = { kind = "spacer" }

        -- File rows (only the visible slice based on scroll_offset).
        for file_i = from_i, to_i do
            local buf  = unsaved_buffers[file_i]
            local icon = selections[buf] and icons.common.is_true or icons.common.is_false
            local fp   = vim.api.nvim_buf_get_name(buf)
            if fp == "" then
                fp = "[No Name #" .. buf .. "]"
            end
            local line = " " .. icon .. " " .. fp
            table.insert(lines, line)
            lines_meta[#lines] = { kind = "file", bufnr = buf, icon_len = 1 + #icon, file_index = file_i }
        end

        -- Inject "…" scroll indicators at the edge rows when content is clipped.
        if has_above and showing > 0 then
            local first_file_line = 2  -- line index 2 = first visible file (1 = spacer)
            lines[first_file_line] = "… " .. lines[first_file_line]
            local m = lines_meta[first_file_line]
            if m then
                m.more_above = true
                m.icon_len   = m.icon_len + 2  -- account for the "… " prefix in column maths
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

        -- Horizontal separator above the actions row.
        table.insert(lines, make_hline())
        lines_meta[#lines] = { kind = "hline" }

        -- Actions row: all three action segments on a single line, separated by spaces.
        local action_line = ""
        local spacer      = "    "
        local col         = 0
        for i, a in ipairs(actions) do
            local seg_full  = " " .. a.icon .. " " .. a.text .. " "
            local start_col = col
            local icon_start = start_col + 1
            local icon_end   = icon_start + #a.icon
            local end_col    = start_col + #seg_full
            table.insert(actions_segments, {
                start_col  = start_col,
                icon_start = icon_start,
                icon_end   = icon_end,
                end_col    = end_col,
                action_idx = i,
                hl         = a.hl,
                icon_hl    = a.icon_hl,
                id         = a.id,
            })
            action_line = action_line .. seg_full
            col         = end_col
            if i < #actions then
                action_line = action_line .. spacer
                col         = col + #spacer
            end
        end
        table.insert(lines, action_line)
        lines_meta[#lines] = { kind = "actions_line" }

        -- Horizontal separator below the actions row.
        table.insert(lines, make_hline())
        lines_meta[#lines] = { kind = "hline" }

        -- Footer hint line.
        table.insert(lines, KEY_HINT)
        lines_meta[#lines] = { kind = "footer" }

        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

        -- Apply extmark-based highlights using a dedicated namespace.
        local ns = vim.api.nvim_create_namespace("quit_dialog_ns")
        vim.api.nvim_buf_clear_namespace(popup.bufnr, ns, 0, -1)

        --- Set a single extmark highlight, clamping column bounds to the line length.
        ---@param lnum  integer  0-based line number
        ---@param s     integer  Start column (byte offset)
        ---@param e     integer  End column (-1 = end of line)
        ---@param group string   Highlight group name
        ---@param prio  integer|nil  Extmark priority (default 100)
        ---@param mode  string|nil   hl_mode ("replace"|"combine"|"blend")
        local function extmark(lnum, s, e, group, prio, mode)
            local txt      = vim.api.nvim_buf_get_text(popup.bufnr, lnum, 0, lnum, -1, {})[1] or ""
            local line_len = #txt
            if e < 0 or e > line_len then
                e = line_len
            end
            if s < 0 then
                s = 0
            end
            -- Ensure the range is at least 1 character wide.
            if e <= s then
                e = s + 1
            end
            vim.api.nvim_buf_set_extmark(popup.bufnr, ns, lnum, s, {
                end_col  = e,
                hl_group = group,
                priority = prio or 100,
                hl_mode  = mode,
            })
        end

        for i, meta in ipairs(lines_meta) do
            local lnum = i - 1  -- 0-based for extmark API
            if meta.kind == "file" then
                local start_col = 0
                if meta.more_above then
                    extmark(lnum, 0, 1, "QuitMoreIndicator", 300, "combine")
                    start_col = 2
                end
                local icon_end = start_col + meta.icon_len
                -- Green checkmark when selected, red cross when deselected.
                local icon_hl  = selections[meta.bufnr] and "QuitIconTrue" or "QuitIconFalse"
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
                -- Determine which action segment (if any) is currently selected.
                local sel_action_idx = (current_index > file_count_local)
                    and (current_index - file_count_local)
                    or nil
                for _, seg in ipairs(actions_segments) do
                    -- Icon glyph uses a separate (often coloured) highlight.
                    extmark(lnum, seg.icon_start, seg.icon_end, seg.icon_hl or seg.hl, 260, "combine")
                    extmark(lnum, seg.icon_end,   seg.end_col,  seg.hl,                250, "combine")
                    -- Overlay a selection background on the active action segment.
                    if sel_action_idx == seg.action_idx then
                        extmark(lnum, seg.start_col, seg.end_col, "QuitCursorLine", 900, "combine")
                    end
                end
            end
        end

        -- Position the cursor and highlight the active row.
        local target_lnum = index_to_linenr(current_index)
        if target_lnum then
            local file_count_local = #unsaved_buffers
            if current_index <= file_count_local then
                -- Cursor is on a file row.
                pcall(vim.api.nvim_win_set_cursor, popup.winid, { target_lnum, 0 })
                local line_idx = target_lnum - 1
                vim.api.nvim_buf_set_extmark(popup.bufnr, ns, line_idx, 0, {
                    line_hl_group = "QuitCursorLine",
                    priority      = 1000,
                })
            else
                -- Cursor is on the actions row; move to the start of the active segment.
                local sel_idx = current_index - file_count_local
                local seg     = actions_segments[sel_idx]
                if seg then
                    pcall(vim.api.nvim_win_set_cursor, popup.winid, { target_lnum, seg.start_col })
                else
                    pcall(vim.api.nvim_win_set_cursor, popup.winid, { target_lnum, 0 })
                end
            end
        end

        vim.api.nvim_set_option_value("modifiable", false, { buf = popup.bufnr })
    end

    -- Navigation ---------------------------------------------------------------

    --- Move the selection by delta (wraps around the full item list).
    ---@param delta integer  +1 (down) or -1 (up)
    ---@return nil
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

    --- Toggle the save-selection state for the file at the current index.
    -- Has no effect when the cursor is on an action row.
    ---@return nil
    local function toggle_current()
        local file_count = #unsaved_buffers
        if current_index > file_count then
            return
        end
        local bufnr           = unsaved_buffers[current_index]
        selections[bufnr]     = not selections[bufnr]
        render()
    end

    -- Action execution ---------------------------------------------------------

    --- Check whether any unsaved changes remain and choose :qa or :qa! accordingly.
    -- When saved_results is provided, uses it to determine per-buffer state;
    -- otherwise re-queries the live buffer list.
    ---@param saved_results table<integer, boolean>|nil  bufnr → write succeeded
    ---@return nil
    local function finalize_and_quit(saved_results)
        local has_unsaved = false

        if saved_results then
            for _, b in ipairs(unsaved_buffers) do
                if vim.api.nvim_buf_is_valid(b) and vim.bo[b].modified then
                    -- saved_results[b] == false means the write failed or was skipped.
                    if saved_results[b] == false then
                        has_unsaved = true
                        break
                    end
                    -- nil means we never attempted to save it (not selected).
                    if saved_results[b] == nil and vim.bo[b].modified then
                        has_unsaved = true
                        break
                    end
                end
            end
        else
            -- Re-scan all loaded buffers when no results table is available.
            for _, info in ipairs(vim.fn.getbufinfo({ bufloaded = 1 })) do
                local b = info.bufnr
                if info.changed == 1 and vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "" then
                    has_unsaved = true
                    break
                end
            end
        end

        -- Use :qa! only when unsaved buffers truly remain to avoid prompts.
        if has_unsaved then
            vim.cmd("qa!")
        else
            vim.cmd("qa")
        end
    end

    --- Write a buffer's content to disk, creating parent directories as needed.
    ---@param bufnr integer   Buffer handle
    ---@param fname string|nil  Destination path (defaults to buffer name)
    ---@return boolean  true when the file was written successfully and exists on disk
    local function try_write_buffer(bufnr, fname)
        if not vim.api.nvim_buf_is_valid(bufnr) then
            return false
        end

        fname = fname or vim.api.nvim_buf_get_name(bufnr)

        if fname == "" then
            return false
        end

        -- Create the directory tree if it does not exist yet.
        local dir = vim.fn.fnamemodify(fname, ":h")
        if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local ok    = pcall(vim.fn.writefile, lines, fname)

        if not ok then
            return false
        end

        -- Clear the modified flag after a successful write.
        pcall(vim.api.nvim_set_option_value, "modified", false, { buf = bufnr })

        -- Verify the file exists as a final sanity check.
        local stat = vim.loop.fs_stat(fname)
        return stat ~= nil
    end

    --- Restore the cursor to fully visible (blend = 0).
    ---@return nil
    local function restore_cursor()
        pcall(vim.cmd, "hi Cursor blend=0")
    end

    --- Focus the popup window and hide the cursor (blend = 100) so the
    --- custom extmark cursor-line highlight is unobstructed.
    ---@return nil
    local function focus_popup()
        if popup and popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
            vim.api.nvim_set_current_win(popup.winid)
            pcall(vim.cmd, "hi Cursor blend=100")
        end
    end

    --- Execute a named action and handle the resulting quit / cancel flow.
    ---@param id "save"|"discard"|"cancel"
    ---@return nil
    local function execute_action(id)
        if id == "save" then
            ---@type table<integer, boolean>  bufnr → write result
            local saved_results = {}

            ---@type integer[]  Buffers with no name that need interactive prompts
            local unnamed_to_prompt = {}
            for b, want in pairs(selections) do
                if want and vim.api.nvim_buf_is_valid(b) and vim.bo[b].modified then
                    local fname = vim.api.nvim_buf_get_name(b)
                    if fname == "" then
                        table.insert(unnamed_to_prompt, b)
                    else
                        -- Named buffer: write immediately.
                        saved_results[b] = try_write_buffer(b)
                    end
                end
            end

            if #unnamed_to_prompt == 0 then
                -- All selected files were named; proceed straight to quit.
                popup:unmount()
                restore_cursor()
                vim.defer_fn(function()
                    finalize_and_quit(saved_results)
                end, 100)
                return
            end

            --- Recursively prompt the user for a save path for each unnamed buffer.
            ---@param idx integer  1-based index into unnamed_to_prompt
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
                    -- Buffer was already saved or closed; skip it.
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
                    -- User cancelled this particular buffer.
                    saved_results[bufnr] = false
                    focus_popup()
                    return
                end

                local expanded = vim.fn.expand(input)

                -- Resolve relative paths against the cwd.
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
            -- Discard all changes and force-quit.
            popup:unmount()
            restore_cursor()
            vim.cmd("qa!")
        elseif id == "cancel" then
            -- Cancel: just close the popup, return to the editor.
            popup:unmount()
            restore_cursor()
        end
    end

    --- Dispatch <CR>: toggle the file if on a file row, or execute the action
    --- if the cursor is on the actions row.
    ---@return nil
    local function handle_enter()
        local file_count = #unsaved_buffers
        if current_index <= file_count then
            toggle_current()
        else
            local action_idx = current_index - file_count
            local action     = actions[action_idx]
            if action then
                execute_action(action.id)
            end
        end
    end

    -- Popup construction -------------------------------------------------------

    popup = Popup({
        enter     = true,
        focusable = true,
        zindex    = 60,
        border    = {
            style     = "rounded",
            highlight = "QuitBorder",
            text      = { top = TITLE_TEXT, top_align = "center" },
        },
        relative  = "editor",
        position  = { row = "50%", col = "50%" },
        size      = {
            width  = calc_width(),
            height = compute_effective_height(),
        },
        win_options = {
            winblend    = 0,
            cursorline  = false,
            winhighlight = "FloatBorder:QuitBorder",
        },
    })

    popup:mount()

    --- Set up autocmds that hide the cursor when the popup is focused and
    --- restore it when focus moves away or the window closes.
    ---@param win integer  Window handle of the popup
    ---@return nil
    local function apply_cursor_blending(win)
        if not win or not vim.api.nvim_win_is_valid(win) then
            return
        end
        cursor_blend_augroup = vim.api.nvim_create_augroup("QuitPopupCursorBlend", { clear = true })
        -- Hide the cursor immediately upon mount.
        vim.cmd("hi Cursor blend=100")
        vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
            group    = cursor_blend_augroup,
            callback = function()
                local current = vim.api.nvim_get_current_win()
                if current == win and vim.api.nvim_win_is_valid(win) then
                    vim.cmd("hi Cursor blend=100")
                else
                    vim.cmd("hi Cursor blend=0")
                end
            end,
        })
        -- Guarantee the cursor is restored when the window is closed.
        vim.api.nvim_create_autocmd("WinClosed", {
            group    = cursor_blend_augroup,
            pattern  = tostring(win),
            callback = function()
                vim.schedule(function()
                    pcall(vim.cmd, "hi Cursor blend=0")
                end)
            end,
        })
    end
    apply_cursor_blending(popup.winid)

    -- Suppress BufLeave to avoid unintended side effects when the popup loses focus.
    popup:on(event.BufLeave, function() end)

    -- Keymaps ------------------------------------------------------------------

    --- Helper to set a buffer-local normal-mode keymap inside the popup.
    ---@param lhs string
    ---@param rhs function
    ---@return nil
    local function map(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, { buffer = popup.bufnr, nowait = true, silent = true })
    end

    map("j",       function() move(1)  end)
    map("<Down>",  function() move(1)  end)
    map("k",       function() move(-1) end)
    map("<Up>",    function() move(-1) end)
    map("<Tab>",   function() move(1)  end)
    map("<S-Tab>", function() move(-1) end)
    map("<Space>", toggle_current)
    map("<CR>",    handle_enter)
    map("q", function()
        popup:unmount()
        restore_cursor()
    end)
    map("<Esc>", function()
        popup:unmount()
        restore_cursor()
    end)

    -- Initial draw.
    rebuild_size()
    render()
end

return M
