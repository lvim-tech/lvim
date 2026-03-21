-- Appearance settings group for the LVIM Control Center.
-- Exposes a "colorscheme" select and a "floatheight" select that let the user
-- change the active colorscheme and the default floating-window height ratio
-- at runtime.  Changes are persisted via the lvim-control-center data store.

---@module "modules.base.configs.editor.control_center.appearance"

local funcs = require("core.funcs")
local data = require("lvim-control-center.persistence.data")
local icons = require("configs.base.ui.icons")

--- Return true when the control-center floating window is the currently focused
--- window, false in every other case (invalid handle, different window focused).
---@param win integer|nil  Window handle to test
---@return boolean
local function is_control_center_focused(win)
    if not win or not vim.api.nvim_win_is_valid(win) then
        return false
    end
    return vim.api.nvim_get_current_win() == win
end

---@type table  Control Center settings group descriptor for appearance options
return {
    name = "appearance",
    label = "Appearance",
    icon = icons.common.palette,
    settings = {
        -- -----------------------------------------------------------------
        -- Colorscheme selector
        -- -----------------------------------------------------------------
        {
            name = "colorscheme",
            label = "Colorscheme",
            type = "select",
            -- All bundled LVIM colorscheme variants
            options = {
                "lvim-soft",
                "lvim-dark",
                "lvim-darker",
                "lvim-light",
                "lvim-kanagawa-soft",
                "lvim-kanagawa-dark",
                "lvim-kanagawa-darker",
                "lvim-kanagawa-light",
                "lvim-gruvbox-soft",
                "lvim-gruvbox-dark",
                "lvim-gruvbox-darker",
                "lvim-gruvbox-light",
                "lvim-everforest-soft",
                "lvim-everforest-dark",
                "lvim-everforest-darker",
                "lvim-everforest-light",
            },
            default = "lvim-darker",
            -- When true the control center closes before applying the change,
            -- because loading a new colorscheme can redraw the whole UI.
            break_load = true,
            ---@return string  Currently active colorscheme name
            get = function()
                if _G.LVIM.theme ~= nil then
                    return _G.LVIM.theme
                else
                    return "lvim-everforest-soft"
                end
            end,
            ---@param val string   New colorscheme name chosen by the user
            ---@param _ any        Unused on_init flag (colorscheme is always applied immediately)
            set = function(val, _)
                _G.LVIM.theme = val
                vim.cmd("colorscheme " .. val)
                -- Persist the chosen theme to the .theme config file so it survives restarts.
                funcs.write_file(_G.LVIM.global.lvim_path .. "/.configs/lvim/.theme", _G.LVIM.theme)
                ---@diagnostic disable-next-line: undefined-field
                -- Hide the hardware cursor inside the control center to avoid a
                -- visible blinking cursor over the floating window content.
                if _G.LVIM.control_center_win and is_control_center_focused(_G.LVIM.control_center_win) then
                    vim.cmd("hi Cursor blend=100")
                else
                    vim.cmd("hi Cursor blend=0")
                end
                data.save("colorscheme", val)
            end,
        },
        -- -----------------------------------------------------------------
        -- Float height ratio selector
        -- -----------------------------------------------------------------
        {
            name = "floatheight",
            label = "Float height",
            type = "select",
            -- Values are fractions of the total editor height (0.1 = 10 %, 1.0 = 100 %).
            options = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 },
            default = 0.4,
            ---@return number  Current float height ratio (falls back to 0.4 when unset)
            get = function()
                return _G.LVIM.settings and _G.LVIM.settings["floatheight"] or 0.4
            end,
            ---@param val     number   New height ratio chosen by the user
            ---@param on_init boolean  True during startup initialisation; skip persistence in that case
            set = function(val, on_init)
                _G.LVIM.settings["floatheight"] = val
                if not on_init then
                    data.save("floatheight", val)
                end
            end,
        },
    },
}
