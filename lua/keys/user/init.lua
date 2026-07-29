-- keys/user — YOUR keymap overrides, merged over the base manifest.
--
-- Return the same sections `keys/base` does; anything you leave out is simply the base's. The merge
-- is BY LHS, and yours wins: an array entry `{ lhs, rhs, desc }` adds or rewrites that binding, and
-- a hash entry `["<lhs>"] = false` disables a base one.
--
--   groups   = { ["<Leader>x"] = "My group" }
--   global   = { normal = { { "<Leader>xx", "<Cmd>Foo<CR>", "Foo" } } }
--   global   = { normal = { ["<Leader>gg"] = false } }   -- disable a base binding
--   lsp      = { { "gH", "<Cmd>LvimLsp hover<CR>", "Hover" } }
--   filetype = { python = { { "<Leader>rr", "<Cmd>LvimBuild run<CR>", "Run (py)" } } }
--   plugins  = { ["lvim-files"] = { open_vsplit = "v" } }
--
-- Split it into `keys/user/<section>.lua` files the way `keys/base` does if it grows.
-- EMPTY by default — the distribution ships nothing here.
---@module "keys.user"

return {}
