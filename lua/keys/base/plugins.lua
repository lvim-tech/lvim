-- keys/base/plugins.lua — OVERRIDES forwarded into a plugin's own setup(opts.keys).
--
-- Defaults live in the plugin repo; this file only rebinds. An entry here really reaches the
-- plugin: `core.keys.plugin("<name>")` is passed into lvim-files, lvim-term, lvim-vault and
-- lvim-installer. An EMPTY table is returned as nil, because the shared merge treats an empty
-- table as a list and would REPLACE the plugin's whole key table with nothing.
---@module "keys.base.plugins"

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- PLUGINS  (forwarded into each plugin's setup(opts.keys) — DEFAULTS live in the plugin repo;
-- these are OVERRIDES only; internal UI keys stay buffer-local + guarded by the helper opt-out)
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- WIRED, not decorative: `core.keys.plugin("<name>")` is forwarded into the setup() of
-- lvim-files, lvim-term, lvim-vault and lvim-installer (their key tables), so an entry written
-- here really rebinds that plugin's internal key. An empty table changes nothing.
return {
    -- ["lvim-files"] = { open_split = "s", open_vsplit = "v", delete = "d" },
    -- ["lvim-installer"] = { update = "U" },
}

