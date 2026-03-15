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
---@field os           "mac"|"linux"|"unsuported"|"other"
---@field lvim_path    string   Absolute path to the nvim config directory
---@field cache_path   string   Absolute path to the nvim cache directory
---@field snapshot_path string  Absolute path to the plugin snapshots directory
---@field modules_path string   Absolute path to the Lua modules directory
---@field home         string   User home directory
---@field mason_path   string   Absolute path to the Mason packages directory
---@field efm          LvimEfm  EFM language server aggregated configuration

-- ---------------------------------------------------------------------------
-- Color palette
-- ---------------------------------------------------------------------------

---@class LvimColors
---@field bg         string   Base background color (#rrggbb)
---@field fg         string   Base foreground color (#rrggbb)
---@field bg_dark    string   Darkened background (used for winbar, floats)
---@field bg_float   string   Background for floating windows
---@field gray       string   Neutral gray (NonText fg)
---@field fg_light   string   Lightened foreground for secondary text
---@field blue       string   Primary accent (functions)
---@field green      string   Success / strings
---@field orange     string   Constants / warnings
---@field red        string   Errors / deletions
---@field cyan       string   Special tokens
---@field purple     string   Statements / keywords
---@field blue_bh    string   Blue blended at 10% opacity over bg
---@field blue_bl    string   Blue blended at 30% opacity over bg
---@field green_bh   string   Green blended at 10% opacity over bg
---@field green_bl   string   Green blended at 30% opacity over bg
---@field orange_bh  string   Orange blended at 10% opacity over bg
---@field orange_bl  string   Orange blended at 30% opacity over bg
---@field red_bh     string   Red blended at 10% opacity over bg
---@field red_bl     string   Red blended at 30% opacity over bg
---@field cyan_bh    string   Cyan blended at 10% opacity over bg
---@field cyan_bl    string   Cyan blended at 30% opacity over bg
---@field purple_bh  string   Purple blended at 10% opacity over bg
---@field purple_bl  string   Purple blended at 30% opacity over bg
---@field diag_error string   Diagnostic error color
---@field diag_warn  string   Diagnostic warning color
---@field diag_hint  string   Diagnostic hint color
---@field diag_info  string   Diagnostic info color
---@field git_add    string   Git added lines color
---@field git_change string   Git changed lines color
---@field git_delete string   Git deleted lines color
---@field yellow     string   Yellow accent (used for fold icons, warnings)
---@field red_01     string   Lighter red variant (used in heirline recording indicator)
---@field green_01   string   Lighter green variant (used in heirline recording text)

-- ---------------------------------------------------------------------------
-- Git status (populated by heirline git component)
-- ---------------------------------------------------------------------------

---@class LvimGitHead
---@field branch string|nil   Full branch name (nil when in detached HEAD)
---@field abbrev string|nil   Abbreviated commit SHA shown alongside branch

---@class LvimGit
---@field head    LvimGitHead  Branch and commit info from the git backend
---@field added   integer      Number of added lines
---@field changed integer      Number of changed lines
---@field removed integer      Number of removed lines

-- ---------------------------------------------------------------------------
-- Main _G.LVIM namespace
-- ---------------------------------------------------------------------------

---@class LvimNamespace
---@field nvim_version    table          Neovim version object (from vim.version())
---@field global          LvimGlobal     Runtime paths and OS information
---@field colors          LvimColors     Extracted theme color palette
---@field theme           string         Active colorscheme name
---@field version         string         LVIM IDE version string
---@field snapshot        string         Active plugin snapshot name
---@field settings        table          Runtime settings store (open-ended)
---@field keyshelper      boolean        Whether which-key helper is enabled
---@field file_types      table<string, string[]>  Merged filetype → extensions map
---@field mode            string         Current Vim mode character (set by heirline)
---@field git             LvimGit|nil    Current buffer git status (set by heirline git component)
---@field control_center_win integer|nil Window handle for the control center float
---@field _float_index    integer        Cycling index for focus_float_window

-- ---------------------------------------------------------------------------
-- Plugin system
-- ---------------------------------------------------------------------------

---@class LvimModule  Plugin specification passed to lazy.nvim
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

---@class LvimFileSizeOptions
---@field bits?     boolean                              Report in bits instead of bytes
---@field unix?     boolean                              Use short single-char suffixes
---@field base?     integer                              Base 2 (1024) or base 10 (1000)
---@field round?    integer                              Decimal places
---@field spacer?   string                               Separator between number and unit
---@field suffixes? table<string, string>                Override suffix labels
---@field output?   "string"|"array"|"exponent"|"object" Return format
---@field exponent? integer                              Force a specific unit exponent

---@class LvimCommentEdit  Internal structure used during remove_comments
---@field row       integer   Zero-based buffer row of the edit
---@field start_col integer   Start column of the comment token
---@field end_col   integer   End column of the comment token
---@field type      "partial" Always "partial" for inline comments
