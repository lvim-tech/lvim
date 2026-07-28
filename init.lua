-- Entry point for LVIM IDE.
-- Initialises the global _G.LVIM namespace, validates the Neovim version,
-- and delegates all further setup to the core module.
-- Enable Neovim's built-in Lua module bytecode cache. Without it every require() is recompiled
-- from source on each startup. Must run before any require().
vim.loader.enable()

---@type LvimNamespace
_G.LVIM = { _float_index = 1 }
_G.LVIM.nvim_version = vim.version()
-- Startup marker for the dashboard's load-time stat.
_G.LVIM.start_time = vim.uv.hrtime()

-- MINIMUM 0.12: the whole plugin set is loaded through `vim.pack`, which is where it was
-- introduced — 0.11 has no plugin manager at all, so the previous 0.11.4 floor could not have
-- started this config. vim.pack's LOCKFILE (`nvim-pack-lock.json`) is newer, but nothing here
-- REQUIRES it: lvim-pack only rewrites it to unpin a plugin that tracks latest, and that pass
-- returns early when the file is not there. Development happens on 0.13.
--
-- `vim.fn.has`, NOT `vim.version.ge`: a development build calls itself `0.13.0-dev`, and by semver
-- a pre-release sorts BELOW its release — so `vim.version.ge(v, { 0, 13, 0 })` is false on exactly
-- the nightly this config is developed against. `has("nvim-0.12")` answers the question actually
-- being asked: "does this Neovim have 0.12's features".
if vim.fn.has("nvim-0.12") == 1 then
    require("core")
else
    print("LVIM IDE requires Neovim >= 0.12 (vim.pack)")
end
