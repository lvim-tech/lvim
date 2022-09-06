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
    self.lvim_path = home .. "/.config/nvim"
    self.cache_path = home .. "/.cache/nvim"
    self.packer_path = home .. "/.local/share/nvim/site"
    self.snapshot_path = home .. "/.config/nvim/.snapshots/"
    self.modules_path = home .. "/.config/nvim/lua/modules"
    self.global_config = home .. "/.config/nvim/lua/config/global"
    self.custom_config = home .. "/.config/nvim/lua/config/custom"
    self.home = home
    self.mason_path = home .. "/.local/share/nvim/mason"
    self.languages = {}
    self.lvim_packages = false
    self.install_proccess = false
end

global:load_variables()

return global
