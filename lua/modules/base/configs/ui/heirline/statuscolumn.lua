local M = {}

M.get_statuscolumn = function()
    local colors = _G.LVIM_COLORS["colors"][_G.LVIM_SETTINGS.theme]
    local icons = require("configs.base.ui.icons")
    local conditions = require("heirline.conditions")
    local gitsigns = require("gitsigns")
    local buf_types = require("modules.base.configs.ui.heirline.buf_types")
    local file_types = require("modules.base.configs.ui.heirline.file_types")
    local space = { provider = " " }
    local align = { provider = "%=" }
    local file_types_statuscolumn = {}
    for i, v in ipairs(file_types) do
        file_types_statuscolumn[i] = v
    end
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
                    and extmark[4].sign_hl_group ~= "GitSignsTopDelete"
                    and extmark[4].sign_hl_group ~= "GitSignsChangeDelete"
                    and extmark[4].sign_hl_group ~= "GitSignsUntracked"
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
                return (a.priority or 0) < (b.priority or 0)
            end)
            return signs
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
                    or extmark[4].sign_hl_group == "GitSignsTopDelete"
                    or extmark[4].sign_hl_group == "GitSignsChangeDelete"
                    or extmark[4].sign_hl_group == "GitSignsUntracked"
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
        -- ns_git = vim.api.nvim_create_namespace("gitsigns_extmark_signs_"),
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
                    require("dap").continue()
                end,
                ["Diagnostic.*"] = function(_, _)
                    vim.cmd("LspShowDiagnosticCurrent")
                end,
            },
            Dap = function(_, _)
                require("dap").toggle_breakpoint()
            end,
            GitSigns = function(_, _)
                vim.defer_fn(function()
                    gitsigns.preview_hunk()
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
            return self.sign and self.sign.text or "  "
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

    local line_numbers = {
        provider = function()
            if vim.bo.filetype == "qf" or vim.bo.filetype == "replacer" or vim.v.virtnum ~= 0 then
                return ""
            end
            if vim.v.relnum == 0 then
                return vim.v.lnum
            end
            return vim.v.relnum
        end,
        on_click = {
            name = "sc_linenumber_click",
            callback = function(self, ...)
                self.handlers.Dap(self.click_args(self, ...))
            end,
        },
    }

    local gits = {
        {
            condition = function()
                return not conditions.is_git_repo() or vim.v.virtnum ~= 0
            end,
            provider = icons.common.vline,
            hl = { fg = colors.bg_04 },
        },
        {
            condition = function()
                return conditions.is_git_repo() and vim.v.virtnum == 0
            end,
            init = function(self)
                local gits = self.get_extmarks_gits(self, -1, vim.v.lnum)
                self.sign = gits[1]
            end,
            provider = function(self)
                return self.sign and self.sign.text or icons.common.vline
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
            return not conditions.buffer_matches({
                buftype = buf_types,
                filetype = file_types_statuscolumn,
            })
        end,
        hl = { fg = colors.bg_04 },
        static = static,
        init = init,
        space,
        signs,
        align,
        line_numbers,
        space,
        gits,
        space,
    }

    return statuscolumn
end

return M
