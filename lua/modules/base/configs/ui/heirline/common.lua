-- Shared heirline building blocks consumed by statusline, winbar, and statuscolumn.
-- Exports: heirline / heirline_conditions / heirline_utils handles, the active
-- theme color palette, buffer/filetype exclusion lists, the vi-mode component,
-- the file-type label component, the file-icon component, and layout primitives
-- (align, space).

---@module "modules.base.configs.ui.heirline.common"

local heirline = require("heirline")
local heirline_conditions = require("heirline.conditions")
local heirline_utils = require("heirline.utils")

---@type table  Per-theme colour palette (subset of LvimColors with _01/_02 variants)
local theme_colors = _G.LVIM.colors["colors"][_G.LVIM.settings.theme]

local icons = require("configs.base.ui.icons")

-- ---------------------------------------------------------------------------
-- Exclusion lists
-- Buffer types for which heirline components should be hidden / simplified.
-- ---------------------------------------------------------------------------

---@type string[]  Buffer types that should suppress decorations
local buftype = {
    "nofile",
    "prompt",
    "help",
}

---@type string[]  File types that should suppress decorations
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

-- ---------------------------------------------------------------------------
-- vi_mode component
-- Displays the current Vim mode as a short abbreviated label with a
-- mode-specific background colour.  Also keeps _G.LVIM.mode in sync so that
-- other components (file_icon, file_name) can react to the active mode.
-- ---------------------------------------------------------------------------

---@type table  Heirline component for the vi-mode pill
local vi_mode = {
    ---@param self table  Heirline component self reference
    init = function(self)
        -- Cache the full mode string (e.g. "niI", "^V") for provider / hl lookups
        self.mode = vim.fn.mode(1)
        if not self.once then
            -- Redraw the statusline when entering operator-pending sub-modes
            vim.api.nvim_create_autocmd("ModeChanged", {
                pattern = "*:*o",
                command = "redrawstatus",
            })
            self.once = true
        end
    end,
    static = {
        -- Human-readable two-char abbreviations for each Vim mode code
        ---@type table<string, string>
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
        -- Background colour for the mode pill keyed by the first mode character
        ---@type table<string, string>
        mode_colors = {
            n  = theme_colors.green_02,
            i  = theme_colors.red_02,
            v  = theme_colors.orange_02,
            V  = theme_colors.orange_02,
            ["\22"] = theme_colors.orange_02,
            c  = theme_colors.teal_01,
            s  = theme_colors.teal_01,
            S  = theme_colors.teal_01,
            ["\19"] = theme_colors.teal_01,
            R  = theme_colors.cyan_01,
            r  = theme_colors.cyan_01,
            ["!"] = theme_colors.cyan_01,
            t  = theme_colors.blue_01,
        },
    },
    ---@param self table  Heirline component self reference
    ---@return string     Rendered mode label with surrounding spaces
    provider = function(self)
        return " " .. icons.common.vim .. " %(" .. self.mode_names[self.mode] .. "%)  "
    end,
    ---@param self table  Heirline component self reference
    ---@return table      Highlight spec { bg, fg, bold }
    hl = function(self)
        -- Keep _G.LVIM.mode in sync so other components can read the current mode
        _G.LVIM.mode = self.mode:sub(1, 1)
        return { bg = self.mode_colors[self.mode:sub(1, 1)], fg = theme_colors.bg_01, bold = true }
    end,
    -- Re-evaluate on every mode transition and command-line enter/leave
    update = {
        "ModeChanged",
        "MenuPopup",
        "CmdlineEnter",
        "CmdlineLeave",
    },
}

-- ---------------------------------------------------------------------------
-- file_type component
-- Shows the current buffer's filetype in uppercase letters.
-- ---------------------------------------------------------------------------

---@type table  Heirline component that renders the filetype label
local file_type = {
    ---@return string|nil  Uppercased filetype string, or nil for unnamed buffers
    provider = function()
        local file_type = vim.bo.filetype
        if file_type ~= "" then
            return "  " .. string.upper(file_type)
        end
    end,
    hl = { fg = theme_colors.orange_02, bold = true },
}

-- ---------------------------------------------------------------------------
-- file_icon component
-- Renders the devicon for the current file, coloured with the active mode
-- colour so it tracks mode changes visually.
-- ---------------------------------------------------------------------------

---@type table  Heirline component for the file-type devicon
local file_icon = {
    ---@param self table  Component self; sets self.icon from nvim-web-devicons
    init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        -- Fetch the glyph for this filename + extension combo
        self.icon = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    end,
    ---@param self table   Component self (has self.icon, self.filename)
    ---@return string|nil  Icon glyph followed by a space, or nil for unnamed buffers
    provider = function(self)
        -- Only render the icon when the buffer has a name
        local is_filename = vim.fn.fnamemodify(self.filename, ":.")
        if is_filename ~= "" then
            return self.icon and self.icon .. " "
        end
    end,
    ---@return table  Highlight spec using the current vi-mode colour
    hl = function()
        return {
            fg = vi_mode.static.mode_colors[_G.LVIM.mode],
            bold = true,
        }
    end,
}

-- ---------------------------------------------------------------------------
-- Public exports
-- ---------------------------------------------------------------------------

return {
    heirline            = heirline,
    heirline_conditions = heirline_conditions,
    heirline_utils      = heirline_utils,
    ---@type table  Active theme palette (see LvimColors in core/types.lua)
    theme_colors        = theme_colors,
    ---@type string[]  Buffer types excluded from decorations
    buftype             = buftype,
    ---@type string[]  File types excluded from decorations
    filetype            = filetype,
    vi_mode             = vi_mode,
    file_type           = file_type,
    file_icon           = file_icon,
    icons               = icons,
    -- Flexible spacer that pushes content to the right of the statusline
    align               = { provider = "%=" },
    -- Single-character horizontal padding
    space               = { provider = " " },
}
