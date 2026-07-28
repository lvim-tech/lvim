-- General editor settings group for the LVIM Control Center.
-- Window-local display toggles (relativenumber, cursorline, wrap, …) and global editor
-- options (search, indent, undo, timeout) are built from the shared `utils.win_option` /
-- `utils.global_option` factories so each is a few lines instead of repeated boilerplate.
-- The keys-helper settings keep bespoke logic (they drive the lvim-keys-helper plugin).
-- All settings are persisted through the owning instance's store (`ctx.data`, injected into set).

---@module "modules.base.configs.editor.control_center.general"
---@diagnostic disable: undefined-field

local funcs = require("core.funcs")
local utils = require("modules.base.configs.editor.control_center.utils")
local icons = require("configs.base.ui.icons")

---@type table  Control Center settings group descriptor for general editor options
return {
    name = "general",
    label = "General",
    icon = icons.common.vim2,
    settings = {
        -- ── window-local display options ──────────────────────────────────────
        { name = "sep_display", type = "spacer", label = "Display" },
        utils.win_option({
            name = "number",
            label = "Show line numbers",
            default = true,
            exclude_ft = { "lvim-files" },
        }),
        utils.win_option({
            name = "relativenumber",
            label = "Show relative line numbers",
            default = false,
            exclude_ft = { "lvim-files" },
            -- "Show line numbers" ('number') is the master switch — relative numbers have no
            -- effect while it is off, so show this row as inert (dimmed + struck through). The
            -- value is preserved; it takes effect again once line numbers are re-enabled.
            -- `disabled` receives no ctx, so read the LIVE global value of 'number' — win_option.set
            -- keeps it in sync (it always writes the global scope), so this tracks the "Show line
            -- numbers" checkbox exactly without needing the instance's store.
            disabled = function()
                return not vim.api.nvim_get_option_value("number", { scope = "global" })
            end,
        }),
        utils.win_option({
            name = "cursorline",
            label = "Show cursor line",
            default = true,
            exclude_ft = { "lvim-files" },
        }),
        utils.win_option({
            name = "cursorcolumn",
            label = "Show cursor column",
            default = true,
            exclude_ft = { "lvim-files", "markdown" },
        }),
        utils.win_option({
            name = "wrap",
            label = "Wrap lines",
            default = true,
            exclude_ft = { "markdown" },
        }),
        utils.win_option({
            name = "list",
            label = "Show whitespace characters",
            default = false,
            exclude_ft = { "lvim-files" },
        }),
        utils.win_option({
            name = "colorcolumn",
            label = "Color column",
            type = "string",
            default = "80",
            exclude_ft = { "lvim-files" },
        }),
        utils.win_option({
            name = "signcolumn",
            label = "Sign column",
            type = "select",
            options = { "yes", "no", "auto", "number" },
            -- Same value options.lua sets, so the panel's "default" and the editor agree.
            default = "no",
            exclude_ft = { "lvim-files" },
        }),
        utils.win_option({
            name = "scrolloff",
            label = "Scroll offset",
            desc = "Lines of context kept above/below the cursor",
            type = "int",
            default = 2,
        }),
        utils.win_option({
            name = "conceallevel",
            label = "Conceal level",
            type = "select",
            options = { 0, 1, 2, 3 },
            default = 2,
            -- markdown/org are OWNED by lvim-render: it records, asserts and restores
            -- 'conceallevel' per attached window. Without this exclusion the enforcer and the
            -- plugin write the same option on the same events (BufWinEnter/FileType) and the
            -- markers never conceal — a measured live fight, 2026-07-27.
            exclude_ft = { "lvim-files", "markdown", "org" },
        }),

        -- ── global search options ─────────────────────────────────────────────
        { name = "sep_search", type = "spacer", label = "Search" },
        utils.global_option({
            name = "ignorecase",
            label = "Ignore case in search",
            default = true,
        }),
        utils.global_option({
            name = "smartcase",
            label = "Smart case in search",
            desc = "Case-sensitive when the query has an uppercase letter",
            default = true,
            -- 'smartcase' only takes effect together with 'ignorecase' (Vim ignores it
            -- otherwise), so mark it inert while "Ignore case in search" is off.
            disabled = function()
                return not vim.api.nvim_get_option_value("ignorecase", { scope = "global" })
            end,
        }),
        utils.global_option({
            name = "hlsearch",
            label = "Highlight search matches",
            default = true,
        }),

        -- ── global indentation options ────────────────────────────────────────
        -- These are buffer-local in Vim; setting vim.opt updates the default for new
        -- buffers (existing buffers keep their value until reopened).
        { name = "sep_indent", type = "spacer", label = "Indentation" },
        utils.global_option({
            name = "tabstop",
            label = "Tab width",
            type = "int",
            default = 4,
        }),
        utils.global_option({
            name = "shiftwidth",
            label = "Indent width",
            type = "int",
            default = 4,
        }),
        utils.global_option({
            name = "expandtab",
            label = "Use spaces for indentation",
            default = true,
        }),

        -- ── global editor options ─────────────────────────────────────────────
        { name = "sep_editor", type = "spacer", label = "Editor" },
        utils.global_option({
            name = "undofile",
            label = "Persistent undo",
            default = true,
        }),
        utils.global_option({
            name = "timeoutlen",
            label = "Timeout Length (ms)",
            desc = "Time to wait for a mapped key sequence to complete",
            type = "int",
            default = 500,
        }),

        -- ── keys helper (lvim-keys-helper) ────────────────────────────────────
        { name = "sep_keyshelper", type = "spacer", label = "Keys Helper" },
        {
            name = "keyshelper",
            label = "Keys helper",
            type = "bool",
            default = true,
            ---@return boolean  Whether the keys-helper panel is enabled (falls back to true when unset)
            get = function()
                if _G.LVIM.keyshelper ~= nil then
                    return _G.LVIM.keyshelper
                else
                    return true
                end
            end,
            ---@param val     boolean  New enabled state for the keys helper
            ---@param on_init boolean  True during startup; skip persistence (file write is always done)
            ---@param ctx     LvimControlCenterCtx  the owning instance's context
            set = function(val, on_init, ctx)
                _G.LVIM.keyshelper = val
                -- Persist to a flat file so the setting survives before the data store is ready.
                funcs.write_file(_G.LVIM.global.lvim_path .. "/.configs/lvim/.keyshelper", _G.LVIM.keyshelper)
                if not on_init then
                    -- Apply live (no restart): enable/disable the panel right away.
                    pcall(function()
                        local kh = require("lvim-keys-helper")
                        if val then
                            kh.enable()
                        else
                            kh.disable()
                        end
                    end)
                    if ctx and ctx.data then
                        ctx.data:save("keyshelper", val)
                    end
                end
            end,
        },
        {
            name = "keyshelperdelay",
            label = "Keys helper delay",
            type = "select",
            options = { 0, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000 },
            default = 200,
            -- Inert while the keys helper itself is disabled.
            disabled = function()
                return _G.LVIM.keyshelper == false
            end,
            ---@return integer  Current popup delay in ms
            get = function()
                if _G.LVIM.settings and _G.LVIM.settings["keyshelperdelay"] ~= nil then
                    return _G.LVIM.settings["keyshelperdelay"]
                else
                    return 200
                end
            end,
            ---@param val     integer  New delay in milliseconds
            ---@param on_init boolean  True during startup; skip persistence (apply is always done)
            ---@param ctx     LvimControlCenterCtx  the owning instance's context
            set = function(val, on_init, ctx)
                _G.LVIM.settings = _G.LVIM.settings or {}
                _G.LVIM.settings["keyshelperdelay"] = val
                -- Apply ALWAYS (also on init) — keeps the startup order-independent between
                -- this restore and the plugin's setup().
                pcall(function()
                    require("lvim-keys-helper").set_delay(val)
                end)
                if not on_init and ctx and ctx.data then
                    ctx.data:save("keyshelperdelay", val)
                end
            end,
        },
        {
            name = "keyshelperstyle",
            label = "Keys helper style",
            type = "select",
            options = { "mini", "full" },
            default = "mini",
            -- Inert while the keys helper itself is disabled.
            disabled = function()
                return _G.LVIM.keyshelper == false
            end,
            ---@return string  Current panel style
            get = function()
                return (_G.LVIM.settings and _G.LVIM.settings["keyshelperstyle"]) or "mini"
            end,
            ---@param val     string   New style ("mini" | "full")
            ---@param on_init boolean  True during startup; skip persistence (apply is always done)
            ---@param ctx     LvimControlCenterCtx  the owning instance's context
            set = function(val, on_init, ctx)
                _G.LVIM.settings = _G.LVIM.settings or {}
                _G.LVIM.settings["keyshelperstyle"] = val
                -- Apply ALWAYS (also on init): the plugin's setup() and this restore run in
                -- arbitrary order at startup; applying from both sides makes it deterministic.
                pcall(function()
                    require("lvim-keys-helper").set_style(val)
                end)
                if not on_init and ctx and ctx.data then
                    ctx.data:save("keyshelperstyle", val)
                end
            end,
        },
    },
}
