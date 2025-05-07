local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "vim-language-server",
}

local lsp_config = nil
local root_markers = {
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "vim",
        cmd = { "vim-language-server", "--stdio" },
        filetypes = _G.file_types.vim,
        init_options = {
            isNeovim = true,
            iskeyword = "@,48-57,_,192-255,-#",
            vimruntime = "",
            runtimepath = "",
            diagnostic = { enable = true },
            indexes = {
                runtimepath = true,
                gap = 100,
                count = 3,
                projectRootPatterns = { "runtime", "nvim", "autoload", "plugin" },
            },
            suggest = { fromVimruntime = true, fromRuntimepath = true },
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
