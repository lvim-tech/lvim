local icons = require("configs.base.ui.icons")

local M = {}

M.merge = function(tbl1, tbl2)
    if type(tbl1) == "table" and type(tbl2) == "table" then
        for k, v in pairs(tbl2) do
            if type(v) == "table" and type(tbl1[k] or false) == "table" then
                M.merge(tbl1[k], v)
            else
                tbl1[k] = v
            end
        end
    end
    return tbl1
end

M.sort = function(tbl)
    local arr = {}
    for key, value in pairs(tbl) do
        arr[#arr + 1] = { key, value }
    end
    for ix, value in ipairs(arr) do
        tbl[ix] = value
    end
    return tbl
end

M.sort_lua_table = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local sorted_lines = {}
    local inner_lines = {}
    for _, line in ipairs(lines) do
        if line:match('%[".*"%]') then
            table.insert(sorted_lines, line)
        else
            table.insert(inner_lines, line)
        end
    end
    table.sort(sorted_lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, sorted_lines)
    vim.api.nvim_buf_set_lines(0, #sorted_lines, -1, false, inner_lines)
end

M.has_value = function(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

M.merge_unique = function(table1, table2)
    local merged = {}
    for _, v in ipairs(table1) do
        if not M.has_value(merged, v) then
            table.insert(merged, v)
        end
    end
    for _, v in ipairs(table2) do
        if not M.has_value(merged, v) then
            table.insert(merged, v)
        end
    end
    return merged
end

-- local a = {"a", "b", "c", "d"}
-- local order = {"c", "b", "d", "a"}
-- table.sort(a, M.custom_sort(order))
M.custom_sort = function(order)
    return function(a, b)
        local indexA = 0
        local indexB = 0
        for i, value in ipairs(order) do
            if value == a then
                indexA = i
            elseif value == b then
                indexB = i
            end
        end
        return indexA < indexB
    end
end

M.find_key_by_value = function(tbl, search_value)
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            for _, v in ipairs(value) do
                if v == search_value then
                    return key
                end
            end
        end
    end
    return nil
end

M.keymaps = function(mode, opts, keymaps)
    for _, keymap in ipairs(keymaps) do
        if keymap[3] ~= nil then
            opts.desc = keymap[3]
        else
            opts.desc = nil
        end
        vim.keymap.set(mode, keymap[1], keymap[2], opts)
    end
end

M.configs = function()
    local base_configs = require("configs.base")
    local user_configs = require("configs.user")
    local unsort_configs = M.merge(base_configs, user_configs)
    local configs = M.sort(unsort_configs)
    for _, func in pairs(configs) do
        if type(func) == "function" then
            func()
        end
    end
end

M.remove_duplicate = function(tbl)
    local hash = {}
    local res = {}
    for _, v in ipairs(tbl) do
        if not hash[v] then
            res[#res + 1] = v
            hash[v] = true
        end
    end
    return res
end

M.sudo_exec = function(cmd)
    vim.fn.inputsave()
    local password = vim.fn.inputsecret("Password: ")
    vim.fn.inputrestore()
    if not password or #password == 0 then
        vim.notify("Invalid password, sudo aborted!", vim.log.levels.ERROR, {
            title = "LVIM IDE",
        })
        return false
    end
    vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
    if vim.v.shell_error ~= 0 then
        vim.notify("Shell error or invalid password, sudo aborted!", vim.log.levels.ERROR, {
            title = "LVIM IDE",
        })
        return false
    end
    return true
end

M.sudo_write = function(tmpfile, filepath)
    if not tmpfile then
        tmpfile = vim.fn.tempname()
    end
    if not filepath then
        filepath = vim.fn.expand("%")
    end
    if not filepath or #filepath == 0 then
        vim.notify("No file name!", vim.log.levels.ERROR, {
            title = "LVIM IDE",
        })
        return
    end
    local cmd = string.format("dd if=%s of=%s bs=1048576", vim.fn.shellescape(tmpfile), vim.fn.shellescape(filepath))
    vim.api.nvim_command(string.format("write! %s", tmpfile))
    if M.sudo_exec(cmd) then
        vim.notify(string.format('"%s" written!', filepath), vim.log.levels.INFO, {
            title = "LVIM IDE",
        })
        vim.cmd("e!")
    end
    vim.fn.delete(tmpfile)
end

M.file_exists = function(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end

M.dir_exists = function(path)
    return M.file_exists(path)
end

M.read_file = function(file)
    local content
    local file_content_ok = pcall(function()
        content = vim.fn.readfile(file)
    end)
    if not file_content_ok then
        return nil
    end
    if type(content) == "table" then
        if next(content) == nil then
            return nil
        end
        return vim.fn.json_decode(content)
    else
        return nil
    end
end

M.write_file = function(file, content)
    local f = io.open(file, "w")
    if f ~= nil then
        if type(content) == "table" then
            content = vim.fn.json_encode(content)
        end
        f:write(content)
        f:close()
    end
end

M.copy_file = function(file, dest)
    os.execute("cp " .. file .. " " .. dest)
end

M.delete_file = function(f)
    os.remove(f)
end

M.delete_packages_file = function()
    local lvim_packages_file = _G.global.cache_path .. "/.lvim_packages"
    os.remove(lvim_packages_file)
end

M.change_path = function()
    return vim.fn.input("Path: ", vim.fn.getcwd() .. "/", "file")
end

M.set_global_path = function()
    local path = M.change_path()
    vim.api.nvim_command("silent :cd " .. path)
end

M.set_window_path = function()
    local path = M.change_path()
    vim.api.nvim_command("silent :lcd " .. path)
end

M.file_size = function(size, options)
    local si = {
        bits = { "b", "Kb", "Mb", "Gb", "Tb", "Pb", "Eb", "Zb", "Yb" },
        bytes = { "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" },
    }
    local function isNan(num)
        return num ~= num
    end
    local function roundNumber(num, digits)
        local fmt = "%." .. digits .. "f"
        return tonumber(fmt:format(num))
    end
    local o = {}
    for key, value in pairs(options or {}) do
        o[key] = value
    end
    local function setDefault(name, default)
        if o[name] == nil then
            o[name] = default
        end
    end
    setDefault("bits", false)
    setDefault("unix", false)
    setDefault("base", 2)
    setDefault("round", o.unix and 1 or 2)
    setDefault("spacer", o.unix and "" or " ")
    setDefault("suffixes", {})
    setDefault("output", "string")
    setDefault("exponent", -1)
    assert(not isNan(size), "Invalid arguments")
    local ceil = (o.base > 2) and 1000 or 1024
    local negative = (size < 0)
    if negative then
        size = -size
    end
    local result
    if size == 0 then
        result = {
            0,
            o.unix and "" or (o.bits and "b" or "B"),
        }
    else
        if o.exponent == -1 or isNan(o.exponent) then
            o.exponent = math.floor(math.log(size) / math.log(ceil))
        end
        if o.exponent > 8 then
            o.exponent = 8
        end
        local val
        if o.base == 2 then
            val = size / math.pow(2, o.exponent * 10)
        else
            val = size / math.pow(1000, o.exponent)
        end
        if o.bits then
            val = val * 8
            if val > ceil then
                val = val / ceil
                o.exponent = o.exponent + 1
            end
        end
        result = {
            roundNumber(val, o.exponent > 0 and o.round or 0),
            (o.base == 10 and o.exponent == 1) and (o.bits and "kb" or "kB")
                or si[o.bits and "bits" or "bytes"][o.exponent + 1],
        }
        if o.unix then
            result[2] = result[2]:sub(1, 1)
            if result[2] == "b" or result[2] == "B" then
                result = {
                    math.floor(result[1]),
                    "",
                }
            end
        end
    end
    assert(result)
    if negative then
        result[1] = -result[1]
    end
    result[2] = o.suffixes[result[2]] or result[2]
    if o.output == "array" then
        return result
    elseif o.output == "exponent" then
        return o.exponent
    elseif o.output == "object" then
        return {
            value = result[1],
            suffix = result[2],
        }
    elseif o.output == "string" then
        local value = tostring(result[1])
        value = value:gsub("%.0$", "")
        local suffix = result[2]
        return value .. o.spacer .. suffix
    end
end

M.get_snapshot = function()
    local file_content = M.read_file(_G.global.cache_path .. "/.lvim_snapshot")
    if file_content ~= nil then
        if file_content["snapshot"] ~= nil then
            return file_content["snapshot"]
        end
    end
    return _G.global.snapshot_path .. "/default"
end

M.get_commit = function(plugin, plugins_snapshot)
    if plugins_snapshot ~= nil then
        if plugins_snapshot[plugin] ~= nil and plugins_snapshot[plugin].commit ~= nil then
            return plugins_snapshot[plugin].commit
        end
    else
        return nil
    end
end

M.close_float_windows = function()
    local closed_windows = {}
    vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
                local config = vim.api.nvim_win_get_config(win)
                if config.relative ~= "" then
                    vim.api.nvim_win_close(win, false)
                    table.insert(closed_windows, win)
                end
            end
        end
    end)
end

M.quit = function()
    local status = true
    for _, v in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[v].modified then
            status = false
        end
    end
    if not status then
        local ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
        local opts = ui_config.select({
            "Save all and Quit",
            "Don't save and Quit",
            "Cancel",
        }, { prompt = icons.common.warning .. " Unsaved files" }, {})
        select(opts, function(choice)
            if choice == "Save all and Quit" then
                vim.cmd("wa")
                vim.cmd("qa")
            elseif choice == "Don't save and Quit" then
                vim.cmd("qa!")
            end
        end)
    else
        vim.cmd("qa")
    end
end

M.is_helm = function()
    local filepath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t")
    if
        string.match(filepath, ".+/templates/.+%.yaml$")
        or string.match(filepath, ".+/templates/.+%.yml$")
        or string.match(filepath, ".+/templates/.+%.tpl$")
        or string.match(filepath, ".+/templates/.+%.txt$")
    then
        return true
    end
    if string.match(filename, ".+%.gotmpl$") then
        return true
    end
    if string.match(filename, "helmfile.+%.yaml$") or string.match(filename, "helmfile.+%.yml$") then
        return true
    end
    return false
end

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
            output = vim.api.nvim_exec2(input, { output = true }).output
        else
            local func, load_err = loadstring("return " .. input)
            if not func then
                func, load_err = loadstring(input)
                if not func then
                    output = "Error loading Lua code: " .. tostring(load_err)
                    success = false
                end
            end
            if func then
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
        local keys = { "q", "<Esc>" }
        for _, key in ipairs(keys) do
            vim.api.nvim_buf_set_keymap(
                buf,
                "n",
                key,
                "<cmd>close<CR>",
                { noremap = true, silent = true, desc = "Close window" }
            )
        end
        vim.api.nvim_buf_set_name(buf, "[Output]")
        vim.notify("Press 'q' or <Esc> to close the window", vim.log.levels.INFO)
    end)
end

M.get_highlight = function(hl_group)
    local hl_details = vim.api.nvim_get_hl(0, { name = hl_group })

    local bg_color = nil
    local fg_color = nil

    if hl_details.bg then
        bg_color = string.format("#%06x", hl_details.bg)
    end

    if hl_details.fg then
        fg_color = string.format("#%06x", hl_details.fg)
    end

    return { bg = bg_color, fg = fg_color }
end

local function rgb(c)
    c = string.lower(c)
    return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

M.blend = function(foreground, alpha, background)
    alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
    local bg = rgb(background)
    local fg = rgb(foreground)

    local blendChannel = function(i)
        local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end

M.tm_autocmd = function(action)
    if action == "start" then
        local buftypes = {
            "prompt",
            "help",
            "quickfix",
            "nofile",
        }
        local filetypes = {
            "neo-tree",
            "spectre_panel",
            "Outline",
            "Trouble",
            "NeogitStatus",
            "NeogitPopup",
            "calendar",
            "dapui_breakpoints",
            "dapui_scopes",
            "dapui_stacks",
            "dapui_watches",
            "git",
            "netrw",
            "octo",
            "undotree",
            "diff",
            "DiffviewFiles",
            "flutterToolsOutline",
            "log",
            "toggleterm",
            "netrw",
            "noice",
            "lazy",
            "mason",
            "LvimHelper",
        }
        local buftype = vim.tbl_contains(buftypes, vim.bo.buftype)
        local filetype = vim.tbl_contains(filetypes, vim.bo.filetype)
        if buftype or filetype then
            vim.opt.timeoutlen = 1000
        else
            vim.opt.timeoutlen = 0
        end
        vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
            callback = function()
                vim.schedule(function()
                    buftype = vim.tbl_contains(buftypes, vim.bo.buftype)
                    filetype = vim.tbl_contains(filetypes, vim.bo.filetype)
                    if buftype or filetype then
                        vim.opt.timeoutlen = 1000
                    else
                        vim.opt.timeoutlen = 0
                    end
                end)
            end,
            group = _G.global.tm_augroup,
        })
    elseif action == "stop" then
        local autocommands = vim.api.nvim_get_autocmds({
            group = _G.global.tm_augroup,
        })

        if next(autocommands) == nil then
        else
            vim.schedule(function()
                vim.api.nvim_del_autocmd(autocommands[1]["id"])
                vim.opt.timeoutlen = 1000
            end)
        end
    end
end

local multi_line_patterns = {
    "%-%-%[%[.-%]%]", -- --[[ multi-line comment ]]
    "/%*.-%*/", -- /* multi-line comment */
    "<!%-%-.-%-%->", -- <!-- multi-line comment -->
}

local single_line_patterns = {
    "^%s*%-%-[^%-%[].*$", -- -- single-line comment (but not ---)
    "^%s*//.*$", -- // single-line comment
    "^%s*#[^%x%d].*$", -- # single-line comment (but not #hex)
    "^%s*;.*$", -- ; single-line comment
    "^%s*{{!.-}}%s*$", -- {{! handlebars single-line comment }}
    "^%s*{#.-#}%s*$", -- {# django/jinja single-line comment #}
    "%s%-%-[^%-%[].*$", -- inline -- comment
    "%s//.*$", -- inline // comment
    "%s#[^%x%d].*$", -- inline # comment (but not #hex)
    "%s;.*$", -- inline ; comment
}

M.remove_comments = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(original_lines, "\n")
    local multi_line_comment_count = 0
    local multi_line_total_lines = 0
    for _, pattern in ipairs(multi_line_patterns) do
        content = content:gsub(pattern, function(match)
            multi_line_comment_count = multi_line_comment_count + 1
            local line_count = select(2, match:gsub("\n", "")) + 1
            multi_line_total_lines = multi_line_total_lines + line_count
            return string.rep("\n", line_count)
        end)
    end
    local lines = vim.split(content, "\n", { trimempty = false })
    local result_lines = {}
    local single_line_comment_count = 0
    for i, line in ipairs(lines) do
        local modified_line = line
        local is_original_empty = original_lines[i] and original_lines[i]:match("^%s*$") or false
        if not modified_line:match("#%x%x%x%x%x%x?") then
            for _, pattern in ipairs(single_line_patterns) do
                local before = #modified_line
                modified_line = modified_line:gsub(pattern, "")
                if #modified_line < before then
                    single_line_comment_count = single_line_comment_count + 1
                end
            end
        end
        modified_line = modified_line:gsub("%s+$", "")
        if modified_line:match("%S") or is_original_empty then
            table.insert(result_lines, modified_line)
        end
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result_lines)
    vim.notify(
        "Deleted comments: \n"
            .. "Single-line: "
            .. single_line_comment_count
            .. "\n"
            .. "Multi-line: "
            .. multi_line_comment_count
            .. " (Total lines: "
            .. multi_line_total_lines
            .. ")",
        vim.log.levels.INFO
    )
end

return M
