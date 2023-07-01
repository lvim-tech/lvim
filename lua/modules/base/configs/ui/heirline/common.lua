local heirline = require("heirline")
local heirline_conditions = require("heirline.conditions")
local heirline_utils = require("heirline.utils")
local theme_colors = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme]
local icons = require("configs.base.ui.icons")

local buftype = {
    "nofile",
    "prompt",
    "help",
}

local filetype = {
    "ctrlspace",
    "ctrlspace_help",
    "packer",
    "undotree",
    "diff",
    "Outline",
    "NvimTree",
    "LvimHelper",
    "floaterm",
    "dashboard",
    "vista",
    "spectre_panel",
    "DiffviewFiles",
    "flutterToolsOutline",
    "log",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "calendar",
    "neo-tree",
    "neo-tree-popup",
    "noice",
    "toggleterm",
    "LvimShell",
    "oil",
}

local vi_mode = {
    init = function(self)
        self.mode = vim.fn.mode(1)
        if not self.once then
            vim.api.nvim_create_autocmd("ModeChanged", {
                pattern = "*:*o",
                command = "redrawstatus",
            })
            self.once = true
        end
    end,
    static = {
        mode_names = {
            n = "N",
            no = "N?",
            nov = "N?",
            noV = "N?",
            ["no\22"] = "N?",
            niI = "Ni",
            niR = "Nr",
            niV = "Nv",
            nt = "Nt",
            v = "V",
            vs = "Vs",
            V = "V_",
            Vs = "Vs",
            ["\22"] = "^V",
            ["\22s"] = "^V",
            s = "S",
            S = "S_",
            ["\19"] = "^S",
            i = "I",
            ic = "Ic",
            ix = "Ix",
            R = "R",
            Rc = "Rc",
            Rx = "Rx",
            Rv = "Rv",
            Rvc = "Rv",
            Rvx = "Rv",
            c = "C",
            cv = "Ex",
            r = "...",
            rm = "M",
            ["r?"] = "?",
            ["!"] = "!",
            t = "T",
        },
        mode_colors = {
            n = theme_colors.green_02,
            i = theme_colors.red_02,
            v = theme_colors.orange_02,
            V = theme_colors.orange_02,
            ["\22"] = theme_colors.orange_02,
            c = theme_colors.teal_01,
            s = theme_colors.teal_01,
            S = theme_colors.teal_01,
            ["\19"] = theme_colors.teal_01,
            R = theme_colors.cyan_01,
            r = theme_colors.cyan_01,
            ["!"] = theme_colors.cyan_01,
            t = theme_colors.blue_01,
        },
    },
    provider = function(self)
        return " " .. icons.common.vim .. " %(" .. self.mode_names[self.mode] .. "%)  "
    end,
    hl = function(self)
        _G.LVIM_MODE = self.mode:sub(1, 1)
        return { bg = self.mode_colors[self.mode:sub(1, 1)], fg = theme_colors.bg_01, bold = true }
    end,
    update = {
        "ModeChanged",
        "MenuPopup",
        "CmdlineEnter",
        "CmdlineLeave",
    },
}
local file_type = {
    provider = function()
        local file_type = vim.bo.filetype
        if file_type ~= "" then
            return "  " .. string.upper(file_type)
        end
    end,
    hl = { fg = theme_colors.orange_02, bold = true },
}
local file_icon = {
    init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
        local is_filename = vim.fn.fnamemodify(self.filename, ":.")
        if is_filename ~= "" then
            return self.icon and self.icon .. " "
        end
    end,
    hl = function()
        return {
            fg = vi_mode.static.mode_colors[_G.LVIM_MODE],
            bold = true,
        }
    end,
}

return {
    heirline = heirline,
    heirline_conditions = heirline_conditions,
    heirline_utils = heirline_utils,
    theme_colors = theme_colors,
    buftype = buftype,
    filetype = filetype,
    vi_mode = vi_mode,
    file_type = file_type,
    file_icon = file_icon,
    icons = icons,
    align = { provider = "%=" },
    space = { provider = " " },
}
