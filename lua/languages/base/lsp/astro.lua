-- LSP configuration for Astro
-- Sets up astro-language-server with prettierd formatting via EFM.
---@module "languages.base.lsp.astro"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages that must be installed before setup runs
local lsp_dependencies = {
    "efm",
    "astro-language-server",
    "prettierd",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for Astro projects
local root_markers = {
    "astro.config.mjs",
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    -- Register prettierd as the EFM formatter for Astro files.
    -- Tab width of 4 is the project-wide default; .prettierrc can override it.
    local efm_config = {
        {
            server_name = "prettierd",
            fPrefix = "prettier",
            formatCommand = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
            formatStdin = true,
            rootMarkers = { ".prettierrc" },
        },
    }
    lsp_manager.setup_efm(_G.LVIM.file_types.astro, efm_config)

    lsp_config = {
        name = "astro",
        filetypes = _G.LVIM.file_types.astro,
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
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        settings = {},
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
