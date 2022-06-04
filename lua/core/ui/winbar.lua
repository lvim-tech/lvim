local M = {}

local status_gps_ok, gps = pcall(require, "nvim-gps")
if not status_gps_ok then
    return
end

local function isempty(s)
    return s == nil or s == ""
end

local colors = _G.LVIM_COLORS()
local hl_group_1 = "FileTextColor"
vim.api.nvim_set_hl(0, hl_group_1, { fg = colors.green, bg = colors.status_line_bg, bold = true })

M.filename = function()
    local filename = vim.fn.expand("%:t")
    local extension = ""
    local file_icon = ""
    local file_icon_color = ""
    local default_file_icon = ""
    local default_file_icon_color = ""
    if not isempty(filename) then
        extension = vim.fn.expand("%:e")
        local default = false
        if isempty(extension) then
            extension = ""
            default = true
        end
        file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
            filename,
            extension,
            { default = default }
        )
        local hl_group_2 = "FileIconColor" .. extension
        vim.api.nvim_set_hl(0, hl_group_2, { fg = file_icon_color, bg = colors.status_line_bg })
        if file_icon == nil then
            file_icon = default_file_icon
            file_icon_color = default_file_icon_color
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

M.gps_treesitter = function()
    local retval = M.filename()
    local status_ok, gps_location = pcall(gps.get_location, {})
    if not status_ok then
        return retval
    end
    if not gps.is_available() then
        return retval
    end
    if gps_location == "error" then
        return retval
    else
        if not isempty(gps_location) then
            local location = gps_location:gsub(" > ", " ➤ ")
            return retval .. "%#" .. hl_group_1 .. "#" .. " ➤ " .. "%*" .. location
        else
            return retval
        end
    end
end

return M
