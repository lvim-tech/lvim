-- Appearance settings group for the LVIM Control Center.
-- Exposes a "colorscheme" select (its options come live from lvim-colorscheme, so the list
-- never goes stale) and a "floatheight" select.
--
-- Theme persistence is owned by lvim-colorscheme itself (setup with `remember = true`): it
-- saves every committed theme change to its store (this same DB, shared `colorscheme` key) and
-- a mirror file, and restores + applies the last theme on startup. This panel only APPLIES a
-- chosen theme; it neither persists nor restores it.

---@module "modules.base.configs.editor.control_center.appearance"

local icons = require("configs.base.ui.icons")

-- Live list of every lvim colorscheme (falls back to a small set if the plugin is missing).
local function colorscheme_options()
    local ok, lcs = pcall(require, "lvim-colorscheme")
    if ok and type(lcs.colorschemes) == "function" then
        local list = lcs.colorschemes()
        if type(list) == "table" and #list > 0 then
            return list
        end
    end
    return { "lvim-soft", "lvim-dark", "lvim-darker", "lvim-light" }
end

-- Build control-center rows for EVERY lvim-colorscheme config-panel setting, grouped with a
-- text-separator spacer per section (Background / Focus / Syntax). Each row reads and writes
-- through `lvim-colorscheme.settings`, which applies live AND persists to the shared store
-- (this control-center's database) — so this tab and `:LvimColorschemeConfig` stay in sync.
---@return table[]
local function lcs_settings()
    local ok, S = pcall(require, "lvim-colorscheme.settings")
    if not ok then
        return {}
    end
    local rows, group = {}, nil
    for _, spec in ipairs(S.specs) do
        if spec.group ~= group then
            group = spec.group
            rows[#rows + 1] = { name = "lcs_sep_" .. group, type = "spacer", label = group }
        end
        rows[#rows + 1] = {
            name = spec.name,
            label = spec.label,
            type = spec.type,
            options = spec.options,
            -- lvim-colorscheme OWNS these settings' startup restore (remember = true → settings.restore() applies
            -- them ALL in ONE reload). Skip the control-center's per-setting restore here — otherwise each one
            -- re-applies via S.set → a full highlight reload (~7ms × N) on top. Live editing from the panel still
            -- works through set(); only the redundant startup re-restore is suppressed.
            break_load = true,
            ---@return any
            get = function()
                return S.get(spec)
            end,
            ---@param val     any
            ---@param on_init boolean
            set = function(val, on_init)
                S.set(spec, val, not on_init) -- persist only on a user change, not on startup
            end,
            -- Mark a setting inert when it can't apply in the current config (dimmed + struck,
            -- value preserved): "transparent" sidebar/float while global transparency is off,
            -- darken-active while transparency is on, and either strength select while its own
            -- feature toggle is off. Evaluated live, so it tracks the parent toggles.
            -- The predicate is handed the ROW, not the value — passing the row straight into
            -- `value_disabled` (which compares against a VALUE) silently never matched, so none
            -- of these ever rendered inert.
            ---@param row table
            ---@return boolean
            disabled = function(row)
                return S.value_disabled(spec, row.value)
            end,
        }
    end
    return rows
end

--- Return true when the control-center floating window is the currently focused
--- window, false in every other case (invalid handle, different window focused).
---@param win integer|nil  Window handle to test
---@return boolean
local function is_control_center_focused(win)
    if not win or not vim.api.nvim_win_is_valid(win) then
        return false
    end
    return vim.api.nvim_get_current_win() == win
end

-- Fixed top of the Appearance tab (the theme picker); lvim-colorscheme's own config settings are
-- appended to it by `settings()` below.
local fixed = {
    { name = "sep_main", type = "spacer", label = "Main" },
    -- -----------------------------------------------------------------
    -- Colorscheme selector (options come live from lvim-colorscheme)
    -- -----------------------------------------------------------------
    {
        name = "colorscheme",
        label = "Colorscheme",
        desc = "Active lvim-colorscheme variant",
        type = "select",
        -- The FUNCTION, not its result: this module is required while lvim-control-center loads,
        -- which is BEFORE lvim-colorscheme (the colorscheme depends on the control center), so
        -- calling it here captured the 4-entry fallback and the picker showed 4 of 48 themes
        -- forever. Control-center evaluates it when the panel opens.
        options = colorscheme_options,
        default = "lvim-darker",
        -- Close the panel before applying: loading a theme redraws the whole UI.
        break_load = true,
        ---@return string  The actually-active colorscheme (canonical dash-form name)
        get = function()
            local ok, lcs = pcall(require, "lvim-colorscheme")
            return (ok and lcs.current()) or "lvim-darker"
        end,
        ---@param val string  New colorscheme name chosen by the user
        set = function(val)
            -- Applying fires `User LvimColorscheme` (preview = false); lvim-colorscheme's own
            -- `remember` listener persists it (store + mirror) — no manual save needed here.
            vim.cmd("colorscheme " .. val)
            ---@diagnostic disable-next-line: undefined-field
            -- Hide the hardware cursor inside the control center to avoid a visible
            -- blinking cursor over the floating window content.
            if _G.LVIM.control_center_win and is_control_center_focused(_G.LVIM.control_center_win) then
                vim.cmd("hi Cursor blend=100")
            else
                vim.cmd("hi Cursor blend=0")
            end
        end,
    },
    -- (The old "Float height" select moved to the control center's "Utils" tab — the centralized dock geometry
    -- (float/area/bottom sizes + backdrop) in lvim-utils.config.dock.geometry, defined in control_center/geometry.lua.)
}

--- The tab's rows, BUILT WHEN THE PANEL OPENS.
---
--- This module is required while lvim-control-center loads — which is BEFORE lvim-colorscheme,
--- because the colorscheme declares the control center as a dependency (it builds its own settings
--- panel from it). So `lvim-colorscheme.settings` was not loadable at this module's top level:
--- `lcs_settings()` returned an empty list, it was appended once, and the Appearance tab showed
--- 2 rows instead of 16 for the rest of the session. A function is evaluated at open time, when
--- every plugin is loaded.
---@return table[]
local function settings()
    local rows = vim.list_slice(fixed, 1, #fixed)
    vim.list_extend(rows, lcs_settings())
    return rows
end

---@type table  Control Center settings group descriptor for appearance options
return {
    name = "appearance",
    label = "Appearance",
    icon = icons.common.palette,
    settings = settings,
}
