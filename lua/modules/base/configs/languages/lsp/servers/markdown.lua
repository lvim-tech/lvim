-- LSP configuration for Markdown / MDX
-- Uses marksman for link checking and outline navigation.
-- prettierd and cbfmt are registered via EFM: prettierd formats prose,
-- while cbfmt formats fenced code blocks using per-language formatters.
---@module "modules.base.configs.languages.lsp.servers.markdown"
local ft = require("modules.base.configs.languages.lsp.file_types")

---@type string[]  Root-directory markers for documentation repositories
local root_markers = {
    ".marksman.toml",
    ".git",
}

local efm_config = {
    {
        server_name = "prettierd",
        formatCommand = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
        formatStdin = true,
        rootMarkers = { ".prettierrc" },
    },
    {
        server_name = "cbfmt",
        -- --best-effort: continue formatting even when a code-block language is unknown
        formatCommand = "cbfmt --stdin-filepath ${FILENAME} --best-effort",
        formatStdin = true,
        rootMarkers = { ".cbfmt.toml" },
    },
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "markdown",
            -- marksman requires "server" sub-command to start in server mode
            cmd = { "marksman", "server" },
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
    efm = {
        filetypes = ft.markdown.filetypes,
        tools = efm_config,
    },
}

-- vim: foldmethod=indent foldlevel=1
