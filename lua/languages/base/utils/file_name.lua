local M = {}

local function isempty(s)
    return s == nil or s == ""
end

local colors = _G.LVIM_COLORS()
local hl_group_1 = "FileTextColor"
vim.api.nvim_set_hl(0, hl_group_1, { fg = colors.color_01, bg = colors.status_line_bg, bold = true })

M.get_file_name = function()
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

return M
