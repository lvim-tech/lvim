-- LSP configuration for Perl
-- Uses PerlNavigator which provides linting, navigation, and completions
-- by running Perl::Critic and parsing perlcritic output in the background.
---@module "modules.base.configs.languages.lsp.servers.perl"

---@type string[]  Root-directory markers (Perl projects vary widely; .git is the safest anchor)
local root_markers = {
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "perl",
            cmd = { "perlnavigator" },
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
