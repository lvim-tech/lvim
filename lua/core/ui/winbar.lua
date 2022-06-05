local M = {}

M.winbar_filetype_exclude = {
    "^git.*",
    "ctrlspace",
    "ctrlspace_help",
    "packer",
    "undotree",
    "diff",
    "Outline",
    "NvimTree",
    "LvimHelper",
    "floaterm",
    "Trouble",
    "dashboard",
    "vista",
    "spectre_panel",
    "DiffviewFiles",
    "flutterToolsOutline",
    "log",
    "qf",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "calendar",
}

local function isempty(s)
    return s == nil or s == ""
end

local colors = _G.LVIM_COLORS()
local hl_group_1 = "FileTextColor"
vim.api.nvim_set_hl(0, hl_group_1, { fg = colors.green, bg = colors.status_line_bg, bold = true })

local get_filename = function()
    local filename = vim.fn.expand("%:t")
    local extension = vim.fn.expand("%:e")
    if not isempty(filename) then
        local file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
            filename,
            extension,
            { default = true }
        )
        local hl_group_2 = "FileIconColor" .. extension
        vim.api.nvim_set_hl(0, hl_group_2, { fg = file_icon_color, bg = colors.status_line_bg })
        if isempty(file_icon) then
            file_icon = ""
            file_icon_color = ""
        end
        return " "
            .. "%#"
            .. hl_group_2
            .. "#"
            .. file_icon
            .. "%*"
            .. " "
            .. "%#"
            .. hl_group_1
            .. "#"
            .. filename
            .. "%*"
    end
end

local get_gps = function()
    local status_gps_ok, gps = pcall(require, "nvim-gps")
    if not status_gps_ok then
        return ""
    end

    local status_ok, gps_location = pcall(gps.get_location, {})
    if not status_ok then
        return ""
    end

    if not gps.is_available() or gps_location == "error" then
        return ""
    end

    if not isempty(gps_location) then
        return " ➤ " .. " " .. gps_location:gsub(" > ", " ➤ ")
    else
        return ""
    end
end

local excludes = function()
    if vim.tbl_contains(M.winbar_filetype_exclude, vim.bo.filetype) then
        vim.opt_local.winbar = nil
        return true
    end
    return false
end

M.get_winbar = function()
    if excludes() then
        return
    end
    local value = get_filename()
    if not isempty(value) then
        local gps_value = get_gps()
        value = value .. " " .. gps_value
    end
    local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
    if not status_ok then
        return
    end
end

return M
