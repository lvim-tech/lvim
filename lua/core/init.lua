local global = require("core.global")

if global == "unsuported" then
    print("Your OS is not supported!")
else
    local funcs = require("core.funcs")
    _G.LVIM_SNAPSHOT = funcs.get_snapshot()
    local vim = vim
    vim.g.mapleader = " "
    vim.keymap.set("n", " ", "", { noremap = true })
    vim.keymap.set("x", " ", "", { noremap = true })
    global["diagnostics"] = {}
    global["diagnostics"]["path"] = vim.fn.getcwd()
    global["diagnostics"]["method"] = "global"
    _G.LVIM_SETTINGS = funcs.read_file(global.lvim_path .. "/.configs/lvim/config.json")
    local lazy_packer = require("core.pack")
    lazy_packer.is_lazy()
    funcs.configs()
    lazy_packer.load()
end
