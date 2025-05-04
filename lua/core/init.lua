local home = os.getenv("HOME")

local function getOS()
    if jit then
        return jit.os
    end
    local fh, _ = assert(io.popen("uname -o 1>/dev/null", "r"))
    if fh then
        Osname = fh:read()
    end
    return Osname or "Windows"
end

local os_name = getOS()
local os

if os_name == "OSX" then
    os = "mac"
elseif os_name == "Linux" then
    os = "linux"
elseif os_name == "Windows" then
    os = "unsuported"
else
    os = "other"
end

-- Инициализирам глобалната таблица
local global = {
    os = os,
    lvim_path = home .. "/.config/nvim",
    cache_path = home .. "/.cache/nvim",
    packer_path = home .. "/.local/share/nvim/site",
    snapshot_path = home .. "/.config/nvim/.snapshots",
    modules_path = home .. "/.config/nvim/lua/modules",
    global_config = home .. "/.config/nvim/lua/config/global",
    custom_config = home .. "/.config/nvim/lua/config/custom",
    home = home,
    mason_path = home .. "/.local/share/nvim/mason",
    efm = {
        filetypes = {},
        settings = { languages = {} },
    }
}

-- Глобално достъпна променлива за EFM и други модули
_G.global = global

-- Проверка дали ОС е поддържана
if global.os == "unsuported" then
    print("Your OS is not supported!")
else
    -- Инициализация на основните компоненти
    local funcs = require("core.funcs")
    _G.LVIM_SNAPSHOT = funcs.get_snapshot()
    
    -- Настройка на leader клавиш
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    vim.keymap.set("n", " ", "", { noremap = true })
    vim.keymap.set("x", " ", "", { noremap = true })
    
    -- Зареждане на конфигурацията
    _G.LVIM_SETTINGS = funcs.read_file(global.lvim_path .. "/.configs/lvim/config.json")
    
    -- Инициализация и зареждане на плъгините
    local lazy = require("core.lazy")
    lazy.is_lazy()
    funcs.configs()
    lazy.load()
end

return global
