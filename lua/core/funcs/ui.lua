-- UI utilities: float window management and the interactive command-output window.
-- (Keymap registration lived here until the keymap MANIFEST took it over — the manifest's
-- applier sets every mapping itself, so nothing called it any more.)
---@module "core.funcs.ui"
local M = {}

-- Closes all floating windows. Scheduled so it runs after the current event
-- loop tick — safe to call from keymaps that may themselves be inside a float.
M.close_float_windows = function()
    vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
                local config = vim.api.nvim_win_get_config(win)
                -- Skip managed-UI floats (e.g. the lvim-utils frame / diagnostics peek panels): they mark
                -- their windows with `w:lvim_frame` and tear themselves down as a unit — closing one of
                -- their floats out from under them corrupts the UI.
                if config.relative ~= "" and not vim.w[win].lvim_frame then
                    vim.api.nvim_win_close(win, false)
                end
            end
        end
    end)
end

-- Cycles focus through all open floating windows, wrapping around.
-- _G.LVIM._float_index tracks the current position in the cycle.
M.focus_float_window = function()
    -- Scheduled (like close_float_windows): the trigger key arrives via lvim-keys-helper, which is still
    -- unwinding its sequence (feedkeys / SafeState) when this fires — defer to the next tick so focus sticks.
    vim.schedule(function()
        local floats = {}
        local cur_win = vim.api.nvim_get_current_win()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
                local cfg = vim.api.nvim_win_get_config(win)
                -- Only FOCUSABLE floats: that excludes chrome / transient panels (the lvim-keys-helper
                -- legend, frame containers) which are non-focusable, and the managed-UI floats marked with
                -- `w:lvim_frame` (the docked peek). What's left is real content floats — the popup to focus.
                if cfg.relative ~= "" and cfg.focusable and not vim.w[win].lvim_frame then
                    table.insert(floats, win)
                end
            end
        end
        if #floats == 0 then
            vim.notify("No floating windows found", vim.log.levels.INFO)
            return
        end
        -- Find where we currently are in the float list, then advance by one
        local cur_idx = nil
        for i, win in ipairs(floats) do
            if win == cur_win then
                cur_idx = i
                break
            end
        end
        if not cur_idx or cur_idx > #floats then
            _G.LVIM._float_index = 1
        else
            _G.LVIM._float_index = (cur_idx % #floats) + 1
        end
        vim.api.nvim_set_current_win(floats[_G.LVIM._float_index])
    end)
end

return M
