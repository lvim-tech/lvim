-- UI utilities: keymap registration, float window management, and the
-- interactive command-output REPL window.
---@module "core.funcs.ui"
local M = {}

-- Registers a list of keymaps for a given mode.
-- Each entry is a LvimKeymap tuple: { lhs, rhs, desc?, extra_opts? }.
-- Per-keymap opts (element [4]) are merged with the shared opts table,
-- allowing individual keymaps to set flags like { expr = true }.
---@param mode    string|string[]  Vim mode(s) (e.g. "n", {"n","v"})
---@param opts    table            Shared vim.keymap.set options (noremap, silent…)
---@param keymaps LvimKeymap[]    List of keymap tuples
M.keymaps = function(mode, opts, keymaps)
    for _, keymap in ipairs(keymaps) do
        local keymap_opts = vim.tbl_extend("force", opts, keymap[4] or {})
        keymap_opts.desc = keymap[3] or nil
        vim.keymap.set(mode, keymap[1], keymap[2], keymap_opts)
    end
end

-- Closes all floating windows. Scheduled so it runs after the current event
-- loop tick — safe to call from keymaps that may themselves be inside a float.
M.close_float_windows = function()
    vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
                local config = vim.api.nvim_win_get_config(win)
                if config.relative ~= "" then
                    vim.api.nvim_win_close(win, false)
                end
            end
        end
    end)
end

-- Cycles focus through all open floating windows, wrapping around.
-- _G.LVIM._float_index tracks the current position in the cycle.
M.focus_float_window = function()
    local wins = vim.api.nvim_list_wins()
    local floats = {}
    local cur_win = vim.api.nvim_get_current_win()
    for _, win in ipairs(wins) do
        if vim.api.nvim_win_is_valid(win) then
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative ~= "" then
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
                    local return_output = #return_values > 0
                            and "Return values:\n" .. table.concat(return_values, "\n")
                        or ""
                    local print_content = #print_output > 0
                            and "Printed output:\n" .. table.concat(print_output, "\n")
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
        -- Split output into lines and open a centred, read-only float
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].bufhidden = "wipe"
        local lines = {}
        for line in output:gmatch("([^\n]*)\n?") do
            table.insert(lines, line)
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        local width = math.min(80, vim.o.columns - 4)
        local height = math.min(#lines + 2, math.max(5, vim.o.lines - 4))
        local col = math.floor((vim.o.columns - width) / 2)
        local row = math.floor((vim.o.lines - height) / 2)
        local opts = {
            relative = "editor",
            width = width,
            height = height,
            col = col,
            row = row,
            style = "minimal",
            border = "rounded",
            title = success and " Output: " .. input .. " " or " Error: " .. input .. " ",
            title_pos = "center",
        }
        local win = vim.api.nvim_open_win(buf, true, opts)
        vim.bo[buf].modifiable = false
        vim.wo[win].wrap = true
        vim.wo[win].cursorline = true
        for _, key in ipairs({ "q", "<Esc>" }) do
            vim.api.nvim_buf_set_keymap(
                buf, "n", key, "<cmd>close<CR>",
                { noremap = true, silent = true, desc = "Close window" }
            )
        end
        vim.api.nvim_buf_set_name(buf, "[Output]")
        vim.notify("Press 'q' or <Esc> to close the window", vim.log.levels.INFO)
    end)
end

return M
