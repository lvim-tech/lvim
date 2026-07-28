-- Filesystem utilities: reading, writing, and navigating files and directories.
---@module "core.funcs.fs"
local M = {}

-- Reads a file and attempts to decode its content:
--   1. JSON  → returns decoded Lua value
--   2. "true" / "false" → returns boolean
--   3. Anything else   → returns the first line as a string
-- Returns nil when the file is missing or empty.
---@param file string  Absolute path to the file
---@return any|nil     Decoded content, or nil on failure
M.read_file = function(file)
    local ok, content = pcall(vim.fn.readfile, file)
    if not ok or type(content) ~= "table" or #content == 0 then
        return nil
    end
    local text = table.concat(content, "\n")
    local ok_json, decoded = pcall(vim.fn.json_decode, text)
    if ok_json and decoded ~= nil then
        return decoded
    end
    if text == "true" then
        return true
    elseif text == "false" then
        return false
    end
    return content[1]
end

-- Writes content to a file, serialising tables as JSON and booleans as strings.
---@param file    string        Absolute path to write
---@param content string|table|boolean  Data to persist
M.write_file = function(file, content)
    local f = io.open(file, "w")
    if f ~= nil then
        if type(content) == "table" then
            content = vim.fn.json_encode(content)
        elseif type(content) == "boolean" then
            content = tostring(content)
        end
        f:write(content)
        f:close()
    end
end

-- Copies a file to a destination path via libuv (no shell, handles spaces safely).
---@param file string  Source path
---@param dest string  Destination path
M.copy_file = function(file, dest)
    local uv = vim.uv or vim.loop
    uv.fs_copyfile(file, dest)
end

-- Prompts the user to enter a path, pre-filled with the current working directory.
---@return string  The path entered by the user
M.change_path = function()
    return vim.fn.input("Path: ", vim.fn.getcwd() .. "/", "file")
end

-- Changes the global working directory (:cd) to a user-selected path.
M.set_global_path = function()
    local path = M.change_path()
    vim.api.nvim_command("silent :cd " .. vim.fn.fnameescape(path))
end

-- Changes the current window's local directory (:lcd) to a user-selected path.
M.set_window_path = function()
    local path = M.change_path()
    vim.api.nvim_command("silent :lcd " .. vim.fn.fnameescape(path))
end

return M
