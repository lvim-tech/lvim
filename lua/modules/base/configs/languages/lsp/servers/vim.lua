-- LSP configuration for Vimscript / VimL
-- Uses vim-language-server which understands both Vim and Neovim runtime paths
-- and provides completions, hover, and diagnostics for .vim files.
---@module "modules.base.configs.languages.lsp.servers.vim"

---@type string[]  Root-directory markers (Vim plugins and configs anchor to .git)
local root_markers = {
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "vim",
            cmd = { "vim-language-server", "--stdio" },
            init_options = {
                isNeovim = true, -- enables Neovim-specific API completions and docs
                -- iskeyword mirrors Neovim's default so identifier boundaries are correct
                iskeyword = "@,48-57,_,192-255,-#",
                vimruntime = "", -- empty = auto-detect from $VIMRUNTIME
                runtimepath = "", -- empty = inherit from the running Neovim instance
                diagnostic = { enable = true },
                indexes = {
                    runtimepath = true, -- index the entire runtimepath for completions
                    gap = 100, -- ms between indexing bursts (throttle)
                    count = 3, -- files to index per burst
                    -- Directories that indicate a Vim plugin / config root
                    projectRootPatterns = { "runtime", "nvim", "autoload", "plugin" },
                },
                suggest = {
                    fromVimruntime = true, -- include completions from $VIMRUNTIME
                    fromRuntimepath = true, -- include completions from the full runtimepath
                },
            },
            ---Called by nvim-lspconfig after the client attaches to a buffer.
            ---@param client any
            ---@param bufnr  integer
            on_attach = function(client, bufnr)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end,
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
