-- LSP configuration for Vimscript / VimL
-- Uses vim-language-server which understands both Vim and Neovim runtime paths
-- and provides completions, hover, and diagnostics for .vim files.
---@module "languages.base.lsp.vim"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "vim-language-server",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers (Vim plugins and configs anchor to .git)
local root_markers = {
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "vim",
        cmd = { "vim-language-server", "--stdio" },
        filetypes = _G.LVIM.file_types.vim,
        init_options = {
            isNeovim = true,   -- enables Neovim-specific API completions and docs
            -- iskeyword mirrors Neovim's default so identifier boundaries are correct
            iskeyword = "@,48-57,_,192-255,-#",
            vimruntime = "",   -- empty = auto-detect from $VIMRUNTIME
            runtimepath = "",  -- empty = inherit from the running Neovim instance
            diagnostic = { enable = true },
            indexes = {
                runtimepath = true,  -- index the entire runtimepath for completions
                gap = 100,           -- ms between indexing bursts (throttle)
                count = 3,           -- files to index per burst
                -- Directories that indicate a Vim plugin / config root
                projectRootPatterns = { "runtime", "nvim", "autoload", "plugin" },
            },
            suggest = {
                fromVimruntime = true,    -- include completions from $VIMRUNTIME
                fromRuntimepath = true,   -- include completions from the full runtimepath
            },
        },
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---@param client any
        ---@param bufnr  integer
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
    ---@param _ table
    ---@param key string
    ---@return table|nil
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
