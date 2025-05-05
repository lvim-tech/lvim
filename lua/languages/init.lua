local lsp_manager = require("languages.lsp_manager")

local group = vim.api.nvim_create_augroup("LvimLSPEnable", {
    clear = true,
})

local M = {}

M.init = function()
    lsp_manager.setup_session_lsp_autoload()
    M.lsp_enable()
end

M.lsp_enable = function()
    if M._lsp_enable_registered then
        return
    end
    M._lsp_enable_registered = true
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
            local ft = args.match
            local bufnr = args.buf
            if bufnr ~= vim.api.nvim_get_current_buf() then
                return
            end
            local matches = M.find_matching_keys(ft)
            local enabled_count = 0
            if not _G.lsp_servers_enabled_for_buf then
                _G.lsp_servers_enabled_for_buf = {}
            end
            for _, match in ipairs(matches) do
                -- Проверяем, не отключен ли сервер глобально или для этого буфера
                if
                    not lsp_manager.is_server_disabled_globally(match)
                    and not lsp_manager.is_server_disabled_for_buffer(match, bufnr)
                then
                    local buf_servers = _G.lsp_servers_enabled_for_buf[bufnr] or {}
                    if not buf_servers[match] then
                        lsp_manager.lsp_enable(match)
                        if not _G.lsp_servers_enabled_for_buf[bufnr] then
                            _G.lsp_servers_enabled_for_buf[bufnr] = {}
                        end
                        _G.lsp_servers_enabled_for_buf[bufnr][match] = true
                        enabled_count = enabled_count + 1
                    end
                end
            end
        end,
    })
    vim.api.nvim_create_autocmd("BufDelete", {
        group = group,
        callback = function(args)
            local bufnr = args.buf
            if _G.lsp_servers_enabled_for_buf and _G.lsp_servers_enabled_for_buf[bufnr] then
                _G.lsp_servers_enabled_for_buf[bufnr] = nil
            end
        end,
    })
end

M.find_matching_keys = function(ft)
    local matches = {}
    for key, filetypes in pairs(_G.file_types) do
        if vim.tbl_contains(filetypes, ft) then
            table.insert(matches, key)
        end
    end
    return matches
end

return M
