---@diagnostic disable: undefined-field
local M = {}

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

M.get_statuscolumn = function()
    local icons = require("configs.base.ui.icons")
    local conditions = require("heirline.conditions")
    local buf_types = require("modules.base.configs.ui.heirline.buf_types")
    local file_types = require("modules.base.configs.ui.heirline.file_types")

    local space = { provider = " " }
    local align = { provider = "%=" }

    local file_types_statuscolumn = {}
    for i, v in ipairs(file_types) do file_types_statuscolumn[i] = v end
    table.insert(file_types_statuscolumn, "org")
    table.insert(file_types_statuscolumn, "fzf")

    local mini_ok = pcall(require, "mini.diff") or _G.MiniDiff ~= nil

    local function is_minidiff_hunk_hl(hl)
        if not hl or hl == "" then return false end
        if hl:match("^MiniDiffSign") then return true end
        if mini_ok and (hl:match("Add$") or hl:match("Change$") or hl:match("Delete$")) then
            return true
        end
        return false
    end

    local static = {}

    local function get_extmarks(bufnr, lnum, filter_func)
        if not vim.api.nvim_buf_is_valid(bufnr) then return {} end
        local ok, extmarks = pcall(vim.api.nvim_buf_get_extmarks, bufnr, -1,
            { lnum - 1, 0 }, { lnum - 1, -1 }, { details = true })
        if not ok or not extmarks then return {} end

        local result = {}
        for _, extmark in ipairs(extmarks) do
            local details = extmark[4] or {}
            local hl = details.sign_hl_group or details.number_hl_group or ""
            if hl ~= "" and filter_func(hl) then
                table.insert(result, {
                    name = hl,
                    text = details.sign_text or "",
                    sign_hl_group = hl,
                    priority = details.priority or 0,
                })
            end
        end
        table.sort(result, function(a, b) return (a.priority or 0) > (b.priority or 0) end)
        return result
    end

    static.get_extmarks_signs = function(_, bufnr, lnum)
        return get_extmarks(bufnr, lnum, function(hl)
            return not hl:match("^DiagnosticSign") and not is_minidiff_hunk_hl(hl)
        end)
    end

    static.get_extmarks_diagnostics = function(_, bufnr, lnum)
        return get_extmarks(bufnr, lnum, function(hl) return hl:match("^DiagnosticSign") end)
    end

    static.get_extmarks_gits = function(_, bufnr, lnum)
        return get_extmarks(bufnr, lnum, is_minidiff_hunk_hl)
    end

    static.click_args = function(self, minwid, clicks, button, mods)
        local args = {
            minwid = minwid,
            clicks = clicks,
            button = button,
            mods = mods,
            mousepos = vim.fn.getmousepos(),
        }
        local sign = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
        if sign == " " then
            sign = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
        end
        args.sign = self.signs[sign]
        vim.api.nvim_set_current_win(args.mousepos.winid)
        vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })
        return args
    end

    static.resolve = function(self, name)
        for pattern, callback in pairs(self.handlers.Signs) do
            if name:match(pattern) then
                return vim.defer_fn(callback, 100)
            end
        end
    end

    static.handlers = {}
    static.handlers.Signs = {
        ["Neotest.*"] = function() require("neotest").run.run() end,
        ["Debug.*"] = function() require("dap").continue() end,
        ["Diagnostic.*"] = function() vim.cmd("LspShowDiagnosticCurrent") end,
    }
    static.handlers.Dap = function() require("dap").toggle_breakpoint() end
    static.handlers.DiagnosticSigns = function()
        vim.defer_fn(function() vim.cmd("Trouble diagnostics") end, 100)
    end

    local init = function(self) self.signs = {} end

    local signs = {
        init = function(self)
            local bufnr = self.bufnr or vim.api.nvim_get_current_buf()
            local signs = static.get_extmarks_signs(self, bufnr, vim.v.lnum)
            self.sign = signs[1]
        end,
        provider = function(self) return self.sign and self.sign.text or "" end,
        hl = function(self)
            if self.sign and self.sign.sign_hl_group and vim.api.nvim_get_hl then
                local ok, hl_def = pcall(vim.api.nvim_get_hl, 0, { name = self.sign.sign_hl_group, link = false })
                if ok and hl_def then
                    local fg = hl_def.fg or hl_def.foreground
                    if fg then return { fg = fg, bg = "NONE" } end
                    return self.sign.sign_hl_group
                end
            end
            return nil
        end,
        on_click = {
            name = "sc_sign_click",
            update = true,
            callback = function(self, ...)
                local args = self.click_args(self, ...)
                local line = args.mousepos.line
                local bufnr = self.bufnr or vim.api.nvim_get_current_buf()
                local sign = static.get_extmarks_signs(self, bufnr, line)[1]
                if sign then self:resolve(sign.name) end
            end,
        },
    }

    local line_numbers = {
        init = function(self) self.mark = mark_sign() end,
        provider = function(self)
            if vim.bo.filetype == "qf" or vim.bo.filetype == "replacer" or vim.bo.filetype == "org" or vim.v.virtnum ~= 0 then
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
            if self.mark ~= "" then return { fg = _G.LVIM_COLORS.blue } end
            return nil
        end,
        on_click = {
            name = "sc_linenumber_click",
            callback = function(self, ...) self.handlers.Dap(self.click_args(self, ...)) end,
        },
    }

    local diagnostics = {
        {
            init = function(self)
                local bufnr = self.bufnr or vim.api.nvim_get_current_buf()
                local diag_sign = static.get_extmarks_diagnostics(self, bufnr, vim.v.lnum)
                self.sign = diag_sign[1]
            end,
            provider = function(self)
                if not self.sign then return " " end
                local t = self.sign.sign_hl_group
                return (t == "DiagnosticSignError" and icons.diagnostics.error .. " ")
                    or (t == "DiagnosticSignWarn" and icons.diagnostics.warn .. " ")
                    or (t == "DiagnosticSignInfo" and icons.diagnostics.info .. " ")
                    or (t == "DiagnosticSignHint" and icons.diagnostics.hint .. " ")
                    or icons.diagnostics.global .. " "
            end,
            hl = function(self)
                local t = self.sign and self.sign.sign_hl_group
                if not t then return nil end
                local c = _G.LVIM_COLORS
                return (t == "DiagnosticSignError" and { fg = c.diag_error })
                    or (t == "DiagnosticSignWarn" and { fg = c.diag_warn })
                    or (t == "DiagnosticSignInfo" and { fg = c.diag_info })
                    or (t == "DiagnosticSignHint" and { fg = c.diag_hint })
                    or t
            end,
            on_click = {
                name = "sc_diagnostics_click",
                callback = function(self, ...) self.handlers.DiagnosticSigns(self.click_args(self, ...)) end,
            },
        },
    }

    local gits = {
        condition = function() return vim.v.virtnum == 0 end,
        init = function(self)
            if _G.LVIM_GIT then
                local bufnr = self.bufnr or vim.api.nvim_get_current_buf()
                local git_signs = static.get_extmarks_gits(self, bufnr, vim.v.lnum)
                self.sign = git_signs[1]
            end
        end,
        provider = function(self) return self.sign and self.sign.text or icons.common.vline end,
        hl = function(self) return self.sign and self.sign.sign_hl_group end,
    }

    local statuscolumn = {
        condition = function()
            if conditions.buffer_matches({ buftype = buf_types, filetype = file_types_statuscolumn }) then
                return false
            end
            return true
        end,
        static = static,
        init = init,
        space,
        signs,
        diagnostics,
        align,
        line_numbers,
        space,
        gits,
        space,
    }

    return statuscolumn
end

return M
