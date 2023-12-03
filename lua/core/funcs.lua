local global = require("core.global")
local icons = require("configs.base.ui.icons")
local get_node = vim.treesitter.get_node
local MATH_NODES = {
    displayed_equation = true,
    inline_formula = true,
    math_environment = true,
}

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
    local notify = require("lvim-ui-config.notify")
    vim.fn.inputsave()
    local password = vim.fn.inputsecret("Password: ")
    vim.fn.inputrestore()
    if not password or #password == 0 then
        notify.error("Invalid password, sudo aborted!", {
            title = "LVIM IDE",
        })
        return false
    end
    vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
    if vim.v.shell_error ~= 0 then
        notify.error("Shell error or invalid password, sudo aborted!", {
            title = "LVIM IDE",
        })
        return false
    end
    return true
end

M.sudo_write = function(tmpfile, filepath)
    local notify = require("lvim-ui-config.notify")
    if not tmpfile then
        tmpfile = vim.fn.tempname()
    end
    if not filepath then
        filepath = vim.fn.expand("%")
    end
    if not filepath or #filepath == 0 then
        notify.error("No file name!", {
            title = "LVIM IDE",
        })
        return
    end
    local cmd = string.format("dd if=%s of=%s bs=1048576", vim.fn.shellescape(tmpfile), vim.fn.shellescape(filepath))
    ---@diagnostic disable-next-line: undefined-field
    vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
    if M.sudo_exec(cmd) then
        notify.info(string.format('"%s" written!', filepath), {
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
    local file_content_ok, _ = pcall(function()
        content = vim.fn.readfile(file)
    end)
    if not file_content_ok then
        return nil
    end
    if type(content) == "table" then
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
    local lvim_packages_file = global.cache_path .. "/.lvim_packages"
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
    local file_content = M.read_file(global.cache_path .. "/.lvim_snapshot")
    if file_content ~= nil then
        if file_content["snapshot"] ~= nil then
            return file_content["snapshot"]
        end
    end
    return global.snapshot_path .. "/default"
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

M.hexToRgb = function(c)
    c = string.lower(c)
    return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

M.blend = function(foreground, background, alpha)
    alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
    local bg = M.hexToRgb(background)
    local fg = M.hexToRgb(foreground)
    local blendChannel = function(i)
        local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end
    return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end

M.darken = function(hex, amount, bg)
    return M.blend(hex, bg or M.bg, amount)
end

M.lighten = function(hex, amount, fg)
    return M.blend(hex, fg or M.fg, amount)
end

local function pattern_list_matches(str, pattern_list)
    for _, pattern in ipairs(pattern_list) do
        if str:find(pattern) then
            return true
        end
    end
    return false
end

local buf_matchers = {
    filetype = function(bufnr)
        return vim.bo[bufnr].filetype
    end,
    buftype = function(bufnr)
        return vim.bo[bufnr].buftype
    end,
    bufname = function(bufnr)
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    end,
}

M.buffer_matches = function(patterns, bufnr)
    bufnr = bufnr or 0
    for kind, pattern_list in pairs(patterns) do
        if pattern_list_matches(buf_matchers[kind](bufnr), pattern_list) then
            return true
        end
    end
    return false
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
            group = global.tm_augroup,
        })
    elseif action == "stop" then
        local autocommands = vim.api.nvim_get_autocmds({
            group = global.tm_augroup,
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

M.in_mathzone = function(_, matched_trigger)
    if matched_trigger and matched_trigger:len() == 1 then
        vim.cmd.redraw()
    end
    local current_node = get_node({ ignore_injections = false })
    while current_node do
        if current_node:type() == "text_mode" then
            return false
        elseif MATH_NODES[current_node:type()] then
            return true
        end
        current_node = current_node:parent()
    end
    return false
end

M.in_latex_zone = function()
    local current_node = get_node({ ignore_injections = false })
    while current_node do
        if MATH_NODES[current_node:type()] then
            return true
        end
        current_node = current_node:parent()
    end
    return false
end

M.in_mathzone_ignore_backslash = function(line_to_cursor, matched_trigger)
    if line_to_cursor and line_to_cursor:match(".*\\[%a_]+$") then
        return false
    end
    if matched_trigger and matched_trigger:len() == 1 then
        vim.cmd.redraw()
    end
    local current_node = get_node({ ignore_injections = false })
    while current_node do
        if current_node:type() == "text_mode" then
            return false
        elseif MATH_NODES[current_node:type()] then
            return true
        end
        current_node = current_node:parent()
    end
    return false
end

M.in_text = function()
    return not M.in_mathzone()
end

return M
