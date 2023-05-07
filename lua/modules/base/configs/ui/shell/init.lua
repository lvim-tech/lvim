local lvim_shell = require("lvim-shell")

local M = {}

M.Ranger = function(dir)
    dir = dir or "."
    lvim_shell.float("ranger --choosefiles=/tmp/lvim-shell " .. dir, "l")
end

M.Vifm = function(dir)
    dir = dir or "."
    lvim_shell.float("vifm --choose-files /tmp/lvim-shell " .. dir, "l")
end

M.Lazygit = function(dir)
    dir = dir or "."
    lvim_shell.float("lazygit -w " .. dir, "<CR>")
end

M.Lazydocker = function()
    lvim_shell.float("lazydocker", "<CR>")
end

return M
