local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "css-lsp",
}

local lsp_config = nil
local root_markers = {
    "package.json",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "css",
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = _G.file_types.css,
        settings = {
            css = { validate = true },
            scss = { validate = true },
            less = { validate = true },
        },
        init_options = { provideFormatter = true },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentsymbolprovider then
                navic.attach(client, bufnr)
            end
        end,
    }
end)

return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
