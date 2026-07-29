# LVIM IDE

![LVIM IDE](/assets/lvim-ide-logo.png)

> A modular Neovim configuration written in Lua, built around a first-party plugin ecosystem — `lvim-tech/*` — that provides LSP management, settings persistence, project/workspace handling, colorschemes, and more. Fully customizable without touching core files.

> Current version — **10.0.0**

---

## Table of Contents

- [Requirements](#requirements)
- [Install](#install)
- [Architecture](#architecture)
- [Language support](#language-support)
- [Debug (DAP)](#debug-dap)
- [The set](#the-set)
- [User Customization](#user-customization)
- [Changelog](#changelog)

---

## Requirements

Verified against what the set actually spawns — `:checkhealth lvim-pkg` reports the same list live.

**Required**

| Tool | Why |
|---|---|
| [neovim >= 0.12](https://github.com/neovim/neovim) | the runtime; `vim.pack` (the loader) arrives in 0.12 |
| [git](https://github.com/git/git) | every plugin operation, and github-sourced tools |
| [curl](https://github.com/curl/curl) | every catalogue, archive and binary download |
| [Nerd Font](https://github.com/ryanoasis/nerd-fonts) | the icons the whole UI is drawn with |

**Needed by the parts that use them**

| Tool | Why |
|---|---|
| [ripgrep](https://github.com/BurntSushi/ripgrep) | the grep finder and the project-wide replace |
| [fzf](https://github.com/junegunn/fzf) | the fzf finder backend (with `mkfifo`); without it the picker uses its own list |
| `cc` | compiles treesitter grammars (`parser.c` → `.so`) |
| `tar`, `unzip` | extract downloaded tool archives |
| [node](https://github.com/nodejs/node) + `npm` | npm-sourced language servers and formatters |
| `python3` | pypi-sourced tools (`pip install`) |
| [go](https://go.dev) | go-sourced tools |
| [cargo](https://www.rust-lang.org) | cargo-sourced tools, and the native fuzzy matcher's build — without it the matcher falls back to its pure-Lua twin |

`tree-sitter` (the CLI) is fetched automatically when a grammar needs generating.

---

## Install

```sh
git clone https://github.com/lvim-tech/lvim.git ~/.config/nvim
```

Plugins are loaded by **lvim-pack** on top of Neovim's built-in `vim.pack` and installed on first launch by **lvim-installer** — no external plugin manager is involved. LSP servers, treesitter parsers, linters, formatters and debug adapters are installed on demand by **lvim-pkg** when you first open a file of the matching type.

---

## Architecture

```
~/.config/nvim/
├── init.lua                ← version guard → require("core")
├── lua/
│   ├── core/
│   │   ├── init.lua        ← bootstrap: OS detection, globals, the lvim-pack clone + setup
│   │   ├── keys.lua        ← the keymap manifest's applier (merge + apply per section)
│   │   ├── funcs/          ← shared utility functions (editor, fs, plugins, system, table, ui)
│   │   └── types.lua       ← LuaLS type annotations for the config
│   ├── configs/            ← the editor itself
│   │   ├── base/           ← options, native search/completion, fold/icons
│   │   └── user/           ← user overrides for base configs
│   ├── keys/               ← the keymap MANIFEST
│   │   ├── base.lua        ← groups, global maps, LSP verbs, per-filetype leaves
│   │   └── user.lua        ← user keymap overrides, merged over the base
│   └── modules/            ← the plugins
│       ├── base/
│       │   ├── init.lua    ← THE PLUGIN SPEC (every plugin, its trigger and its deps)
│       │   └── configs/    ← per-plugin wiring (dependencies, editor, languages, ui, …)
│       └── user/           ← user plugin additions/overrides
├── .snapshots/             ← plugin pin sets (`active` names the live one)
└── nvim-pack-lock.json     ← vim.pack's lockfile: what is actually installed
```

The `base/user` separation means all customization lives in `modules/user/` and `configs/user/` — core files are never modified.

---

## Language support

Languages are owned by **lvim-lang**, not by a table in this repository. Each language is a
PROVIDER that declares everything about it in one place — its language server(s), how the project
root is found, the formatter/linter wiring, and, where such a thing genuinely exists, the debug
adapter, the test runner and the build recipe. `lvim-lsp` attaches the servers those providers
declare, and `lvim-pkg` installs the tools on first use.

Providers come in two shapes: a directory per language for the ones with real toolchain behaviour
(run / test / debug / SDK management), and a single declarative file for the ones that are "a
language server and its root markers". Both are registered the same way.

The live set is the authority, so ask the editor rather than a list that ages:

| Command | Answers |
|---|---|
| `:LvimLang providers` | every registered provider and the filetypes it claims |
| `:LvimLang status` | what is active for the current buffer — provider, servers, tools |
| `:checkhealth lvim-lang` | the same, plus which of its tools are actually installed |
| `:LvimLsp info` | the attached clients, their capabilities and diagnostics for this buffer |

Opening a file whose tools are missing offers to install them (Space toggles, Enter installs,
`q`/`Esc` skips for five minutes). A per-project override goes in `.lvim-lsp/config.lua` at the
project root; per-project server settings in `.lvim-ls/servers/<name>.lua`.

---

## Debug (DAP)

Debugging is `lvim-dap` (the client) + `lvim-dap-view` (the panel). Debug adapters are installed by lvim-pkg alongside the LSP servers.

Which languages can be debugged is a provider question, not a list kept here: a provider declares
its adapter (and only where one really exists — nothing is stubbed to pad a count). `:LvimLang
status` on a buffer says whether that language brings a debug adapter, and `:checkhealth lvim-lang`
says whether it is installed.

**Project-local DAP config:** `dap_utils.lua` loads a project-local `nvim-dap.lua` file from the project root when present, allowing per-project adapter/configuration overrides without touching the global config.

Keys are not listed here — they live in the keymap manifest (`lua/keys/base.lua`), and the
editor shows the live set: press a prefix and the hint panel names what follows it, `<Leader>uh`
opens the full cheatsheet, `<Leader>sk` searches every mapping.

---

## The set

Everything the configuration loads, from `lua/modules/base/init.lua`. Each plugin documents itself
in its own repository and its own `:help`; this is the map, not the manual. The live view is
`:LvimInstaller` (installed / pinned / outdated per plugin).

**Foundation**

| Plugin | What it is |
|---|---|
| [lvim-pack](https://github.com/lvim-tech/lvim-pack) | the loader: `vim.pack` underneath, dependency resolution, pins, eager order and the lazy triggers |
| [lvim-pkg](https://github.com/lvim-tech/lvim-pkg) | the data + operations hub for everything installable — packages, parsers, plugins |
| [lvim-installer](https://github.com/lvim-tech/lvim-installer) | the install UI: the first-start panel and the package browser |
| [lvim-nvim](https://github.com/lvim-tech/lvim-nvim) | the umbrella that forwards one option table to every plugin in the right order |
| [lvim-utils](https://github.com/lvim-tech/lvim-utils) | the shared base — palette, highlight factory, cursor, store, dock geometry, merge |
| [lvim-common](https://github.com/lvim-tech/lvim-common) | small editor quality-of-life modules (the universal `gx` opener among them) |
| [lvim-fuzzy](https://github.com/lvim-tech/lvim-fuzzy) | the native fuzzy matcher the picker and completion both rank through |
| [lvim-icons](https://github.com/lvim-tech/lvim-icons) | the icon provider and its highlight groups |
| [lvim-colorscheme](https://github.com/lvim-tech/lvim-colorscheme) | the theme engine — every family in soft / dark / darker / light, switched live |

**Interface**

| Plugin | What it is |
|---|---|
| [lvim-ui](https://github.com/lvim-tech/lvim-ui) | the floating UI toolkit: the surface/frame chassis and the select / tabs / input / info presenters |
| [lvim-hud](https://github.com/lvim-tech/lvim-hud) | everything on screen that is not text — statusline, winbar, tabline, statuscolumn, cmdline, messages |
| [lvim-msgarea](https://github.com/lvim-tech/lvim-msgarea) | the docked message zone (an Emacs-minibuffer-style area) |
| [lvim-dashboard](https://github.com/lvim-tech/lvim-dashboard) | the start screen |
| [lvim-picker](https://github.com/lvim-tech/lvim-picker) | the finders — files, grep, buffers, git, LSP locations — over fzf or its own list |
| [lvim-files](https://github.com/lvim-tech/lvim-files) | the file manager: a tree panel and an editable directory buffer over one model |
| [lvim-term](https://github.com/lvim-tech/lvim-term) | named, toggleable terminals with a tab bar |
| [lvim-shell](https://github.com/lvim-tech/lvim-shell) | TUI programs in a themed float, with presets for the common ones |
| [lvim-image](https://github.com/lvim-tech/lvim-image) | images inside the editor, across the terminal graphics protocols |
| [lvim-winpick](https://github.com/lvim-tech/lvim-winpick) | label a window and jump to it |
| [lvim-winmove](https://github.com/lvim-tech/lvim-winmove) | move and swap windows within a tab |
| [lvim-winnav](https://github.com/lvim-tech/lvim-winnav) | directional window navigation and resizing, handing off to the multiplexer at the edge |
| [lvim-keys-helper](https://github.com/lvim-tech/lvim-keys-helper) | the key-hint panel and the cheatsheet |
| [lvim-indent](https://github.com/lvim-tech/lvim-indent) | indent guides and the enclosing-scope guide |
| [lvim-context](https://github.com/lvim-tech/lvim-context) | the sticky header of the scopes that have scrolled off the top |
| [lvim-control-center](https://github.com/lvim-tech/lvim-control-center) | the settings panel, persisted |

**Editing**

| Plugin | What it is |
|---|---|
| [lvim-space](https://github.com/lvim-tech/lvim-space) | projects, workspaces, tabs and their files |
| [lvim-vault](https://github.com/lvim-tech/lvim-vault) | marks, jumps and a persistent macro bank in one panel |
| [lvim-undo](https://github.com/lvim-tech/lvim-undo) | the branching undo history as a timeline, with named checkpoints |
| [lvim-buf-history](https://github.com/lvim-tech/lvim-buf-history) | per-window buffer history, browser-style |
| [lvim-search](https://github.com/lvim-tech/lvim-search) | a counter beside every visible match, the nearest one painted |
| [lvim-replace](https://github.com/lvim-tech/lvim-replace) | project-wide find and replace with per-result marking |
| [lvim-qf-loc](https://github.com/lvim-tech/lvim-qf-loc) | the quickfix / location workflow: preview, editable list, context, browser |
| [lvim-jump](https://github.com/lvim-tech/lvim-jump) | label motions — enhanced `f`/`t`, live-search jump, treesitter targets |
| [lvim-move](https://github.com/lvim-tech/lvim-move) | move lines and selections in any direction |
| [lvim-comment](https://github.com/lvim-tech/lvim-comment) | line and block commenting, commentstring-aware |
| [lvim-pairs](https://github.com/lvim-tech/lvim-pairs) | autopairs, surround and autotag over one pair table |
| [lvim-cycle](https://github.com/lvim-tech/lvim-cycle) | smart increment/decrement — numbers, dates, booleans, operators |
| [lvim-table](https://github.com/lvim-tech/lvim-table) | table mode: realign as you type, row and column operations |
| [lvim-color-picker](https://github.com/lvim-tech/lvim-color-picker) | a slider picker, converter and inline highlighter |
| [lvim-render](https://github.com/lvim-tech/lvim-render) | in-buffer rendering of markdown, typst, org and latex |
| [lvim-linguistics](https://github.com/lvim-tech/lvim-linguistics) | per-mode keyboard layout and spelling |
| [lvim-calendar](https://github.com/lvim-tech/lvim-calendar) | calendar and agenda with pluggable day sources |
| [lvim-snippets](https://github.com/lvim-tech/lvim-snippets) | the snippet engine and its collections |
| [lvim-cmp](https://github.com/lvim-tech/lvim-cmp) | the completion engine |

**Languages, tools and data**

| Plugin | What it is |
|---|---|
| [lvim-lang](https://github.com/lvim-tech/lvim-lang) | the per-language providers: servers, roots, run / test / debug / SDK behaviour |
| [lvim-ls](https://github.com/lvim-tech/lvim-ls) | the language-server core — server configs, EFM tools, the attach lifecycle |
| [lvim-lsp](https://github.com/lvim-tech/lvim-lsp) | the LSP surface: diagnostics, outline, peek, hover, code actions |
| [lvim-ts](https://github.com/lvim-tech/lvim-ts) | the treesitter runtime over Neovim's own, with parser installation |
| [lvim-breadcrumbs](https://github.com/lvim-tech/lvim-breadcrumbs) | the symbol path to the cursor |
| [lvim-dap](https://github.com/lvim-tech/lvim-dap) | the debug client |
| [lvim-dap-view](https://github.com/lvim-tech/lvim-dap-view) | the debugger panels — watches, scopes, stack, breakpoints, REPL |
| [lvim-test](https://github.com/lvim-tech/lvim-test) | a granular test runner with treesitter discovery and streaming results |
| [lvim-build](https://github.com/lvim-tech/lvim-build) | build / run / test / lint recipes detected per project and file |
| [lvim-tasks](https://github.com/lvim-tech/lvim-tasks) | the task runner panel, with live output and history |
| [lvim-tex](https://github.com/lvim-tech/lvim-tex) | LaTeX as a build pipeline — compile, log-as-diagnostics, viewer, SyncTeX both ways |
| [lvim-git](https://github.com/lvim-tech/lvim-git) | the full git client — status, diff, log, blame, refs, and jj alongside it |
| [lvim-forge](https://github.com/lvim-tech/lvim-forge) | pull requests, issues and reviews from inside the editor |
| [lvim-db](https://github.com/lvim-tech/lvim-db) | the database client — connections, results, notes |
| [lvim-rest](https://github.com/lvim-tech/lvim-rest) | the REST client — `.http` documents, environments, chaining |
| [lvim-preview](https://github.com/lvim-tech/lvim-preview) | live browser preview with hot reload |
| [lvim-remote](https://github.com/lvim-tech/lvim-remote) | project file transfer over ssh/rsync |
| [lvim-keyring](https://github.com/lvim-tech/lvim-keyring) | the encrypted secrets wallet the others ask for credentials |
| [lvim-dependencies](https://github.com/lvim-tech/lvim-dependencies) | project dependency management across package managers |

The only plugin here that is not `lvim-tech`'s own is `sqlite.lua`, the storage library behind the
panels that keep real relational data.

## User Customization

All user customization goes in `lua/configs/user/` and `lua/modules/user/`. Core files are never modified.

### Editor Config

```lua
-- lua/configs/user/init.lua

-- Disable a base config function
configs["base_vim"] = false

-- Rewrite a base config function
configs["base_vim"] = {
    -- your code
}

-- Add a new config function
configs["user_vim"] = {
    -- your code
}
```

### Plugins

```lua
-- lua/modules/user/init.lua

-- Disable a base plugin
modules["lvim-tech/lvim-calendar"] = false

-- Override a base plugin's settings
modules["lvim-tech/lvim-calendar"] = {
    -- the spec fields lvim-pack reads: event / ft / cmd / keys, dependencies,
    -- priority, opts or config, build …
}

-- Add a new plugin
modules["author/new-plugin"] = {
    config = function()
        require("new-plugin").setup({})
    end,
}
```

### LSP — Language Server Config

Servers are declared by their lvim-lang provider, not by a file in this repository — see
[Language support](#language-support). Add a language by writing a provider (a declarative file is
often enough); adjust an existing one per project with `.lvim-ls/servers/<name>.lua` in the project
root, or globally through `lvim-ls`'s own options in `modules/base/configs/languages/init.lua`.

### LSP — Global Feature Flags

Change at runtime via `:LvimControlCenter` → LSP tab, or programmatically:

```lua
-- Apply for session only (memory)
require("lvim-lsp.state").config.features.auto_format = false

-- Apply permanently (survives restarts)
require("lvim-lsp.core.globals").save({ auto_format = false })
```

### LSP — Per-Project Override

Create `.lvim-lsp/config.lua` in any project root:

```lua
-- .lvim-lsp/config.lua
return {
    auto_format = false,
    inlay_hints = true,
    code_lens = { enabled = false },
}
```

Run `:LvimLsp reattach` to apply immediately without restarting.

---

## Changelog

### v10.0.0

**The distribution is now first-party.** Every borrowed plugin has been replaced by an `lvim-tech`
one; what remains from outside the set is a single runtime library (`sqlite.lua`).

- **Loading** — no external plugin manager. `lvim-pack` drives Neovim's built-in `vim.pack`:
  it resolves dependencies, applies the version pins, loads eagerly by priority and wires the
  `event` / `ft` / `cmd` / `keys` triggers. Minimum Neovim is **0.12**, where `vim.pack` arrived.
- **Installing** — `lvim-installer` owns the first-start panel and the package browser; `lvim-pkg`
  installs and tracks LSP servers, treesitter parsers, linters, formatters and debug adapters.
- **Keys** — one manifest, `lua/keys/base.lua`: group labels, global maps, capability-guarded
  LSP verbs applied on `LspAttach`, per-filetype leaves, and overrides forwarded into a plugin's own
  key table. User overrides live in `lua/keys/user.lua`.
- **UI** — every popup, picker and prompt goes through `lvim-ui` / `lvim-hud`; there is no
  hand-rolled float left in the configuration.
