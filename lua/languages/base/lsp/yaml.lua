-- LSP configuration for YAML
-- Uses yaml-language-server (from Red Hat) for schema-driven completions and
-- validation. yamllint (via EFM) provides style/consistency linting, and
-- yamlfmt (via EFM) handles opinionated formatting.
-- Red Hat telemetry is explicitly disabled.
---@module "languages.base.lsp.yaml"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "efm",
    "yaml-language-server",
    "yamllint",
    "yamlfmt",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers (YAML files are generic; .git is sufficient)
local root_markers = {
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    local efm_config = {
        {
            server_name = "yamllint",
            lPrefix = "yamllint",
            -- parsable output format produces machine-readable diagnostics for EFM
            lintCommand = "yamllint -f parsable -",
            lintStdin = true,
            rootMarkers = { ".yamllint", ".yamllint.yaml", ".yamllint.yml" },
        },
        {
            server_name = "yamlfmt",
            fPrefix = "yamlfmt",
            formatCommand = "yamlfmt -",
            formatStdin = true,
            rootMarkers = { ".yamlfmt" },
        },
    }
    lsp_manager.setup_efm(_G.LVIM.file_types.yaml, efm_config)

    lsp_config = {
        name = "yaml",
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = _G.LVIM.file_types.yaml,
        settings = {
            redhat = {
                telemetry = {
                    -- Opt out of Red Hat's usage telemetry
                    enabled = false,
                },
            },
            yaml = {
                -- keyOrdering = false: do not enforce alphabetical key order
                -- (useful for YAML that encodes meaningful ordering, e.g. Kubernetes)
                keyOrdering = false,
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
