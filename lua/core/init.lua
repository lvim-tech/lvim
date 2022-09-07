local global = require("core.global")

if global == "unsuported" then
    print("Your OS is not supported!")
else
    local funcs = require("core.funcs")
    _G.LVIM_SNAPSHOT = funcs.get_snapshot()
    local vim = vim
    vim.g.mapleader = " "
    vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
    vim.api.nvim_set_keymap("x", " ", "", { noremap = true })
    global["diagnostics"] = {}
    global["diagnostics"]["path"] = vim.fn.getcwd()
    global["diagnostics"]["method"] = "global"
    local packer = require("core.pack")
    packer.ensure_plugins()
    funcs.configs()
    packer.load_compile()
end
