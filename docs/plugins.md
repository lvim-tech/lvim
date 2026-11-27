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
| [sqlite.lua](https://github.com/kkharji/sqlite.lua) | The one third-party runtime **library** the set requires: the storage behind the panels that keep real relational data. | startup · priority 900 |

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
| [lvim-commander](https://github.com/lvim-tech/lvim-commander) | The two-panel file commander, the counterpart of the terminal `lvc`: marks, trash, archives, remotes, devices, git state, previews. *(builds its helper programs on first use)* | `:LvimCommander` |
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
| [lvim-ansi](https://github.com/lvim-tech/lvim-ansi) | Terminal colour in a buffer — painted from a `.spans` sidecar or from the escapes themselves, with the text left plain. | startup |
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
| [lvim-ansi](https://github.com/lvim-tech/lvim-ansi) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-breadcrumbs](https://github.com/lvim-tech/lvim-breadcrumbs) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-build](https://github.com/lvim-tech/lvim-build) | [lvim-tasks](https://github.com/lvim-tech/lvim-tasks) |
| [lvim-calendar](https://github.com/lvim-tech/lvim-calendar) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-cmp](https://github.com/lvim-tech/lvim-cmp) | [lvim-fuzzy](https://github.com/lvim-tech/lvim-fuzzy), [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-color-picker](https://github.com/lvim-tech/lvim-color-picker) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-colorscheme](https://github.com/lvim-tech/lvim-colorscheme) | [lvim-utils](https://github.com/lvim-tech/lvim-utils), [lvim-control-center](https://github.com/lvim-tech/lvim-control-center) |
| [lvim-commander](https://github.com/lvim-tech/lvim-commander) | [lvim-picker](https://github.com/lvim-tech/lvim-picker), [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-common](https://github.com/lvim-tech/lvim-common) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-context](https://github.com/lvim-tech/lvim-context) | [lvim-ts](https://github.com/lvim-tech/lvim-ts), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-control-center](https://github.com/lvim-tech/lvim-control-center) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-cycle](https://github.com/lvim-tech/lvim-cycle) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-dap-view](https://github.com/lvim-tech/lvim-dap-view) | [lvim-dap](https://github.com/lvim-tech/lvim-dap) |
| [lvim-dashboard](https://github.com/lvim-tech/lvim-dashboard) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-db](https://github.com/lvim-tech/lvim-db) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-dependencies](https://github.com/lvim-tech/lvim-dependencies) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-files](https://github.com/lvim-tech/lvim-files) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-forge](https://github.com/lvim-tech/lvim-forge) | [sqlite.lua](https://github.com/kkharji/sqlite.lua), [lvim-git](https://github.com/lvim-tech/lvim-git) |
| [lvim-git](https://github.com/lvim-tech/lvim-git) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-hud](https://github.com/lvim-tech/lvim-hud) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-icons](https://github.com/lvim-tech/lvim-icons) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-image](https://github.com/lvim-tech/lvim-image) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-indent](https://github.com/lvim-tech/lvim-indent) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-installer](https://github.com/lvim-tech/lvim-installer) | [lvim-pkg](https://github.com/lvim-tech/lvim-pkg), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-keyring](https://github.com/lvim-tech/lvim-keyring) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-lang](https://github.com/lvim-tech/lvim-lang) | [lvim-lsp](https://github.com/lvim-tech/lvim-lsp), [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-linguistics](https://github.com/lvim-tech/lvim-linguistics) | [lvim-utils](https://github.com/lvim-tech/lvim-utils), [lvim-control-center](https://github.com/lvim-tech/lvim-control-center) |
| [lvim-lsp](https://github.com/lvim-tech/lvim-lsp) | [lvim-ls](https://github.com/lvim-tech/lvim-ls), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-msgarea](https://github.com/lvim-tech/lvim-msgarea) | [lvim-hud](https://github.com/lvim-tech/lvim-hud), [lvim-picker](https://github.com/lvim-tech/lvim-picker), [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-nvim](https://github.com/lvim-tech/lvim-nvim) | [lvim-utils](https://github.com/lvim-tech/lvim-utils), [lvim-common](https://github.com/lvim-tech/lvim-common), [lvim-hud](https://github.com/lvim-tech/lvim-hud), [lvim-msgarea](https://github.com/lvim-tech/lvim-msgarea), [lvim-picker](https://github.com/lvim-tech/lvim-picker), [lvim-image](https://github.com/lvim-tech/lvim-image), [lvim-snippets](https://github.com/lvim-tech/lvim-snippets) |
| [lvim-pairs](https://github.com/lvim-tech/lvim-pairs) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-picker](https://github.com/lvim-tech/lvim-picker) | [lvim-fuzzy](https://github.com/lvim-tech/lvim-fuzzy), [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-preview](https://github.com/lvim-tech/lvim-preview) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-remote](https://github.com/lvim-tech/lvim-remote) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-render](https://github.com/lvim-tech/lvim-render) | [lvim-ts](https://github.com/lvim-tech/lvim-ts), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-replace](https://github.com/lvim-tech/lvim-replace) | [lvim-utils](https://github.com/lvim-tech/lvim-utils), [lvim-ui](https://github.com/lvim-tech/lvim-ui) |
| [lvim-rest](https://github.com/lvim-tech/lvim-rest) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-search](https://github.com/lvim-tech/lvim-search) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-snippets](https://github.com/lvim-tech/lvim-snippets) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-space](https://github.com/lvim-tech/lvim-space) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-table](https://github.com/lvim-tech/lvim-table) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-tasks](https://github.com/lvim-tech/lvim-tasks) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-term](https://github.com/lvim-tech/lvim-term) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-test](https://github.com/lvim-tech/lvim-test) | [lvim-tasks](https://github.com/lvim-tech/lvim-tasks), [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils), [lvim-ts](https://github.com/lvim-tech/lvim-ts) |
| [lvim-tex](https://github.com/lvim-tech/lvim-tex) | [lvim-utils](https://github.com/lvim-tech/lvim-utils), [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-preview](https://github.com/lvim-tech/lvim-preview), [lvim-snippets](https://github.com/lvim-tech/lvim-snippets) |
| [lvim-ts](https://github.com/lvim-tech/lvim-ts) | [lvim-pkg](https://github.com/lvim-tech/lvim-pkg) |
| [lvim-ui](https://github.com/lvim-tech/lvim-ui) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-undo](https://github.com/lvim-tech/lvim-undo) | [lvim-utils](https://github.com/lvim-tech/lvim-utils), [lvim-ui](https://github.com/lvim-tech/lvim-ui) |
| [lvim-vault](https://github.com/lvim-tech/lvim-vault) | [lvim-ui](https://github.com/lvim-tech/lvim-ui), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-winmove](https://github.com/lvim-tech/lvim-winmove) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-winnav](https://github.com/lvim-tech/lvim-winnav) | [lvim-winmove](https://github.com/lvim-tech/lvim-winmove), [lvim-utils](https://github.com/lvim-tech/lvim-utils) |
| [lvim-winpick](https://github.com/lvim-tech/lvim-winpick) | [lvim-utils](https://github.com/lvim-tech/lvim-utils) |

## Helper programs

`lvim-commander` (and the `lvim-picker` menus it opens) lean on a few small Rust programs. They are **not**
plugins and `lvim-pack` does not manage them: they are built from source, once, and nothing has to be
installed first except `git` and `cargo`. Without them the rest of the configuration is unaffected.

| Program | From | What it does |
|---|---|---|
| `lvim-commander-host` | [lvim-fuzzy-commander-core](https://github.com/lvim-tech/lvim-fuzzy-commander-core) | The filesystem side of the commander: listing, sorting, copy / move / delete, the trash, archives. The same crate backs the terminal `lvc`, so both behave alike. |
| `lvim-plugin` | [lvim-fuzzy-plugin](https://github.com/lvim-tech/lvim-fuzzy-plugin) | The plugin host: starts a plugin program, speaks JSON lines to it. Neovim talks to it through `lvim-utils.pluginhost`. |
| `lvim-fuzzy-plugin-git` | [lvim-fuzzy-plugin-git](https://github.com/lvim-tech/lvim-fuzzy-plugin-git) | The git marks column and the git bar (branch, ahead / behind, counts), also for a previewed folder; tags, submodules, move. |
| `lvim-fuzzy-plugin-remote` | [lvim-fuzzy-plugin-remote](https://github.com/lvim-tech/lvim-fuzzy-plugin-remote) | Remote locations (ssh): add, edit, delete, connect. |
| `lvim-fuzzy-plugin-devices` | [lvim-fuzzy-plugin-devices](https://github.com/lvim-tech/lvim-fuzzy-plugin-devices) | The devices menu: mount, unmount, open. |
| `lvim-fuzzy-plugin-preview` | [lvim-fuzzy-plugin-preview](https://github.com/lvim-tech/lvim-fuzzy-plugin-preview) | Previews for files the commander cannot show as text. |
| `lvim-fuzzy-plugin-open` | [lvim-fuzzy-plugin-open](https://github.com/lvim-tech/lvim-fuzzy-plugin-open) | "Open with": the program for a file type. |

**How they are resolved.**

- Every crate depends on the others through `git` dependencies on `github.com/lvim-tech/…`, so a lone
  clone builds without any sibling folder. A developer with all repositories side by side adds a
  `[patch]` in a `.cargo/config.toml` above them and builds against the local checkouts instead.
- One bootstrap script, `lvim-fuzzy-plugin/scripts/bootstrap.sh`, fetches, builds and installs a chosen set of
  parts (`commander-host host git remote devices preview open`; `cli` adds `lvim-fuzzy-cli`, which takes minutes).
  It uses a sibling checkout when there is one, otherwise clones into `~/.local/share/lvim-tech/src`.
  Programs go to `${XDG_BIN_HOME:-~/.local/bin}`; each plugin's `plugin.toml` to `~/.config/lvim-plugins/<name>/`.
- From Neovim: the first `:LvimCommander` builds what is missing, `:LvimCommanderInstall` does it on demand, and a
  `build = "sh scripts/install.sh"` hook (present in `lvim-commander` and `lvim-picker`) does it from `lvim-pack`.
  Programs are looked up on `PATH` and in `~/.local/bin` (`lvim-utils.pluginhost.which`), so a Neovim started
  from a launcher still finds them. `:checkhealth lvim-commander` and `:checkhealth lvim-picker` say what is missing.
- From the terminal: `scripts/install.sh` of `lvc` and `lfz` fetches the same host and plugins. The terminal tools
  need none of the Neovim plugins, and the Neovim plugins need neither `lvc` nor `lfz`.

**What the latest versions of the plugins expect from each other.**

| Plugin | Needs from | For |
|---|---|---|
| lvim-commander | lvim-ui | The surface chassis (header tabs, panels, bars, footer); `close_keys = {}` so that `q` and `<Esc>` are the commander's own keys. |
| lvim-commander | lvim-utils | `pluginhost` (client of `lvim-plugin`, `which`, keepalive handling) and the highlight factory for the palette-coloured bars. |
| lvim-commander | lvim-picker | The menus opened by plugin instructions (devices, remotes): the `hints`, `placeholder` and `start_in_list` options, `layout = "float"`. |
| lvim-calendar | lvim-ui | The `moves` flag on a keymap, which lets the day cursor keep `j` / `k` (otherwise lvim-ui refuses a keymap on the navigation keys). |
| lvim-picker | lvim-utils | `pluginhost.which` for the engine lookup and the `LvimUiPickerPrompt` highlight. |

The pins in `.snapshots/default` are a consistent set: updating one of lvim-ui, lvim-utils, lvim-picker or
lvim-commander on its own may break the others.

## Third party

One entry in the whole spec is not `lvim-tech`'s own: `sqlite.lua`, a runtime **library** (not a
plugin) that backs the panels keeping real relational data — vault macros, control-center settings,
lvim-space projects, the database client, build and task history.
