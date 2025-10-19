---@diagnostic disable: undefined-field
local mini_ok = pcall(require, "mini.diff") or _G.MiniDiff ~= nil
local icons = require("configs.base.ui.icons")
local conditions = require("heirline.conditions")
local buf_types = require("modules.base.configs.ui.heirline.buf_types")
local file_types = require("modules.base.configs.ui.heirline.file_types")

local static = {}

-- EXTMARKS
local function get_extmarks(bufnr, lnum, filter_func)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return {}
    end
    local ok, extmarks = pcall(
        vim.api.nvim_buf_get_extmarks,
        bufnr,
        -1,
        { lnum - 1, 0 },
        { lnum - 1, -1 },
        { details = true }
    )
    if not ok or not extmarks then
        return {}
    end
    local result = {}
    for _, extmark in ipairs(extmarks) do
        local details = extmark[4] or {}
        local hl = details.sign_hl_group or details.number_hl_group or ""
        if hl ~= "" and filter_func(hl) then
            table.insert(result, {
                name = details.sign_name or hl,
                text = details.sign_text or "",
                sign_hl_group = hl,
                priority = details.priority or 0,
            })
        end
    end
    table.sort(result, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    return result
end
static.get_extmarks_diagnostics = function(_, bufnr, lnum)
    return get_extmarks(bufnr, lnum, function(hl)
        return hl:match("^DiagnosticSign")
    end)
end
static.get_extmarks_git = function(_, bufnr, lnum)
    return get_extmarks(bufnr, lnum, function(hl)
        return hl:match("^MiniDiffSign")
    end)
end
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
-- EXTMARKS

-- HANDLERS
static.click_args = function(_, minwid, clicks, button, mods)
    local mp = vim.fn.getmousepos() or {}
    local args = {
        minwid = minwid,
        clicks = clicks,
        button = button,
        mods = mods,
        mousepos = mp,
    }
    local ok_ss, sign_char = pcall(vim.fn.screenstring, mp.screenrow or 0, mp.screencol or 0)
    if not ok_ss or not sign_char then
        sign_char = ""
    end
    if sign_char == " " then
        local ok2, s2 = pcall(vim.fn.screenstring, mp.screenrow or 0, (mp.screencol or 1) - 1)
        if ok2 and s2 then
            sign_char = s2
        end
    end
    local ok, bufnr = pcall(vim.api.nvim_win_get_buf, mp.winid)
    if not ok or not bufnr then
        bufnr = vim.api.nvim_get_current_buf()
    end
    local lnum = mp.line or vim.v.lnum
    local diags = static.get_extmarks_diagnostics(nil, bufnr, lnum) or {}
    local gits = static.get_extmarks_git(nil, bufnr, lnum) or {}
    local others = static.get_extmarks_other(nil, bufnr, lnum) or {}
    local all = {}
    for _, e in ipairs(diags) do
        table.insert(all, e)
    end
    for _, e in ipairs(gits) do
        table.insert(all, e)
    end
    for _, e in ipairs(others) do
        table.insert(all, e)
    end
    local chosen = nil
    if sign_char and sign_char ~= "" then
        for _, e in ipairs(all) do
            local t = vim.trim(tostring(e.text or ""))
            local n = tostring(e.name or "")
            if t ~= "" and t:sub(1, #sign_char) == sign_char then
                chosen = e
                break
            end
            if n ~= "" and n:find(sign_char, 1, true) then
                chosen = e
                break
            end
        end
    end
    if not chosen then
        chosen = (diags[1] or gits[1] or others[1]) or nil
    end
    args.sign = chosen
    pcall(vim.api.nvim_set_current_win, mp.winid)
    pcall(vim.api.nvim_win_set_cursor, mp.winid, { lnum, 0 })
    return args
end

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

static.handlers = {}
static.handlers.Signs = {
    ["Neotest.*"] = function()
        require("neotest").run.run()
    end,
    ["DiagnosticSign.*"] = function()
        vim.cmd("Trouble diagnostics")
    end,
    ["MiniDiffSign.*"] = function()
        MiniDiff.toggle_overlay()
    end,
    ["Dap.*"] = function()
        require("dap").continue()
    end,
}
-- HANDLERS

local function mark_sign()
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_line = vim.v.lnum
    local marks = vim.fn.getmarklist()
    local marks_local = vim.fn.getmarklist(cur_buf)
    local all_marks = vim.list_extend(marks, marks_local)
    for _, m in ipairs(all_marks) do
        local letter = m.mark:match("^[`']?([a-zA-Z])$")
        if letter then
            local buf = m.pos[1]
            local line = m.pos[2]
            if buf == cur_buf and line == cur_line then
                return letter
            end
        end
    end
    return ""
end

local function ft()
    local file_types_statuscolumn = {}
    for i, v in ipairs(file_types) do
        file_types_statuscolumn[i] = v
    end
    table.insert(file_types_statuscolumn, "org")
    table.insert(file_types_statuscolumn, "fzf")
    return file_types_statuscolumn
end

local init = function(self)
    self.signs = {}
end

local space = { provider = " " }
local align = { provider = "%=" }

local diagnostic_signs = {
    init = function(self)
        self.click_args = static.click_args
        local bufnr = self.bufnr or vim.api.nvim_get_current_buf()
        local diag_sign = static.get_extmarks_diagnostics(self, bufnr, vim.v.lnum)
        self.sign = diag_sign[1]
        self.diagnostic_sign_name = diag_sign[1] and diag_sign[1].name or nil
    end,
    provider = function(self)
        if not self.sign then
            return " "
        end
        local t = self.sign.sign_hl_group
        local icon = (t == "DiagnosticSignError" and icons.diagnostics.error)
            or (t == "DiagnosticSignWarn" and icons.diagnostics.warn)
            or (t == "DiagnosticSignInfo" and icons.diagnostics.info)
            or (t == "DiagnosticSignHint" and icons.diagnostics.hint)
            or icons.diagnostics.global
        return icon .. " "
    end,
    hl = function(self)
        local t = self.sign and self.sign.sign_hl_group
        if not t then
            return nil
        end
        local c = _G.LVIM_COLORS
        return (t == "DiagnosticSignError" and { fg = c.diag_error })
            or (t == "DiagnosticSignWarn" and { fg = c.diag_warn })
            or (t == "DiagnosticSignInfo" and { fg = c.diag_info })
            or (t == "DiagnosticSignHint" and { fg = c.diag_hint })
            or t
    end,
    on_click = {
        name = "sc_diagnostics_click",
        callback = function(self, minwid, clicks, button, mods)
            local args = static.click_args(self, minwid, clicks, button, mods)
            local name = (args and args.sign and args.sign.name) or self.diagnostic_sign_name
            if name then
                static.resolve(static, name)
            end
        end,
    },
}

local line_numbers = {
    init = function(self)
        self.mark = mark_sign()
        self.click_args = static.click_args
    end,
    provider = function(self)
        if
            vim.bo.filetype == "qf"
            or vim.bo.filetype == "replacer"
            or vim.bo.filetype == "org"
            or vim.v.virtnum ~= 0
        then
            return ""
        end
        local mark = self.mark
        local max_len = tostring(vim.api.nvim_buf_line_count(self.bufnr or 0)):len()
        if mark ~= "" then
            if vim.v.relnum == 0 then
                return string.rep(" ", math.max(0, max_len - 1)) .. mark
            else
                return mark
            end
        end
        local lnum = vim.wo.relativenumber and (vim.v.relnum ~= 0 and vim.v.relnum or vim.v.lnum) or vim.v.lnum
        local str = tostring(lnum)
        return string.rep(" ", max_len - #str) .. str
    end,
    hl = function(self)
        if self.mark ~= "" then
            return { fg = _G.LVIM_COLORS.blue }
        end
        return nil
    end,
    on_click = {
        name = "sc_linenumber_click",
        callback = function(_, _)
            require("dap").toggle_breakpoint()
        end,
    },
}

local git_signs = {
    condition = function()
        return vim.v.virtnum == 0
    end,
    init = function(self)
        self.click_args = static.click_args
        self.git_sign = icons.common.vline or "│"
        self.git_hl = "LineNr"
        self.git_sign_name = nil

        if not mini_ok then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local lnum = vim.v.lnum
        local vcs_extmarks = static.get_extmarks_git(self, bufnr, lnum) or {}
        for _, em in ipairs(vcs_extmarks) do
            local hl = em.sign_hl_group or em.name or ""
            local name = em.name or ""
            if
                hl == "MiniDiffSignChangeDelete"
                or hl == "MiniDiffSignAdd"
                or hl == "MiniDiffSignChange"
                or hl == "MiniDiffSignDelete"
            then
                self.git_sign = icons.common.vline or "│"
                self.git_hl = hl
                self.git_sign_name = name
                break
            end
        end
    end,
    provider = function(self)
        return self.git_sign or (icons.common.vline or "│")
    end,
    hl = function(self)
        return self.git_hl or "LineNr"
    end,
    on_click = {
        name = "sc_gitsigns_click",
        callback = function(self, minwid, clicks, button, mods)
            local args = static.click_args(self, minwid, clicks, button, mods)
            local name = (args and args.sign and args.sign.name) or self.git_sign_name
            if name then
                static.resolve(static, name)
            end
        end,
    },
}

local other_signs = {
    init = function(self)
        self.click_args = static.click_args
        self.other_sign = ""
        self.other_hl = "StatusColumnOtherSign"
        self.other_sign_name = nil
        local bufnr = vim.api.nvim_get_current_buf()
        local lnum = vim.v.lnum
        local extmarks = static.get_extmarks_other(nil, bufnr, lnum)
        for _, extmark in ipairs(extmarks) do
            local hl = extmark.sign_hl_group or ""
            local text = extmark.text or ""
            local name = extmark.name or ""
            if text ~= "" then
                self.other_sign = vim.trim(text)
                self.other_hl = hl
                self.other_sign_name = name
                return
            end
        end
    end,
    provider = function(self)
        return self.other_sign ~= "" and (self.other_sign .. " ") or ""
    end,
    hl = function(self)
        return self.other_hl or "StatusColumnOtherSign"
    end,
    on_click = {
        name = "sc_othersign_click",
        callback = function(self, minwid, clicks, button, mods)
            local args = static.click_args(self, minwid, clicks, button, mods)
            local name = (args and args.sign and args.sign.name) or self.other_sign_name
            if name then
                static.resolve(static, name)
            end
        end,
    },
}

local M = {}
M.get_statuscolumn = function()
    local statuscolumn = {
        condition = function()
            if conditions.buffer_matches({ buftype = buf_types, filetype = ft() }) then
                return false
            end
            return true
        end,
        static = static,
        init = init,
        -- space,
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
