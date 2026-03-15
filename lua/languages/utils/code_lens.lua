-- Description: CodeLens lifecycle utilities for LVIM IDE.
-- Provides enable/disable toggling of the Neovim CodeLens subsystem,
-- autocommand-based refresh triggers, and a smart "run nearest lens"
-- command.  When CodeLens is disabled the three core vim.lsp.codelens
-- functions are replaced with no-ops so no extmarks are rendered.
--
---@module "languages.utils.code_lens"

local M = {}

-- ── Preserve original vim.lsp.codelens functions on first load ────────────────
-- These are saved at module load time so they can be restored later when
-- CodeLens is re-enabled after being disabled.

if not _G.orig_codelens_display then
    _G.orig_codelens_display = vim.lsp.codelens.display
end
if not _G.orig_codelens_refresh then
    _G.orig_codelens_refresh = vim.lsp.codelens.refresh
end
if not _G.orig_codelens_clear then
    _G.orig_codelens_clear = vim.lsp.codelens.clear
end

--- Returns true when CodeLens is enabled in the LVIM settings store.
--- Defaults to false when the setting is absent.
---@return boolean
M.is_codelens_enabled = function()
    if _G.LVIM.settings and _G.LVIM.settings["codelens"] ~= nil then
        return _G.LVIM.settings["codelens"]
    end
    return false
end

--- Clears all CodeLens extmarks from every valid buffer by iterating over
--- every Neovim namespace whose name contains "codelens".
---@return nil
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

--- Triggers a global CodeLens refresh when CodeLens is enabled, then fires
--- a BufEnter autocommand on each normal buffer to let plugins re-populate.
---@return nil
M.refresh_all_codelens = function()
    if M.is_codelens_enabled() then
        vim.lsp.codelens.refresh()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            -- Only trigger for normal file buffers (buftype == "")
            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
                vim.cmd("doautocmd BufEnter")
            end
        end
        vim.cmd("redraw!")
    end
end

--- Registers the `AutoCodeLens` autocommand group that automatically refreshes
--- CodeLens 100 ms after LSP attachment or any text change.
---@return integer  The autocommand group id
M.setup_codelens_autocmds = function()
    local group = vim.api.nvim_create_augroup("AutoCodeLens", { clear = true })
    vim.api.nvim_create_autocmd({ "LspAttach", "TextChanged", "TextChangedI" }, {
        callback = function()
            -- Small delay to avoid hammering the LSP server on every keystroke
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

--- Runs the CodeLens on the current cursor line.
--- If no lens is on that exact line, falls back to the closest lens in the
--- buffer and moves the cursor there before running.
---@return nil
M.lsp_code_lens_run = function()
    if not M.is_codelens_enabled() then
        vim.notify("CodeLens is disabled", vim.log.levels.WARN)
        return
    end
    local pos    = vim.api.nvim_win_get_cursor(0)
    -- Convert from 1-based cursor row to 0-based LSP line number
    local line   = pos[1] - 1
    local lenses = vim.lsp.codelens.get(0) or {}
    local found  = false

    -- First pass: look for an exact line match
    for _, lens in ipairs(lenses) do
        if lens.range.start.line == line then
            vim.lsp.codelens.run()
            found = true
            break
        end
    end

    -- Second pass: if no exact match, jump to the nearest lens
    if not found then
        local closest_lens = nil
        local min_distance = math.huge
        for _, lens in ipairs(lenses) do
            local distance = math.abs(lens.range.start.line - line)
            if distance < min_distance then
                min_distance  = distance
                closest_lens  = lens
            end
        end
        if closest_lens then
            -- Move cursor to the lens line (1-based row, 0-based column)
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

--- Enables or disables CodeLens globally.
---
--- When enabling:
---   - Restores the original `vim.lsp.codelens` functions.
---   - Schedules an immediate refresh.
---   - Sets up refresh autocommands if not already registered.
---
--- When disabling:
---   - Replaces the three `vim.lsp.codelens` functions with no-ops to prevent
---     any new extmarks from being created.
---   - Clears all existing CodeLens namespaces from all buffers.
---   - Removes the refresh autocommand group.
---
---@param val boolean  true to enable, false to disable
---@return nil
M.set_codelens_enabled = function(val)
    -- Re-capture originals in case this is called before module-level guards ran
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
        -- Restore original functions so CodeLens works normally again
        vim.lsp.codelens.display = _G.orig_codelens_display
        vim.lsp.codelens.refresh = _G.orig_codelens_refresh
        vim.lsp.codelens.clear   = _G.orig_codelens_clear
        vim.schedule(function()
            vim.lsp.codelens.refresh()
        end)
        -- Only register autocmds once (guard by checking M.group is a valid integer)
        if not (M.group and type(M.group) == "number") then
            M.group = M.setup_codelens_autocmds()
        end
    else
        -- Disable: replace with no-ops so CodeLens is completely suppressed
        vim.lsp.codelens.display = function() end
        vim.lsp.codelens.refresh = function() end
        vim.lsp.codelens.clear   = function() end
        -- Clear all existing codelens extmarks from every namespace/buffer
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

--- Initialises the CodeLens subsystem based on `_G.LVIM.settings.codelens`.
--- - If enabled: restores original functions, registers autocmds, sets up the
---   `LspCodeLensRun` user command, and binds double-click to run CodeLens.
--- - If disabled: installs no-ops and clears any lingering extmarks.
---@return nil
M.setup = function()
    -- Ensure originals are captured (idempotent)
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
        vim.lsp.codelens.clear   = _G.orig_codelens_clear
        M.group = M.setup_codelens_autocmds()
    else
        -- Install no-ops and clean up any extmarks left from a previous session
        vim.lsp.codelens.display = function() end
        vim.lsp.codelens.refresh = function() end
        vim.lsp.codelens.clear   = function() end
        if M.group and type(M.group) == "number" then
            pcall(vim.api.nvim_clear_autocmds, { group = M.group })
            M.group = nil
        end
        M.clear_all_codelens()
    end

    -- Double-click handler: run CodeLens when clicked on a lens line,
    -- otherwise pass the event through as a normal double-click
    vim.keymap.set("n", "<2-LeftMouse>", function()
        if not M.is_codelens_enabled() then
            vim.api.nvim_input("<2-LeftMouse>")
            return
        end
        local pos    = vim.api.nvim_win_get_cursor(0)
        local line   = pos[1] - 1
        local lenses = vim.lsp.codelens.get(0) or {}
        for _, lens in ipairs(lenses) do
            if lens.range.start.line == line then
                vim.lsp.codelens.run()
                return
            end
        end
        -- No CodeLens on this line; fall through to the default double-click action
        vim.api.nvim_input("<2-LeftMouse>")
    end, { noremap = true, silent = true })

    vim.api.nvim_create_user_command("LspCodeLensRun", function()
        M.lsp_code_lens_run()
    end, {})
end

return M
