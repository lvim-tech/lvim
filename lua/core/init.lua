-- Core bootstrap module.
-- Detects the OS, populates _G.LVIM.global with runtime paths, reads
-- user preferences from config files, then kicks off the plugin manager.
local home = os.getenv("HOME") or ""

-- Detects the operating system via LuaJIT's jit.os field.
---@return string  Raw OS name as reported by jit
local function getOS()
    return jit.os
end

local os_name = getOS()
---@type "mac"|"linux"|"unsupported"|"other"
local os

if os_name == "OSX" then
    os = "mac"
elseif os_name == "Linux" then
    os = "linux"
elseif os_name == "Windows" then
    os = "unsupported"
else
    os = "other"
end

---@type LvimGlobal
local global = {
    os = os,
    lvim_path = home .. "/.config/nvim",
    cache_path = home .. "/.cache/nvim",
    snapshot_path = home .. "/.config/nvim/.snapshots",
    modules_path = home .. "/.config/nvim/lua/modules",
    home = home,
    mason_path = home .. "/.local/share/nvim/mason",
    efm = {
        filetypes = {},
        settings = { languages = {} },
    },
}

_G.LVIM.global = global
-- Backwards-compatible alias — modules/user/ still references _G.global
_G.global = _G.LVIM.global

if global.os == "unsupported" then
    print("Your OS is not supported!")
else
    local funcs = require("core.funcs")
    local lazy = require("core.lazy")

    -- Space is the leader key; disable its default behaviour in normal/visual mode
    -- so it never triggers accidentally while a chord is being typed
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    vim.keymap.set("n", " ", "", { noremap = true })
    vim.keymap.set("x", " ", "", { noremap = true })

    -- Read the active snapshot name from the cache file written by the IDE
    local snapshot = funcs.read_file(global.cache_path .. "/.lvim_snapshot")
    if type(snapshot) == "table" then
        _G.LVIM.snapshot = snapshot.snapshot
    else
        _G.LVIM.snapshot = "default"
    end
    _G.LVIM.settings = {}

    -- Helper: read a file and return its value, or `default` when absent
    ---@param path    string  Absolute file path
    ---@param default any     Fallback value
    ---@return any
    local function read_file_default(path, default)
        local val = funcs.read_file(path)
        return val ~= nil and val or default
    end

    _G.LVIM.theme = read_file_default(_G.LVIM.global.lvim_path .. "/.configs/lvim/.theme", "lvim-darker")
    _G.LVIM.keyshelper = read_file_default(_G.LVIM.global.lvim_path .. "/.configs/lvim/.keyshelper", true)
    _G.LVIM.version = read_file_default(_G.LVIM.global.lvim_path .. "/.version", true)

    funcs.configs() -- execute all merged config functions
    lazy.is_lazy() -- ensure lazy.nvim is installed
    lazy.load() -- register and load all plugins
end

return global
