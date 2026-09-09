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

-- Paths come from `vim.fn.stdpath`, NOT from `$HOME .. "/.config/nvim"`: stdpath is the only
-- resolver that honours NVIM_APPNAME (`NVIM_APPNAME=nvim-lvim nvim` → `~/.config/nvim-lvim`) as
-- well as XDG_CONFIG_HOME / XDG_CACHE_HOME. With the path hardcoded, an install in any directory
-- other than `~/.config/nvim` read its `.snapshots`, `.version` and `.configs` from a foreign
-- directory — the snapshot came back empty and the plugin loader never started.
---@type LvimGlobal
local global = {
    os = os,
    lvim_path = vim.fn.stdpath("config"),
    cache_path = vim.fn.stdpath("cache"),
    home = home,
}

_G.LVIM.global = global

if global.os == "unsupported" then
    print("Your OS is not supported!")
else
    local funcs = require("core.funcs")

    -- Space is the GLOBAL leader; comma is the LOCAL leader. Keeping them distinct means
    -- `<leader>…` and `<localleader>…` never resolve to the same keystroke, so buffer-local
    -- panel keys (e.g. lvim-rest's editor `,r`/`,s`) can't collide with the `<leader>r…`
    -- command prefix. Space's default motion is disabled so it never triggers accidentally
    -- while a chord is being typed; comma keeps its default (backward f/t repeat).
    vim.g.mapleader = " "
    vim.g.maplocalleader = ","
    vim.keymap.set("n", " ", "", { noremap = true })
    vim.keymap.set("x", " ", "", { noremap = true })

    -- The active version snapshot is read on demand via funcs.read_snapshot()
    -- (<config>/.snapshots/active) — no global state.
    _G.LVIM.settings = {}

    -- Helper: read a file and return its value, or `default` when absent
    ---@param path    string  Absolute file path
    ---@param default any     Fallback value
    ---@return any
    local function read_file_default(path, default)
        local val = funcs.read_file(path)
        -- Explicit nil check: `val ~= nil and val or default` would wrongly return the
        -- default for a legitimately stored `false` (e.g. a disabled keyshelper).
        if val ~= nil then
            return val
        end
        return default
    end

    -- The active theme is OWNED by lvim-colorscheme (it restores + applies + persists it
    -- itself, in sync with control-center's DB). No `_G.LVIM.theme` global, no `.theme` read
    -- here. The install panel reads the plugin's own mirror file (lvim-installer's bootstrap)
    -- for the rare case it paints before the plugin loads.
    _G.LVIM.keyshelper = read_file_default(_G.LVIM.global.lvim_path .. "/.configs/lvim/.keyshelper", true)
    _G.LVIM.version = read_file_default(_G.LVIM.global.lvim_path .. "/.version", true)

    funcs.configs() -- execute all merged config functions

    -- Bootstrap lvim-pack (the plugin loader): clone it when it is not there, put it on the
    -- runtimepath, and hand it the spec. Everything below this point is plugin-managed — the
    -- loader itself, the dependency resolver, the install panel and the build hooks.
    --
    -- It is deliberately the INSTALLED copy, not a local checkout: the loader is the one plugin
    -- that cannot be swapped at runtime (it has already answered `require` by the time any dev
    -- override is read), so pointing this at `~/lvim-tech/lvim-pack` would silently make every
    -- "clean install" test run the working tree instead. To develop the loader itself, point
    -- `pack_dir` at the checkout here, on purpose.
    local pack_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/lvim-pack"
    if not vim.uv.fs_stat(pack_dir) then
        local out = vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/lvim-tech/lvim-pack",
            pack_dir,
        })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({ { "lvim-pack clone failed:\n" .. out, "ErrorMsg" } }, true, {})
        end
    end
    vim.opt.rtp:prepend(pack_dir)

    require("lvim-pack").setup({
        -- The spec source: this distribution's base layer with the user layer merged over it.
        -- A function, so it is built when the loader asks rather than when it is configured.
        spec = function()
            return funcs.merge(vim.deepcopy(require("modules.base")), require("modules.user"))
        end,
        -- Version pins come from the active snapshot; a plugin absent from it tracks HEAD.
        pin = (function()
            local snap = funcs.read_snapshot()
            return function(name)
                return funcs.get_commit(name, snap)
            end
        end)(),
        -- Only this process can measure its own start; the loader freezes the stat at UIEnter and
        -- serves it through `require("lvim-pack").stats()`.
        start_time = _G.LVIM.start_time,
    })
end

return global
