local global = require("core.global")
local languages_setup = require("languages.base.utils")
local flutter_tools = require("flutter-tools")
local navic = require("nvim-navic")

local language_configs = {}

language_configs["lsp"] = function()
    flutter_tools.setup({
        debugger = {
            enabled = true,
        },
        closing_tags = {
            prefix = " ",
        },
        lsp = {
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["dart"]["pid"], client.rpc.pid)
                languages_setup.omni(client, bufnr)
                languages_setup.tag(client, bufnr)
                languages_setup.document_highlight(client, bufnr)
                languages_setup.document_formatting(client, bufnr)
                navic.attach(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
        },
    })
end

return language_configs
