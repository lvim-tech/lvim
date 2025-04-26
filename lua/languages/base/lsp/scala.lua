local metals = require("metals")
local metals_config = require("metals").bare_config()
local dap = require("dap")
local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")

metals_config.settings = {
    showImplicitArguments = true,
}
metals_config.capabilities = setup_diagnostics.get_capabilities()
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
    metals.setup_dap()
    setup_diagnostics.keymaps(client, bufnr)
    setup_diagnostics.document_highlight(client, bufnr)
    setup_diagnostics.document_auto_format(client, bufnr)
    setup_diagnostics.inlay_hint(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end
end
metals.initialize_or_attach(metals_config)
-- LSP

-- vim: foldmethod=indent foldlevel=0
