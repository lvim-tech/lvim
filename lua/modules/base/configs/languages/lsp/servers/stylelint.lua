-- LSP configuration for Stylelint
-- Uses stylelint-lsp which wraps the Stylelint CSS/SCSS linter as a language
-- server, providing diagnostics for style rule violations across CSS dialects.
-- Note: document_auto_format is intentionally omitted because Stylelint is a
-- linter, not a formatter; use prettierd or the CSS LSP for formatting.
---@module "modules.base.configs.languages.lsp.servers.stylelint"

---@type string[]  Stylelint config file names used as root markers
local root_markers = {
    ".stylelintrc",
    ".stylelintrc.mjs",
    ".stylelintrc.cjs",
    ".stylelintrc.js",
    ".stylelintrc.json",
    ".stylelintrc.yaml",
    ".stylelintrc.yml",
    "stylelint.config.mjs",
    "stylelint.config.cjs",
    "stylelint.config.js",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "stylelint",
            cmd = { "stylelint-lsp", "--stdio" },
            settings = {}, -- all Stylelint configuration lives in the config files above
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
