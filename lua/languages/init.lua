local lsp_manager = require("languages.lsp_manager")
local group = vim.api.nvim_create_augroup("LvimLSPEnable", { clear = true })

local M = {}

local function attach_lsp_to_buffer(bufnr)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end
    local ft = vim.bo[bufnr].filetype
    if not ft or ft == "" then
        return
    end
    local matches = {}
    for key, filetypes in pairs(_G.file_types or {}) do
        if vim.tbl_contains(filetypes, ft) then
            table.insert(matches, key)
        end
    end
    for _, match in ipairs(matches) do
        if
            not lsp_manager.is_server_disabled_globally(match)
            and not lsp_manager.is_server_disabled_for_buffer(match, bufnr)
        then
            lsp_manager.ensure_lsp_for_buffer(match, bufnr)
        end
    end
    if
        (_G.efm_configs and _G.efm_configs[ft])
        or (_G.global and _G.global.efm and _G.global.efm.filetypes and vim.tbl_contains(_G.global.efm.filetypes, ft))
    then
        if
            not lsp_manager.is_server_disabled_globally("efm")
            and not lsp_manager.is_server_disabled_for_buffer("efm", bufnr)
        then
            lsp_manager.ensure_lsp_for_buffer("efm", bufnr)
        end
    end
end

M.init = function()
    vim.defer_fn(function()
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            callback = function(args)
                local bufnr = args.buf
                attach_lsp_to_buffer(bufnr)
            end,
        })
        vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
            group = group,
            callback = function(args)
                local bufnr = args.buf
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        attach_lsp_to_buffer(bufnr)
                    end
                end, 100)
            end,
        })
        vim.api.nvim_create_user_command("LspReattach", function()
            local bufnr = vim.api.nvim_get_current_buf()
            attach_lsp_to_buffer(bufnr)
        end, {})
        vim.api.nvim_create_autocmd("DirChanged", {
            pattern = "*",
            callback = function()
                vim.defer_fn(function()
                    require("languages.lsp_manager").stop_servers_for_old_project()
                    vim.cmd("Fidget clear")
                end, 5000)
            end,
            desc = "Stops LSP servers from other projects when directory is changed",
        })
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype ~= "" then
                attach_lsp_to_buffer(bufnr)
            end
        end
    end, 100)
end

M.lsp_enable = function()
    return true
end
M.find_matching_keys = function(ft)
    if not ft or ft == "" then
        return {}
    end

    local matches = {}
    for key, filetypes in pairs(_G.file_types or {}) do
        if vim.tbl_contains(filetypes, ft) then
            table.insert(matches, key)
        end
    end
    return matches
end

M.setup = M.init

return M
