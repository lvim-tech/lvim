-- LSP configuration for YAML
-- Uses yaml-language-server (from Red Hat) for schema-driven completions and
-- validation. yamllint (via EFM) provides style/consistency linting, and
-- yamlfmt (via EFM) handles opinionated formatting.
-- Red Hat telemetry is explicitly disabled.
---@module "modules.base.configs.languages.lsp.servers.yaml"
local ft = require("modules.base.configs.languages.lsp.file_types")

---@type string[]  Root-directory markers (YAML files are generic; .git is sufficient)
local root_markers = {
    ".git",
}

local efm_config = {
    {
        server_name = "yamllint",
        -- parsable output format produces machine-readable diagnostics for EFM
        lintCommand = "yamllint -f parsable -",
        lintStdin = true,
        rootMarkers = { ".yamllint", ".yamllint.yaml", ".yamllint.yml" },
    },
    {
        server_name = "yamlfmt",
        formatCommand = "yamlfmt -",
        formatStdin = true,
        rootMarkers = { ".yamlfmt" },
    },
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "yaml",
            cmd = { "yaml-language-server", "--stdio" },
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
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end,
        },
    },
    efm = {
        filetypes = ft.yaml.filetypes,
        tools = efm_config,
    },
}

-- vim: foldmethod=indent foldlevel=1
