-- LSP configuration for Tailwind CSS
-- Uses tailwindcss-language-server with a comprehensive filetype list covering
-- all template engines and front-end frameworks that can contain Tailwind classes.
-- Language mappings translate non-standard vim filetypes to their HTML/CSS
-- equivalents so the server applies the correct class completions.
---@module "languages.base.lsp.tailwind"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "tailwindcss-language-server",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Tailwind config file root markers (any variant activates the server)
local root_markers = {
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "tailwind.config.ts",
    "postcss.config.js",   -- PostCSS-only projects also use Tailwind
    "postcss.config.cjs",
    "postcss.config.mjs",
    "postcss.config.ts",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "tailwind",
        cmd = { "tailwindcss-language-server", "--stdio" },
        -- Full list of filetypes defined in file_types.lua (html, css, js, frameworks…)
        filetypes = _G.LVIM.file_types.tailwind,
        settings = {
            tailwindCSS = {
                validate = true,
                lint = {
                    cssConflict = "warning",           -- conflicting utility classes → warning
                    invalidApply = "error",            -- @apply with non-existent class → error
                    invalidScreen = "error",
                    invalidVariant = "error",
                    invalidConfigPath = "error",
                    invalidTailwindDirective = "error",
                    recommendedVariantOrder = "warning",
                },
                -- HTML attributes that receive Tailwind class completions
                classAttributes = {
                    "class",
                    "className",   -- React JSX
                    "class:list",  -- Astro conditional classes
                    "classList",
                    "ngClass",     -- Angular directive
                },
                -- Map vim-internal filetypes to HTML variants so the server
                -- parses template syntax correctly.
                includeLanguages = {
                    eelixir = "html-eex",     -- Elixir/Phoenix EEx templates (vim ft)
                    eruby = "erb",             -- Ruby ERB templates (vim ft)
                    templ = "html",            -- Go templ component files
                    htmlangular = "html",      -- Angular-specific HTML filetype
                },
            },
        },
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---@param client any
        ---@param bufnr  integer
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
