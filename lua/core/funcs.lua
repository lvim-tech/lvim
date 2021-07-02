local M = {}
local global = require "core.global"

M.augroups = function(definitions)
    for group_name, definition in pairs(definitions) do
        vim.api.nvim_command("augroup " .. group_name)
        vim.api.nvim_command("autocmd!")
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten {"autocmd", def}, " ")
            vim.api.nvim_command(command)
        end
        vim.api.nvim_command("augroup END")
    end
end

M.commands = function(commands)
    for name, c in pairs(commands) do
        local command
        if c.buffer then
            command = "command!-buffer"
        else
            command = "command!"
        end
        vim.cmd(command .. " -nargs=" .. c.nargs .. " " .. name .. " " .. c.cmd)
    end
end

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
    for name, value in pairs(options) do vim.o[name] = value end
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
        vim.api.nvim_set_keymap(mode, keymap[1], keymap[2], opts)
    end
end

M.configs = function()
    local global_configs = require "configs.global"
    local custom_configs = require "configs.custom"
    local configs = M.merge(global_configs, custom_configs)
    for _, func in pairs(configs) do if func ~= false then func() end end
end

M.file_exists = function(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end

M.change_path = function()
    return vim.fn.input("Path: ", vim.fn.getcwd() .. global.path_sep, "file")
end

M.set_global_path = function()
    local path = M.change_path()
    vim.api.nvim_command("silent :cd " .. path)
end

M.set_window_path = function()
    local path = M.change_path()
    vim.api.nvim_command("silent :lcd " .. path)
end

return M
