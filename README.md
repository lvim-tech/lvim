# LVIM IDE

![LVIM IDE](/assets/lvim-ide-logo.png)

> A modular Neovim configuration written in Lua, built around a first-party plugin ecosystem — `lvim-tech/*` — that provides LSP management, settings persistence, project/workspace handling, colorschemes, and more. Fully customizable without touching core files.

> Current version — **9.0.0** (2026-03-21)

---

## Table of Contents

- [Requirements](#requirements)
- [Install](#install)
- [Architecture](#architecture)
- [LSP Support](#lsp-support)
- [Debug (DAP)](#debug-dap)
- [lvim-tech Plugin Ecosystem](#lvim-tech-plugin-ecosystem)
    - [lvim-lsp](#lvim-lsp)
    - [lvim-control-center](#lvim-control-center)
    - [lvim-colorscheme](#lvim-colorscheme)
    - [lvim-utils](#lvim-utils)
    - [lvim-space](#lvim-space)
    - [lvim-linguistics](#lvim-linguistics)
    - [lvim-shell](#lvim-shell)
    - [lvim-move](#lvim-move)
    - [lvim-qf-loc](#lvim-qf-loc)
- [User Customization](#user-customization)
- [Changelog](#changelog)

---

## Requirements

| Tool                                                    | Purpose                |
| ------------------------------------------------------- | ---------------------- |
| [neovim >= 0.11.4](https://github.com/neovim/neovim)    | Runtime                |
| [pynvim](https://github.com/neovim/pynvim)              | Python provider        |
| [neovim-remote](https://github.com/mhinz/neovim-remote) | Remote control         |
| [node](https://github.com/nodejs/node)                  | JS/TS language servers |
| [ripgrep](https://github.com/BurntSushi/ripgrep)        | Search backend         |
| [fzf](https://github.com/junegunn/fzf)                  | Fuzzy finder binary    |
| [git](https://github.com/git/git)                       | Version control        |
| [curl](https://github.com/curl/curl)                    | HTTP downloads         |
| [wget](https://www.gnu.org/software/wget/)              | HTTP downloads         |
| [tar](https://www.gnu.org/software/tar/)                | Archive extraction     |
| [gzip](https://www.gnu.org/software/gzip/)              | Compression            |
| [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)   | Icons                  |
| [sed](https://github.com/mirror/sed)                    | Text processing        |

---

## Install

```sh
git clone https://github.com/lvim-tech/lvim.git ~/.config/nvim
```

Plugin dependencies are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) and installed automatically on first launch. LSP servers, linters, formatters, and debuggers are installed on demand via Mason when you open a file of the corresponding type.

---

## Architecture

```
~/.config/nvim/
├── lua/
│   ├── configs/
│   │   ├── base/           ← base editor settings, keymaps, options, UI
│   │   └── user/           ← user overrides for base configs
│   ├── core/
│   │   ├── init.lua        ← bootstrap: OS detection, globals, lazy load
│   │   ├── lazy.lua        ← lazy.nvim integration
│   │   ├── funcs/          ← shared utility functions
│   │   └── types.lua       ← LuaLS type annotations for the entire config
│   └── modules/
│       ├── base/
│       │   ├── init.lua    ← all plugin registrations
│       │   └── configs/    ← per-plugin configuration
│       │       ├── dependencies/
│       │       ├── editor/
│       │       │   └── control_center/   ← lvim-control-center groups
│       │       ├── languages/
│       │       │   └── lsp/
│       │       │       ├── servers/      ← per-language LSP configs (34 files)
│       │       │       ├── dap_utils.lua ← DAP process picker & local config loader
│       │       │       ├── diagnostics.lua
│       │       │       └── file_types.lua
│       │       └── ui/
│       │           └── heirline/         ← statusline, winbar, statuscolumn components
│       └── user/
│           ├── init.lua    ← user plugin additions/overrides
│           └── configs/    ← user plugin configs
```

The `base/user` separation means all customization lives in `modules/user/` and `configs/user/` — core files are never modified.

---

## LSP Support

LSP is managed entirely by `lvim-lsp` (see below). Language server configs live in `lua/modules/base/configs/languages/lsp/servers/` — one file per language.

**Supported languages (34):**

| Language          | Server                                   | Notes                       |
| ----------------- | ---------------------------------------- | --------------------------- |
| Angular           | `angularls`                              |                             |
| Astro             | `astro`                                  |                             |
| C / C++           | `clangd` + `cpptools` DAP                | cpplint via EFM             |
| CMake             | `cmake`                                  |                             |
| CSS / SCSS / Less | `vscode-css-language-server`             |                             |
| D                 | `serve-d`                                |                             |
| Dart / Flutter    | `dartls`                                 | flutter-tools integration   |
| Emmet             | `emmet-language-server`                  |                             |
| Go                | `gopls` + `delve` DAP                    | golangci-lint via EFM       |
| Helm              | `helm_ls`                                |                             |
| HTML              | `vscode-html-language-server`            | prettierd via EFM           |
| JSON              | `vscode-json-language-server`            |                             |
| JS / TS           | `typescript-language-server` + DAP       | prettierd via EFM           |
| Kotlin            | `kotlin-language-server`                 |                             |
| LaTeX             | `texlab`                                 | vimtex integration          |
| Lua               | `lua-language-server` + `osv` DAP        | stylua via EFM              |
| Markdown          | `marksman`                               | cbfmt via EFM               |
| Nginx             | `nginx-language-server`                  |                             |
| OCaml             | `ocamllsp`                               |                             |
| Perl              | `PerlNavigator`                          |                             |
| PHP               | `intelephense` + `php-debug-adapter` DAP |                             |
| Python            | `pyright` + `debugpy` DAP                | black via EFM               |
| R                 | `r-languageserver`                       |                             |
| Rust              | `rust-analyzer` + `codelldb` DAP         |                             |
| Scala             | `metals` + DAP                           | nvim-metals integration     |
| Shell             | `bash-language-server`                   | shfmt via EFM, vint via EFM |
| SQL               | `sqls`                                   |                             |
| Stylelint         | `stylelint-lsp`                          |                             |
| Tailwind          | `tailwindcss-language-server`            |                             |
| TOML              | `taplo`                                  |                             |
| Vim               | `vim-language-server`                    |                             |
| Vue               | `volar`                                  |                             |
| XML               | `lemminx`                                |                             |
| YAML              | `yaml-language-server`                   | yamllint + yamlfmt via EFM  |
| Zig               | `zls`                                    |                             |

---

## Debug (DAP)

DAP is managed by `nvim-dap` + `nvim-dap-view`. Debug adapters are installed via Mason automatically alongside LSP servers.

**Languages with DAP support (8):**

| Language | Adapter                             |
| -------- | ----------------------------------- |
| C / C++  | `cpptools` (OpenDebugAD7)           |
| Go       | `delve` (dlv dap, local port 38697) |
| JS / TS  | `vscode-js-debug`                   |
| Lua      | `one-small-step-for-vimkind` (osv)  |
| PHP      | `php-debug-adapter`                 |
| Python   | `debugpy`                           |
| Rust     | `codelldb`                          |
| Scala    | Metals built-in DAP                 |

**Project-local DAP config:** `dap_utils.lua` loads a project-local `nvim-dap.lua` file from the project root when present, allowing per-project adapter/configuration overrides without touching the global config.

**DAP keymaps:**

| Key     | Action                      |
| ------- | --------------------------- |
| `<A-1>` | Toggle breakpoint           |
| `<A-2>` | Start / Continue (Lua: osv) |
| `<A-3>` | Step into                   |
| `<A-4>` | Step over                   |
| `<A-5>` | Step out                    |
| `<A-6>` | Up (stack frame)            |
| `<A-7>` | Down (stack frame)          |
| `<A-8>` | Close session + UI          |
| `<A-9>` | Restart                     |
| `<A-0>` | Toggle REPL                 |

---

## lvim-tech Plugin Ecosystem

All `lvim-tech/*` plugins share a common design: they use `lvim-utils` for UI components and `lvim-colorscheme` for color palette, so every floating window, notification, and picker inherits the active theme automatically.

---

### lvim-lsp

> `lvim-tech/lvim-lsp` — LSP lifecycle manager

Manages LSP servers, EFM tools, DAP adapters, and Mason installations without requiring third-party config bridges like `mason-lspconfig`.

**Features:**

- **State management** — all LSP feature flags live in `lvim-lsp.state` and are the single source of truth
- **Global settings persistence** — feature flags are written to `stdpath("data")/lvim-lsp-settings.json` and survive across sessions independently of any UI plugin
- **Per-project override** — `.lvim-lsp/config.lua` in any project root is loaded after global defaults, allowing project-specific server settings, disabled servers, or feature overrides
- **On-demand Mason installer** — when opening a file type for the first time, a popup lists missing tools; Space toggles, Enter installs, q/Esc skips (suppressed for 5 min)
- **Declined tools tracking** — skipped tools are stored in `stdpath("data")/lvim-lsp-declined.json`; review with `:LvimLsp declined`

**Feature flags (all persistable globally and per-project):**

| Flag                 | Default | Description                                 |
| -------------------- | ------- | ------------------------------------------- |
| `auto_format`        | `true`  | Format on save (BufWritePre)                |
| `inlay_hints`        | `true`  | Inline type/parameter hints                 |
| `document_highlight` | `false` | Highlight symbol under cursor on CursorHold |
| `code_lens`          | `true`  | Display code lens annotations               |
| `progress.enabled`   | `true`  | LSP progress notifications                  |

**Virtual diagnostics modes:** `text-and-lines` / `text` / `lines` / `none`

**Commands:**

| Command                                  | Description                                                                        |
| ---------------------------------------- | ---------------------------------------------------------------------------------- |
| `:LvimLsp info`                          | Floating info panel: clients, capabilities, diagnostics, Mason versions, EFM tools |
| `:LvimLsp restart`                       | Restart all LSP clients on the current buffer                                      |
| `:LvimLsp toggle_servers`                | Picker to enable/disable servers for the current workspace                         |
| `:LvimLsp toggle_servers_buffer <bufnr>` | Picker scoped to a specific buffer                                                 |
| `:LvimLsp declined`                      | Review and re-enable declined Mason tools                                          |
| `:LvimLsp reattach`                      | Re-read project config and reattach clients                                        |

**Global settings UI** (inside `:LvimControlCenter` → Global tab):

- "Apply for session" — writes to `lvim-lsp.state` (memory only, lost on exit)
- "Apply permanently" — writes to `lvim-lsp-settings.json` (survives restarts)

**Load order priority:**

1. lvim-lsp defaults
2. User config (`languages/init.lua`)
3. `globals.load()` — wins over defaults
4. Project `.lvim-lsp/config.lua` — wins over globals for that project
5. `apply_buffer_features()` per `LspAttach`

---

### lvim-control-center

> `lvim-tech/lvim-control-center` — Runtime settings panel with SQLite persistence

```
:LvimControlCenter
```

A tabbed floating panel for changing frequently used settings at runtime — no restart required for most options. All settings are persisted to an SQLite database and applied automatically on startup.

**General tab:**

| Setting               | Type   | Description                                                                 |
| --------------------- | ------ | --------------------------------------------------------------------------- |
| Relative line numbers | bool   | `vim.opt.relativenumber` — skips neo-tree, Fyler                            |
| Cursor line           | bool   | `vim.opt.cursorline` — skips neo-tree                                       |
| Cursor column         | bool   | `vim.opt.cursorcolumn` — skips neo-tree, markdown, Fyler, time-machine-list |
| Wrap lines            | bool   | `vim.opt.wrap` — skips markdown                                             |
| Color column          | string | Column position(s), comma-separated (default: `"80"`)                       |
| Timeout length        | int    | Key sequence timeout in ms (default: 500)                                   |
| Keys helper           | bool   | Enable/disable which-key (requires restart)                                 |
| Keys helper delay     | select | which-key popup delay in ms: 0–1000                                         |

**LSP tab** (reads from and writes to `lvim-lsp.state` + global persistence):

| Setting                          | Type   | Description                                  |
| -------------------------------- | ------ | -------------------------------------------- |
| Auto format                      | bool   | Format on save                               |
| Inlay hint                       | bool   | Inline hints                                 |
| Virtual diagnostic               | select | `text-and-lines` / `text` / `lines` / `none` |
| LSP progress                     | bool   | Show/hide LSP progress notifications         |
| Code lens                        | bool   | Enable/disable code lens                     |
| Info LSP                         | action | `:LvimLsp info`                              |
| Restart LSP                      | action | `:LvimLsp restart`                           |
| Toggle LSP servers for workspace | action | `:LvimLsp toggle_servers`                    |
| Toggle LSP servers for buffer    | action | `:LvimLsp toggle_servers_buffer`             |

**Jump to specific setting:**

```lua
require("lvim-control-center.ui").open("lsp", "codelens") -- by name
require("lvim-control-center.ui").open("lsp", 2) -- by row index
```

---

### lvim-colorscheme

> `lvim-tech/lvim-colorscheme` — Multi-family, multi-variant colorscheme

**4 theme families × 4 variants = 16 themes:**

| Family     | Soft                   | Dark                   | Darker                   | Light                   |
| ---------- | ---------------------- | ---------------------- | ------------------------ | ----------------------- |
| Lvim       | `lvim-soft`            | `lvim-dark`            | `lvim-darker`            | `lvim-light`            |
| Kanagawa   | `lvim-kanagawa-soft`   | `lvim-kanagawa-dark`   | `lvim-kanagawa-darker`   | `lvim-kanagawa-light`   |
| Gruvbox    | `lvim-gruvbox-soft`    | `lvim-gruvbox-dark`    | `lvim-gruvbox-darker`    | `lvim-gruvbox-light`    |
| Everforest | `lvim-everforest-soft` | `lvim-everforest-dark` | `lvim-everforest-darker` | `lvim-everforest-light` |

The active theme is persisted to `.configs/lvim/.theme` and applied on startup. Change it via `:LvimControlCenter` → Appearance tab or directly:

```vim
:colorscheme lvim-darker
```

---

### lvim-utils

> `lvim-tech/lvim-utils` — Shared utility library for the lvim-tech ecosystem

Independent modules, each usable standalone:

| Module                 | Description                                                                                 |
| ---------------------- | ------------------------------------------------------------------------------------------- |
| `lvim-utils.colors`    | Shared color palette, auto-synced from lvim-colorscheme; `blend()`, `lighten()`, `darken()` |
| `lvim-utils.ui`        | Floating window components used by all lvim-tech plugins                                    |
| `lvim-utils.cursor`    | Hides cursor in registered filetypes (uses `blend=100` highlight)                           |
| `lvim-utils.notify`    | Notification system with theming                                                            |
| `lvim-utils.quit`      | Quit dialog — replaces the old `:Quit` custom command                                       |
| `lvim-utils.gx`        | Universal "open under cursor" — URLs, files, Git repos, plugin specs                        |
| `lvim-utils.highlight` | Highlight group registration with auto-reload on colorscheme change                         |

The `:Quit` user command and the `gx` key binding are both registered through `lvim-utils` in `modules/base/configs/dependencies/init.lua`:

```lua
vim.api.nvim_create_user_command("Quit", function()
    require("lvim-utils.quit").open()
end, {})

require("lvim-utils.gx").map_default()
```

---

### lvim-space

> `lvim-tech/lvim-space` v1.3.0 — Project, workspace, tab, and file manager

A full project management system backed by SQLite.

**Features:**

- **Projects** — multiple independent projects, each with their own workspaces
- **Workspaces** — named contexts within a project (e.g. `frontend`, `backend`)
- **Tabs** — multiple tab layouts per workspace, each remembering window/buffer layout and cursor positions
- **Files** — per-tab file tracking with fuzzy search
- **Session management** — automatic or manual save/restore
- **Reordering** — move projects, workspaces, tabs up/down
- **Public API** — `require("lvim-space.pub")` for statusline and plugin integration
- **NerdFont icons** for all entity types

---

### lvim-linguistics

> `lvim-tech/lvim-linguistics` v1.2.00 — Spelling and keyboard language control

Manages spell checking and keyboard layout switching in insert mode — useful for writing documents in a foreign language without leaving Neovim.

**Supported display servers and tools:**

| Session            | Tool         |
| ------------------ | ------------ |
| X11                | `xkb-switch` |
| Wayland — Hyprland | `hyprctl`    |
| Wayland — niri     | `niri`       |
| Wayland — sway     | `swaymsg`    |
| Wayland — mango    | `mmsg`       |
| Wayland — GNOME    | `gdbus`      |

The tool is auto-detected from `XDG_SESSION_TYPE` / `XDG_CURRENT_DESKTOP` / `WAYLAND_DISPLAY` at startup. Can be overridden manually via `kbrd_cmd`.

**Per-project config:** `.lvim_linguistics.json` in the project root overrides global spell/language settings for that project.

---

### lvim-shell

> `lvim-tech/lvim-shell` — Shell applications in Neovim buffers

Runs any shell application (lazygit, btop, etc.) in a floating window or split. Configurable borders, blend, dimensions, and backdrop.

**Default mappings inside the shell buffer:**

| Key         | Action                   |
| ----------- | ------------------------ |
| `<C-x>`     | Open in horizontal split |
| `<C-v>`     | Open in vertical split   |
| `<C-t>`     | Open in new tab          |
| `<C-e>`     | Open in current window   |
| `<C-Space>` | Close                    |

---

### lvim-move

> `lvim-tech/lvim-move` — Move lines and selections in any direction

**Features:**

- Move lines **up/down** in normal and linewise visual mode
- Move character selections **up/down/left/right** in charwise visual mode
- Move lines **left/right** (indent/dedent) in normal and linewise visual mode
- **Fold-aware** — opens folds instead of moving when cursor is inside one
- Auto-indent after vertical moves (configurable)
- Custom highlight color while moving
- Column position preserved across vertical moves

---

### lvim-qf-loc

> `lvim-tech/lvim-qf-loc` — Enhanced quickfix and location list

**Features:**

- Navigation (prev/next) via floating popup
- Switch between quickfix and location lists
- Delete entries from quickfix/location lists
- Save and load lists to/from JSON files
- Diagnostics in quickfix
- Floating tabbed UI powered by `lvim-utils`

---

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
modules["author/plugin-name"] = false

-- Override a base plugin's settings
modules["author/plugin-name"] = {
    -- your lazy.nvim spec
}

-- Add a new plugin
modules["author/new-plugin"] = {
    config = function()
        require("new-plugin").setup({})
    end,
}
```

### LSP — Language Server Config

Language server configs live in `lua/modules/base/configs/languages/lsp/servers/`. To override or add a server, place a file with the same name in `lua/modules/user/configs/languages/lsp/servers/`.

File types are registered in `lua/modules/base/configs/languages/lsp/file_types.lua`. Override by returning a table from `lua/modules/user/configs/languages/lsp/file_types.lua`.

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

### v9.0.0 — Breaking Changes (2026-03-21)

**New features:**

- `lvim-lsp/core/globals.lua` — new JSON-based persistence for LSP feature flags written to `stdpath("data")/lvim-lsp-settings.json`; survives sessions without SQLite. Persisted flags: `auto_format`, `inlay_hints`, `document_highlight`, `code_lens`, `progress`, `virtual_text`, `virtual_lines`, `underline`, `severity_sort`, `update_in_insert`
- Load order: lvim-lsp defaults → user config → `globals.load()` → project `.lvim-lsp/config.lua`
- LSP Progress toggle — "LSP Progress" bool added to both `lvim-control-center` LSP tab and `lvim-lsp` Global tab UI with "Apply for session" / "Apply permanently"

**lvim-control-center LSP tab rewrite:**

- All LSP settings now read from and write to `lvim-lsp.state` + `globals.save()` directly — no duplication between CC and lvim-lsp
- `lspprogress` changed from `select` (fidget/notify/none) to `bool` — fidget.nvim removed
- `virtualdiagnostic` now correctly calls `vim.diagnostic.config()` at runtime
- Fixed action button commands: `LvimLspInfo` → `:LvimLsp info`, `LvimLspRestart` → `:LvimLsp restart`, etc.
- Fixed `colorcolumn` in General tab (was displaying Lua table address instead of value)

**Bug fixes:**

- `ocaml.lua` — critical copy-paste bug: `cmd` was `"r-languageserver"` instead of `"ocamllsp"`; removed duplicate `.git` root marker
- `css.lua` — `documentSymbolProvider` capability check was all-lowercase — nvim-navic never attached to CSS buffers
- `go.lua` — replaced deprecated `vim.loop.spawn` with `vim.uv.spawn`
- `heirline/git.lua` — replaced deprecated `vim.loop` with `vim.uv`
- `dap_utils.lua` — removed dead code: two IIFE assignments immediately overwritten by `:luafile`
- `modules/user/init.lua` — treewalker spec used `setup` instead of `config` (lazy.nvim field); plugin was never configured
- `core/init.lua` — removed unreachable `io.popen` fallback in `getOS()` (Neovim always uses LuaJIT); removed implicit global `Osname`
- Spelling: "unsuported" → "unsupported" in `core/init.lua` and `core/types.lua`

**Refactoring:**

- `lsp/dap.lua` renamed to `lsp/dap_utils.lua` — resolved `different-requires` LuaLS diagnostic caused by name conflict with the `nvim-dap` plugin module
- All DAP key handler closures use consistent `local dap = require("dap")` pattern
- `core/types.lua` — `LvimGit` and `LvimGitHead` type definitions updated to match actual runtime structure; added `LvimGitTag` class

**Removed:**

- `lua/core/ext/gxplus.lua` — replaced by `lvim-utils.gx.map_default()`
- `lua/core/ext/quite.lua` — replaced by `lvim-utils.quit.open()` via `:Quit` user command
- `fidget.nvim` — plugin registration and config block removed entirely
- `lua/languages/` — entire old LSP directory structure removed; all language configs now in `lua/modules/base/configs/languages/lsp/servers/`
