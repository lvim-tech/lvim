-- LSP configuration for Scala
-- Uses nvim-metals (Scala Metals client) instead of the standard lspconfig
-- pattern. Metals manages its own lifecycle and does not go through
-- lsp_installer / ensure_mason_tools. DAP is provided by Metals' built-in
-- debug adapter (metals.setup_dap()).
---@module "languages.base.lsp.scala"

local metals = require("metals")
---@type table  Bare Metals config with default values; populated below
local metals_config = require("metals").bare_config()
local dap = require("dap")
local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")

-- Show implicit arguments as inlay hints so function calls read more clearly
metals_config.settings = {
    showImplicitArguments = true,
}
metals_config.capabilities = setup_diagnostics.get_capabilities()

-- DAP: Metals provides its own Scala debug protocol on top of the DAP spec.
-- runOrTestFile: run or test the file under the cursor.
-- testTarget: run all tests in the current build target.
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

---Called by Metals after the client attaches to a buffer.
---@param client any
---@param bufnr  integer
metals_config.on_attach = function(client, bufnr)
    -- Wire up the Metals DAP adapter (must be called after on_attach fires)
    metals.setup_dap()
    setup_diagnostics.keymaps(client, bufnr)
    setup_diagnostics.document_highlight(client, bufnr)
    setup_diagnostics.document_auto_format(client, bufnr)
    setup_diagnostics.inlay_hint(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end
end

-- initialize_or_attach: reuse an existing Metals instance if one is already
-- running for this workspace, otherwise start a new one.
metals.initialize_or_attach(metals_config)
-- LSP

-- vim: foldmethod=indent foldlevel=0
