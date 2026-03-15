-- Core bootstrap module.
-- Detects the OS, populates _G.LVIM.global with runtime paths, reads
-- user preferences from config files, then kicks off the plugin manager.
local home = os.getenv("HOME") or ""

-- Detects the operating system via LuaJIT's jit.os field when available,
-- falling back to `uname` for non-JIT environments.
---@return string  Raw OS name as reported by jit or uname
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
---@type "mac"|"linux"|"unsuported"|"other"
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

---@type LvimGlobal
local global = {
    os           = os,
    lvim_path    = home .. "/.config/nvim",
    cache_path   = home .. "/.cache/nvim",
    snapshot_path = home .. "/.config/nvim/.snapshots",
    modules_path = home .. "/.config/nvim/lua/modules",
    home         = home,
    mason_path   = home .. "/.local/share/nvim/mason",
    efm = {
        filetypes = {},
        settings  = { languages = {} },
    },
}

_G.LVIM.global = global
-- Backwards-compatible alias — modules/user/ still references _G.global
_G.global = _G.LVIM.global

if global.os == "unsuported" then
    print("Your OS is not supported!")
else
    local funcs = require("core.funcs")
    local lazy  = require("core.lazy")

    -- Space is the leader key; disable its default behaviour in normal/visual mode
    -- so it never triggers accidentally while a chord is being typed
    vim.g.mapleader      = " "
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

    _G.LVIM.theme      = read_file_default(_G.LVIM.global.lvim_path .. "/.configs/lvim/.theme",     "lvim-darker")
    _G.LVIM.keyshelper = read_file_default(_G.LVIM.global.lvim_path .. "/.configs/lvim/.keyshelper", true)
    _G.LVIM.version    = read_file_default(_G.LVIM.global.lvim_path .. "/.version",                  true)

    -- Backwards-compatible flat aliases for external code (e.g. modules/user/)
    -- that still references the old _G.LVIM_* naming convention
    _G.LVIM_SNAPSHOT   = _G.LVIM.snapshot
    _G.LVIM_THEME      = _G.LVIM.theme
    _G.LVIM_KEYSHELPER = _G.LVIM.keyshelper
    _G.LVIM_VERSION    = _G.LVIM.version
    _G.LVIM_SETTINGS   = _G.LVIM.settings
    -- _G.LVIM_COLORS is set after ColorScheme fires (configs/base/init.lua),
    -- but the alias must exist on _G so LuaLS and modules/user/ can reference it
    _G.LVIM_COLORS     = _G.LVIM.colors

    funcs.configs()   -- execute all merged config functions
    lazy.is_lazy()    -- ensure lazy.nvim is installed
    lazy.load()       -- register and load all plugins
end

return global
