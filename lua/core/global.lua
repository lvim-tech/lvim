local home = os.getenv("HOME")
local os_name = vim.loop.os_uname().sysname

local global = {}

local os
if os_name == "Darwin" then
    os = "mac"
elseif os_name == "Linux" then
    os = "linux"
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
    self.snapshot_path = home .. "/.config/nvim/.snapshots"
    self.modules_path = home .. "/.config/nvim/lua/modules"
    self.global_config = home .. "/.config/nvim/lua/config/global"
    self.custom_config = home .. "/.config/nvim/lua/config/custom"
    self.home = home
    self.mason_path = home .. "/.local/share/nvim/mason"
    self.languages = {}
    self.efm = false
    self.lvim_packages = false
    self.install_proccess = false
    self.tm_augroup = vim.api.nvim_create_augroup("ClueStatus", {
        clear = true,
    })
end

global:load_variables()

return global
