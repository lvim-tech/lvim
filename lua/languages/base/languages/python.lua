local global = require("core.global")
local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "python",
}
local pyright_config = require("languages.base.languages._configs").default_config(ft, "python")
local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "python-lsp-server", "debugpy", "flake8" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "python",
        ["ft"] = ft,
        ["dap"] = { "debugpy" },
        ["python-lsp-server"] = { "pylsp", pyright_config },
        ["efm"] = {
            "flake8",
        },
    })
end

language_configs["dap"] = function()
    dap.adapters.python = {
        type = "executable",
        command = global.mason_path .. "/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
    }
    dap.configurations.python = {
        {
            type = "python",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            pythonPath = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                end
                if vim.fn.executable(global.mason_path .. "/packages/debugpy/venv/" .. "bin/python") == 1 then
                    return global.mason_path .. "/packages/debugpy/venv/" .. "bin/python"
                else
                    return "python"
                end
            end,
        },
    }
end

return language_configs
