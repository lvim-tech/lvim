# LVIM

![LVIM](/assets/lvim-logo.png)

> A modular Neovim configuration written in Lua, built entirely on a first-party plugin ecosystem —
> `lvim-tech/*`. LSP and language tooling, debugging, building and testing, git, database and REST
> clients, the whole UI: one set, one style, one place to configure it.

> Current version — **10.0.5**

---

## At a glance

Measured on this machine, on the revisions the active snapshot pins — the editor answers the same
questions live, and the commands that ask are in the last column.

| What | Measured | Ask the editor |
|---|---|---|
| **Plugins** | **64**, all but one first-party | `:LvimInstaller` |
| **Startup** | **~110 ms** to a usable editor (98–115 ms over five runs) | the dashboard, or `require("lvim-pack").stats()` |
| **Languages** | **92 providers** over **150 filetypes** | `:LvimLang providers` |
| **LSP** | **94 distinct language servers**, attached per project root | `:LvimLsp info` |
| **Run / Build** | **49** languages run, **47** build | `:LvimBuild`, `:LvimLang status` |
| **Test** | **44** languages, with treesitter discovery | `:LvimTest` |
| **Debug** | **17** languages with a real adapter — nothing stubbed to pad the number | `:LvimDap adapters` |
| **Commands** | **60** `:Lvim*` commands | `:LvimPicker commands` |

Nothing on that list is installed up front: a language server, parser, formatter, linter or debug
adapter is fetched the first time you open a file that needs it, and you are asked before it is.

---

## Documentation

The detail lives in its own file — this page is the overview.

| Page | What is in it |
|---|---|
| [docs/plugins.md](docs/plugins.md) | every plugin: what it is, when it loads, what it depends on |
| [docs/languages.md](docs/languages.md) | the language model, all 92 providers, per-project overrides |
| [docs/keys.md](docs/keys.md) | the whole keymap manifest, group by group |
| [docs/commands.md](docs/commands.md) | every command and its subcommands |

---

## Philosophy

**One ecosystem, not a collection.** Every plugin is written for this set: they share a palette, a
highlight factory, a storage layer, a UI toolkit and a cursor manager. A theme change repaints all of
them; a panel opened by one behaves like a panel opened by another. The single third-party entry left
is a runtime *library* (`sqlite.lua`), not a plugin.

**No external plugin manager.** `lvim-pack` drives Neovim's own `vim.pack` — dependencies, version
pins, eager order, lazy triggers, build hooks. One clone, no bootstrap script to trust.

**Nothing loads that is not needed.** Plugins that must be listening at the first keystroke load at
startup by priority; the rest wait on a filetype, a command, a key or an event. Where a plugin waits
on a command, its keymap calls that command — so it arrives exactly when you first ask for it.

**One place per question.** Keymaps live in one manifest, not scattered across plugin configs.
A language declares everything about itself in one provider. A setting has one live home
(`config.lua` inside the plugin), which `setup()` merges into — so what you read is what is running.

**Canonical UI only.** Every popup, picker, prompt and panel goes through `lvim-ui` / `lvim-hud`.
There is no hand-rolled float in the configuration and no `vim.ui.select` left to look out of place.

**Your layer is separate.** `configs/user/`, `modules/user/` and `keys/user/` sit beside the base
ones and are merged over them. Core files are never edited, so an update never collides with your
changes.

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

Start Neovim. `lvim-pack` clones what the install itself needs, then `lvim-installer` shows a panel
that installs the rest and runs the build hooks; the editor is usable when it closes. Language
tooling is not part of that — it arrives per language, on the first file that needs it.

---

## Architecture

```
~/.config/nvim/
├── init.lua                ← version guard → require("core")
├── lua/
│   ├── core/
│   │   ├── init.lua        ← bootstrap: globals, the lvim-pack clone + setup, the snapshot pin
│   │   ├── keys.lua        ← the keymap manifest's applier (merge user over base, apply per section)
│   │   ├── funcs.lua       ← the helper API: resolves each name from funcs/ on first use, cached
│   │   ├── funcs/          ← shared helpers (editor, fs, plugins, system, table, ui)
│   │   └── types.lua       ← LuaLS annotations for the config
│   ├── configs/            ← the editor itself
│   │   ├── base/           ← options.lua (settings + folding), init.lua, ui/icons.lua
│   │   └── user/           ← your editor overrides            ← edit here
│   ├── keys/               ← the keymap MANIFEST
│   │   ├── base/           ← groups, global, lsp, lang, filetype, plugins
│   │   └── user/           ← your keymap overrides            ← edit here
│   └── modules/            ← the plugins
│       ├── base/
│       │   ├── init.lua    ← THE PLUGIN SPEC (every plugin, its trigger, its deps)
│       │   └── configs/    ← per-plugin wiring, by area: completion, dependencies,
│       │                     editor, languages, ui, version_control
│       └── user/           ← your plugin additions/overrides  ← edit here
├── docs/                   ← commands, keys, languages, plugins (the long-form reference)
├── snippets/               ← custom/ (yours) + vendor/
├── assets/                 ← the image this README shows (the dashboard's own banner is
│                             ASCII art, in lua/modules/base/configs/ui/logo.lua)
├── .configs/               ← templates handed to projects + per-plugin state written at runtime
├── .snapshots/             ← the version pin sets (`active` names the live one)
├── .version                ← this config's own version
└── nvim-pack-lock.json     ← vim.pack's own record of what is installed (machine-local)
```

`stylua.toml`, `.cbfmt.toml`, `.editorconfig` and `.luarc.json` at the root are the formatter / linter
settings for editing this repository itself.

The load order is the design, not an accident: built-ins off → bootstrap clone → local checkouts on
the runtimepath → bundle, resolve, pin → the install UI → eager loads by priority → the lazy triggers
→ `UIEnter` freezes the startup stat and fires `VeryLazy`.

---

## Customization

Everything user-facing is a merge over the base, in three parallel places. Core files stay untouched.

### The editor

```lua
-- lua/configs/user/init.lua
configs["base_options"] = false     -- disable a base phase
configs["base_options"] = { … }     -- rewrite one
configs["user_thing"] = { … }       -- add your own
```

### Plugins

```lua
-- lua/modules/user/init.lua
modules["lvim-tech/lvim-calendar"] = false   -- disable
modules["lvim-tech/lvim-calendar"] = {       -- override the spec
    -- the fields lvim-pack reads: event / ft / cmd / keys, dependencies,
    -- priority, opts or config, build …
}
modules["author/new-plugin"] = {             -- add one
    config = function()
        require("new-plugin").setup({})
    end,
}
```

### Keys

```lua
-- lua/keys/user/init.lua — merged over the manifest
return {
    global = {
        normal = {
            { "<Leader>zz", "<Cmd>LvimGit status<CR>", "Git: status" },
        },
    },
}
```

See [docs/keys.md](docs/keys.md) for the sections and what each is applied to.

### Settings, live

`:LvimControlCenter` is the same surface as a panel — general editor options, appearance, LSP
features, commands and projects, persisted across restarts. Per-project overrides go in the project
root: `.lvim-lsp/config.lua`, `.lvim-ls/servers/<name>.lua`, `.lvim/lang/run.lua`, `nvim-dap.lua`.

---

## Versions and pinning

`.snapshots/` holds the pin sets and `active` names the live one. That pin is the **declared intent**
and outranks `nvim-pack-lock.json` — vim.pack's own, machine-local record of what happens to be
installed. A fresh machine therefore installs what the snapshot says; where the snapshot is silent,
the lockfile decides; where neither has an answer, the plugin tracks its branch.

Switching `active` governs what a fresh install gets. Moving plugins already on disk to another
snapshot is the installer's snapshot tab (diff → restore), which checks them out explicitly.

---

## Changelog

### v10.0.0

**The distribution is now first-party.** Every borrowed plugin has been replaced by an `lvim-tech`
one; what remains from outside the set is a single runtime library (`sqlite.lua`).

- **Loading** — no external plugin manager. `lvim-pack` drives Neovim's built-in `vim.pack`: it
  resolves dependencies, applies the version pins, loads eagerly by priority and wires the `event` /
  `ft` / `cmd` / `keys` triggers. Minimum Neovim is **0.12**, where `vim.pack` arrived.
- **Installing** — `lvim-installer` owns the first-start panel and the package browser; `lvim-pkg`
  installs and tracks LSP servers, treesitter parsers, linters, formatters and debug adapters.
- **Languages** — owned by `lvim-lang`: one provider per language declares its servers, roots, tools
  and its run / build / test / debug behaviour, and fans them out to the plugins that use them.
- **Keys** — one manifest, `lua/keys/base/`: group labels, global maps, capability-guarded LSP verbs
  applied on `LspAttach`, per-filetype leaves, and overrides forwarded into a plugin's own key table.
  Your layer is `lua/keys/user/`.
- **UI** — every popup, picker and prompt goes through `lvim-ui` / `lvim-hud`; there is no
  hand-rolled float left in the configuration.

---

## License

BSD 3-Clause. See [LICENSE](LICENSE).
