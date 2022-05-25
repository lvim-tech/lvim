local M = {}

M.merge = function(a, b)
    if type(a) == "table" and type(b) == "table" then
        for k, v in pairs(b) do
            if type(v) == "table" and type(a[k] or false) == "table" then
                M.merge(a[k], v)
            else
                a[k] = v
            end
        end
    end
    return a
end

M.options_global = function(options)
    for name, value in pairs(options) do
        vim.o[name] = value
    end
end

M.options_set = function(options)
    for k, v in pairs(options) do
        if v == true or v == false then
            vim.cmd("set " .. k)
        else
            vim.cmd("set " .. k .. "=" .. v)
        end
    end
end

M.keymaps = function(mode, opts, keymaps)
    for _, keymap in ipairs(keymaps) do
        vim.keymap.set(mode, keymap[1], keymap[2], opts)
    end
end

M.configs = function()
    local global_configs = require("configs.global")
    local custom_configs = require("configs.custom")
    local configs = M.merge(global_configs, custom_configs)
    for _, func in pairs(configs) do
        if type(func) == "function" then
            func()
        end
    end
end

M.file_exists = function(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end

M.dir_exists = function(path)
    return M.file_exists(path)
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
        -- Flipping a negative number to determine the size
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

M.get_highlight = function(hlname)
    local hl = vim.api.nvim_get_hl_by_name(hlname, true)
    setmetatable(hl, {
        __index = function(t, k)
            if k == "fg" then
                return t.foreground
            elseif k == "bg" then
                return t.background
            elseif k == "sp" then
                return t.special
            else
                return rawget(t, k)
            end
        end,
    })
    return hl
end

_G.LVIM_COLORS = function()
    return {
        green = M.get_highlight("CursorLineNr").fg,
        red = M.get_highlight("DiagnosticError").fg,
        orange = M.get_highlight("DiagnosticWarn").fg,
        yellow = M.get_highlight("DiagnosticInfo").fg,
        blue = M.get_highlight("DiagnosticHint").fg,
        status_line_bg = M.get_highlight("StatusLine").bg,
        status_line_fg = M.get_highlight("StatusLine").fg,
        status_line_nc_bg = M.get_highlight("StatusLineNC").bg,
        status_line_nc_fg = M.get_highlight("StatusLineNC").fg,
    }
end

return M
