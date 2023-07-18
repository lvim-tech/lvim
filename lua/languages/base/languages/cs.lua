local global = require("core.global")
local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "cs",
    "vb",
}
local omnisharp_config = require("languages.base.languages._configs").omnisharp_config(ft, "cs")
local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "omnisharp", "netcoredbg" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "cs",
        ["ft"] = ft,
        ["dap"] = { "netcoredbg" },
        ["omnisharp"] = { "omnisharp", omnisharp_config },
    })
end

language_configs["dap"] = function()
    dap.adapters.netcoredbg = {
        type = "executable",
        command = global.mason_path .. "/packages/netcoredbg/netcoredbg",
        args = { "--interpreter=vscode" },
    }
    dap.configurations.cs = {
        {
            type = "netcoredbg",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input(
                    global.mason_path .. "/packages/netcoredbg/build/ManagedPart.dll",
                    vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                )
            end,
        },
    }
end

return language_configs
