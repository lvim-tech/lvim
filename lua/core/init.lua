local global = require("core.global")

if global == "unsuported" then
    print("Your OS is not supported!")
else
    local funcs = require("core.funcs")
    _G.LVIM_SNAPSHOT = funcs.get_snapshot()
    local vim = vim
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    vim.keymap.set("n", " ", "", { noremap = true })
    vim.keymap.set("x", " ", "", { noremap = true })
    global["diagnostics"] = {}
    global["diagnostics"]["path"] = vim.fn.getcwd()
    global["diagnostics"]["method"] = "global"
    _G.LVIM_SETTINGS = funcs.read_file(global.lvim_path .. "/.configs/lvim/config.json")
    _G.LVIM_COLORS = funcs.read_file(global.lvim_path .. "/.configs/lvim/colors.json")
    local lazy = require("core.lazy")
    lazy.is_lazy()
    funcs.configs()
    lazy.load()
end
