local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "efm",
    "bash-language-server",
    "shfmt",
}

local lsp_config = nil
local root_markers = {
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    local efm_config = {
        {
            server_name = "shfmt",
            fPrefix = "shfmt",
            formatCommand = "shfmt -",
            formatStdin = true,
            rootMarkers = { ".editorconfig" },
        },
    }
    lsp_manager.setup_efm(_G.file_types.shell, efm_config)

    lsp_config = {
        name = "shell",
        cmd = { "bash-language-server", "start" },
        filetypes = _G.file_types.shell,
        settings = {
            bashIde = {
                globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
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
