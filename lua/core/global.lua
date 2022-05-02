local global = {}

local home = os.getenv("HOME")
local os_name = vim.loop.os_uname().sysname
local vim_path = vim.fn.stdpath("config")
local os
if os_name == "Darwin" then
    os = "macOS"
elseif os_name == "Linux" then
    os = "Linux"
elseif os_name == "Windows" then
    os = "unsuported"
else
    os = "other"
end

function global:load_variables()
    self.os = os
    self.vim_path = vim_path
    self.cache_path = home .. "/.cache/nvim/"
    self.modules_path = vim_path .. "/lua/modules"
    self.global_config = vim_path .. "/lua/config/global/"
    self.custom_config = vim_path .. "/lua/config/custom/"
    self.languages_path = vim_path .. "/lua/languages/global/languages/"
    self.lsp_languages = vim_path .. "/lua/lsp/languages/"
    self.home = home
    self.data_path = string.format("%s/site/", vim.fn.stdpath("data"))
    self.lsp_path = string.format("%s/", vim.fn.stdpath("data"))
    self.languages = {}
    self.current_cwd = vim.fn.getcwd()
    self.diagnostics = {}
    self.virtual_text = "no"
    self.pack_installer = nil
end

global:load_variables()

return global
