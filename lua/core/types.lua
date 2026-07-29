-- Central type definitions for LVIM IDE.
-- Consumed by LuaLS for type checking and autocompletion across all modules.
-- Import in any file with: require("core.types") -- side-effect: registers classes
-- Or reference types directly in annotations without importing.

---@meta

-- ---------------------------------------------------------------------------
-- Paths & OS
-- ---------------------------------------------------------------------------

---@class LvimEfm
---@field filetypes string[]              File types handled by EFM
---@field settings  { languages: table<string, any> }  Per-language tool config

---@class LvimGlobal
---@field os           "mac"|"linux"|"unsupported"|"other"
---@field lvim_path    string   Absolute path to the nvim config directory
---@field cache_path   string   Absolute path to the nvim cache directory
---@field home         string   User home directory

-- ---------------------------------------------------------------------------
-- Color palette
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- Main _G.LVIM namespace
-- ---------------------------------------------------------------------------

---@class LvimNamespace
---@field nvim_version    table          Neovim version object (from vim.version())
---@field start_time      integer        Startup timestamp in ns (vim.uv.hrtime), for the dashboard load stat
---@field startup_ms      number|nil     Time-to-editor-ready in ms, frozen at UIEnter (dashboard stat)
---@field global          LvimGlobal     Runtime paths and OS information
---@field version         string         LVIM IDE version string
---@field settings        table          Runtime settings store (open-ended)
---@field keyshelper      boolean        Whether the key-hint panel (lvim-keys-helper) is enabled
---@field control_center_win integer|nil Window handle for the control center float
---@field _float_index    integer        Cycling index for focus_float_window

-- ---------------------------------------------------------------------------
-- Plugin system
-- ---------------------------------------------------------------------------

---@class LvimModule  Plugin specification consumed by the lvim-pack (vim.pack) loader
---@field commit?       string            Pinned commit hash (from snapshot)
---@field lazy?         boolean           Whether to defer loading
---@field event?        string|string[]   Load trigger events
---@field cmd?          string|string[]   Load trigger commands
---@field ft?           string|string[]   Load trigger file types
---@field keys?         table             Load trigger key specs
---@field priority?     integer           Load order priority (higher = earlier)
---@field opts?         table             Options passed to plugin setup()
---@field config?       function          Custom setup function
---@field build?        string|function   Post-install build step
---@field dependencies? string|string[]  Other plugins that must load first
---@field cond?         boolean|function  Conditional loading predicate
---@field branch?       string            Git branch to track

---@alias LvimSnapshot table<string, { commit: string }>

-- ---------------------------------------------------------------------------
-- Keymaps
-- ---------------------------------------------------------------------------

-- Tuple format used by funcs.keymaps():
--   [1] lhs    – left-hand side key sequence
--   [2] rhs    – right-hand side (string or function)
--   [3] desc?  – human-readable description
--   [4] opts?  – extra vim.keymap.set options (e.g. { expr = true })
---@alias LvimKeymap { [1]: string, [2]: string|function, [3]?: string, [4]?: table }

-- ---------------------------------------------------------------------------
-- Utilities
-- ---------------------------------------------------------------------------

---@class LvimHighlight
---@field bg string|nil   Background color in #rrggbb format, or nil if unset
---@field fg string|nil   Foreground color in #rrggbb format, or nil if unset

