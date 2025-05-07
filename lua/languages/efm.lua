local M = {}

local function get_efm_config()
    if not _G.efm_configs or vim.tbl_isempty(_G.efm_configs) then
        return nil
    end
    local all_markers = { ".git/" }
    local filetypes = {}
    local languages = {}
    for ft, lang_config in pairs(_G.efm_configs) do
        table.insert(filetypes, ft)
        languages[ft] = lang_config
        for _, tool_config in ipairs(lang_config) do
            if tool_config.rootMarkers then
                for _, marker in ipairs(tool_config.rootMarkers) do
                    if not vim.tbl_contains(all_markers, marker) then
                        table.insert(all_markers, marker)
                    end
                end
            end
        end
    end
    if #filetypes == 0 then
        return nil
    end
    _G.efm_root_markers = all_markers
    return {
        name = "efm",
        cmd = { "efm-langserver" },
        filetypes = filetypes,
        single_file_support = true,
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
        },
        settings = { 
            rootMarkers = all_markers,
            languages = languages
        },
        on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true
            if setup_diagnostics then
                setup_diagnostics.keymaps(client, bufnr)
                setup_diagnostics.document_highlight(client, bufnr)
                setup_diagnostics.document_auto_format(client, bufnr)
                setup_diagnostics.inlay_hint(client, bufnr)
            end
        end,
    }
end

return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return get_efm_config()
        elseif key == "root_patterns" then
            return _G.efm_root_markers or { ".git" }
        end
    end,
})
