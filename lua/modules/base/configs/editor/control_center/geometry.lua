-- modules.base.configs.editor.control_center.geometry: the "Utils" Control Center tab —
-- the centralized DOCK surface geometry (float / area / bottom sizes) and the per-layout
-- backdrop (dim / darken). Formerly read the shared lvim-ui `config.size` / `config.backdrop`;
-- those were REMOVED when geometry was centralized into `lvim-utils.config.dock.geometry` (the
-- single authority every dock consumer + surface now resolves through `dock.slot(layout)`).
--
-- Every row reads and writes the LIVE `require("lvim-utils.config").dock.geometry` table in place
-- (the same table `dock.slot(layout)` reads), so a change takes effect on the next opened surface.
-- The backdrop now lives NESTED under each layout (`geometry.<layout>.backdrop`), not in a separate
-- root. Persistence goes through the OWNING instance's store (`ctx.data`, injected into set) under
-- the SAME keys the old panel used (`ui_size_*` / `ui_backdrop_*`), so existing saved values carry
-- over untouched. Startup restore is automatic: the instance's `apply_saved_settings()` calls each
-- row's `set` with the persisted value, which writes it back into `config.dock.geometry`.
--
---@module "modules.base.configs.editor.control_center.geometry"

-- The discrete size fractions, ASCENDING (strings): the form engine cycles <CR> FORWARD /
-- <BS> backward, so ascending means <CR> INCREASES the size.
local SIZE_OPTIONS = { "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0" }

-- Backdrop MODE per layout: "darken" (fg+bg toward black) / "dim" (fg muted, lighter).
local BACKDROP_MODE_OPTIONS = { "darken", "dim" }

---@type string[]
local BACKDROP_AMOUNT_OPTIONS = {}
for i = 1, 9 do
    BACKDROP_AMOUNT_OPTIONS[i] = tostring(i / 10)
end

--- The live `config.dock.geometry` table (the single geometry authority), created if missing.
--- Both the size rows and the (now nested) backdrop rows resolve their paths against THIS table.
---@return table
local function geom_tbl()
    local dock = require("lvim-utils.config").dock
    dock.geometry = dock.geometry or {}
    return dock.geometry
end

--- Read a nested value by path.
---@param t table
---@param path string[]
---@return any
local function read_path(t, path)
    for _, k in ipairs(path) do
        if type(t) ~= "table" then
            return nil
        end
        t = t[k]
    end
    return t
end

--- Write a nested value by path (creating intermediate tables).
---@param t table
---@param path string[]
---@param v any
local function write_path(t, path, v)
    for i = 1, #path - 1 do
        t[path[i]] = t[path[i]] or {}
        t = t[path[i]]
    end
    t[path[#path]] = v
end

--- Option string → the numeric fraction the config holds ("0.8" → 0.8).
---@param v any
---@return any
local function decode(v)
    return tonumber(v) or v
end

--- Numeric value → the option string the panel / store use. A whole number has two candidate
--- forms — trimmed FRACTION ("1.0") and bare INTEGER ("1"); when `options` is given, return
--- whichever IS a real option so a select always round-trips.
---@param v any
---@param options? string[]
---@return any
local function encode(v, options)
    if v == nil then
        return v
    end
    if type(v) ~= "number" then
        return tostring(v)
    end
    local frac = (("%.2f"):format(v):gsub("0$", ""):gsub("%.$", ""))
    local int = (v == math.floor(v)) and tostring(math.floor(v)) or nil
    if options then
        for _, o in ipairs(options) do
            if o == int or o == frac then
                return o
            end
        end
    end
    return int or frac
end

--- Propagate a changed setting to the LIVE UI. The `area` height feeds the msgarea zone's reserve
--- cap, so refresh an open zone; a backdrop change re-applies any open backdrop through the shared
--- applier. Both guarded — a missing plugin is fine.
---@param spec GeometrySpec
local function apply(spec)
    if spec.root == "size" and spec.path[1] == "area" then
        pcall(function()
            local ma = require("lvim-msgarea")
            if ma.refresh then
                ma.refresh()
            end
        end)
    elseif spec.root == "backdrop" then
        pcall(function()
            local dim = require("lvim-utils.dim")
            if dim.refresh_backdrop then
                dim.refresh_backdrop()
            end
        end)
    end
end

---@class GeometrySpec
---@field name     string     persistence key (== the old panel key)
---@field root     string     "size" | "backdrop" — only a tag now (both live under dock.geometry)
---@field path     string[]   nested location under `config.dock.geometry`
---@field label    string     display label
---@field type     "select"|"bool"
---@field options? string[]   choices (select only)
---@field disabled? fun(): boolean  render the row dimmed + struck through, evaluated LIVE

--- The current value of `spec`: a BOOLEAN for `bool` specs, else the fraction as an OPTION STRING.
---@param spec GeometrySpec
---@return any
local function spec_get(spec)
    local v = read_path(geom_tbl(), spec.path)
    if spec.type == "bool" then
        return v == true
    end
    return encode(v, spec.options)
end

--- Apply a new value LIVE into `config.dock.geometry` and (unless restoring) persist it through the
--- instance's own store (`ctx.data`), so the same group works in any control-center instance.
---@param spec GeometrySpec
---@param value any
---@param is_load boolean  true while control-center restores a persisted value on startup
---@param ctx LvimControlCenterCtx  the owning instance's context (nil-safe on load)
local function spec_set(spec, value, is_load, ctx)
    local resolved
    if spec.type == "bool" then
        resolved = value == true or value == "true" or value == 1
    else
        resolved = decode(value)
    end
    write_path(geom_tbl(), spec.path, resolved)
    if not is_load and ctx and ctx.data then
        ctx.data:save(spec.name, resolved)
    end
    apply(spec)
end

--- Backdrop specs for one layout: an `enabled` toggle, a `mode` selector, and BOTH modes'
--- `amount` — each amount row DISABLED (inert) unless ITS mode is the live one, so the two
--- modes are tuned independently and flipping `mode` swaps which amount lights up. The backdrop
--- now lives NESTED under the layout: `config.dock.geometry.<layout>.backdrop`.
---@param layout string
---@return GeometrySpec[]
local function backdrop_specs(layout)
    local cap = layout:sub(1, 1):upper() .. layout:sub(2)
    local function bd()
        local g = require("lvim-utils.config").dock.geometry[layout] or {}
        return g.backdrop or {}
    end
    local function is_off()
        return bd().enabled == false
    end
    return {
        {
            name = "ui_backdrop_" .. layout .. "_enabled",
            root = "backdrop",
            path = { layout, "backdrop", "enabled" },
            label = cap .. " backdrop",
            type = "bool",
        },
        {
            name = "ui_backdrop_" .. layout .. "_mode",
            root = "backdrop",
            path = { layout, "backdrop", "mode" },
            label = cap .. " mode",
            type = "select",
            options = BACKDROP_MODE_OPTIONS,
            disabled = is_off,
        },
        {
            name = "ui_backdrop_" .. layout .. "_dim_amount",
            root = "backdrop",
            path = { layout, "backdrop", "dim", "amount" },
            label = cap .. " dim amount",
            type = "select",
            options = BACKDROP_AMOUNT_OPTIONS,
            disabled = function()
                return is_off() or bd().mode ~= "dim"
            end,
        },
        {
            name = "ui_backdrop_" .. layout .. "_darken_amount",
            root = "backdrop",
            path = { layout, "backdrop", "darken", "amount" },
            label = cap .. " darken amount",
            type = "select",
            options = BACKDROP_AMOUNT_OPTIONS,
            disabled = function()
                return is_off() or bd().mode ~= "darken"
            end,
        },
    }
end

--- The SIZE + BEHAVIOUR specs for one layout, in display order: dimensions first (auto + fraction),
--- then the open-behaviour toggles. Only the free-floating FLOAT has a width axis; the docked
--- area/bottom are ALWAYS full-width (no width row at all). The `name` keys are the SAME as the old
--- list, so persisted values carry over untouched.
---@param layout string
---@return GeometrySpec[]
local function size_specs(layout)
    local cap = layout:sub(1, 1):upper() .. layout:sub(2)
    local rows = {
        {
            name = "ui_size_" .. layout .. "_height_auto",
            root = "size",
            path = { layout, "height_auto" },
            label = cap .. " height auto (fit)",
            type = "bool",
        },
        {
            name = "ui_size_" .. layout .. "_height",
            root = "size",
            path = { layout, "height" },
            label = cap .. " height",
            type = "select",
            options = SIZE_OPTIONS,
        },
    }
    -- The float is free-floating in BOTH axes; the docked area/bottom are always full-width, so they
    -- carry NO width row (width lives only on float in config.dock.geometry).
    if layout == "float" then
        rows[#rows + 1] = {
            name = "ui_size_float_width_auto",
            root = "size",
            path = { "float", "width_auto" },
            label = "Float width auto (fit)",
            type = "bool",
        }
        rows[#rows + 1] = {
            name = "ui_size_float_width",
            root = "size",
            path = { "float", "width" },
            label = "Float width",
            type = "select",
            options = SIZE_OPTIONS,
        }
    end
    rows[#rows + 1] = {
        name = "ui_size_" .. layout .. "_auto_hide",
        root = "size",
        path = { layout, "auto_hide" },
        label = cap .. " auto hide on open",
        type = "bool",
    }
    -- Only the docked surfaces (area/bottom) can keep focus in the source after opening; a float
    -- always takes focus, so it has no such toggle.
    if layout ~= "float" then
        rows[#rows + 1] = {
            name = "ui_size_" .. layout .. "_keep_focus",
            root = "size",
            path = { layout, "keep_focus" },
            label = cap .. " keep focus after open",
            type = "bool",
        }
    end
    return rows
end

--- Convert a GeometrySpec into a Control Center row. `default` is the LIVE dock.geometry value
--- (via spec_get), NOT a hardcoded literal — config.dock.geometry is the single source of truth, so
--- a value set in your dock setup wins and control-center never overwrites it with a stale default.
---@param spec GeometrySpec
---@return table
local function to_setting(spec)
    return {
        name = spec.name,
        type = spec.type,
        label = spec.label,
        options = spec.options,
        disabled = spec.disabled,
        default = spec_get(spec),
        get = function()
            return spec_get(spec)
        end,
        set = function(value, is_load, ctx)
            spec_set(spec, value, is_load == true, ctx)
        end,
    }
end

-- Build the group grouped semantically BY LAYOUT (Float / Area / Bottom): a `spacer` header per
-- surface, then that surface's size, behaviour and backdrop rows together — so the whole config
-- of one surface reads top-to-bottom in one section, the way General splits Display / Search / ….
local settings = {}
for _, layout in ipairs({ "float", "area", "bottom" }) do
    local cap = layout:sub(1, 1):upper() .. layout:sub(2)
    settings[#settings + 1] = { name = "sep_" .. layout, type = "spacer", label = cap }
    for _, spec in ipairs(size_specs(layout)) do
        settings[#settings + 1] = to_setting(spec)
    end
    for _, spec in ipairs(backdrop_specs(layout)) do
        settings[#settings + 1] = to_setting(spec)
    end
end

return {
    name = "Utils",
    label = "Utils",
    icon = "󰒓",
    settings = settings,
}
