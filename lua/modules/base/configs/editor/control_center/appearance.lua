local funcs = require("core.funcs")
local data = require("lvim-control-center.persistence.data")
local icons = require("configs.base.ui.icons")

local function is_control_center_focused(win)
    if not win or not vim.api.nvim_win_is_valid(win) then
        return false
    end
    return vim.api.nvim_get_current_win() == win
end

return {
    name = "appearance",
    label = "Appearance",
    icon = icons.common.palette,
    settings = {
        {
            name = "colorscheme",
            label = "Colorscheme",
            type = "select",
            options = { "lvim-dark", "lvim-darker", "lvim-everforest", "lvim-gruvbox", "lvim-kanagawa", "lvim-light" },
            default = "lvim-darker",
            break_load = true,
            get = function()
                if _G.LVIM_THEME ~= nil then
                    return _G.LVIM_THEME
                else
                    return "lvim-darker"
                end
            end,
            set = function(val, _)
                _G.LVIM_THEME = val
                vim.cmd("colorscheme " .. val)
                funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/.theme", _G.LVIM_THEME)
                ---@diagnostic disable-next-line: undefined-field
                if _G.LVIM_CONTROL_CENTER_WIN and is_control_center_focused(_G.LVIM_CONTROL_CENTER_WIN) then
                    vim.cmd("hi Cursor blend=100")
                else
                    vim.cmd("hi Cursor blend=0")
                end
                data.save("colorscheme", val)
            end,
        },
        {
            name = "floatheight",
            label = "Float height",
            type = "select",
            options = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 },
            default = 0.4,
            get = function()
                return _G.LVIM_SETTINGS and _G.LVIM_SETTINGS["floatheight"] or 0.4
            end,
            set = function(val, on_init)
                _G.LVIM_SETTINGS["floatheight"] = val
                if not on_init then
                    data.save("floatheight", val)
                end
            end,
        },
    },
}
