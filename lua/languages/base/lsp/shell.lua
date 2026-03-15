-- LSP configuration for Shell scripts (Bash, Zsh, sh, csh, ksh)
-- Uses bash-language-server for completions and diagnostics, and shfmt
-- via EFM for formatting. The glob pattern restricts which files the
-- language server indexes (overridable via GLOB_PATTERN env var).
---@module "languages.base.lsp.shell"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "efm",
    "bash-language-server",
    "shfmt",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers (shell scripts rarely have project roots)
local root_markers = {
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    -- shfmt reads stdin ("-") and writes formatted output to stdout.
    -- .editorconfig is used as the root marker so indentation settings
    -- from EditorConfig files are respected.
    local efm_config = {
        {
            server_name = "shfmt",
            fPrefix = "shfmt",
            formatCommand = "shfmt -",
            formatStdin = true,
            rootMarkers = { ".editorconfig" },
        },
    }
    lsp_manager.setup_efm(_G.LVIM.file_types.shell, efm_config)

    lsp_config = {
        name = "shell",
        cmd = { "bash-language-server", "start" },
        filetypes = _G.LVIM.file_types.shell,
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
