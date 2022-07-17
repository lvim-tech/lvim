local global = {}

local home = os.getenv("HOME")
local os_name = vim.loop.os_uname().sysname
local lvim_path = vim.fn.stdpath("config")
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
    self.lvim_path = lvim_path
    self.cache_path = home .. "/.cache/nvim/"
    self.modules_path = lvim_path .. "/lua/modules"
    self.global_config = lvim_path .. "/lua/config/global/"
    self.custom_config = lvim_path .. "/lua/config/custom/"
    self.home = home
    self.mason_path = string.format("%s/mason/", vim.fn.stdpath("data"))
    self.languages = {}
    self.lvim_packages = false
    self.install_proccess = false
end

global:load_variables()

return global
