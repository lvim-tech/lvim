-- User keymap overrides (entry point) — override seam for anyone using this config.
-- Return a `keys` table shaped like modules/base/keys.lua to add / rewrite / disable
-- individual bindings. Merged over the base manifest, keyed by lhs, user wins.
-- Empty by default — WE ship nothing here.
--
--   groups   = { ["<Leader>x"] = "My group" }
--   global   = { normal = { { "<Leader>xx", "<Cmd>Foo<CR>", "Foo" } } }
--   -- disable a base binding:
--   -- global = { normal = { ["<Leader>gg"] = false } }
--   filetype = { python = { { "<Leader>rr", "<Cmd>LvimBuild run<CR>", "Run (py)" } } }
---@type table
local keys = {}

return keys
