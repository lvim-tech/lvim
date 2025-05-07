local setup_diagnostics = require("languages.utils.setup_diagnostics")

local function get_efm_config()
    if not _G.efm_configs or vim.tbl_isempty(_G.efm_configs) then
        vim.notify("No registered EFM configurations", vim.log.levels.DEBUG)
        return nil
    end

    local filetypes = {}
    local languages = {}
    local root_markers = { ".git" }

    for ft, lang_config in pairs(_G.efm_configs) do
        table.insert(filetypes, ft)
        languages[ft] = lang_config

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
        single_file_support = true,
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
        },
        settings = {
            rootMarkers = root_markers,
            languages = languages,
        },
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

return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return get_efm_config()
        elseif key == "root_patterns" then
            local config = get_efm_config()
            return config and config.settings.rootMarkers or { ".git" }
        end
    end,
})
