local ui_config = require("lvim-ui-config.config")
local select = require("lvim-ui-config.select")
local funcs = require("core.funcs")

local M = {}

M.group = vim.api.nvim_create_augroup("AutoCodeLens", { clear = true })

M.is_codelens_enabled = function()
    if _G.LVIM_SETTINGS and _G.LVIM_SETTINGS["codelence"] ~= nil then
        return _G.LVIM_SETTINGS["codelence"]
    end
    return false
end

M.clear_all_codelens = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            vim.lsp.codelens.clear(buf)
            local ns_id = vim.api.nvim_create_namespace("vim_lsp_codelens")
            vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
            for id = 1, 100 do
                vim.api.nvim_buf_clear_namespace(buf, id, 0, -1)
            end
        end
    end
    vim.cmd("redraw!")
end

M.refresh_all_codelens = function()
    vim.lsp.codelens.refresh()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
            vim.cmd("doautocmd BufEnter")
        end
    end
    vim.cmd("redraw!")
end

M.setup_codelens_autocmds = function()
    local group = vim.api.nvim_create_augroup("AutoCodeLens", { clear = true })
    vim.api.nvim_create_autocmd({ "LspAttach", "TextChanged", "TextChangedI" }, {
        -- vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "LspAttach", "ColorScheme" }, {
        callback = function()
            vim.defer_fn(function()
                if M.is_codelens_enabled() and vim.lsp.codelens and vim.lsp.codelens.refresh then
                    vim.lsp.codelens.refresh()
                end
            end, 100)
        end,
        group = group,
    })
    return group
end

M.toggle_code_lens = function()
    local status
    if M.is_codelens_enabled() then
        status = "Enabled"
    else
        status = "Disabled"
    end
    local opts = ui_config.select({
        "Enable",
        "Disable",
        "Cancel",
    }, { prompt = "CodeLens (" .. status .. ")" }, {})
    select(opts, function(choice)
        if choice == "Enable" then
            _G.LVIM_SETTINGS["codelence"] = true
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            if _G.original_codelens_module then
                vim.lsp.codelens = _G.original_codelens_module
                _G.original_codelens_module = nil
                M.group = M.setup_codelens_autocmds()
                vim.schedule(function()
                    vim.lsp.codelens.refresh()
                    vim.defer_fn(function()
                        vim.lsp.codelens.refresh()
                    end, 500)
                end)
            end
            vim.notify("CodeLens enabled", vim.log.levels.INFO)
        elseif choice == "Disable" then
            _G.LVIM_SETTINGS["codelence"] = false
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            if not _G.original_codelens_module then
                _G.original_codelens_module = vim.deepcopy(vim.lsp.codelens)
                vim.api.nvim_clear_autocmds({ group = "AutoCodeLens" })
                M.clear_all_codelens()
            end
            vim.notify("CodeLens disabled", vim.log.levels.INFO)
        end
    end)
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

M.setup = function()
    local orig_codelens_display = vim.lsp.codelens.display
    vim.lsp.codelens.display = function(lenses, bufnr, client_id)
        if not M.is_codelens_enabled() then
            return
        end
        local filtered_lenses = {}
        for _, lens in ipairs(lenses or {}) do
            if lens.command and lens.command.title and not lens.command.title:match("Unresolved") then
                table.insert(filtered_lenses, lens)
            end
        end
        return orig_codelens_display(filtered_lenses, bufnr, client_id)
    end
    local orig_codelens_refresh = vim.lsp.codelens.refresh
    vim.lsp.codelens.refresh = function(bufnr, client_id)
        if not M.is_codelens_enabled() then
            return
        end
        return orig_codelens_refresh(bufnr, client_id)
    end
    M.group = M.setup_codelens_autocmds()
    vim.o.mouse = "a"
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
    vim.api.nvim_create_user_command("LvimCodeLens", function()
        M.toggle_code_lens()
    end, {})
end

return M
