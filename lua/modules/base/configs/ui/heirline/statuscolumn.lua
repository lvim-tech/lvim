-- Heirline statuscolumn configuration.
-- Builds a custom statuscolumn with four sections (left to right):
--   other signs | diagnostic signs | (align) | line numbers | git gutter | space
-- Each section supports mouse click handlers that dispatch to the appropriate
-- action (Trouble, MiniDiff overlay, DAP breakpoints, Neotest run, etc.).

---@diagnostic disable: undefined-field

---@module "modules.base.configs.ui.heirline.statuscolumn"

---@type boolean  true when mini.diff is available (used to gate git-gutter logic)
local mini_ok = pcall(require, "mini.diff") or _G.MiniDiff ~= nil

local icons = require("configs.base.ui.icons")
local conditions = require("heirline.conditions")
local buf_types = require("modules.base.configs.ui.heirline.buf_types")
local file_types = require("modules.base.configs.ui.heirline.file_types")

-- ---------------------------------------------------------------------------
-- static: shared helper functions stored on the heirline static table so they
-- are accessible from every component via self.* without re-requiring modules.
-- ---------------------------------------------------------------------------

---@type table  Shared static methods for the statuscolumn component
local static = {}

-- ---------------------------------------------------------------------------
-- Extmark helpers
-- ---------------------------------------------------------------------------

-- Fetches all extmarks on a given buffer line, optionally filtered by highlight
-- group name, sorted by priority (highest first).
-- Returns an empty table on invalid buffer or API error.
---@param bufnr       integer                         Buffer number to query
---@param lnum        integer                         1-based line number
---@param filter_func fun(hl: string): boolean        Predicate; return true to include the mark
---@return table[]    Filtered extmark records with .name, .text, .sign_hl_group, .priority
local function get_extmarks(bufnr, lnum, filter_func)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return {}
    end
    local ok, extmarks = pcall(
        vim.api.nvim_buf_get_extmarks,
        bufnr,
        -1,                   -- all namespaces
        { lnum - 1, 0 },      -- start of line (0-based)
        { lnum - 1, -1 },     -- end of line
        { details = true }
    )
    if not ok or not extmarks then
        return {}
    end
    local result = {}
    for _, extmark in ipairs(extmarks) do
        local details = extmark[4] or {}
        -- Prefer sign_hl_group; fall back to number_hl_group for diagnostics that use it
        local hl = details.sign_hl_group or details.number_hl_group or ""
        if hl ~= "" and filter_func(hl) then
            table.insert(result, {
                name           = details.sign_name or hl,
                text           = details.sign_text or "",
                sign_hl_group  = hl,
                priority       = details.priority or 0,
            })
        end
    end
    -- Sort so the highest-priority mark is first (index 1)
    table.sort(result, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    return result
end

-- Returns diagnostic extmarks (DiagnosticSign*) for the given line.
---@param _     any      Unused self reference (called via static method)
---@param bufnr integer  Buffer number
---@param lnum  integer  1-based line number
---@return table[]       Filtered diagnostic extmark records
static.get_extmarks_diagnostics = function(_, bufnr, lnum)
    return get_extmarks(bufnr, lnum, function(hl)
        return hl:match("^DiagnosticSign")
    end)
end

-- Returns MiniDiff git extmarks (MiniDiffSign*) for the given line.
---@param _     any      Unused self reference
---@param bufnr integer  Buffer number
---@param lnum  integer  1-based line number
---@return table[]       Filtered git extmark records
static.get_extmarks_git = function(_, bufnr, lnum)
    return get_extmarks(bufnr, lnum, function(hl)
        return hl:match("^MiniDiffSign")
    end)
end

-- Returns all non-diagnostic, non-git extmarks (e.g. Neotest, DAP) for a line.
-- Explicitly excludes DiagnosticSign*, MiniDiffSign*, and several GitSigns
-- variants to avoid duplication with the dedicated columns.
---@param _     any      Unused self reference
---@param bufnr integer  Buffer number
---@param lnum  integer  1-based line number
---@return table[]       Filtered "other" extmark records
static.get_extmarks_other = function(_, bufnr, lnum)
    return get_extmarks(bufnr, lnum, function(hl)
        return not (
            hl:match("^DiagnosticSign")
            or hl:match("^MiniDiffSign")
            or hl:match("^GitSigns")
            or hl:match("^GitSign")
            or hl:match("^Gitsigns")
            or hl:match("^VGitSign")
            or hl:match("^Gitsigns")
        )
    end)
end

-- ---------------------------------------------------------------------------
-- Click handler helpers
-- ---------------------------------------------------------------------------

-- Builds a click-args table from a mouse event and resolves which sign was
-- clicked.  Tries to match the glyph under the mouse pointer against known
-- extmarks so the correct action handler can be dispatched.
---@param _      any      Unused self reference
---@param minwid integer  Minimum widget id from heirline on_click
---@param clicks integer  Click count
---@param button string   Mouse button identifier
---@param mods   string   Modifier keys held during the click
---@return table  args table with .minwid, .clicks, .button, .mods, .mousepos, .sign
static.click_args = function(_, minwid, clicks, button, mods)
    ---@type table  vim.fn.getmousepos() result
    local mp = vim.fn.getmousepos() or {}
    local args = {
        minwid   = minwid,
        clicks   = clicks,
        button   = button,
        mods     = mods,
        mousepos = mp,
    }

    -- Read the screen character at the click position to identify the glyph
    local ok_ss, sign_char = pcall(vim.fn.screenstring, mp.screenrow or 0, mp.screencol or 0)
    if not ok_ss or not sign_char then
        sign_char = ""
    end
    -- Some multi-byte glyphs occupy two screen columns; check the column to the
    -- left when the right half of the glyph (a space) was clicked.
    if sign_char == " " then
        local ok2, s2 = pcall(vim.fn.screenstring, mp.screenrow or 0, (mp.screencol or 1) - 1)
        if ok2 and s2 then
            sign_char = s2
        end
    end

    -- Resolve the buffer for the clicked window
    local ok, bufnr = pcall(vim.api.nvim_win_get_buf, mp.winid)
    if not ok or not bufnr then
        bufnr = vim.api.nvim_get_current_buf()
    end

    local lnum = mp.line or vim.v.lnum

    -- Gather all extmarks at the clicked line across all three categories
    local diags  = static.get_extmarks_diagnostics(nil, bufnr, lnum) or {}
    local gits   = static.get_extmarks_git(nil, bufnr, lnum) or {}
    local others = static.get_extmarks_other(nil, bufnr, lnum) or {}

    -- Merge into a single ordered list: diagnostics first, then git, then other
    local all = {}
    for _, e in ipairs(diags)  do table.insert(all, e) end
    for _, e in ipairs(gits)   do table.insert(all, e) end
    for _, e in ipairs(others) do table.insert(all, e) end

    -- Try to pick the sign whose text or name matches the clicked glyph
    local chosen = nil
    if sign_char and sign_char ~= "" then
        for _, e in ipairs(all) do
            local t = vim.trim(tostring(e.text or ""))
            local n = tostring(e.name or "")
            -- Match by text prefix (handles multi-char glyphs)
            if t ~= "" and t:sub(1, #sign_char) == sign_char then
                chosen = e
                break
            end
            -- Fall back to substring match on the sign name
            if n ~= "" and n:find(sign_char, 1, true) then
                chosen = e
                break
            end
        end
    end
    -- If no glyph match, fall back to priority order: diagnostic > git > other
    if not chosen then
        chosen = (diags[1] or gits[1] or others[1]) or nil
    end

    args.sign = chosen
    -- Move focus to the clicked window and position cursor at the clicked line
    pcall(vim.api.nvim_set_current_win, mp.winid)
    pcall(vim.api.nvim_win_set_cursor, mp.winid, { lnum, 0 })
    return args
end

-- Dispatches a sign name to the matching handler from static.handlers.Signs.
-- Pattern keys in handlers.Signs are matched as Lua patterns against the name.
-- The callback is deferred by 100 ms to let the cursor settle first.
---@param self table   Component self (must have self.handlers.Signs)
---@param name string  Sign name to resolve (e.g. "DiagnosticSignError")
---@return nil
static.resolve = function(self, name)
    if not name or name == "" then
        return
    end
    for pattern, callback in pairs(self.handlers.Signs) do
        if name:match(pattern) then
            return vim.defer_fn(callback, 100)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Click action handlers
-- ---------------------------------------------------------------------------

static.handlers = {}

-- Maps sign-name patterns to the action that should be triggered on click.
---@type table<string, fun(): nil>
static.handlers.Signs = {
    -- Clicking a Neotest sign runs the nearest test
    ["Neotest.*"] = function()
        require("neotest").run.run()
    end,
    -- Clicking a diagnostic sign opens Trouble diagnostics
    ["DiagnosticSign.*"] = function()
        vim.cmd("Trouble diagnostics")
    end,
    -- Clicking a MiniDiff sign toggles the hunk overlay
    ["MiniDiffSign.*"] = function()
        MiniDiff.toggle_overlay()
    end,
    -- Clicking a DAP sign continues the debug session
    ["Dap.*"] = function()
        require("dap").continue()
    end,
}

-- ---------------------------------------------------------------------------
-- mark_sign: Vim marks display
-- ---------------------------------------------------------------------------

-- Returns the single letter of any Vim mark set on the current line,
-- or an empty string when no mark is present.
-- Checks both global marks (uppercase) and buffer-local marks (lowercase).
---@return string  Single letter mark character, or "" if none
local function mark_sign()
    local cur_buf  = vim.api.nvim_get_current_buf()
    local cur_line = vim.v.lnum
    local marks    = vim.fn.getmarklist()
    local marks_local = vim.fn.getmarklist(cur_buf)
    -- Combine global and local marks into one list for a single pass
    local all_marks = vim.list_extend(marks, marks_local)
    for _, m in ipairs(all_marks) do
        -- Extract the letter from mark strings like "'a", "`B", etc.
        local letter = m.mark:match("^[`']?([a-zA-Z])$")
        if letter then
            local buf  = m.pos[1]
            local line = m.pos[2]
            if buf == cur_buf and line == cur_line then
                return letter
            end
        end
    end
    return ""
end

-- ---------------------------------------------------------------------------
-- ft: extended filetype exclusion list for the statuscolumn
-- ---------------------------------------------------------------------------

-- Builds the statuscolumn-specific filetype exclusion list by extending the
-- shared heirline filetype list with "org" and "fzf" which need no gutter.
---@return string[]  File types for which the statuscolumn should be hidden
local function ft()
    local file_types_statuscolumn = {}
    for i, v in ipairs(file_types) do
        file_types_statuscolumn[i] = v
    end
    table.insert(file_types_statuscolumn, "org")
    table.insert(file_types_statuscolumn, "fzf")
    return file_types_statuscolumn
end

-- ---------------------------------------------------------------------------
-- init: resets per-render component state
-- ---------------------------------------------------------------------------

---@param self table  Heirline component self reference
local init = function(self)
    -- Clear the signs cache at the start of each render cycle
    self.signs = {}
end

-- Layout primitives used inside the statuscolumn
local space = { provider = " " }
local align = { provider = "%=" }

-- ---------------------------------------------------------------------------
-- diagnostic_signs component
-- Shows the highest-priority diagnostic icon in the sign column area.
-- The icon and colour are derived from the sign's hl_group.
-- Clicking dispatches via static.resolve to open Trouble diagnostics.
-- ---------------------------------------------------------------------------

---@type table  Heirline component for diagnostic sign column
local diagnostic_signs = {
    ---@param self table  Sets self.sign and self.diagnostic_sign_name for current line
    init = function(self)
        self.click_args = static.click_args
        local bufnr    = self.bufnr or vim.api.nvim_get_current_buf()
        local diag_sign = static.get_extmarks_diagnostics(self, bufnr, vim.v.lnum)
        -- Take only the highest-priority diagnostic (index 1, already sorted)
        self.sign = diag_sign[1]
        self.diagnostic_sign_name = diag_sign[1] and diag_sign[1].name or nil
    end,
    ---@param self table   Component self (has self.sign)
    ---@return string      Diagnostic icon glyph followed by space, or single space if no sign
    provider = function(self)
        if not self.sign then
            return " "
        end
        local t = self.sign.sign_hl_group
        -- Map the highlight group to the corresponding icon
        local icon = (t == "DiagnosticSignError" and icons.diagnostics.error)
            or (t == "DiagnosticSignWarn"  and icons.diagnostics.warn)
            or (t == "DiagnosticSignInfo"  and icons.diagnostics.info)
            or (t == "DiagnosticSignHint"  and icons.diagnostics.hint)
            or icons.diagnostics.global
        return icon .. " "
    end,
    ---@param self table   Component self
    ---@return table|nil   Highlight spec using LvimColors diagnostic colours, or nil
    hl = function(self)
        local t = self.sign and self.sign.sign_hl_group
        if not t then
            return nil
        end
        ---@type LvimColors
        local c = _G.LVIM.colors
        return (t == "DiagnosticSignError" and { fg = c.diag_error })
            or (t == "DiagnosticSignWarn"  and { fg = c.diag_warn })
            or (t == "DiagnosticSignInfo"  and { fg = c.diag_info })
            or (t == "DiagnosticSignHint"  and { fg = c.diag_hint })
            or t
    end,
    on_click = {
        name = "sc_diagnostics_click",
        ---@param self   table   Component self
        ---@param minwid integer Mouse widget id
        ---@param clicks integer Click count
        ---@param button string  Mouse button
        ---@param mods   string  Modifier keys
        callback = function(self, minwid, clicks, button, mods)
            local args = static.click_args(self, minwid, clicks, button, mods)
            local name = (args and args.sign and args.sign.name) or self.diagnostic_sign_name
            if name then
                static.resolve(static, name)
            end
        end,
    },
}

-- ---------------------------------------------------------------------------
-- line_numbers component
-- Renders relative or absolute line numbers, with mark letters substituting
-- the number when a Vim mark is set on that line.
-- Clicking toggles a DAP breakpoint on the clicked line.
-- ---------------------------------------------------------------------------

---@type table  Heirline component for the line number column
local line_numbers = {
    ---@param self table  Sets self.mark for the current line
    init = function(self)
        self.mark = mark_sign()
        self.click_args = static.click_args
    end,
    ---@param self table   Component self
    ---@return string      Formatted line number or mark letter (right-aligned)
    provider = function(self)
        -- Suppress line numbers for quickfix, replacer, org, and virtual lines
        if
            vim.bo.filetype == "qf"
            or vim.bo.filetype == "replacer"
            or vim.bo.filetype == "org"
            or vim.v.virtnum ~= 0
        then
            return ""
        end
        local mark   = self.mark
        -- Pad the number area to align with the longest line number in the buffer
        local max_len = tostring(vim.api.nvim_buf_line_count(self.bufnr or 0)):len()
        if mark ~= "" then
            -- On the cursor line show the mark right-aligned; elsewhere show it left
            if vim.v.relnum == 0 then
                return string.rep(" ", math.max(0, max_len - 1)) .. mark
            else
                return mark
            end
        end
        -- Respect relativenumber: show relnum for off-cursor lines, lnum for cursor
        local lnum = vim.wo.relativenumber and (vim.v.relnum ~= 0 and vim.v.relnum or vim.v.lnum) or vim.v.lnum
        local str  = tostring(lnum)
        -- Right-align the number within the max_len field
        return string.rep(" ", max_len - #str) .. str
    end,
    ---@param self table   Component self
    ---@return table|nil   Highlight spec (blue for mark lines, nil for plain numbers)
    hl = function(self)
        if self.mark ~= "" then
            -- Highlight mark letters in blue to distinguish them from line numbers
            return { fg = _G.LVIM.colors.blue }
        end
        return nil
    end,
    on_click = {
        name = "sc_linenumber_click",
        -- Clicking the line number toggles a DAP breakpoint
        callback = function(_, _)
            require("dap").toggle_breakpoint()
        end,
    },
}

-- ---------------------------------------------------------------------------
-- git_signs component
-- Draws a vertical bar in the rightmost column of the sign area, coloured
-- according to the MiniDiff hunk type at that line (add / change / delete).
-- Falls back to a plain LineNr-coloured bar when mini.diff is not loaded or
-- the line has no diff hunk.  Clicking dispatches to MiniDiff.toggle_overlay.
-- ---------------------------------------------------------------------------

---@type table  Heirline component for the git gutter bar
local git_signs = {
    -- Only render on real lines, not virtual lines (virtnum != 0)
    condition = function()
        return vim.v.virtnum == 0
    end,
    ---@param self table  Sets self.git_sign, self.git_hl, self.git_sign_name
    init = function(self)
        self.click_args    = static.click_args
        self.git_sign      = icons.common.vline or "│"  -- default neutral bar
        self.git_hl        = "LineNr"
        self.git_sign_name = nil

        if not mini_ok then
            return
        end

        local bufnr       = vim.api.nvim_get_current_buf()
        local lnum        = vim.v.lnum
        local vcs_extmarks = static.get_extmarks_git(self, bufnr, lnum) or {}

        -- Pick the first matching MiniDiff hunk sign; the list is already sorted by priority
        for _, em in ipairs(vcs_extmarks) do
            local hl   = em.sign_hl_group or em.name or ""
            local name = em.name or ""
            if
                hl == "MiniDiffSignChangeDelete"
                or hl == "MiniDiffSignAdd"
                or hl == "MiniDiffSignChange"
                or hl == "MiniDiffSignDelete"
            then
                self.git_sign      = icons.common.vline or "│"
                self.git_hl        = hl
                self.git_sign_name = name
                break
            end
        end
    end,
    ---@param self table   Component self
    ---@return string      Vertical bar glyph for the gutter
    provider = function(self)
        return self.git_sign or (icons.common.vline or "│")
    end,
    ---@param self table        Component self
    ---@return string|table     Highlight group name or spec for the bar
    hl = function(self)
        return self.git_hl or "LineNr"
    end,
    on_click = {
        name = "sc_gitsigns_click",
        ---@param self   table   Component self
        ---@param minwid integer Mouse widget id
        ---@param clicks integer Click count
        ---@param button string  Mouse button
        ---@param mods   string  Modifier keys
        callback = function(self, minwid, clicks, button, mods)
            local args = static.click_args(self, minwid, clicks, button, mods)
            local name = (args and args.sign and args.sign.name) or self.git_sign_name
            if name then
                static.resolve(static, name)
            end
        end,
    },
}

-- ---------------------------------------------------------------------------
-- other_signs component
-- Displays miscellaneous extmark signs (Neotest, DAP, custom plugins) that
-- are not diagnostic or git signs.  Shows only the first (highest-priority)
-- sign found on the line.
-- ---------------------------------------------------------------------------

---@type table  Heirline component for miscellaneous sign column entries
local other_signs = {
    ---@param self table  Sets self.other_sign, self.other_hl, self.other_sign_name
    init = function(self)
        self.click_args      = static.click_args
        self.other_sign      = ""
        self.other_hl        = "StatusColumnOtherSign"
        self.other_sign_name = nil
        local bufnr   = vim.api.nvim_get_current_buf()
        local lnum    = vim.v.lnum
        local extmarks = static.get_extmarks_other(nil, bufnr, lnum)
        for _, extmark in ipairs(extmarks) do
            local hl   = extmark.sign_hl_group or ""
            local text = extmark.text or ""
            local name = extmark.name or ""
            if text ~= "" then
                -- Use the first extmark with a non-empty text glyph
                self.other_sign      = vim.trim(text)
                self.other_hl        = hl
                self.other_sign_name = name
                return
            end
        end
    end,
    ---@param self table   Component self
    ---@return string      Sign glyph + space, or empty string when no sign present
    provider = function(self)
        return self.other_sign ~= "" and (self.other_sign .. " ") or ""
    end,
    ---@param self table        Component self
    ---@return string|table     Highlight group or spec for the sign glyph
    hl = function(self)
        return self.other_hl or "StatusColumnOtherSign"
    end,
    on_click = {
        name = "sc_othersign_click",
        ---@param self   table   Component self
        ---@param minwid integer Mouse widget id
        ---@param clicks integer Click count
        ---@param button string  Mouse button
        ---@param mods   string  Modifier keys
        callback = function(self, minwid, clicks, button, mods)
            local args = static.click_args(self, minwid, clicks, button, mods)
            local name = (args and args.sign and args.sign.name) or self.other_sign_name
            if name then
                static.resolve(static, name)
            end
        end,
    },
}

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

local M = {}

-- Builds and returns the complete statuscolumn heirline component table.
-- The column is suppressed entirely for buffer/file types in the exclusion lists.
---@return table  Heirline statuscolumn component ready for heirline.setup()
M.get_statuscolumn = function()
    local statuscolumn = {
        -- Hide the custom statuscolumn for special buffers / tool windows
        condition = function()
            if conditions.buffer_matches({ buftype = buf_types, filetype = ft() }) then
                return false
            end
            return true
        end,
        static = static,
        init   = init,
        -- Column order (left to right): other signs | diagnostics | align | line nr | space | git | space
        -- space,          -- (commented out intentionally)
        other_signs,
        diagnostic_signs,
        align,
        line_numbers,
        space,
        git_signs,
        space,
    }

    return statuscolumn
end

return M
