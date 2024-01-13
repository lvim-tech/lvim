local global = require("core.global")
local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "rust",
}
local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "rust-analyzer", "cpptools" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "rust",
        ["ft"] = ft,
        ["dap"] = { "cpptools" },
        ["rust-analyzer"] = {},
    })
end

language_configs["dap"] = function()
    dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = global.mason_path .. "/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
    }
    dap.configurations.rust = {
        {
            name = "Launch file",
            type = "cppdbg",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = true,
        },
    }
end

return language_configs
