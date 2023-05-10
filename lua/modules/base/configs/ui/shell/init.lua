local lvim_shell = require("lvim-shell")
local config = {
    mappings = {
        split = "<C-x>",
        vsplit = "<C-v>",
        tabedit = "<C-t>",
        edit = "<C-e>",
        close = "<C-q>",
    },
}

local M = {}

M.Ranger = function(dir)
    dir = dir or "."
    lvim_shell.float("ranger --choosefiles=/tmp/lvim-shell " .. dir, "l", config)
end

M.Vifm = function(dir)
    dir = dir or "."
    lvim_shell.float("vifm --choose-files /tmp/lvim-shell " .. dir, "l", config)
end

M.Lazygit = function(dir)
    dir = dir or "."
    lvim_shell.float("lazygit -w " .. dir, "<CR>", config)
end

M.Lazydocker = function()
    lvim_shell.float("lazydocker", "<CR>", config)
end

return M
