local funcs = require("core.funcs")

local M = {}

M.colors = function()
    return {
        color_01 = funcs.get_highlight("CursorLineNr").fg,
        color_02 = funcs.get_highlight("DiagnosticError").fg,
        color_03 = funcs.get_highlight("DiagnosticWarn").fg,
        color_04 = funcs.get_highlight("DiagnosticHint").fg,
        color_05 = funcs.get_highlight("DiagnosticInfo").fg,
        status_line_bg = funcs.get_highlight("StatusLine").bg,
        status_line_fg = funcs.get_highlight("StatusLine").fg,
        status_line_nc_bg = funcs.get_highlight("StatusLineNC").bg,
        status_line_nc_fg = funcs.get_highlight("StatusLineNC").fg,
    }
end

return M
