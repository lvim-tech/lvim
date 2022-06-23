local global = require("core.global")

if global == "unsuported" then
    print("Your OS is not supported!")
else
    local funcs = require("core.funcs")
    local vim = vim
    global["diagnostics"] = {}
    global["diagnostics"]["path"] = vim.fn.getcwd()
    global["diagnostics"]["method"] = "global"
    local packer = require("core.pack")
    packer.ensure_plugins()
    funcs.configs()
    packer.load_compile()
end
