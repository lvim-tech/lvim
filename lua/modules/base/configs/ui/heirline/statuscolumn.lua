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
    for i, v in ipairs(file_types) do
        file_types_statuscolumn[i] = v
    end
    table.insert(file_types_statuscolumn, "org")
    table.insert(file_types_statuscolumn, "fzf")
    local mini_ok = pcall(require, "mini.diff") or _G.MiniDiff ~= nil
    local mini = mini_ok and (require("mini.diff") or _G.MiniDiff) or nil

    local function get_minidiff_hl_names()
        return {
            sign_add = "MiniDiffSignAdd",
            sign_change = "MiniDiffSignChange",
            sign_delete = "MiniDiffSignDelete",
            over_add = "MiniDiffOverAdd",
            over_change = "MiniDiffOverChange",
            over_change_buf = "MiniDiffOverChangeBuf",
            over_context = "MiniDiffOverContext",
            over_context_buf = "MiniDiffOverContextBuf",
            over_delete = "MiniDiffOverDelete",
        }
    end
    local md_hl = get_minidiff_hl_names()
    local function is_minidiff_hunk_hl(hl)
        if not hl or hl == "" then
            return false
        end
        if hl:match("^MiniDiffSign") then
            return true
        end
        if mini_ok and (hl:match("Add$") or hl:match("Change$") or hl:match("Delete$")) then
            return true
        end
        return false
    end
    local static = {}
    local function get_extmarks(bufnr, lnum, filter_func)
        local extmarks = vim.api.nvim_buf_get_extmarks(
            0,
            bufnr,
            { lnum - 1, 0 },
            { lnum - 1, -1 },
            { details = true, type = "sign" }
        )
        if not extmarks then
            return {}
        end
        local result = {}
        for _, extmark in ipairs(extmarks) do
            local details = extmark[4] or {}
            local hl = details.sign_hl_group or details.number_hl_group or ""
            if filter_func(hl) then
                table.insert(result, {
                    name = hl,
                    text = details.sign_text,
                    sign_hl_group = hl,
                    priority = details.priority,
                })
            end
        end
        table.sort(result, function(a, b)
            return (a.priority or 0) > (b.priority or 0)
        end)
        return result
    end
    static.get_extmarks_signs = function(_, bufnr, lnum)
        return get_extmarks(bufnr, lnum, function(hl)
            return not hl:match("^DiagnosticSign") and not is_minidiff_hunk_hl(hl)
        end)
    end
    static.get_extmarks_diagnostics = function(_, bufnr, lnum)
        return get_extmarks(bufnr, lnum, function(hl)
            return hl:match("^DiagnosticSign")
        end)
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
        ["Neotest.*"] = function()
            require("neotest").run.run()
        end,
        ["Debug.*"] = function()
            local dap = require("dap")
            dap.continue()
        end,
        ["Diagnostic.*"] = function()
            vim.cmd("LspShowDiagnosticCurrent")
        end,
    }
    static.handlers.Dap = function()
        require("dap").toggle_breakpoint()
    end
    static.handlers.DiagnosticSigns = function()
        vim.defer_fn(function()
            vim.cmd("Trouble diagnostics")
        end, 100)
    end
    static.handlers.MiniDiffPreview = function(_, args)
        if not mini_ok or not mini then
            return
        end
        local mouse_line = (args and args.mousepos and args.mousepos.line) or vim.fn.line(".")
        local winid = (args and args.mousepos and args.mousepos.winid) or nil
        local buf = nil
        if winid and pcall(vim.api.nvim_win_is_valid, winid) and vim.api.nvim_win_is_valid(winid) then
            buf = vim.api.nvim_win_get_buf(winid)
        else
            buf = vim.api.nvim_get_current_buf()
        end
        local name = vim.api.nvim_buf_get_name(buf)
        if not name or name == "" then
            return
        end
        local get_buf_data = mini.get_buf_data or (_G.MiniDiff and _G.MiniDiff.get_buf_data)
        if type(get_buf_data) ~= "function" then
            return
        end
        local data = get_buf_data(buf)
        if not data or type(data.hunks) ~= "table" or #data.hunks == 0 then
            return
        end
        local found = nil
        for _, h in ipairs(data.hunks) do
            local from, to
            if h.buf_count and h.buf_count > 0 then
                from = h.buf_start
                to = h.buf_start + h.buf_count - 1
            else
                from = math.max(h.buf_start, 1)
                to = from
            end
            if mouse_line >= from and mouse_line <= to then
                found = h
                break
            end
        end
        if not found then
            return
        end
        local ref_lines = {}
        if data.ref_text and type(data.ref_text) == "string" then
            ref_lines = vim.split(data.ref_text, "\n")
        end
        local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local preview_lines = {}
        table.insert(
            preview_lines,
            string.format(
                "%s hunk — buf:%d..%d | ref:%d..%d",
                found.type,
                found.buf_start,
                (found.buf_start or 0) + (found.buf_count or 0) - 1,
                found.ref_start,
                (found.ref_start or 0) + (found.ref_count or 0) - 1
            )
        )
        table.insert(preview_lines, string.rep("-", 60))
        local line_meta = {}
        if found.type == "add" then
            for i = found.buf_start, found.buf_start + found.buf_count - 1 do
                table.insert(preview_lines, "+ " .. (buf_lines[i] or ""))
                table.insert(line_meta, { kind = "add" })
            end
        elseif found.type == "delete" then
            for i = found.ref_start, found.ref_start + found.ref_count - 1 do
                table.insert(preview_lines, "- " .. (ref_lines[i] or ""))
                table.insert(line_meta, { kind = "delete" })
            end
        else
            local maxc = math.max(found.ref_count, found.buf_count)
            for k = 1, maxc do
                local ri = found.ref_start + k - 1
                local bi = found.buf_start + k - 1
                if ri <= found.ref_start + found.ref_count - 1 then
                    table.insert(preview_lines, "- " .. (ref_lines[ri] or ""))
                    table.insert(line_meta, { kind = "change_ref" })
                end
                if bi <= found.buf_start + found.buf_count - 1 then
                    table.insert(preview_lines, "+ " .. (buf_lines[bi] or ""))
                    table.insert(line_meta, { kind = "change_buf" })
                end
            end
        end
        local buf_preview = vim.api.nvim_create_buf(false, true)
        vim.bo[buf_preview].bufhidden = "wipe"
        vim.api.nvim_buf_set_lines(buf_preview, 0, -1, false, preview_lines)
        pcall(function()
            vim.bo[buf_preview].filetype = "diff"
        end)
        pcall(function()
            vim.bo[buf_preview].modifiable = false
        end)
        local ns = vim.api.nvim_create_namespace("sc_minidiff_preview")
        pcall(vim.api.nvim_buf_clear_namespace, buf_preview, ns, 0, -1)
        for i, meta in ipairs(line_meta) do
            local ln = i + 2
            if meta.kind == "add" then
                pcall(
                    vim.api.nvim_buf_set_extmark,
                    buf_preview,
                    ns,
                    ln - 1,
                    0,
                    { hl_group = md_hl.over_add, hl_eol = true }
                )
            elseif meta.kind == "delete" then
                pcall(
                    vim.api.nvim_buf_set_extmark,
                    buf_preview,
                    ns,
                    ln - 1,
                    0,
                    { hl_group = md_hl.over_delete, hl_eol = true }
                )
            elseif meta.kind == "change_ref" then
                pcall(
                    vim.api.nvim_buf_set_extmark,
                    buf_preview,
                    ns,
                    ln - 1,
                    0,
                    { hl_group = md_hl.over_change, hl_eol = true }
                )
            elseif meta.kind == "change_buf" then
                pcall(
                    vim.api.nvim_buf_set_extmark,
                    buf_preview,
                    ns,
                    ln - 1,
                    0,
                    { hl_group = md_hl.over_change_buf, hl_eol = true }
                )
            end
        end
        local width = math.min(80, math.max(40, math.floor(vim.o.columns * 0.6)))
        local height = math.min(20, math.max(5, #preview_lines))
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)
        local opts = {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            style = "minimal",
            border = "rounded",
        }
        pcall(vim.api.nvim_open_win, buf_preview, false, opts)
    end
    local init = function(self)
        self.signs = {}
    end
    local signs = {
        init = function(self)
            local signs = static.get_extmarks_signs(self, -1, vim.v.lnum)
            self.sign = signs[1]
        end,
        provider = function(self)
            return self.sign and self.sign.text or ""
        end,
        hl = function(self)
            if self.sign and self.sign.sign_hl_group and vim.api.nvim_get_hl then
                local ok, original_hl = pcall(vim.api.nvim_get_hl, 0, { name = self.sign.sign_hl_group, link = false })
                if ok and original_hl then
                    local fg = original_hl.fg or original_hl.foreground
                    if fg then
                        return {
                            fg = fg,
                            bg = "NONE",
                        }
                    end
                    return self.sign.sign_hl_group
                end
            end
            return nil
        end,
        on_click = {
            name = "sc_sign_click",
            update = true,
            callback = function(self, ...)
                local line = self.click_args(self, ...).mousepos.line
                local sign = static.get_extmarks_signs(self, -1, line)[1]
                if sign then
                    self:resolve(sign.name)
                end
            end,
        },
    }
    local line_numbers = {
        init = function(self)
            self.mark = mark_sign()
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
            local max_len = tostring(vim.api.nvim_buf_line_count(0)):len()
            if mark ~= "" then
                if vim.v.relnum == 0 then
                    return string.rep(" ", math.max(0, max_len - 1)) .. mark
                else
                    return mark
                end
            end
            if vim.wo.relativenumber then
                if vim.v.relnum == 0 then
                    local lnum = vim.v.lnum
                    local number_str = tostring(lnum)
                    local spaces_needed = max_len - #number_str
                    return string.rep(" ", spaces_needed) .. number_str
                else
                    local rel_str = tostring(vim.v.relnum)
                    local spaces_needed = max_len - #rel_str
                    return string.rep(" ", spaces_needed) .. rel_str
                end
            else
                local lnum = vim.v.lnum
                local number_str = tostring(lnum)
                local spaces_needed = max_len - #number_str
                return string.rep(" ", spaces_needed) .. number_str
            end
        end,
        hl = function(self)
            if self.mark ~= "" then
                return { fg = _G.LVIM_COLORS.blue }
            end
            return nil
        end,
        on_click = {
            name = "sc_linenumber_click",
            callback = function(self, ...)
                self.handlers.Dap(self.click_args(self, ...))
            end,
        },
    }
    local diagnostics = {
        {
            init = function(self)
                local diag_sign = static.get_extmarks_diagnostics(self, -1, vim.v.lnum)
                self.sign = diag_sign[1]
            end,
            provider = function(self)
                if not self.sign then
                    return " "
                end
                if self.sign.sign_hl_group == "DiagnosticSignError" then
                    return icons.diagnostics.error .. " "
                elseif self.sign.sign_hl_group == "DiagnosticSignWarn" then
                    return icons.diagnostics.warn .. " "
                elseif self.sign.sign_hl_group == "DiagnosticSignInfo" then
                    return icons.diagnostics.info .. " "
                elseif self.sign.sign_hl_group == "DiagnosticSignHint" then
                    return icons.diagnostics.hint .. " "
                else
                    return icons.diagnostics.global .. " "
                end
            end,
            hl = function(self)
                if not self.sign then
                    return nil
                end

                if self.sign.sign_hl_group == "DiagnosticSignError" then
                    return { fg = _G.LVIM_COLORS.diag_error }
                elseif self.sign.sign_hl_group == "DiagnosticSignWarn" then
                    return { fg = _G.LVIM_COLORS.diag_warn }
                elseif self.sign.sign_hl_group == "DiagnosticSignInfo" then
                    return { fg = _G.LVIM_COLORS.diag_info }
                elseif self.sign.sign_hl_group == "DiagnosticSignHint" then
                    return { fg = _G.LVIM_COLORS.diag_hint }
                else
                    return self.sign.sign_hl_group
                end
            end,
            on_click = {
                name = "sc_diagnostics_click",
                callback = function(self, ...)
                    self.handlers.DiagnosticSigns(self.click_args(self, ...))
                end,
            },
        },
    }
    local gits = {
        condition = function()
            return vim.v.virtnum == 0
        end,
        init = function(self)
            if _G.LVIM_GIT then
                local git_signs = static.get_extmarks_gits(self, -1, vim.v.lnum)
                self.sign = git_signs[1]
            end
        end,
        provider = function(self)
            return self.sign and self.sign.text or icons.common.vline
        end,
        hl = function(self)
            return self.sign and self.sign.sign_hl_group
        end,
        -- on_click = {
        --     name = "sc_gitsigns_click",
        --     callback = function(self, ...)
        --         self.handlers.MiniDiffPreview(self, self.click_args(self, ...))
        --     end,
        -- },
    }
    local statuscolumn = {
        condition = function()
            if
                conditions.buffer_matches({
                    buftype = buf_types,
                    filetype = file_types_statuscolumn,
                })
            then
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
