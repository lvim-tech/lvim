-- core/keys.lua — appliers for the keymap MANIFEST (keys/base/).
--
-- Reads the sectioned manifest, merges the user overrides over it (by lhs; a `false`
-- entry disables a base binding), then applies each section at the right lifecycle point:
--   groups   → lvim-keys-helper.register_groups (menu labels)          [once]
--   global   → applied once at startup, per mode                       [startup]
--   lsp      → buffer-local on LspAttach                               [per attached buffer]
--   filetype → buffer-local on FileType                                [per matching buffer]
--
-- The `plugins` section is NOT applied here — those override tables are forwarded into each
-- plugin's setup(opts.keys) by the module configs; defaults live in the plugin repo.
---@module "core.keys"

local M = {}

local AUGROUP = "LvimKeysManifest"

--- Merge a user override LIST over a base tuple LIST, keyed by lhs.
--- User entries: array tuples `{ lhs, rhs, desc, opts? }` add/override by lhs;
--- hash entries `["<lhs>"] = false` disable that base binding.
---@param base_list LvimKeymap[]|nil
---@param user_list table|nil
---@return LvimKeymap[]
local function merge_list(base_list, user_list)
    local disabled, override, added = {}, {}, {}
    for k, v in pairs(user_list or {}) do
        if type(k) == "string" and v == false then
            disabled[k] = true
        end
    end
    for _, tuple in ipairs(user_list or {}) do
        if override[tuple[1]] == nil then
            added[#added + 1] = tuple[1]
        end
        override[tuple[1]] = tuple
    end

    local out, seen = {}, {}
    for _, tuple in ipairs(base_list or {}) do
        local lhs = tuple[1]
        seen[lhs] = true
        if not disabled[lhs] then
            out[#out + 1] = override[lhs] or tuple
        end
    end
    -- user-added bindings not present in the base
    for _, lhs in ipairs(added) do
        if not seen[lhs] and not disabled[lhs] then
            out[#out + 1] = override[lhs]
        end
    end
    return out
end

--- Load base + user manifests (both optional) and return the merged sections.
---@return { groups: table, global: table<string, LvimKeymap[]>, lsp: LvimKeymap[], lang: LvimKeymap[], filetype: table<string, LvimKeymap[]>, plugins: table }
function M.resolve()
    local base = require("keys.base")
    local ok, user = pcall(require, "keys.user")
    if not ok or type(user) ~= "table" then
        user = {}
    end

    local groups = vim.tbl_extend("force", base.groups or {}, user.groups or {})
    -- allow the user to drop a group label with `["<lhs>"] = false`
    for lhs, label in pairs(groups) do
        if label == false then
            groups[lhs] = nil
        end
    end

    local global = {}
    for _, mode in ipairs({ "normal", "visual", "insert", "terminal" }) do
        global[mode] = merge_list((base.global or {})[mode], (user.global or {})[mode])
    end

    local lsp = merge_list(base.lsp, user.lsp)

    local filetype = {}
    local fts = {}
    for ft in pairs(base.filetype or {}) do
        fts[ft] = true
    end
    for ft in pairs(user.filetype or {}) do
        fts[ft] = true
    end
    for ft in pairs(fts) do
        filetype[ft] = merge_list((base.filetype or {})[ft], (user.filetype or {})[ft])
    end

    -- The language layer is a LIST of `{ chord, command, desc }`, merged by chord the same way the
    -- other sections merge by lhs — a user entry rebinds a chord, `["<chord>"] = false` drops it.
    local lang = merge_list(base.lang, user.lang)

    return {
        groups = groups,
        global = global,
        lsp = lsp,
        lang = lang,
        filetype = filetype,
        plugins = base.plugins or {},
    }
end

--- Look up a plugin's forwarded key overrides, for a module config to pass into its setup().
---
--- RETURNS nil WHEN THERE ARE NO OVERRIDES, and that distinction matters: the shared merge
--- (`lvim-utils.utils.merge`) replaces a value when the incoming table is a LIST, and `vim.islist({})`
--- is true — so handing a plugin `keys = {}` does not mean "change nothing", it means "replace your
--- key table with an empty one". Forwarding an empty table wiped lvim-installer's browser keys
--- (measured: `keys.install` became nil). `nil` is the honest way to say "no overrides".
---@param plugin string
---@return table|nil
function M.plugin(plugin)
    local overrides = (require("keys.base").plugins or {})[plugin]
    if type(overrides) ~= "table" or next(overrides) == nil then
        return nil
    end
    return overrides
end

--- Apply the whole manifest: groups + global + the LspAttach / FileType autocmds.
function M.apply()
    local m = M.resolve()
    local base_opts = { noremap = true, silent = true }

    -- NO GROUP REGISTRATION HERE. `apply()` runs from `funcs.configs()`, which is BEFORE lvim-pack
    -- is bootstrapped — so `require("lvim-keys-helper")` could never succeed and the labels were
    -- dropped without a word. The helper's own plugin config reads `resolve().groups` instead, at a
    -- point where the plugin exists; `groups` stays part of the manifest, it is just consumed by
    -- the one place that can act on it.

    -- Global, at startup. Per-entry opts (4th tuple element) may override the section mode via
    -- `mode` (string or list) — used for multi-mode maps such as the n/x/o jump keys.
    --- `into` carries options every entry of the list shares — a `buffer` for the FileType section,
    --- nothing for the global one. An entry's own 4th element still wins over it, so a single map can
    --- opt out of whatever the section imposes.
    ---@param default_mode string|string[]
    ---@param list LvimKeymap[]
    ---@param into table?
    local function apply_list(default_mode, list, into)
        for _, t in ipairs(list) do
            local extra = t[4] or {}
            local mode = extra.mode or default_mode
            local opts = vim.tbl_extend("force", base_opts, into or {}, extra)
            opts.mode = nil
            opts.desc = t[3]
            vim.keymap.set(mode, t[1], t[2], opts)
        end
    end
    apply_list("n", m.global.normal)
    apply_list("x", m.global.visual)
    apply_list("i", m.global.insert)
    apply_list("t", m.global.terminal)

    vim.api.nvim_create_augroup(AUGROUP, { clear = true })

    -- LSP verbs, buffer-local on attach. Each entry may carry opts { mode?, cap? }:
    --   mode = the keymap mode (default "n"); cap = a capability GUARD so the key is only
    --   bound when the attached server actually provides it (string = server_capabilities key,
    --   or a fun(caps): boolean for nested checks). This is what stops g* firing on a server
    --   that has no such action.
    if #m.lsp > 0 then
        vim.api.nvim_create_autocmd("LspAttach", {
            group = AUGROUP,
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                local caps = (client and client.server_capabilities) or {}
                for _, t in ipairs(m.lsp) do
                    local o = t[4] or {}
                    local ok_cap = true
                    if o.cap ~= nil then
                        ok_cap = (type(o.cap) == "function") and o.cap(caps) or caps[o.cap]
                    end
                    if ok_cap then
                        vim.keymap.set(o.mode or "n", t[1], t[2], {
                            noremap = true,
                            silent = true,
                            buffer = args.buf,
                            desc = t[3],
                        })
                    end
                end
            end,
        })
    end

    -- THE LANGUAGE LAYER, buffer-local on FileType — but bound per PROVIDER, not per filetype: the
    -- pattern is `*` and the decision is made from what lvim-lang answers for this buffer, so a
    -- language gets exactly the keys its provider implements and a new provider is covered the day
    -- it is written, with no edit here. Asked at FileType time, which is also when lvim-lang loads
    -- for that language, so the registry is populated by the time the question is put.
    if #m.lang > 0 then
        vim.api.nvim_create_autocmd("FileType", {
            group = AUGROUP,
            pattern = "*",
            callback = function(args)
                -- ONE TICK LATER, and that is the whole trick: lvim-lang is loaded BY this same
                -- FileType event (it is the plugin's `ft` trigger), so asking its registry from
                -- inside the event answers "no provider" for every language — measured: rust and
                -- python resolved a provider a moment afterwards but bound nothing here. By the
                -- next tick the plugin is on the runtimepath and its providers are registered.
                vim.schedule(function()
                    if not vim.api.nvim_buf_is_valid(args.buf) then
                        return
                    end
                    local ok, reg = pcall(require, "lvim-lang.registry")
                    if not ok then
                        return
                    end
                    local ok_p, provider = pcall(reg.for_buffer, args.buf)
                    if not ok_p or type(provider) ~= "table" then
                        return
                    end
                    local commands = provider.commands or {}
                    for _, t in ipairs(m.lang) do
                        if commands[t[2]] ~= nil then
                            vim.keymap.set("n", t[1], ("<Cmd>LvimLang %s<CR>"):format(t[2]), {
                                noremap = true,
                                silent = true,
                                buffer = args.buf,
                                desc = t[3],
                            })
                        end
                    end
                end)
            end,
        })
    end

    -- Filetype leaves, buffer-local on FileType (this is what makes menus ft-accurate)
    for ft, list in pairs(m.filetype) do
        if #list > 0 then
            vim.api.nvim_create_autocmd("FileType", {
                group = AUGROUP,
                pattern = ft,
                callback = function(args)
                    -- The SAME applier the global section uses, with the buffer folded in — a
                    -- filetype leaf is a normal keymap that happens to be buffer-local, and per-entry
                    -- `mode` has to keep working here too.
                    apply_list("n", list, { buffer = args.buf })
                end,
            })
        end
    end
end

return M
