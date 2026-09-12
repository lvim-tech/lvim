-- keys/base/init.lua — the keymap MANIFEST, assembled from its sections.
--
-- One source of truth for every launcher and global keymap. Each section is keyed by WHEN and
-- WHERE it applies, and `core.keys` (the applier) reads them:
--   groups   → lvim-keys-helper's prefix labels                        [once, at its setup]
--   global   → applied at startup, per mode                            [startup]
--   lsp      → buffer-local on LspAttach, capability-guarded           [per attached buffer]
--   lang     → buffer-local on FileType, per the PROVIDER's own commands  [per language]
--   filetype → buffer-local on FileType                                [per matching buffer]
--   plugins  → forwarded into each plugin's own setup(opts.keys)       [at that plugin's load]
--
-- WHAT IS NOT HERE, AND WHY. A key that drives a plugin's LIVE API rather than a command is set
-- by that plugin's own config, because it needs the module in hand: lvim-winnav's <C-h/j/k/l> and
-- <C-Arrows>, lvim-dap's <A-1>…<A-0>, and lvim-term's generated <C-c>1…9.
---@module "keys.base"

return {
    groups = require("keys.base.groups"),
    global = require("keys.base.global"),
    lsp = require("keys.base.lsp"),
    lang = require("keys.base.lang"),
    filetype = require("keys.base.filetype"),
    plugins = require("keys.base.plugins"),
}
