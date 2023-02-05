local languages_setup = require("languages.base.utils")
local navic = require("nvim-navic")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    local metals_config = require("metals").bare_config()
    metals_config.settings = {
        showImplicitArguments = true,
    }
    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
    dap.configurations.scala = {
        {
            type = "scala",
            request = "launch",
            name = "RunOrTest",
            metals = {
                runType = "runOrTestFile",
            },
        },
        {
            type = "scala",
            request = "launch",
            name = "Test Target",
            metals = {
                runType = "testTarget",
            },
        },
    }

    metals_config.on_attach = function(client, bufnr)
        languages_setup.keymaps(client, bufnr)
        require("metals").setup_dap()
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                if _G.LVIM_SETTINGS.autoformat == true then
                    vim.lsp.buf.format()
                end
            end,
            group = "LvimIDE",
        })
        if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end
    end
    require("metals").initialize_or_attach(metals_config)
end

return language_configs
