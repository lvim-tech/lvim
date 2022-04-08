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

return M
