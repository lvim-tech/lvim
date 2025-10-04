local M = {}

if not _G.orig_codelens_display then
    _G.orig_codelens_display = vim.lsp.codelens.display
end
if not _G.orig_codelens_refresh then
    _G.orig_codelens_refresh = vim.lsp.codelens.refresh
end
if not _G.orig_codelens_clear then
    _G.orig_codelens_clear = vim.lsp.codelens.clear
end

M.is_codelens_enabled = function()
    if _G.LVIM_SETTINGS and _G.LVIM_SETTINGS["codelens"] ~= nil then
        return _G.LVIM_SETTINGS["codelens"]
    end
    return false
end

M.clear_all_codelens = function()
    for name, id in pairs(vim.api.nvim_get_namespaces()) do
        if type(name) == "string" and name:lower():find("codelens") then
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_clear_namespace(buf, id, 0, -1)
                end
            end
        end
    end
    vim.cmd("redraw!")
end

M.refresh_all_codelens = function()
    if M.is_codelens_enabled() then
        vim.lsp.codelens.refresh()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
                vim.cmd("doautocmd BufEnter")
            end
        end
        vim.cmd("redraw!")
    end
end

M.setup_codelens_autocmds = function()
    local group = vim.api.nvim_create_augroup("AutoCodeLens", { clear = true })
    vim.api.nvim_create_autocmd({ "LspAttach", "TextChanged", "TextChangedI" }, {
        callback = function()
            vim.defer_fn(function()
                if M.is_codelens_enabled() then
                    vim.lsp.codelens.refresh()
                end
            end, 100)
        end,
        group = group,
    })
    return group
end

M.lsp_code_lens_run = function()
    if not M.is_codelens_enabled() then
        vim.notify("CodeLens is disabled", vim.log.levels.WARN)
        return
    end
    local pos = vim.api.nvim_win_get_cursor(0)
    local line = pos[1] - 1
    local lenses = vim.lsp.codelens.get(0) or {}
    local found = false
    for _, lens in ipairs(lenses) do
        if lens.range.start.line == line then
            vim.lsp.codelens.run()
            found = true
            break
        end
    end
    if not found then
        local closest_lens = nil
        local min_distance = math.huge
        for _, lens in ipairs(lenses) do
            local distance = math.abs(lens.range.start.line - line)
            if distance < min_distance then
                min_distance = distance
                closest_lens = lens
            end
        end
        if closest_lens then
            vim.api.nvim_win_set_cursor(0, { closest_lens.range.start.line + 1, closest_lens.range.start.character })
            vim.lsp.codelens.run()
            found = true
        end
    end
    if not found then
        if #lenses == 0 then
            vim.notify("No CodeLens found in this buffer", vim.log.levels.WARN)
        else
            vim.notify("No CodeLens on current line", vim.log.levels.INFO)
        end
    end
end

M.set_codelens_enabled = function(val)
    if not _G.orig_codelens_display then
        _G.orig_codelens_display = vim.lsp.codelens.display
    end
    if not _G.orig_codelens_refresh then
        _G.orig_codelens_refresh = vim.lsp.codelens.refresh
    end
    if not _G.orig_codelens_clear then
        _G.orig_codelens_clear = vim.lsp.codelens.clear
    end

    if val then
        vim.lsp.codelens.display = _G.orig_codelens_display
        vim.lsp.codelens.refresh = _G.orig_codelens_refresh
        vim.lsp.codelens.clear = _G.orig_codelens_clear
        vim.schedule(function()
            vim.lsp.codelens.refresh()
        end)
        if not (M.group and type(M.group) == "number") then
            M.group = M.setup_codelens_autocmds()
        end
    else
        -- disable all codelens redraw and clear all codelens extmarks
        vim.lsp.codelens.display = function() end
        vim.lsp.codelens.refresh = function() end
        vim.lsp.codelens.clear = function() end
        for name, id in pairs(vim.api.nvim_get_namespaces()) do
            if type(name) == "string" and name:lower():find("codelens") then
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_clear_namespace(buf, id, 0, -1)
                    end
                end
            end
        end
        vim.cmd("redraw!")
        if M.group and type(M.group) == "number" then
            pcall(vim.api.nvim_clear_autocmds, { group = M.group })
            M.group = nil
        end
    end
end

M.setup = function()
    if not _G.orig_codelens_display then
        _G.orig_codelens_display = vim.lsp.codelens.display
    end
    if not _G.orig_codelens_refresh then
        _G.orig_codelens_refresh = vim.lsp.codelens.refresh
    end
    if not _G.orig_codelens_clear then
        _G.orig_codelens_clear = vim.lsp.codelens.clear
    end

    if M.is_codelens_enabled() then
        vim.lsp.codelens.display = _G.orig_codelens_display
        vim.lsp.codelens.refresh = _G.orig_codelens_refresh
        vim.lsp.codelens.clear = _G.orig_codelens_clear
        M.group = M.setup_codelens_autocmds()
    else
        vim.lsp.codelens.display = function() end
        vim.lsp.codelens.refresh = function() end
        vim.lsp.codelens.clear = function() end
        if M.group and type(M.group) == "number" then
            pcall(vim.api.nvim_clear_autocmds, { group = M.group })
            M.group = nil
        end
        M.clear_all_codelens()
    end

    vim.keymap.set("n", "<2-LeftMouse>", function()
        if not M.is_codelens_enabled() then
            vim.api.nvim_input("<2-LeftMouse>")
            return
        end
        local pos = vim.api.nvim_win_get_cursor(0)
        local line = pos[1] - 1
        local lenses = vim.lsp.codelens.get(0) or {}
        for _, lens in ipairs(lenses) do
            if lens.range.start.line == line then
                vim.lsp.codelens.run()
                return
            end
        end
        vim.api.nvim_input("<2-LeftMouse>")
    end, { noremap = true, silent = true })

    vim.api.nvim_create_user_command("LspCodeLensRun", function()
        M.lsp_code_lens_run()
    end, {})
end

return M
