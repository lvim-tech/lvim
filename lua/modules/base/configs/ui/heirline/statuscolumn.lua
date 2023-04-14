local common = require("modules.base.configs.ui.heirline.common")
local conditions = require("heirline.conditions")
local gitsigns_avail, gitsigns = pcall(require, "gitsigns")

local static = {
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
    handlers = {},
}

local init = function(self)
    self.signs = {}
    self.handlers.signs = function()
        return vim.schedule(vim.cmd("LspShowDiagnosticCurrent"))
    end
    self.handlers.line_number = function()
        local dap_avail, dap = pcall(require, "dap")
        if dap_avail then
            vim.schedule(dap.toggle_breakpoint)
        end
    end
    self.handlers.git_signs = function()
        if gitsigns_avail then
            vim.schedule(gitsigns.preview_hunk)
        end
    end
    self.handlers.fold = function(args)
        local lnum = args.mousepos.line
        if vim.fn.foldlevel(lnum) <= vim.fn.foldlevel(lnum - 1) then
            return
        end
        vim.cmd.execute("'" .. lnum .. "fold" .. (vim.fn.foldclosed(lnum) == -1 and "close" or "open") .. "'")
    end
end

local signs = {
    init = function(self)
        local signs = vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), {
            group = "*",
            lnum = vim.v.lnum,
        })
        if #signs == 0 or signs[1].signs == nil then
            self.sign = nil
            self.has_sign = false
            return
        end
        signs = vim.tbl_filter(function(sign)
            return not vim.startswith(sign.group, "gitsigns")
        end, signs[1].signs)
        if #signs == 0 then
            self.sign = nil
        else
            self.sign = signs[1]
        end
        self.has_sign = self.sign ~= nil
    end,
    provider = function(self)
        if self.has_sign then
            return vim.fn.sign_getdefined(self.sign.name)[1].text
        end
        return " "
    end,
    hl = function(self)
        if self.has_sign then
            if self.sign.group == "neotest-status" then
                if self.sign.name == "neotest_running" then
                    return "NeotestRunning"
                end
                if self.sign.name == "neotest_failed" then
                    return "NeotestFailed"
                end
                if self.sign.name == "neotest_passed" then
                    return "NeotestPassed"
                end
                return "NeotestSkipped"
            end
            local hl = self.sign.name
            return (vim.fn.hlexists(hl) ~= 0 and hl)
        end
    end,
    on_click = {
        name = "sign_click",
        callback = function(self, ...)
            if self.handlers.signs then
                self.handlers.signs(self.click_args(self, ...))
            end
        end,
    },
}

local line_numbers = {
    provider = function()
        if vim.v.virtnum ~= 0 then
            return ""
        end
        if vim.v.relnum == 0 then
            return vim.v.lnum
        end
        return vim.v.relnum
    end,
    on_click = {
        name = "line_number_click",
        callback = function(self, ...)
            if self.handlers.line_number then
                self.handlers.line_number(self.click_args(self, ...))
            end
        end,
    },
}

local git_signs = {
    {
        condition = function()
            return not conditions.is_git_repo() or vim.v.virtnum ~= 0
        end,
        provider = "▌",
    },
    {
        condition = function()
            return conditions.is_git_repo() and vim.v.virtnum == 0
        end,
        init = function(self)
            local signs = vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), {
                group = "gitsigns_vimfn_signs_",
                id = vim.v.lnum,
                lnum = vim.v.lnum,
            })

            if #signs == 0 or signs[1].signs == nil or #signs[1].signs == 0 or signs[1].signs[1].name == nil then
                self.sign = nil
            else
                self.sign = signs[1].signs[1]
            end

            self.has_sign = self.sign ~= nil
        end,
        provider = "▌",
        hl = function(self)
            if self.has_sign then
                return self.sign.name
            end
        end,
        on_click = {
            name = "gitsigns_click",
            callback = function(self, ...)
                if self.handlers.git_signs then
                    self.handlers.git_signs(self.click_args(self, ...))
                end
            end,
        },
    },
}

return {
    condition = function()
        return not conditions.buffer_matches({
            buftype = common.buftype,
            filetype = common.filetype,
        })
    end,
    static = static,
    init = init,
    signs,
    common.align,
    line_numbers,
    git_signs,
}
