-- LSP configuration for Tailwind CSS
-- Uses tailwindcss-language-server with a comprehensive filetype list covering
-- all template engines and front-end frameworks that can contain Tailwind classes.
-- Language mappings translate non-standard vim filetypes to their HTML/CSS
-- equivalents so the server applies the correct class completions.
---@module "modules.base.configs.languages.lsp.servers.tailwind"

---@type string[]  Tailwind config file root markers (any variant activates the server)
local root_markers = {
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "tailwind.config.ts",
    "postcss.config.js", -- PostCSS-only projects also use Tailwind
    "postcss.config.cjs",
    "postcss.config.mjs",
    "postcss.config.ts",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "tailwind",
            cmd = { "tailwindcss-language-server", "--stdio" },
            -- Full list of filetypes defined in file_types.lua (html, css, js, frameworks…)
            settings = {
                tailwindCSS = {
                    validate = true,
                    lint = {
                        cssConflict = "warning", -- conflicting utility classes → warning
                        invalidApply = "error", -- @apply with non-existent class → error
                        invalidScreen = "error",
                        invalidVariant = "error",
                        invalidConfigPath = "error",
                        invalidTailwindDirective = "error",
                        recommendedVariantOrder = "warning",
                    },
                    -- HTML attributes that receive Tailwind class completions
                    classAttributes = {
                        "class",
                        "className", -- React JSX
                        "class:list", -- Astro conditional classes
                        "classList",
                        "ngClass", -- Angular directive
                    },
                    -- Map vim-internal filetypes to HTML variants so the server
                    -- parses template syntax correctly.
                    includeLanguages = {
                        eelixir = "html-eex", -- Elixir/Phoenix EEx templates (vim ft)
                        eruby = "erb", -- Ruby ERB templates (vim ft)
                        templ = "html", -- Go templ component files
                        htmlangular = "html", -- Angular-specific HTML filetype
                    },
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
