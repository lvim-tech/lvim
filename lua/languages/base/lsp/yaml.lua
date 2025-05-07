local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "efm",
    "yaml-language-server",
    "yamllint",
    "yamlfmt",
}

local lsp_config = nil
local root_markers = {
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    local efm_config = {
        {
            server_name = "yamllint",
            lPrefix = "yamllint",
            lintCommand = "yamllint -f parsable -",
            lintStdin = true,
            rootMarkers = { ".yamllint", ".yamllint.yaml", ".yamllint.yml" },
        },
        {
            server_name = "yamlfmt",
            fPrefix = "yamlfmt",
            formatCommand = "yamlfmt -",
            formatStdin = true,
            rootMarkers = { ".yamlfmt" },
        },
    }
    lsp_manager.setup_efm(_G.file_types.yaml, efm_config)

    lsp_config = {
        name = "yaml",
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = _G.file_types.yaml,
        settings = {
            redhat = {
                telemetry = {
                    enabled = false,
                },
            },
            yaml = {
                keyOrdering = false,
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = setup_diagnostics.get_capabilities(),
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
