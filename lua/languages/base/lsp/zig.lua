local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "zls",
}

local lsp_config = nil
local root_markers = {
    "zls.json",
    "build.zig",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "zig",
        cmd = { "zls" },
        filetypes = _G.file_types.zig,
        settings = {
            zls = {
                enable_semantic_tokens = true,
                enable_snippets = true,
                enable_inlay_hints = true,
                inlay_hints_show_builtin = true,
                inlay_hints_show_variable_type_hints = true,
                inlay_hints_show_parameter_name = true,
                warn_style = true,
                enable_autofix = true,
                analyze_with_same_ast = true,
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = (function()
            local capabilities = setup_diagnostics.get_capabilities()
            capabilities.textDocument = capabilities.textDocument or {}
            capabilities.textDocument.codeLens = {
                dynamicRegistration = true,
                resolveProvider = true,
            }
            capabilities.workspace = capabilities.workspace or {}
            capabilities.workspace.codeLens = {
                refreshSupport = true,
            }
            return capabilities
        end)(),
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
