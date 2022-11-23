local languages_setup = require("languages.base.utils")
local hls_config = require("languages.base.languages._configs").default_config({ "haskell", "lhaskell" }, "haskell")
local dap = require("dap")

local language_configs = {}

language_configs["dependencies"] = { "haskell-language-server" }

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "haskell",
        ["haskell-language-server"] = { "hls", hls_config },
    })
end

language_configs["dap"] = function()
    dap.adapters.haskell = {
        type = "executable",
        command = "haskell-debug-adapter",
        args = { "--hackage-version=0.0.33.0" },
    }
    dap.configurations.haskell = {
        {
            type = "haskell",
            request = "launch",
            name = "Debug",
            workspace = "${workspaceFolder}",
            startup = "${file}",
            stopOnEntry = true,
            logFile = vim.fn.stdpath("data") .. "/haskell-dap.log",
            logLevel = "WARNING",
            ghciEnv = vim.empty_dict(),
            ghciPrompt = "λ: ",
            -- Adjust the prompt to the prompt you see when you invoke the stack ghci command below
            ghciInitialPrompt = "λ: ",
            ghciCmd = "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
        },
    }
end

return language_configs
