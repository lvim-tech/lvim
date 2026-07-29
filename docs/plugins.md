# The plugin set

Every plugin the configuration loads, what it is, and **when** it loads. Each one documents itself in
its own repository and its own `:help` — this is the map, not the manual. The live view is
`:LvimInstaller` (installed / pinned / outdated per plugin).

## How loading works

There is no external plugin manager. `lvim-pack` reads the spec in `lua/modules/base/init.lua`,
resolves dependencies, applies the pins from the active snapshot and then loads in two waves:

- **at startup**, highest `priority` first — for anything that has to be listening before the first
  keystroke (a decoration provider, the theme, the chrome);
- **on a trigger** — `event` (`VeryLazy`, `LspAttach`, …), `ft`, `cmd` or `keys`. A command trigger
  installs a stub, so `:LvimTerm` works before lvim-term has ever been loaded.

A plugin listed as loading on a command is not idle: its keymaps in the manifest call that command,
so the first keystroke pulls it in. What each one's command actually does is in
[commands.md](commands.md); its keys are in [keys.md](keys.md).

## Foundation

What the distribution stands on: the loader, the data hub, the shared base. Every one of these is loaded at startup — nothing else can wait for them.

| Plugin | What it is | Loads |
|---|---|---|
| [lvim-pack](https://github.com/lvim-tech/lvim-pack) | The loader over Neovim's `vim.pack`: dependencies, version pins, eager order, the lazy triggers, the build hooks. | bootstrapped in `init.lua` |
| [lvim-pkg](https://github.com/lvim-tech/lvim-pkg) | The data and operations hub for everything installable — packages, treesitter parsers, plugins, snapshots. | startup |
| [lvim-installer](https://github.com/lvim-tech/lvim-installer) | The install UI: the first-start progress panel and the package browser. | startup |
| [lvim-nvim](https://github.com/lvim-tech/lvim-nvim) | The umbrella that forwards one option table to every plugin in a dependency-safe order. | startup |
| [lvim-utils](https://github.com/lvim-tech/lvim-utils) | The shared base — palette, highlight factory, cursor manager, store, dock geometry, merge. | startup · priority 100 |
| [lvim-common](https://github.com/lvim-tech/lvim-common) | Small editor quality-of-life modules (the universal `gx` opener among them). | startup |
| [lvim-fuzzy](https://github.com/lvim-tech/lvim-fuzzy) | The native fuzzy matcher the picker and the completion rank through; falls back to a pure-Lua twin. *(has a build step)* | startup |
| [lvim-icons](https://github.com/lvim-tech/lvim-icons) | The icon provider and its highlight groups. | startup · priority 100 |
| [lvim-colorscheme](https://github.com/lvim-tech/lvim-colorscheme) | The theme engine — every family in soft / dark / darker / light, switched live. | startup · priority 100 |
| `sqlite.lua` | The one third-party runtime **library** the set requires: the storage behind the panels that keep real relational data. | startup · priority 900 |

## Interface

Everything drawn on screen that is not the text you are editing.

| Plugin | What it is | Loads |
|---|---|---|
| [lvim-ui](https://github.com/lvim-tech/lvim-ui) | The floating UI toolkit: the surface/frame chassis and the select / tabs / input / info presenters. | startup |
| [lvim-hud](https://github.com/lvim-tech/lvim-hud) | The chrome — statusline, winbar, tabline, statuscolumn, cmdline and messages. | startup |
| [lvim-msgarea](https://github.com/lvim-tech/lvim-msgarea) | The docked message zone, a minibuffer-style area at the bottom of the screen. | startup |
| [lvim-dashboard](https://github.com/lvim-tech/lvim-dashboard) | The start screen. | startup |
| [lvim-picker](https://github.com/lvim-tech/lvim-picker) | The finders — files, grep, buffers, git, LSP locations — over fzf or its own list. | startup |
| [lvim-files](https://github.com/lvim-tech/lvim-files) | The file manager: a tree side panel and an editable directory buffer over one filesystem model. | startup |
| [lvim-term](https://github.com/lvim-tech/lvim-term) | Named, toggleable terminals with a tab bar. | `:LvimTerm` |
| [lvim-shell](https://github.com/lvim-tech/lvim-shell) | TUI programs in a themed float, with presets for the common ones. | `:LvimShell` |
| [lvim-image](https://github.com/lvim-tech/lvim-image) | Images inside the editor, across the terminal graphics protocols. | startup |
| [lvim-winpick](https://github.com/lvim-tech/lvim-winpick) | Label a window and jump to it. | `:LvimWinPick` |
| [lvim-winmove](https://github.com/lvim-tech/lvim-winmove) | Move and swap windows within a tab. | `:LvimWinMove` |
| [lvim-winnav](https://github.com/lvim-tech/lvim-winnav) | Directional window navigation and resizing, handing off to the multiplexer at the edge of the layout. | startup |
| [lvim-keys-helper](https://github.com/lvim-tech/lvim-keys-helper) | The key-hint panel and the cheatsheet, built from the keymap manifest. | startup |
| [lvim-indent](https://github.com/lvim-tech/lvim-indent) | Indent guides through blank lines, and the enclosing-scope guide. | startup |
| [lvim-context](https://github.com/lvim-tech/lvim-context) | The sticky header of the scopes that have scrolled off the top. | startup |
| [lvim-control-center](https://github.com/lvim-tech/lvim-control-center) | The settings panel, persisted across restarts. | startup |

## Editing

The verbs — what you do to a buffer.

| Plugin | What it is | Loads |
|---|---|---|
| [lvim-space](https://github.com/lvim-tech/lvim-space) | Projects, workspaces, tabs and the files inside them. | startup |
| [lvim-vault](https://github.com/lvim-tech/lvim-vault) | Marks, jumps and a persistent macro bank in one panel. | `:LvimVault` |
| [lvim-undo](https://github.com/lvim-tech/lvim-undo) | The branching undo history as a timeline, with named checkpoints. | `VeryLazy` |
| [lvim-buf-history](https://github.com/lvim-tech/lvim-buf-history) | Per-window buffer history, browser-style back and forward. | `VeryLazy` |
| [lvim-search](https://github.com/lvim-tech/lvim-search) | A counter beside every visible match, with the nearest one painted above `hlsearch`. | startup |
| [lvim-replace](https://github.com/lvim-tech/lvim-replace) | Project-wide find and replace with per-result marking. | `:LvimReplace` |
| [lvim-qf-loc](https://github.com/lvim-tech/lvim-qf-loc) | The quickfix / location workflow: preview, editable list, context, browser. | `VeryLazy` |
| [lvim-jump](https://github.com/lvim-tech/lvim-jump) | Label motions — enhanced `f`/`t`, live-search jump, treesitter targets. | `VeryLazy` |
| [lvim-move](https://github.com/lvim-tech/lvim-move) | Move lines and selections in any direction. | `VeryLazy` |
| [lvim-comment](https://github.com/lvim-tech/lvim-comment) | Line and block commenting, commentstring resolved per position. | `VeryLazy` |
| [lvim-pairs](https://github.com/lvim-tech/lvim-pairs) | Autopairs, surround and autotag over one shared pair table. | startup |
| [lvim-cycle](https://github.com/lvim-tech/lvim-cycle) | Smart increment / decrement — numbers, dates, booleans, operators. | `VeryLazy` |
| [lvim-table](https://github.com/lvim-tech/lvim-table) | Table mode: realign as you type, row and column operations, formulas. | `:LvimTable` |
| [lvim-color-picker](https://github.com/lvim-tech/lvim-color-picker) | A slider picker, a converter and an inline highlighter. | `:LvimColorPicker`, its keys |
| [lvim-render](https://github.com/lvim-tech/lvim-render) | In-buffer rendering of markdown, typst, org and latex. | a matching filetype |
| [lvim-linguistics](https://github.com/lvim-tech/lvim-linguistics) | Per-mode keyboard layout and spelling. | `VeryLazy` |
| [lvim-calendar](https://github.com/lvim-tech/lvim-calendar) | Calendar and agenda with pluggable day sources. | `:LvimCalendar` |
| [lvim-snippets](https://github.com/lvim-tech/lvim-snippets) | The snippet engine and its collections. | startup |
| [lvim-cmp](https://github.com/lvim-tech/lvim-cmp) | The completion engine, ranked through lvim-fuzzy. | startup |

## Languages, tools and data

Everything that knows what a language, a project or a service is.

| Plugin | What it is | Loads |
|---|---|---|
| [lvim-lang](https://github.com/lvim-tech/lvim-lang) | The per-language providers: servers, project roots, run / test / debug / SDK behaviour. See [languages.md](languages.md). | a matching filetype |
| [lvim-ls](https://github.com/lvim-tech/lvim-ls) | The language-server core — server configs, EFM tools, the attach lifecycle. | startup |
| [lvim-lsp](https://github.com/lvim-tech/lvim-lsp) | The LSP surface: diagnostics, outline, peek, hover, code actions. | startup |
| [lvim-ts](https://github.com/lvim-tech/lvim-ts) | The treesitter runtime over Neovim's own, with parser installation. | startup |
| [lvim-breadcrumbs](https://github.com/lvim-tech/lvim-breadcrumbs) | The symbol path to the cursor. | `LspAttach` |
| [lvim-dap](https://github.com/lvim-tech/lvim-dap) | The debug client. | `VeryLazy` |
| [lvim-dap-view](https://github.com/lvim-tech/lvim-dap-view) | The debugger panels — watches, scopes, stack, breakpoints, REPL. | `VeryLazy` |
| [lvim-test](https://github.com/lvim-tech/lvim-test) | A granular test runner with treesitter discovery and streaming results. | a matching filetype, `:LvimTest` |
| [lvim-build](https://github.com/lvim-tech/lvim-build) | Build / run / test / lint recipes detected per project and per file. | `:LvimBuild` |
| [lvim-tasks](https://github.com/lvim-tech/lvim-tasks) | The task runner panel, with live output and history. | `:LvimTasks` |
| [lvim-tex](https://github.com/lvim-tech/lvim-tex) | LaTeX as a build pipeline — compile, log-as-diagnostics, viewer, SyncTeX both ways. | a matching filetype |
| [lvim-git](https://github.com/lvim-tech/lvim-git) | The full git client — status, diff, log, blame, refs, and jj alongside it. | startup |
| [lvim-forge](https://github.com/lvim-tech/lvim-forge) | Pull requests, issues and reviews from inside the editor. | `:LvimForge` |
| [lvim-db](https://github.com/lvim-tech/lvim-db) | The database client — connections, results, notes. | `:LvimDb` |
| [lvim-rest](https://github.com/lvim-tech/lvim-rest) | The REST client — `.http` documents, environments, chaining. | a matching filetype, `:LvimRest` |
| [lvim-preview](https://github.com/lvim-tech/lvim-preview) | Live browser preview with hot reload, served by its own pure-Lua server. | `:LvimPreview` |
| [lvim-remote](https://github.com/lvim-tech/lvim-remote) | Project file transfer over ssh / rsync. | `:LvimRemote` |
| [lvim-keyring](https://github.com/lvim-tech/lvim-keyring) | The encrypted secrets wallet the others ask for credentials. | `VeryLazy` |
| [lvim-dependencies](https://github.com/lvim-tech/lvim-dependencies) | Project dependency management across package managers. | `VeryLazy` |

## Dependencies

What each plugin declares as a hard dependency — the loader installs and loads these first.

| Plugin | Depends on |
|---|---|
| `lvim-breadcrumbs` | lvim-utils |
| `lvim-build` | lvim-tasks |
| `lvim-calendar` | lvim-ui, lvim-utils |
| `lvim-cmp` | lvim-fuzzy, lvim-ui, lvim-utils |
| `lvim-color-picker` | lvim-ui, lvim-utils |
| `lvim-colorscheme` | lvim-utils, lvim-control-center |
| `lvim-common` | lvim-utils |
| `lvim-context` | lvim-ts, lvim-utils |
| `lvim-control-center` | lvim-utils |
| `lvim-cycle` | lvim-utils |
| `lvim-dap-view` | lvim-dap |
| `lvim-dashboard` | lvim-utils |
| `lvim-db` | lvim-ui, lvim-utils |
| `lvim-dependencies` | lvim-utils |
| `lvim-files` | lvim-ui, lvim-utils |
| `lvim-forge` | sqlite.lua, lvim-git |
| `lvim-git` | lvim-ui, lvim-utils |
| `lvim-hud` | lvim-ui, lvim-utils |
| `lvim-icons` | lvim-utils |
| `lvim-image` | lvim-ui, lvim-utils |
| `lvim-indent` | lvim-utils |
| `lvim-installer` | lvim-pkg, lvim-utils |
| `lvim-keyring` | lvim-ui, lvim-utils |
| `lvim-lang` | lvim-lsp, lvim-ui, lvim-utils |
| `lvim-linguistics` | lvim-utils, lvim-control-center |
| `lvim-lsp` | lvim-ls, lvim-utils |
| `lvim-msgarea` | lvim-hud, lvim-picker, lvim-ui, lvim-utils |
| `lvim-nvim` | lvim-utils, lvim-common, lvim-hud, lvim-msgarea, lvim-picker, lvim-image, lvim-snippets |
| `lvim-pairs` | lvim-utils |
| `lvim-picker` | lvim-fuzzy, lvim-ui, lvim-utils |
| `lvim-preview` | lvim-ui, lvim-utils |
| `lvim-remote` | lvim-ui, lvim-utils |
| `lvim-render` | lvim-ts, lvim-utils |
| `lvim-replace` | lvim-utils, lvim-ui |
| `lvim-rest` | lvim-ui, lvim-utils |
| `lvim-search` | lvim-utils |
| `lvim-snippets` | lvim-utils |
| `lvim-space` | lvim-utils |
| `lvim-table` | lvim-utils |
| `lvim-tasks` | lvim-ui, lvim-utils |
| `lvim-term` | lvim-ui, lvim-utils |
| `lvim-test` | lvim-tasks, lvim-ui, lvim-utils, lvim-ts |
| `lvim-tex` | lvim-utils, lvim-ui, lvim-preview, lvim-snippets |
| `lvim-ts` | lvim-pkg |
| `lvim-ui` | lvim-utils |
| `lvim-undo` | lvim-utils, lvim-ui |
| `lvim-vault` | lvim-ui, lvim-utils |
| `lvim-winmove` | lvim-utils |
| `lvim-winnav` | lvim-winmove, lvim-utils |
| `lvim-winpick` | lvim-utils |

## Third party

One entry in the whole spec is not `lvim-tech`'s own: `sqlite.lua`, a runtime **library** (not a
plugin) that backs the panels keeping real relational data — vault macros, control-center settings,
lvim-space projects, the database client, build and task history.
