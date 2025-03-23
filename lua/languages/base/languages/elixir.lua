local global = require("core.global")
local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "elixir",
    "eelixir",
}
local language_server_config = require("languages.base.languages._configs").elixir_config(ft)
local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "elixir-ls" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "elixir",
        ["ft"] = ft,
        ["elixir-ls"] = { "elixirls", language_server_config },
    })
end

language_configs["dap"] = function()
    dap.adapters.mix_task = {
        type = "executable",
        command = global.mason_path .. "/bin/elixir-ls-debugger",
        args = {},
    }
    dap.configurations.elixir = {
        {
            type = "mix_task",
            name = "mix test",
            task = "test",
            taskArgs = { "--trace" },
            request = "launch",
            startApps = true,
            projectDir = "${workspaceFolder}",
            requireFiles = {
                "test/**/test_helper.exs",
                "test/**/*_test.exs",
            },
        },
    }
end

return language_configs
