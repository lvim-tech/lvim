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
    local vgit = require("vgit")
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
    local static = {
        get_extmarks_signs = function(_, bufnr, lnum)
            local signs = {}
            local extmarks = vim.api.nvim_buf_get_extmarks(
                0,
                bufnr,
                { lnum - 1, 0 },
                { lnum - 1, -1 },
                { details = true, type = "sign" }
            )
            for _, extmark in pairs(extmarks) do
                if
                    extmark[4].sign_hl_group ~= "GitSignsAdd"
                    and extmark[4].sign_hl_group ~= "GitSignsChange"
                    and extmark[4].sign_hl_group ~= "GitSignsDelete"
                    and extmark[4].sign_hl_group ~= "DiagnosticSignError"
                    and extmark[4].sign_hl_group ~= "DiagnosticSignWarn"
                    and extmark[4].sign_hl_group ~= "DiagnosticSignInfo"
                    and extmark[4].sign_hl_group ~= "DiagnosticSignHint"
                then
                    signs[#signs + 1] = {
                        name = extmark[4].sign_hl_group or "",
                        text = extmark[4].sign_text,
                        sign_hl_group = extmark[4].sign_hl_group,
                        priority = extmark[4].priority,
                    }
                end
            end
            table.sort(signs, function(a, b)
                return (a.priority or 0) > (b.priority or 0)
            end)
            return signs
        end,
        get_extmarks_diagnostics = function(_, bufnr, lnum)
            local diagnostics = {}
            local extmarks = vim.api.nvim_buf_get_extmarks(
                0,
                bufnr,
                { lnum - 1, 0 },
                { lnum - 1, -1 },
                { details = true, type = "sign" }
            )
            for _, extmark in pairs(extmarks) do
                if
                    extmark[4].sign_hl_group == "DiagnosticSignError"
                    or extmark[4].sign_hl_group == "DiagnosticSignWarn"
                    or extmark[4].sign_hl_group == "DiagnosticSignInfo"
                    or extmark[4].sign_hl_group == "DiagnosticSignHint"
                then
                    diagnostics[#diagnostics + 1] = {
                        name = extmark[4].sign_hl_group or "",
                        text = extmark[4].sign_text,
                        sign_hl_group = extmark[4].sign_hl_group,
                        priority = extmark[4].priority,
                    }
                end
            end
            return diagnostics
        end,
        get_extmarks_gits = function(_, bufnr, lnum)
            local gits = {}
            local extmarks = vim.api.nvim_buf_get_extmarks(
                0,
                bufnr,
                { lnum - 1, 0 },
                { lnum - 1, -1 },
                { details = true, type = "sign" }
            )
            for _, extmark in pairs(extmarks) do
                if
                    extmark[4].sign_hl_group == "GitSignsAdd"
                    or extmark[4].sign_hl_group == "GitSignsChange"
                    or extmark[4].sign_hl_group == "GitSignsDelete"
                then
                    gits[#gits + 1] = {
                        name = extmark[4].sign_hl_group or "",
                        text = extmark[4].sign_text,
                        sign_hl_group = extmark[4].sign_hl_group,
                        priority = extmark[4].priority,
                    }
                end
            end
            return gits
        end,
        click_args = function(self, minwid, clicks, button, mods)
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
        end,
        resolve = function(self, name)
            for pattern, callback in pairs(self.handlers.Signs) do
                if name:match(pattern) then
                    return vim.defer_fn(callback, 100)
                end
            end
        end,
        handlers = {
            Signs = {
                ["Neotest.*"] = function(_, _)
                    require("neotest").run.run()
                end,
                ["Debug.*"] = function(_, _)
                    local dap = require("dap")
                    dap.continue()
                end,
                ["Diagnostic.*"] = function(_, _)
                    vim.cmd("LspShowDiagnosticCurrent")
                end,
            },
            Dap = function(_, _)
                require("dap").toggle_breakpoint()
            end,
            DiagnosticSigns = function(_, _)
                vim.defer_fn(function()
                    vim.cmd("Trouble diagnostics")
                end, 100)
            end,
            GitSigns = function(_, _)
                vim.defer_fn(function()
                    vgit.buffer_hunk_preview()
                end, 100)
            end,
        },
    }

    local init = function(self)
        self.signs = {}
    end

    local signs = {
        init = function(self)
            local signs = self.get_extmarks_signs(self, -1, vim.v.lnum)
            self.sign = signs[1]
        end,
        provider = function(self)
            return self.sign and self.sign.text or ""
        end,
        hl = function(self)
            return self.sign and self.sign.sign_hl_group
        end,
        on_click = {
            name = "sc_sign_click",
            update = true,
            callback = function(self, ...)
                local line = self.click_args(self, ...).mousepos.line
                local sign = self.get_extmarks_signs(self, -1, line)[1]
                if sign then
                    self:resolve(sign.name)
                end
            end,
        },
    }

    -- local marks = {
    --     provider = function()
    --         if vim.bo.filetype == "qf" or vim.bo.filetype == "org" or vim.v.virtnum ~= 0 then
    --             return ""
    --         end
    --         local mark = mark_sign()
    --         return (mark ~= " ") and (mark .. " ") or ""
    --     end,
    --     hl = { fg = _G.LVIM_COLORS.blue, bold = true },
    --     on_click = {
    --         name = "sc_mark_click",
    --         callback = function(_, minwid, _, button, _)
    --             if button == "m" then
    --                 local letter = string.char(minwid)
    --                 vim.cmd("delmarks " .. letter)
    --                 vim.notify("Mark '" .. letter .. "' removed")
    --             end
    --         end,
    --     },
    -- }

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

            local max_len = tostring(vim.api.nvim_buf_line_count(0)):len()
            local mark = self.mark

            if mark ~= "" then
                if vim.v.relnum == 0 then
                    return string.rep(" ", math.max(0, max_len - 1)) .. mark
                else
                    return mark
                end
            end

            if vim.v.relnum == 0 then
                local lnum = vim.v.lnum
                local number_str = tostring(lnum)
                local spaces_needed = max_len - #number_str
                return string.rep(" ", spaces_needed) .. number_str
            end
            return tostring(vim.v.relnum)
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
                local diag_sign = self.get_extmarks_diagnostics(self, -1, vim.v.lnum)
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

    local vline = " " .. icons.common.vline
    local gits = {
        {
            condition = function()
                return (_G.LVIM_GIT == nil) or vim.v.virtnum ~= 0
            end,
            provider = vline,
        },
        {
            condition = function()
                return (_G.LVIM_GIT ~= nil) and vim.v.virtnum == 0
            end,
            init = function(self)
                local gits = self.get_extmarks_gits(self, -1, vim.v.lnum)
                self.sign = gits[1]
            end,
            provider = function(self)
                return self.sign and self.sign.text or vline
            end,
            hl = function(self)
                return self.sign and self.sign.sign_hl_group
            end,
            on_click = {
                name = "sc_gitsigns_click",
                callback = function(self, ...)
                    self.handlers.GitSigns(self.click_args(self, ...))
                end,
            },
        },
    }

    local statuscolumn = {
        condition = function()
            if
                conditions.buffer_matches({
                    buftype = buf_types,
                    filetype = file_types_statuscolumn,
                })
            then
                vim.opt.number = false
                vim.opt.relativenumber = false
                return false
            else
                return true
            end
        end,
        static = static,
        init = init,
        space,
        -- marks,
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
