-- Base plugin registry — the master plugin manifest.
-- PURE lvim-tech configuration: every plugin is one of the user's own lvim-* plugins,
-- fetched from its published repository, plus the minimal
-- third-party plugins the set still borrows (gathered in their own section at the end).
-- Organised into sections
-- (dependencies, UI, editor, version control, languages/LSP, completion). Merged with
-- modules/user/init.lua in core.pack before being loaded via vim.pack.
--
-- This file names REPOSITORIES only — no local paths. Working on the plugins is a personal setup, not a
-- property of the configuration, so the dev checkouts live in modules/user/init.lua: it scans ~/lvim-tech
-- and merges a `dir=` over whichever plugins are cloned there. That block is a no-op for anyone without
-- that directory, so this config clones and runs the published plugins for them.

local modules = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- DEPENDENCIES -------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local dependencies_config = require("modules.base.configs.dependencies")

modules["lvim-tech/lvim-colorscheme"] = {
    dependencies = {
        "lvim-tech/lvim-utils",
        -- Its theme picker AND its settings panel render through lvim-ui, so this is a load-order
        -- fact, not a preference. Declared here rather than packadd-ed from inside the plugin — a
        -- plugin reaching for the package manager assumes how it was installed, and overrides the
        -- lazy rules the reader set.
        "lvim-tech/lvim-ui",
    },
    priority = 100,
    opts = dependencies_config.lvim_colorscheme.opts,
}

-- lvim-utils is the BASE (utils / colors / highlight / cursor / store + the central highlight
-- factory). No config here — the whole lvim-tech set is configured through lvim-nvim below.
modules["lvim-tech/lvim-utils"] = {
    opts = dependencies_config.lvim_utils.opts,
    priority = 100,
}

-- lvim-fuzzy: the shared native fuzzy-matching engine (lvim-picker + lvim-cmp rank through it). The
-- compiled native library (native/build/, gitignored) lives only in the dev checkout, so the dir entry
-- keeps the fast backend live; no config (the defaults work; options would go through lvim-nvim below).
modules["lvim-tech/lvim-fuzzy"] = {
    -- The native matcher is a post-install BUILD, not something the plugin can do at runtime: the
    -- FFI loader probes `native/build/liblvimfuzzy.so` and falls back to the byte-identical
    -- pure-Lua matcher when it is absent. Declaring the hook is what makes the loader run it (and
    -- re-run it whenever the plugin changes).
    build = "sh native/build.sh",
    -- Self-healing: the marker records the commit a build ran for, but a build that succeeded
    -- without producing a usable artefact would still look current. This says what "built" means.
    built = function(ctx)
        return vim.fn.filereadable(ctx.dir .. "/native/build/liblvimfuzzy.so") == 1
    end,
}

-- lvim-nvim: the umbrella. Its config forwards each option table to the right plugin via
-- require("lvim-nvim").setup({ ["lvim-<plugin>"] = {…} }) in a dependency-safe order. The split base
-- modules it configures are declared right below (each from its dev checkout), so they are always on the
-- runtimepath before the forwarder runs. Every plugin also works standalone.
modules["lvim-tech/lvim-nvim"] = {
    -- WHAT IT CONFIGURES, IT DEPENDS ON. The forwarder calls each of these plugins' `setup()`, so
    -- they must be on the runtimepath before its config runs — being declared as separate modules
    -- below does not order them, only a dependency does. Stated here because this is where the
    -- forwarded option table is built: the umbrella cannot know which plugins a host will hand it.
    dependencies = {
        "lvim-tech/lvim-utils",
        "lvim-tech/lvim-common",
        "lvim-tech/lvim-hud",
        "lvim-tech/lvim-msgarea",
        "lvim-tech/lvim-picker",
        "lvim-tech/lvim-image",
        "lvim-tech/lvim-snippets",
    },
    config = dependencies_config.lvim_nvim.config,
}

-- The split BASE MODULES of the lvim-tech set — configured centrally through the lvim-nvim
-- forwarder above (see modules.base.configs.dependencies lvim_nvim.config); declared here so
-- each one is explicitly present from its dev checkout.
modules["lvim-tech/lvim-common"] = {
    opts = dependencies_config.lvim_common.opts,
    dependencies = {
        "lvim-tech/lvim-utils",
    },
}
modules["lvim-tech/lvim-ui"] = {
    opts = dependencies_config.lvim_ui.opts,
    dependencies = {
        "lvim-tech/lvim-utils",
    },
}
modules["lvim-tech/lvim-picker"] = {
    opts = dependencies_config.lvim_picker.opts,
    dependencies = {
        "lvim-tech/lvim-fuzzy",
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
}
modules["lvim-tech/lvim-hud"] = {
    opts = dependencies_config.lvim_hud.opts,
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
}
modules["lvim-tech/lvim-msgarea"] = {
    opts = dependencies_config.lvim_msgarea.opts,
    dependencies = {
        "lvim-tech/lvim-hud",
        "lvim-tech/lvim-picker",
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
}
modules["lvim-tech/lvim-image"] = {
    opts = dependencies_config.lvim_image.opts,
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
}
modules["lvim-tech/lvim-dashboard"] = {
    opts = dependencies_config.lvim_dashboard.opts,
    dependencies = {
        "lvim-tech/lvim-utils",
    },
}

-- lvim-icons: the icon provider of the lvim-tech set. Loaded eagerly (priority) so the icon
-- resolver + LvimIcon* highlight groups are ready before the dashboard / hud chrome render at
-- startup. opts → require("lvim-icons").setup.
modules["lvim-tech/lvim-icons"] = {
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    priority = 100,
    opts = dependencies_config.lvim_icons.opts,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require("modules.base.configs.ui")
local version_control_config = require("modules.base.configs.version_control")

-- lvim-winpick: label each window so you can jump to it by key. Lazy, on :LvimWinPick — but a dependency of
-- lvim-winmove (the swap target), so in practice it is loaded at startup along with winmove/winnav.
modules["lvim-tech/lvim-winpick"] = {
    cmd = "LvimWinPick",
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    config = ui_config.lvim_winpick.config,
}

-- lvim-winmove: interactively move and swap windows within a tab. Loaded at startup as a dependency of
-- lvim-winnav (its cmd trigger is then moot). lvim-winpick is a declared dependency: swap picks its target
-- through `require("lvim-winpick")`, which on a published install is not on the runtimepath until
-- :LvimWinPick has run — without the dependency, swap silently fell back to "the first other window".
modules["lvim-tech/lvim-winmove"] = {
    cmd = "LvimWinMove",
    dependencies = {
        "lvim-tech/lvim-winpick",
        "lvim-tech/lvim-utils",
    },
    config = ui_config.lvim_winmove.config,
}

-- lvim-keys-helper: the self-contained key-hint panel. Always loaded; enable/disable, popup
-- delay and mini/full style are all switched live from the control center (no restart).
modules["lvim-tech/lvim-keys-helper"] = {
    opts = ui_config.lvim_keys_helper.opts,
}

-- lvim-files: the file manager — a persistent tree side panel + an editable-buffer
-- directory view over one fs model.
modules["lvim-tech/lvim-files"] = {
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = ui_config.lvim_files.config,
}

-- lvim-shell: full-screen terminal integrations for TUI apps (Yazi, Vifm, LazyGit,
-- LazyDocker, Neomutt + the ~55 preset addons of :LvimShell).
-- Every command its config registers has to be listed here: a lazy plugin's config has not run yet,
-- so anything it would define does not exist until a declared trigger loads it. There is now
-- exactly ONE — `:LvimShell <name> [dir]` — since the per-program wrapper commands were removed in
-- favour of the plugin's own addon presets.
modules["lvim-tech/lvim-shell"] = {
    cmd = { "LvimShell" },
    -- Launcher keys (<Leader>o{s,g,D,y,n}) live in the manifest (keys/base/global.lua) and
    -- lazy-load via the cmd above: a manifest key that calls the command is all a cmd-lazy plugin needs.
    config = ui_config.lvim_shell.config,
}

-- lvim-term: persistent, named, toggleable terminals with a tab bar.
modules["lvim-tech/lvim-term"] = {
    cmd = "LvimTerm",
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = ui_config.lvim_term.config,
}

-- lvim-indent: indent guides through blank lines + the enclosing-scope guide. Eager: it
-- installs one decoration provider, so there is nothing to lazy-load onto.
modules["lvim-tech/lvim-indent"] = {
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    config = ui_config.lvim_indent.config,
}

-- lvim-context: the sticky context header — the enclosing scopes that have scrolled off the
-- top stay pinned above the window. Reads treesitter through lvim-ts.
modules["lvim-tech/lvim-context"] = {
    dependencies = {
        "lvim-tech/lvim-ts",
        "lvim-tech/lvim-utils",
    },
    config = ui_config.lvim_context.config,
}

-- lvim-winnav: directional window navigation + resizing, handing off to tmux at the edge of
-- the Neovim layout. Owns <C-h/j/k/l> and <C-Arrows> (they were native wincmd maps before).
modules["lvim-tech/lvim-winnav"] = {
    dependencies = {
        "lvim-tech/lvim-winmove",
        "lvim-tech/lvim-utils",
    },
    opts = ui_config.lvim_winnav.opts,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- EDITOR -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("modules.base.configs.editor")

modules["lvim-tech/lvim-space"] = {
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    opts = editor_config.lvim_space.opts,
}

-- lvim-control-center: the settings panel. Its eager setup() restores every persisted
-- setting at startup in ONE bulk query (see the appearance bridge notes in the config).
modules["lvim-tech/lvim-control-center"] = {
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    opts = editor_config.lvim_control_center.opts,
}

modules["lvim-tech/lvim-linguistics"] = {
    -- VeryLazy: per-mode keyboard layout + spell switching; nothing to switch until the UI is up.
    event = "VeryLazy",
    dependencies = {
        "lvim-tech/lvim-utils",
        -- Its settings panel is built straight on lvim-ui (two layer tabs). It does NOT go through
        -- control-center: that host stores one value per name, and these settings are per-directory.
        "lvim-tech/lvim-ui",
    },
    opts = editor_config.lvim_linguistics.opts,
}

-- lvim-vault: marks + jumps + a persistent macro bank (sqlite via lvim-utils.store) in one
-- lvim-ui.tabs panel.
modules["lvim-tech/lvim-vault"] = {
    -- Lazy on its command: every vault key in the manifest is a `:LvimVault …`, so the
    -- loader's command stub brings it in on the first keystroke that needs it.
    cmd = "LvimVault",
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = editor_config.lvim_vault.config,
}

-- lvim-undo: the branching undo history as a timeline panel (diff preview, persistent named
-- checkpoints, undofile purging). Eager: setup() installs the auto-checkpoint hooks.
modules["lvim-tech/lvim-undo"] = {
    -- VeryLazy, not a command: its automatic checkpoints hook format / lsp-rename / build, so it
    -- has to be listening before those happen — but nothing needs it during startup itself.
    event = "VeryLazy",
    dependencies = {
        "lvim-tech/lvim-utils",
        "lvim-tech/lvim-ui",
    },
    config = editor_config.lvim_undo.config,
}

modules["lvim-tech/lvim-qf-loc"] = {
    -- VeryLazy rather than `ft = "qf"`: it OWNS 'quickfixtextfunc', which has to be set before a
    -- list renders — waiting for the qf filetype would let the first list draw natively.
    event = "VeryLazy",
    opts = editor_config.lvim_qf_loc.opts,
}

-- lvim-replace: project-wide find & replace (ripgrep) with selective per-result marking.
modules["lvim-tech/lvim-replace"] = {
    cmd = "LvimReplace",
    dependencies = {
        "lvim-tech/lvim-utils",
        "lvim-tech/lvim-ui",
    },
    config = editor_config.lvim_replace.config,
}

-- lvim-cycle: smart increment/decrement for numbers, dates, booleans, and operators.
modules["lvim-tech/lvim-cycle"] = {
    -- VeryLazy: its <C-a>/<C-x> operators are armed ~50 ms after the UI, long before a keystroke.
    event = "VeryLazy",
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    config = editor_config.lvim_cycle.config,
}

modules["lvim-tech/lvim-move"] = {
    -- VeryLazy: editing operators, needed only once a human is typing.
    event = "VeryLazy",
    opts = editor_config.lvim_move.opts,
}

-- lvim-comment: smart line and block commenting (gc/gb + gco/gcO/gcA), commentstring
-- resolved per position via treesitter.
modules["lvim-tech/lvim-comment"] = {
    -- VeryLazy: editing operators, needed only once a human is typing.
    event = "VeryLazy",
    config = editor_config.lvim_comment.config,
}

-- lvim-buf-history: per-window buffer history (browser-style back/forward).
modules["lvim-tech/lvim-buf-history"] = {
    -- VeryLazy: its history autocmds arm right after the UI — the buffers opened before that are
    -- the ones already on screen.
    event = "VeryLazy",
    config = editor_config.lvim_buf_history.config,
}

-- lvim-color-picker: slider picker + converter + inline highlighter.
modules["lvim-tech/lvim-color-picker"] = {
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    cmd = editor_config.lvim_color_picker.cmd,
    keys = editor_config.lvim_color_picker.keys,
    config = editor_config.lvim_color_picker.config,
}

-- lvim-jump: label-based motions — enhanced f/t/F/T, live-search jump mode, treesitter
-- node selection and the operator-pending remote jump.
modules["lvim-tech/lvim-jump"] = {
    -- VeryLazy: motion keys, needed only once a human is typing.
    event = "VeryLazy",
    config = editor_config.lvim_jump.config,
}

-- lvim-search: a counter beside every visible search match, and the nearest one painted above
-- 'hlsearch'. Loaded eagerly on purpose — it owns no mappings and no command to lazy-load on; it
-- waits on v:hlsearch from a decoration provider, so it must already be listening at the first `/`.
modules["lvim-tech/lvim-search"] = {
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    config = editor_config.lvim_search.config,
}

-- lvim-render: decorated rendering of markdown, typst, org and latex inside the buffer you are
-- editing (the browser-side counterpart is lvim-preview). Attaches by filetype, so it loads on the
-- first such buffer rather than at startup.
modules["lvim-tech/lvim-render"] = {
    ft = { "markdown", "typst", "org", "tex", "latex", "plaintex" },
    dependencies = {
        "lvim-tech/lvim-ts",
        "lvim-tech/lvim-utils",
    },
    opts = editor_config.lvim_render.opts,
}

-- lvim-ansi: terminal colour in a Neovim buffer, with the escapes out of the text. Paints from
-- the .spans sidecar lvim-zcopy writes beside a zellij scrollback, or parses the escapes still in
-- a buffer (:LvimAnsi colorize). Loaded eagerly, and that is deliberate: the usual entry point is
-- `nvim <dump> -c "lua require('lvim-ansi').attach(0, ...)"` from lvim-zcopy, and a lazy plugin is
-- not on the runtimepath yet, so that require would fail with nothing to trigger it first.
modules["lvim-tech/lvim-ansi"] = {
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    config = editor_config.lvim_ansi.config,
}

-- lvim-calendar: month/quarter/year/agenda calendar with pluggable day sources.
modules["lvim-tech/lvim-calendar"] = {
    cmd = "LvimCalendar",
    -- Launcher keys (<Leader>oc / <Leader>oC) live in the manifest and lazy-load via the cmd above.
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    opts = editor_config.lvim_calendar.opts,
}

-- lvim-table: per-buffer table mode — realign as you edit, row/column operations, cell
-- text objects/motions, tableize and formulas.
modules["lvim-tech/lvim-table"] = {
    cmd = "LvimTable",
    -- Launcher key (<Leader>ct) lives in the manifest and lazy-loads via the cmd above.
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    config = editor_config.lvim_table.config,
}

-- lvim-tasks: the task runner — panel with live output preview, filters, history,
-- redo/redo-failed (persisted per project via lvim-utils.store).
modules["lvim-tech/lvim-tasks"] = {
    -- On demand: the task list is opened, never needed at startup. lvim-build / lvim-test declare
    -- it as a dependency, so their triggers pull it in when they need it.
    cmd = "LvimTasks",
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = editor_config.lvim_tasks.config,
}

-- lvim-build: project/file action detection (Build/Run/Test/Bench/Lint recipes) with a
-- frecency-ordered chooser; every action runs through lvim-tasks.
modules["lvim-tech/lvim-build"] = {
    cmd = "LvimBuild",
    dependencies = {
        "lvim-tech/lvim-tasks",
    },
    config = editor_config.lvim_build.config,
}

-- lvim-test: granular test runner (go + dart) — treesitter discovery, streaming per-test
-- results, every run through lvim-tasks. Loads on a go/dart buffer or the :LvimTest command.
modules["lvim-tech/lvim-test"] = {
    cmd = "LvimTest",
    ft = { "go", "dart" },
    dependencies = {
        "lvim-tech/lvim-tasks",
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
        "lvim-tech/lvim-ts",
    },
    config = editor_config.lvim_test.config,
}

-- lvim-remote: project file transfer over ssh/rsync — upload/download/diff/sync with a
-- dry-run review panel; targets in .lvim/remote.lua.
modules["lvim-tech/lvim-remote"] = {
    cmd = "LvimRemote",
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = editor_config.lvim_remote.config,
}

-- lvim-rest: REST/HTTP client — `.http` documents, environments + variables, request chaining, a
-- response dock and history. The native Rust backend (`core/`) is OPTIONAL: build it once with
-- `sh core/build.sh` for HTTP/2 + native timing, else the curl fallback runs (see :checkhealth).
modules["lvim-tech/lvim-rest"] = {
    cmd = "LvimRest",
    ft = { "http", "rest" }, -- also load on a loose .http/.rest file, so its buffer keys bind without :LvimRest
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = editor_config.lvim_rest.config,
}

-- lvim-preview: live browser preview (markdown / html / asciidoc / svg) with hot reload, served by
-- the plugin's own pure-Lua HTTP + WebSocket server. Loopback-only and fully offline — the render
-- assets are vendored, so no CDN request is ever made.
modules["lvim-tech/lvim-preview"] = {
    cmd = "LvimPreview",
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = editor_config.lvim_preview.config,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- VERSION CONTROL ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- lvim-git: the in-house Magit/fugitive/neogit/vgit/diffview replica (+ jj + colocated git↔jj sync). Eager
-- (like lvim-files): setup() registers :LvimGit + binds highlights + auto-attaches the gutter signs at
-- startup, then each component (status/diffview/log/blame/refs/oplog/rebase/stash/…) bootstraps lazily on its
-- opener. Keymaps under <Leader>g*. LazyGit (<Leader>og / :LvimShell lazygit) stays as the terminal-
-- based alternative.
modules["lvim-tech/lvim-git"] = {
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = version_control_config.lvim_git.config,
}

-- lvim-forge: the in-house Magit Forge (forge.el) replica — PR/issue/review across GitHub/GitLab/Gitea/
-- Forgejo/Codeberg, cached offline in SQLite (lvim-utils.store). Eager: setup() registers :LvimForge, binds
-- highlights, self-registers the "Forge" section into :LvimGit status, and wires the #topic/@user completion.
-- Deps: sqlite.lua (the DB is the plugin) + lvim-git (soft: status section + PR diff/refresh — load order).
-- Keymaps under <Leader>gf / gF / gN (dispatch / topics / notifications).
modules["lvim-tech/lvim-forge"] = {
    cmd = "LvimForge",
    dependencies = {
        "kkharji/sqlite.lua",
        "lvim-tech/lvim-git",
    },
    config = version_control_config.lvim_forge.config,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- LANGUAGES ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require("modules.base.configs.languages")

modules["lvim-tech/lvim-lsp"] = {
    dependencies = {
        "lvim-tech/lvim-ls",
        "lvim-tech/lvim-utils",
    },
    opts = languages_config.lvim_lsp.opts,
}

-- lvim-ls: the language-server core lvim-lsp drives (server configs, EFM tools, the
-- DAP registration seam). Declared explicitly from its dev checkout.
modules["lvim-tech/lvim-ls"] = {}

-- lvim-lang: the lvim-tech per-language dev-tooling base and the SOLE LSP/tooling source for the
-- languages it covers. Two provider shapes: a directory per language for the ones with real
-- toolchain behaviour (run / test / debug / SDK), and a declarative file for "a server and its root
-- markers". No count here — `:LvimLang providers` is the live list. Loads on a provider's filetype;
-- its setup registers ALL providers and fans their servers out to lvim-lsp/lvim-ls (each ships its own
-- server-config dir, lvim-lang.servers). Pure lvim-tech — no third-party deps. NB: the ft list below
-- must cover every provider's filetypes so the plugin loads for that language.
modules["lvim-tech/lvim-lang"] = {
    -- Every filetype of every provider (21 bespoke + 6 declarative Tier 2), so opening any of them loads
    -- lvim-lang (which registers ALL providers + fans their servers out to lvim-lsp). Keep in sync.
    ft = {
        -- dart / go / rust / python / typescript+js / c-family / java / c# / f#
        "dart",
        "go",
        "gomod",
        "gowork",
        "gotmpl",
        "rust",
        "python",
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
        "c",
        "cpp",
        "objc",
        "objcpp",
        "java",
        "cs",
        "fsharp",
        -- ruby / swift / php / kotlin / scala / zig / unison
        "ruby",
        "eruby",
        "swift",
        "php",
        "kotlin",
        "scala",
        "sbt",
        "zig",
        "zir",
        "unison",
        -- ocaml / erlang / clojure / elixir / haskell
        "ocaml",
        "ocaml.interface",
        "ocamllex",
        "menhir",
        "dune",
        "erlang",
        "clojure",
        "edn",
        "elixir",
        "eelixir",
        "heex",
        "haskell",
        "lhaskell",
        -- declarative Tier 2 providers (data files in lvim-lang.providers.registry) — lua/shell/r/perl/d
        -- restore the LSP the manual catalog archive gave up; julia is new.
        "lua",
        "sh",
        "bash",
        "r",
        "rmd",
        "perl",
        "d",
        "julia",
        -- Tier 2 batch 2
        "crystal",
        "nim",
        "nims",
        "nimble",
        "elm",
        "vlang",
        "v",
        "odin",
        "gleam",
        "racket",
        "scheme",
        "purescript",
        "ada",
        "hare",
        -- Tier 2 batch 3
        "groovy",
        "rescript",
        "vala",
        "roc",
        "fish",
        "nu",
        "grain",
        "lisp",
        "pascal",
        -- Tier 3 batch 4 (config / markup / data)
        "html",
        "css",
        "scss",
        "less",
        "sass",
        "json",
        "jsonc",
        "yaml",
        "toml",
        "markdown",
        "xml",
        "xsd",
        "xsl",
        "xslt",
        "svg",
        "graphql",
        -- Tier 3 batch 5 (infra / DevOps)
        "dockerfile",
        "terraform",
        "hcl",
        "nix",
        "sql",
        "mysql",
        "plsql",
        "proto",
        "helm",
        "yaml.ansible",
        "ansible",
        -- Tier 3 batch 6 (web frameworks / templating)
        "svelte",
        "vue",
        "astro",
        "twig",
        -- Tier 3 batch 7 (scientific / legacy)
        "fortran",
        "cobol",
        "matlab",
        "octave",
        "tcl",
        "solidity",
        "prolog",
        "ps1",
        "asm",
        "nasm",
        -- Tier 3 batch 8 (config / DSL + archived leftovers: vim / latex / cmake)
        "jsonnet",
        "libsonnet",
        "cue",
        "bzl",
        "starlark",
        "nginx",
        "vim",
        "tex",
        "plaintex",
        "bib",
        "cmake",
        -- Tier 3 batches 9-13 (typesetting/data, shaders, HDL, blockchain, proof assistants)
        "typst",
        "awk",
        "gdscript",
        "nextflow",
        "glsl",
        "vert",
        "frag",
        "geom",
        "comp",
        "tesc",
        "tese",
        "wgsl",
        "vhdl",
        "verilog",
        "systemverilog",
        "move",
        "cairo",
        "lean",
        "coq",
        -- org (formatter-only provider: cbfmt over efm) + the markdown provider's mdx filetypes
        "org",
        "markdown.mdx",
        "mdx",
    },
    dependencies = {
        "lvim-tech/lvim-lsp",
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = languages_config.lvim_lang.config,
}

-- lvim-pack: the plugin LOADER itself. The bootstrap in core/init.lua clones and prepends it, so
-- it is already on the runtimepath before this table is read; the entry exists purely so vim.pack
-- manages and updates it like every other plugin. No config — it was configured by the bootstrap.
modules["lvim-tech/lvim-pack"] = {
    lazy = true,
}

-- lvim-pkg: the single data + operations hub for installable things (packages,
-- treesitter parsers, vim.pack plugins). Loaded first — the loader's dependency
-- resolver runs through it.
modules["lvim-tech/lvim-pkg"] = {
    config = languages_config.lvim_pkg.config,
}

-- lvim-ts: buffer-side treesitter runtime over the built-in vim.treesitter; parsers +
-- queries are compiled/installed by lvim-pkg's self-contained parser backend.
modules["lvim-tech/lvim-ts"] = {
    dependencies = {
        "lvim-tech/lvim-pkg",
    },
    config = languages_config.lvim_ts.config,
}

-- lvim-installer: the install UI — unified on-open prompt (LSP tools + treesitter
-- parsers, sourced from lvim-pkg) and the package panel.
modules["lvim-tech/lvim-installer"] = {
    dependencies = {
        "lvim-tech/lvim-pkg",
        "lvim-tech/lvim-utils",
    },
    config = languages_config.lvim_installer.config,
}

modules["lvim-tech/lvim-dependencies"] = {
    -- VeryLazy: keeps its manifest-file autocmds armed without paying for them at startup.
    event = "VeryLazy",
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    opts = languages_config.lvim_dependencies.opts,
}

-- lvim-dap: the DAP client (debug engine) — plug-and-play adapter registry; the
-- per-language adapters/configurations register through lvim-ls from the server
-- configs (see configs/languages/lsp/servers/*.lua).
modules["lvim-tech/lvim-dap"] = {
    -- VeryLazy: the reactive listeners are armed long before any debug session can start.
    event = "VeryLazy",
    config = languages_config.lvim_dap.config,
}

-- lvim-dap-view: the debugger UI — a dock of tabbed panels (watches / scopes / stack /
-- breakpoints / exceptions / repl / console / sessions) over the lvim-dap listener bus.
-- NOT lazy: the debugger UI is REACTIVE — its setup() registers the on_session / event_stopped
-- listeners that drive auto_open. Lazy-loading it on its own :LvimDapView / <Leader>dv would register
-- those listeners too late (only AFTER the user manually opens it), so `auto_open` on the first
-- session would silently never fire. lvim-dap (the engine) is eager for the same reason; its UI must
-- be armed alongside it. The config still installs the <Leader>dv keymap + :LvimDapView command.
modules["lvim-tech/lvim-dap-view"] = {
    -- VeryLazy, with the engine it renders for.
    event = "VeryLazy",
    dependencies = {
        "lvim-tech/lvim-dap",
    },
    config = languages_config.lvim_dap_view.config,
}

-- lvim-db: the database client — connections drawer, result dock, notes, its own
-- encrypted daemon backend (build once with `sh native/build.sh`).
modules["lvim-tech/lvim-db"] = {
    cmd = "LvimDb",
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = languages_config.lvim_db.config,
    -- The DB client's daemon is a post-install Rust build; the loader
    -- (lua/lvim-db/daemon.lua) probes native/build/lvim-db-daemon. Declaring the
    -- hook is what makes the build sweep produce it (and rebuild on change).
    build = "sh native/build.sh",
    built = function(ctx)
        return vim.fn.filereadable(ctx.dir .. "/native/build/lvim-db-daemon") == 1
    end,
}

-- lvim-keyring: the password wallet / secrets agent — an encrypted (Argon2id + XChaCha20-Poly1305) store
-- behind ONE master password, held out-of-editor by a per-user Rust daemon (build once with
-- `sh native/build.sh`). Shared with lvim-db (`{{ vault "db/…" }}` connection credentials), lvim-forge
-- (API tokens) and git (the HTTPS credential helper). :LvimKeyring opens the wallet panel.
-- EAGER, not lazy: its setup() spawns the agent (locked, idle) so it is RUNNING and this client is
-- LISTENING from startup — which is what lets a background consumer (an lvim-db `{{ vault }}` connect,
-- git resolving HTTPS creds) reach the wallet and trigger the transparent unlock prompt WITHOUT the user
-- first opening the panel. Lazy-loading on `:LvimKeyring` defeated that: the agent stayed unspawned until
-- the panel was opened, so an early DB connect failed with "lvim-keyring is not running". The daemon
-- spawn is itself scheduled off the startup path, so eager costs only running setup(). :LvimKeyring is
-- registered by setup(), so it is still available.
modules["lvim-tech/lvim-keyring"] = {
    -- VeryLazy: consumers (the DB client, git credentials) `require` it directly, so it must be on
    -- the runtimepath by the time anything asks — but nothing asks during startup.
    event = "VeryLazy",
    dependencies = {
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = languages_config.lvim_keyring.config,
    -- The wallet's secrets daemon is a post-install Rust build; the loader
    -- (lua/lvim-keyring/daemon.lua) probes native/build/lvim-keyring-daemon and
    -- reports "daemon binary not found" without it. Declaring the hook is what
    -- makes the build sweep produce it (and rebuild when the plugin changes).
    build = "sh native/build.sh",
    built = function(ctx)
        return vim.fn.filereadable(ctx.dir .. "/native/build/lvim-keyring-daemon") == 1
    end,
}

-- lvim-breadcrumbs: the symbol path to the cursor (LSP documentSymbol + treesitter
-- fallback); rendered as a segment inside the lvim-hud chrome winbar (see
-- configs/ui/chrome/winbar.lua) and attached per server via attach().
modules["lvim-tech/lvim-breadcrumbs"] = {
    -- LspAttach: the symbol trail has nothing to show until a server attaches, and that is exactly
    -- when it can build one. The winbar segment that consumes it is pcall-guarded for the window
    -- before the first attach.
    event = "LspAttach",
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    config = languages_config.lvim_breadcrumbs.config,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- COMPLETION ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require("modules.base.configs.completion")

-- lvim-cmp: the completion engine — ranks through the shared lvim-fuzzy native matcher
-- (lvim-ui menu, LSP/buffer/path/snippet sources, ghost text + docs float). Its LSP
-- capabilities are merged in languages/lsp get_capabilities().
modules["lvim-tech/lvim-cmp"] = {
    dependencies = {
        "lvim-tech/lvim-fuzzy",
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-utils",
    },
    config = completion_config.lvim_cmp.config,
}

-- lvim-snippets: the snippet collection engine (VS Code / SnipMate formats) + its own session
-- engine (tabstops, mirrors, choices, transforms, postfix rules) +
-- the :LvimSnippets picker. Its setup() (forwarded through lvim-nvim above) registers
-- the "snippets" completion source via lvim-cmp's public register_source.
modules["lvim-tech/lvim-snippets"] = {
    opts = dependencies_config.lvim_snippets.opts,
    -- No `cmd` trigger: it is a DEPENDENCY of lvim-nvim (the forwarder configures it), so it is
    -- loaded with the umbrella and a command trigger could never defer anything.
    dependencies = {
        "lvim-tech/lvim-utils",
    },
}

-- lvim-pairs: autopairs + surround + autotag in one plugin over one shared pair table.
modules["lvim-tech/lvim-pairs"] = {
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    config = completion_config.lvim_pairs.config,
}

-- lvim-tex: LaTeX is a build pipeline, not just a syntax — root detection, compilation, the log
-- parsed into real diagnostics, the viewer and SyncTeX both ways, the TOC, the editing operators,
-- conceal and the maths abbreviations. Replaces vimtex, and needs nothing external beyond a TeX
-- distribution: forward/inverse search reaches this Neovim through its own `v:servername` socket,
-- so neovim-remote is no longer a dependency.
modules["lvim-tech/lvim-tex"] = {
    ft = { "tex", "plaintex", "bib" },
    dependencies = {
        "lvim-tech/lvim-utils",
        "lvim-tech/lvim-ui",
        -- The default viewer (its pdf.js page) and the engine the maths abbreviations register into.
        "lvim-tech/lvim-preview",
        "lvim-tech/lvim-snippets",
    },
    config = languages_config.lvim_tex.config,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- THIRD-PARTY --------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--
-- Everything above this line is lvim-tech's own. What follows is NOT. The section is down to a
-- single runtime LIBRARY — every borrowed PLUGIN has been replaced by an lvim-tech one — and it is
-- kept as its own section so that boundary stays visible at a glance.
--
-- Each one carries a `commit` pin from the snapshot, like every other plugin, so an upstream change
-- cannot alter the distribution without an explicit snapshot update.

-- sqlite.lua: the only non-lvim RUNTIME LIBRARY the set requires — lvim-utils.store.sqlite wraps it for
-- the plugins that need real relational data (vault macros, control-center settings, lvim-space
-- projects, lvim-db store, build/tasks history…). Loaded early (high priority) so it is on the
-- runtimepath before any consumer's config runs.
modules["kkharji/sqlite.lua"] = {
    priority = 900,
}

-- Java is owned by lvim-lang's Java provider (jdtls through lvim-lsp/lvim-ls, with a per-project
-- `-data` workspace + java-debug bundles). The former nvim-jdtls plugin was declared but never wired
-- to start (no ftplugin/start_or_attach), so it was inert dead-weight — removed.

-- Scala is owned by lvim-lang's Scala provider (metals through lvim-lsp/lvim-ls; metals drives BSP/Bloop
-- itself). The former standalone nvim-metals plugin is removed — superseded.

return modules
