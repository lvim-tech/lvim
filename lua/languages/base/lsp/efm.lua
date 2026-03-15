-- LSP configuration for EFM (general-purpose language server)
-- EFM acts as a multiplexer: it aggregates formatter/linter configurations
-- registered by individual language modules via lsp_manager.setup_efm() into
-- a single server instance that Neovim connects to once.
---@module "languages.base.lsp.efm"

local setup_diagnostics = require("languages.utils.setup_diagnostics")

---Builds and returns the EFM server configuration table by collecting all
---language-specific tool registrations from the global `_G.efm_configs` map.
---Root markers are merged across all registered languages so the server can
---locate project roots regardless of which language is being edited.
---@return table|nil  Ready-to-use lspconfig config table, or nil if no tools are registered
local function get_efm_config()
    if not _G.efm_configs or vim.tbl_isempty(_G.efm_configs) then
        vim.notify("No registered EFM configurations", vim.log.levels.DEBUG)
        return nil
    end

    ---@type string[]   Accumulated list of filetypes EFM should handle
    local filetypes = {}
    ---@type table<string, table>  Per-filetype tool config (linters / formatters)
    local languages = {}
    ---@type string[]   Merged set of root marker filenames across all languages
    local root_markers = { ".git" }

    for ft, lang_config in pairs(_G.efm_configs) do
        table.insert(filetypes, ft)
        languages[ft] = lang_config

        -- Collect any tool-specific root markers so that EFM resolves project
        -- roots even when only tool config files (e.g. .prettierrc) are present.
        for _, formatter in ipairs(lang_config) do
            if formatter.rootMarkers and type(formatter.rootMarkers) == "table" then
                for _, marker in ipairs(formatter.rootMarkers) do
                    if not vim.tbl_contains(root_markers, marker) then
                        table.insert(root_markers, marker)
                    end
                end
            end
        end
    end

    if #filetypes == 0 then
        return nil
    end

    local config = {
        name = "efm",
        cmd = { "efm-langserver" },
        filetypes = filetypes,
        -- single_file_support = true allows EFM to attach even when no root marker
        -- is found (e.g. editing a standalone script file).
        single_file_support = true,
        init_options = {
            documentFormatting = true,       -- enable whole-document formatting
            documentRangeFormatting = true,  -- enable range (selection) formatting
        },
        settings = {
            rootMarkers = root_markers,
            languages = languages,  -- maps filetype → list of tool configs
        },
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---Explicitly sets formatting provider flags because EFM does not
        ---always advertise them via server capabilities.
        ---@param client any
        ---@param bufnr  integer
        on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
        end,
    }
    return config
end

-- EFM config is computed lazily on each access so that language modules which
-- call lsp_manager.setup_efm() after this file is loaded are still included.
return setmetatable({}, {
    ---@param _ table
    ---@param key string
    ---@return table|string[]|nil
    __index = function(_, key)
        if key == "config" then
            return get_efm_config()
        elseif key == "root_patterns" then
            local config = get_efm_config()
            return config and config.settings.rootMarkers or { ".git" }
        end
    end,
})
