local global = {}
local home = os.getenv("HOME")
-- local path_sep = global.is_windows and '\\' or '/'
local path_sep = package.config:sub(1, 1)
local os_name = vim.loop.os_uname().sysname

function global:load_variables()
    self.is_mac = os_name == "Darwin"
    self.is_linux = os_name == "Linux"
    self.is_windows = os_name == "Windows"
    self.vim_path = vim.fn.stdpath("config")
    self.cache_path = home .. path_sep .. ".cache" .. path_sep .. "nvim" .. path_sep
    self.modules_path = self.vim_path .. path_sep .. "lua" .. path_sep .. "modules"
    self.global_config = self.vim_path .. path_sep .. "lua" .. path_sep .. "config" .. path_sep .. "global" .. path_sep
    self.custom_config = self.vim_path .. path_sep .. "lua" .. path_sep .. "config" .. path_sep .. "custom" .. path_sep
    self.lsp_languages = self.vim_path .. path_sep .. "lua" .. path_sep .. "lsp" .. path_sep .. "languages" .. path_sep
    self.path_sep = path_sep
    self.home = home
    self.data_path = string.format("%s" .. path_sep .. "site" .. path_sep, vim.fn.stdpath("data"))
    self.lsp_path = string.format("%s" .. path_sep, vim.fn.stdpath("data"))
end

global:load_variables()

return global
