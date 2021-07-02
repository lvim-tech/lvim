local configs = {}
local funcs = require "core.funcs"

configs["custom_events"] = function()
    funcs.augroups({
        custom_bufs = {
            {"BufWritePre", "*.go", ":Neoformat"},
            {"BufWritePre", "*.py", ":Neoformat"},
            {"BufWritePre", "*.rs", ":Neoformat"},
            {"BufWritePre", "*.dart", ":Neoformat"},
            {"BufWritePre", "*.cpp", ":Neoformat"},
            {"BufWritePre", "*.js", ":Neoformat"},
            {"BufWritePre", "*.ts", ":Neoformat"}
        }
    })
end

return configs
