-- System-level utilities: privileged file writes and human-readable file sizes.
---@module "core.funcs.system"
local M = {}

-- Executes a shell command with sudo by piping the user's password via stdin.
-- Uses `-p ''` to suppress sudo's own password prompt and reads it via inputsecret.
---@param cmd string  Shell command to run as root (must be properly escaped)
---@return boolean    True if the command succeeded, false on bad password or error
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

-- Saves the current buffer to a temp file and copies it to its real path with
-- sudo, allowing root-owned files to be written from a user-level Neovim session.
---@param tmpfile? string  Temp file path; defaults to vim.fn.tempname()
---@param filepath? string Target file path; defaults to current buffer's file
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
    -- Use dd to perform a block-level copy so file permissions are preserved
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

-- Converts a raw byte count into a human-readable string (e.g. "4.2 MB").
-- Supports base-2 and base-10 units, bits/bytes, and multiple output formats.
---@param size    number              File size in bytes
---@param options? LvimFileSizeOptions Formatting options
---@return string|table|number|nil    Formatted result (format depends on options.output)
M.file_size = function(size, options)
    local si = {
        bits  = { "b", "Kb", "Mb", "Gb", "Tb", "Pb", "Eb", "Zb", "Yb" },
        bytes = { "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" },
    }
    local function isNan(num)
        return num ~= num
    end
    local function roundNumber(num, digits)
        local fmt = "%." .. digits .. "f"
        return tonumber(fmt:format(num))
    end
    -- Copy options so we don't mutate the caller's table
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
        result = { 0, o.unix and "" or (o.bits and "b" or "B") }
    else
        if o.exponent == -1 or isNan(o.exponent) then
            o.exponent = math.floor(math.log(size) / math.log(ceil))
        end
        if o.exponent > 8 then
            o.exponent = 8
        end
        local val
        if o.base == 2 then
            val = size / (2 ^ (o.exponent * 10))
        else
            val = size / (1000 ^ o.exponent)
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
                result = { math.floor(result[1]), "" }
            end
        end
    end
    assert(result)
    if negative then
        result[1] = -result[1]
    end
    -- Apply any custom suffix overrides (e.g. replace "MB" with "мб")
    result[2] = o.suffixes[result[2]] or result[2]
    if o.output == "array" then
        return result
    elseif o.output == "exponent" then
        return o.exponent
    elseif o.output == "object" then
        return { value = result[1], suffix = result[2] }
    elseif o.output == "string" then
        local value = tostring(result[1])
        value = value:gsub("%.0$", "")  -- strip trailing ".0" for whole numbers
        return value .. o.spacer .. result[2]
    end
end

return M
