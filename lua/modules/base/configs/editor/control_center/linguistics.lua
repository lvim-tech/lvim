-- Linguistics settings for the LVIM Control Center's General group.
--
-- The GLOBAL half of lvim-linguistics: spelling and the insert-mode keyboard layout as editor-wide
-- preferences, persisted in the control center's own database like every other setting here. A LIST
-- of settings, not a group: they are a section of General (see general.lua), which is where the rest
-- of the editor-wide preferences live.
--
-- The plugin keeps the other half — a per-directory override written to `.lvim/linguistics/config.json`
-- by `:LvimLinguistics` — which WINS over these values in the directory that carries it. That is why
-- each row hands its value to `lvim-linguistics.store` instead of applying it directly: the store
-- records the global layer and re-derives the effective config through the same fold the plugin uses
-- at startup (base -> global -> local), so a global change can never quietly override a project that
-- has settled its own.
--
-- `set` also persists, because a setting that defines `set` owns its own persistence in
-- control-center — `ctx.data:save` is the same database the automatic path would have written to.
-- On load (`on_init`) nothing is saved: the value came FROM the database.
--
---@module "modules.base.configs.editor.control_center.linguistics"

--- The plugin's store, or nil when lvim-linguistics is not installed.
---
--- The plugin loads on VeryLazy while this panel restores its database EAGERLY at startup, so a bare
--- `require` would run before the plugin is on the runtimepath and every stored value would be
--- dropped in silence. `lvim-pack.load_plugin` is the documented "I need it now" seam; it is a no-op
--- once the plugin is loaded.
---@return table?
local function store()
    local ok_pack, pack = pcall(require, "lvim-pack")
    if ok_pack and type(pack.load_plugin) == "function" then
        pack.load_plugin("lvim-linguistics", "control-center linguistics settings")
    end
    local ok, mod = pcall(require, "lvim-linguistics.store")
    if not ok then
        return nil
    end
    -- Hand the plugin THIS panel's database as the place its global layer persists, so the plugin's
    -- own `:LvimLinguistics` panel writes the same store these rows do — one set of global values,
    -- two ways in, instead of two half-truths. The instance is resolved at SAVE time: it does not
    -- exist yet while these groups are being built.
    mod.bind_global(function(key, value)
        local ok_cc, cc = pcall(require, "lvim-control-center")
        local inst = ok_cc and cc.get("LvimControlCenter")
        if inst and inst.data then
            inst.data:save(key, value)
        end
    end)
    return mod
end

--- The plugin's defaults — the fallback a row shows before anything has been stored.
---@return table
local function base()
    local ok, cfg = pcall(require, "lvim-linguistics.config")
    return (ok and cfg.base_config) or { spell = {}, mode_language = {} }
end

--- One row's current value: what the global layer holds, else the plugin default.
---@param key string
---@param fallback any
---@return any
local function current(key, fallback)
    local s = store()
    local v = s and s.get_global(key)
    if v ~= nil then
        return v
    end
    return fallback
end

--- Build a row's `set`: record the value in the global layer (which re-derives and applies it), and
--- persist it to this panel's database unless we are being restored FROM that database.
---@param key string
---@return fun(val: any, on_init: boolean, ctx: table)
local function setter(key)
    return function(val, on_init)
        local s = store()
        if not s then
            return
        end
        if on_init then
            s.set_global(key, val) -- restoring FROM the database; recording it is the whole job
        else
            s.save_global(key, val)
        end
    end
end

--- The spell languages the plugin has configured, for the dropdown. A FUNCTION so the list is read
--- when the panel opens rather than when this module is first required — the plugin may not be
--- loaded yet at that point.
---@return string[]
local function spell_languages()
    local langs = vim.tbl_keys(base().spell.languages or {})
    table.sort(langs)
    return langs
end

---@type table[]  Control Center settings, spliced into the General group
return {
    { name = "sep_linguistics", type = "spacer", label = "Linguistics" },
    {
        name = "spell_active",
        label = "Spelling",
        type = "bool",
        default = false,
        ---@return boolean
        get = function()
            return current("spell_active", base().spell.active == true) == true
        end,
        set = setter("spell_active"),
    },
    {
        name = "spell_language",
        label = "Spell language",
        type = "select",
        options = spell_languages,
        ---@return any
        get = function()
            return current("spell_language", base().spell.language or spell_languages()[1])
        end,
        set = setter("spell_language"),
    },
    {
        name = "mode_active",
        label = "Insert-mode layout",
        type = "bool",
        default = false,
        ---@return boolean
        get = function()
            return current("mode_active", base().mode_language.active == true) == true
        end,
        set = setter("mode_active"),
    },
    {
        name = "insert_mode_language",
        label = "Insert language",
        type = "select",
        options = function()
            return base().mode_language.insert_mode_languages or {}
        end,
        -- Nothing to choose when no layouts are configured.
        enabled = function()
            return #(base().mode_language.insert_mode_languages or {}) > 0
        end,
        ---@return any
        get = function()
            local langs = base().mode_language.insert_mode_languages or {}
            return current("insert_mode_language", base().mode_language.insert_mode_language or langs[1])
        end,
        set = setter("insert_mode_language"),
    },
}
