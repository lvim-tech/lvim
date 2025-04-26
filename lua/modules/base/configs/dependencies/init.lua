local icons = require("configs.base.ui.icons")

local config = {}

config.lvim_colorscheme = function()
    local lvim_colorscheme_status_ok, lvim_colorscheme = pcall(require, "lvim-colorscheme")
    if not lvim_colorscheme_status_ok then
        return
    end
    lvim_colorscheme.setup({
        cache = false,
        transparent = false,
        dim_active = true,
        styles = {
            floats = "dark",
            sidebars = "dark",
        },
        on_highlights = function(hl, c)
            hl.FloatBorder = {
                bg = c.bg_float,
                fg = c.bg_float,
            }
        end,
    })
    vim.cmd("colorscheme " .. _G.LVIM_SETTINGS.theme)
end

config.nvim_web_devicons = function()
    local web_devicons_status_ok, web_devicons = pcall(require, "nvim-web-devicons")
    if not web_devicons_status_ok then
        return
    end
    web_devicons.setup()
end

return config
