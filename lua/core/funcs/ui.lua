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

-- Opens a prompt that accepts either a Vim command (prefixed with `:`) or
-- arbitrary Lua code, executes it, and displays the output in a centred float.
-- print() calls inside Lua snippets are captured and shown alongside return values.
M.command_output = function()
    vim.ui.input({
        prompt = "Enter command or Lua code: ",
        default = "",
    }, function(input)
        if not input or input == "" then
            return
        end
        local output
        local success = true
        local is_command = input:match("^:")
        if is_command then
            -- Execute as a Vim Ex command and capture its output
            output = vim.api.nvim_exec2(input, { output = true }).output
        else
            -- Try "return <expr>" first so bare expressions like "1+1" work
            local func, load_err = load("return " .. input)
            if not func then
                func, load_err = load(input)
                if not func then
                    output = "Error loading Lua code: " .. tostring(load_err)
                    success = false
                end
            end
            if func then
                -- Temporarily replace the global print to capture its output
                local original_print = print
                local print_output = {}
                _G.print = function(...)
                    local args = { ... }
                    local str_args = {}
                    for i, v in ipairs(args) do
                        str_args[i] = tostring(v)
                    end
                    table.insert(print_output, table.concat(str_args, "\t"))
                end
                local results = { pcall(func) }
                _G.print = original_print
                if not results[1] then
                    output = "Lua execution error: " .. tostring(results[2])
                    success = false
                else
                    table.remove(results, 1)
                    local return_values = {}
                    for i, v in ipairs(results) do
                        return_values[i] = vim.inspect(v)
                    end
                    local return_output = #return_values > 0 and "Return values:\n" .. table.concat(return_values, "\n")
                        or ""
                    local print_content = #print_output > 0 and "Printed output:\n" .. table.concat(print_output, "\n")
                        or ""
                    if #return_output > 0 and #print_content > 0 then
                        output = print_content .. "\n\n" .. return_output
                    else
                        output = print_content .. return_output
                    end
                end
            end
        end
        if output == "" then
            vim.notify("No output from " .. (is_command and "command" or "Lua code"), vim.log.levels.INFO)
            return
        end
        -- THE CANONICAL VIEWER, not a hand-rolled float: `lvim-ui.info` is the shared read-only
        -- panel (frame + border title + `q close` footer + scrolling), so this output looks and
        -- behaves like every other panel in the editor instead of being a second, unthemed
        -- implementation of the same window with its own keymaps and sizing math.
        require("lvim-ui").info(output, {
            title = (success and "Output: " or "Error: ") .. input,
            wrap = true,
        })
    end)
end

return M
