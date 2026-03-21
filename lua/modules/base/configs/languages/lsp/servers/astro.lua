-- LSP configuration for Astro
-- Sets up astro-language-server with prettierd formatting via EFM.
---@module "modules.base.configs.languages.lsp.servers.astro"
local ft = require("modules.base.configs.languages.lsp.file_types")

---@type string[]  Root-directory markers for Astro projects
local root_markers = {
    "astro.config.mjs",
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
}

-- Register prettierd as the EFM formatter for Astro files.
-- Tab width of 4 is the project-wide default; .prettierrc can override it.
local efm_config = {
    {
        server_name = "prettierd",
        formatCommand = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
        formatStdin = true,
        rootMarkers = { ".prettierrc" },
    },
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "astro",
            cmd = { "astro-ls", "--stdio" },
            init_options = {
                typescript = {
                    -- Use the TypeScript SDK bundled inside the astro-language-server Mason package
                    -- so that the Astro LS and the TS compiler versions stay in sync.
                    tsdk = vim.fs.normalize(
                        "~/.local/share/nvim/mason/packages/astro-language-server/node_modules/typescript/lib"
                    ),
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
            settings = {},
        },
    },
    efm = {
        filetypes = ft.astro.filetypes,
        tools = efm_config,
    },
}

-- vim: foldmethod=indent foldlevel=1
