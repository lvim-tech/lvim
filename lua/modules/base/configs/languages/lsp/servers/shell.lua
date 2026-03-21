-- LSP configuration for Shell scripts (Bash, Zsh, sh, csh, ksh)
-- Uses bash-language-server for completions and diagnostics, and shfmt
-- via EFM for formatting. The glob pattern restricts which files the
-- language server indexes (overridable via GLOB_PATTERN env var).
---@module "modules.base.configs.languages.lsp.servers.shell"
local ft = require("modules.base.configs.languages.lsp.file_types")

---@type string[]  Root-directory markers (shell scripts rarely have project roots)
local root_markers = {
    ".git",
}

-- shfmt reads stdin ("-") and writes formatted output to stdout.
-- .editorconfig is used as the root marker so indentation settings
-- from EditorConfig files are respected.
local efm_config = {
    {
        server_name = "shfmt",
        formatCommand = "shfmt -",
        formatStdin = true,
        rootMarkers = { ".editorconfig" },
    },
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "shell",
            cmd = { "bash-language-server", "start" },
            settings = {
                bashIde = {
                    -- Override the file glob pattern at runtime via GLOB_PATTERN env var;
                    -- the default covers the most common shell script extensions.
                    globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
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
    efm = {
        filetypes = ft.shell.filetypes,
        tools = efm_config,
    },
}

-- vim: foldmethod=indent foldlevel=1
