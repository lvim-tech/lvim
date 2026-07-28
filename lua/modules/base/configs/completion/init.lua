-- Plugin configuration for completion and editing-assist plugins.
-- Pure lvim-tech: lvim-cmp (the completion engine over the shared lvim-fuzzy
-- matcher; snippets come from lvim-snippets via register_source) and lvim-pairs
-- (autopairs + surround + autotag over one shared pair table).

---@module "modules.base.configs.completion"

return {
    -- -------------------------------------------------------------------------
    -- lvim-cmp: the lvim-tech completion engine. Ranks through the shared lvim-fuzzy
    -- native matcher; LSP / buffer / path sources built-in, the lvim-ui menu, ghost
    -- text + docs float. Its LSP capabilities fragment is merged in the languages/lsp
    -- get_capabilities(). Snippets come from lvim-snippets (configured through the
    -- lvim-nvim forwarder), which registers its source via register_source.
    -- -------------------------------------------------------------------------
    lvim_cmp = {
        config = function()
            require("lvim-cmp").setup({})
        end,
    },

    -- -------------------------------------------------------------------------
    -- lvim-pairs: autopairs + surround + autotag in one plugin over one shared pair
    -- table.
    -- -------------------------------------------------------------------------
    lvim_pairs = {
        config = function()
            require("lvim-pairs").setup({
                autopairs = {
                    -- lvim-cmp owns <CR> (accept selection, else its lvim-pairs.cr() handshake), so keep
                    -- lvim-pairs OFF <CR>. Prompt/query buffers get the plain key so a typed "(" in the finder
                    -- input stays a lone "(".
                    map_cr = false,
                    -- (`disable_filetype` is the plugin's default now that its own list no longer
                    -- names third-party prompt filetypes.)
                },
            })
        end,
    },
}

-- vim: foldmethod=indent foldlevel=1
