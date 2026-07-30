-- keys/base/lang.lua — the LANGUAGE layer: one chord set, every language.
--
-- `:LvimLang <cmd>` dispatches to the provider of the buffer you are in, so ONE binding is the
-- right action in every language: `<C-c><C-c>r` runs a Go file with `go run`, a Rust one with
-- `cargo run`, a Python one with the interpreter its project resolves to. That is what this section
-- exists for — the per-filetype table used to hold this shape for Dart alone, and every other
-- language went without.
--
-- APPLIED ONLY WHERE THE PROVIDER REALLY HAS THE COMMAND. `core.keys` asks lvim-lang at FileType
-- time what the buffer's provider offers and binds the rest; a language with no `debug` never gets
-- a debug key that would only report "no such command". Measured across the live registry: config
-- 91 providers, run 49, build 47, test 43, test-func 19, debug 17, deps 16, test-file 14,
-- debug-test 10 — so most of these keys exist for most languages, and none of them lies.
--
-- WHY `<C-c><C-c>` AND NOT `<Leader>r`. The `<Leader>r` group is the CROSS-LANGUAGE tooling —
-- lvim-tasks, lvim-build, lvim-test — and it is full: putting the language layer there would
-- shadow those the way dart's `<Leader>rl` silently shadowed "Build: show redo target". `<C-c><C-c>`
-- is already the language chord space in this configuration; this makes it uniform.
--
-- Dart keeps its own chords (keys/base/filetype.lua): `r` is hot reload there, `f` is run, `c` is
-- the run config — a Flutter dev session is a different shape of work, and the muscle memory is
-- older than this table. The filetype section is applied after this one, so it wins.
---@module "keys.base.lang"

return {
    { "<C-c><C-c>r", "run", "Run" },
    { "<C-c><C-c>b", "build", "Build" },
    { "<C-c><C-c>t", "test", "Test: all" },
    { "<C-c><C-c>f", "test-func", "Test: function under the cursor" },
    { "<C-c><C-c>F", "test-file", "Test: this file" },
    { "<C-c><C-c>d", "debug", "Debug" },
    { "<C-c><C-c>D", "debug-test", "Debug: the test under the cursor" },
    { "<C-c><C-c>p", "deps", "Dependencies" },
    { "<C-c><C-c>c", "config", "Run configuration" },
}
