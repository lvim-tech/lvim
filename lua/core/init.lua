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
    local packer = require("core.pack")
    funcs.configs()
    packer.ensure_plugins()
    packer.load_compile()
end
