# Commands

Every command the distribution registers, with its subcommands. The list is generated from a live
session — `:LvimPicker commands` searches the same set inside the editor, and `<Leader>sc` opens it.

A command belonging to a lazily-loaded plugin exists as a stub from startup: typing it loads the
plugin, then runs. There is nothing to require first.

Most commands take a **dock mode** — `float`, `area`, `bottom` — to say where the panel should open.
Where it appears in the subcommand list below, that is what it means.

## The set

Every command, and what it is for. The subcommands each one takes are listed below the table — a
command with none takes an argument instead (a path, a name) or takes nothing at all.

| Command | What it does |
|---|---|
| **:LvimBufHistory** | Per-window buffer history — back, forward, the list. |
| **:LvimBuild** | Detected build / run / test / bench / lint actions for this project and file. |
| **:LvimCalendar** | The calendar and agenda, in any of the dock modes. |
| **:LvimColorPicker** | Pick, convert or highlight a colour under the cursor. |
| **:LvimColorscheme** | Switch the theme; `extras` writes the palette out for other programs. |
| **:LvimColorschemeConfig** | The theme's own settings panel (variants, transparency, dimming, italics). |
| **:LvimComment** | Comment a line or a block. |
| **:LvimComments** | `strip` removes every comment from the buffer. |
| **:LvimContext** | The sticky scope header — toggle, refresh, jump to the context line. |
| **:LvimControlCenter** | The settings panel. Any tab name jumps straight to it; a setting name opens on that row. |
| **:LvimControlCenterList** | Print every registered setting and its live value. |
| **:LvimDap** | The debugger — breakpoints, stepping, continue, terminate, the adapter list. |
| **:LvimDapView** | The debugger panels: watches, scopes, stack, breakpoints, exceptions, REPL, console. |
| **:LvimDashboard** | The start screen. |
| **:LvimDb** | The database client — connections, results dock, notes, its own daemon. |
| **:LvimDeps** | Project dependencies across package managers — install, update, metrics. |
| **:LvimDock** | The shared dock: which panel owns the bottom / side region. |
| **:LvimEval** | Run a command and put its output in a window. |
| **:LvimFiles** | The file manager — the tree panel, or the editable directory buffer (`edit`). |
| **:LvimForge** | Pull requests, issues, reviews and notifications from the forge. |
| **:LvimGit** | The git client. Also drives jj on a colocated repository. |
| **:LvimIcons** | The icon picker. |
| **:LvimImage** | Render an image file in the editor. |
| **:LvimImageInline** | Inline image rendering for the current buffer. |
| **:LvimIndent** | Indent guides — enable, disable, toggle, refresh. |
| **:LvimInstaller** | The package browser: LSP, DAP, linters, formatters, runtimes, compilers, parsers, plugins, snapshots. |
| **:LvimJump** | Label motions — jump, treesitter select, the enhanced character motions. |
| **:LvimKeyring** | The encrypted secrets wallet — unlock, add, generate, rotate. |
| **:LvimKeysHelper** | The key-hint panel: the cheatsheet, the style and delay, the diagnostics. |
| **:LvimLang** | The language providers — the list, this buffer's status, the toolchain, the log. |
| **:LvimLinguistics** | Per-mode keyboard layout and spelling. |
| **:LvimLoc** | The location list workflow — browse, open, delete, navigate, storage. |
| **:LvimLsp** | Every LSP verb, one command. The `g*` keymaps are thin wrappers over it. |
| **:LvimLuaTable** | `sort` sorts the Lua table under the cursor. |
| **:LvimMessages** | The message history in a panel. |
| **:LvimMsgArea** | The docked message zone. |
| **:LvimPicker** | The finders — files, grep (word / WORD / cword / visual / buffer), buffers, git, help, marks, jumps. |
| **:LvimPreview** | Live browser preview with hot reload; `qr` shows a phone-reachable code. |
| **:LvimQf** | The quickfix workflow — browse, open, delete, navigate, diagnostics into the list. |
| **:LvimQuit** | Quit the editor the distribution's way (sessions and panels closed in order). |
| **:LvimRemote** | Project file transfer over ssh / rsync — upload, download, diff, sync, watch. |
| **:LvimRender** | In-buffer rendering of markdown / typst / org / latex. |
| **:LvimReplace** | Project-wide find and replace, with per-result marking. |
| **:LvimRest** | The REST client — send, replay, environments, history, auth, cookies, gRPC. |
| **:LvimSearchExport** | The last search as a quickfix list — this buffer, every buffer, or `args`. |
| **:LvimSearchRefresh** | Recount the visible search matches. |
| **:LvimSearchToggle** | Turn the match counter on or off. |
| **:LvimShell** | Run a TUI program in a themed float. |
| **:LvimSnippets** | Browse and insert snippets. |
| **:LvimSpace** | Projects, workspaces, tabs and their files. |
| **:LvimTable** | Table mode: realign, row and column operations, formulas, tableize. |
| **:LvimTasks** | The task runner — run, redo, stop, history, the panel. |
| **:LvimTerm** | Named, toggleable terminals. |
| **:LvimTest** | The test runner — nearest, file, suite, failed, marked, watch. |
| **:LvimTex** | The LaTeX pipeline — build, view, TOC, labels, citations, reverse search, errors. |
| **:LvimUndo** | The undo timeline — checkpoints, the project view, purging. |
| **:LvimVault** | Marks, jumps and macros. |
| **:LvimWinMove** | Move or swap the current window. |
| **:LvimWinNav** | Directional window navigation and resizing, multiplexer-aware. |
| **:LvimWinPick** | Label the windows and jump to one. |

## Subcommands

Completion knows all of these: type the command, press `Tab`. The dock modes `float`,
`area` and `bottom` say where the panel opens.

- **:LvimBufHistory** — `back` `forward` `list` `clear` `status`
- **:LvimBuild** — `redo` `last` `Build` `Run` `Test` `Bench` `Lint` `float` `area` `bottom`
- **:LvimCalendar** — `month` `quarter` `year` `agenda` `float` `area` `bottom`
- **:LvimColorPicker** — `pick` `convert` `highlight`
- **:LvimColorscheme** — `extras` `reload`
- **:LvimColorschemeConfig** — `search` `export` `import` `reset` `preset` `float` `area` `bottom` `Background` `transparent` `sidebars` `floats` `terminal_colors` `auto_background` `day_brightness` `cache` `Focus` `dim_inactive` `dim_inactive_amount` `dark_active` `dark_active_amount` `Syntax` `comments_italic` `keywords_italic` …
- **:LvimComment** — `line` `block`
- **:LvimComments** — `strip`
- **:LvimContext** — `enable` `disable` `toggle` `refresh` `jump`
- **:LvimControlCenter** — `search` `export` `import` `reset` `preset` `float` `area` `bottom` `general` `sep_display` `number` `relativenumber` `cursorline` `cursorcolumn` `wrap` `list` `colorcolumn` `signcolumn` `scrolloff` `conceallevel` `sep_search` `ignorecase` `smartcase` `hlsearch` …
- **:LvimDap** — `run_last` `step_back` `run_to_cursor` `up` `disconnect` `clear_breakpoints` `down` `toggle_breakpoint` `adapters` `step_into` `step_over` `step_out` `pause` `continue` `run` `breakpoints` `close` `terminate` `log`
- **:LvimDapView** — `exceptions` `sessions` `open` `scopes` `console` `close` `breakpoints` `toggle` `stack` `repl` `watches` `area` `float` `bottom`
- **:LvimDashboard** — `open` `pick`
- **:LvimDb** — `add` `close` `dock` `health` `keyring-migrate` `log` `status` `toggle`
- **:LvimDeps** — `cache` `clear-all-caches` `clear-declared` `clear-installed` `clear-latest` `delete` `features` `help` `hide` `install` `metrics` `show` `show-manager` `show-registry` `state` `toggle` `update` `update-direct`
- **:LvimDock** — `menu` `area` `bottom` `float` `tab`
- **:LvimFiles** — `panel` `focus` `close` `edit` `toggle`
- **:LvimForge** — `topics` `issues` `pulls` `topic` `create` `comment` `review` `checkout` `merge` `pull` `notifications` `browse` `yank` `add` `remove` `repos` `note` `mark` `dispatch` `auth`
- **:LvimGit** — `status` `diffview` `diff` `log` `history` `blame` `stash` `refs` `oplog` `conflict` `submodule` `worktree` `bisect` `subtree` `patch` `sparse` `wip` `dispatch` `commit` `push` `pull` `fetch` `rebase` `merge` …
- **:LvimImage** — `<path>`
- **:LvimImageInline** — `toggle` `on` `off`
- **:LvimIndent** — `enable` `disable` `toggle` `refresh`
- **:LvimInstaller** — `lsp` `dap` `linter` `formatter` `runtime` `compiler` `parsers` `plugins` `float` `area` `bottom` `snapshot` `update-registry`
- **:LvimJump** — `jump` `ts` `char` `status`
- **:LvimKeyring** — `add` `generate` `import` `lock` `rotate` `status` `unlock`
- **:LvimKeysHelper** — `toggle` `enable` `disable` `status` `style` `delay` `doctor` `cheatsheet` `stats` `test` `debug` `log`
- **:LvimLang** — `log` `providers` `status` `toolchain`
- **:LvimLinguistics** — `search` `export` `import` `reset` `preset` `float` `area` `bottom` `toggle-insert-mode` `toggle-spelling` `Spelling` `spell_active` `spell_language` `Insert` `Mode` `mode_active` `insert_mode_language` `Config` `save_local` `delete_local` `config_sep` `show_path`
- **:LvimLoc** — `browse` `close` `delete` `next` `open` `prev` `storage` `area` `float` `bottom`
- **:LvimLsp** — `add_workspace_folder` `clear_references` `code_action` `dap` `declaration` `declined` `definition` `diagnostic_current` `diagnostic_next` `diagnostic_prev` `diagnostics` `document_highlight` `document_symbol` `format` `hover` `implementation` `incoming_calls` `info` `list_workspace_folders` `log` `outgoing_calls` `outline` `outline_focus` `project` …
- **:LvimLuaTable** — `sort`
- **:LvimPicker** — `files` `grep` `grep_cword` `grep_cWORD` `grep_word` `grep_visual` `grep_curbuf` `buffers` `oldfiles` `git_files` `directories` `help_tags` `commands` `keymaps` `marks` `quickfix` `jumplist` `colorschemes` `area` `float` `bottom`
- **:LvimPreview** — `start` `stop` `open` `artifacts` `qr` `status` `pick` `export`
- **:LvimQf** — `browse` `close` `delete` `diagnostics` `next` `open` `prev` `storage` `area` `float` `bottom`
- **:LvimRemote** — `init` `upload` `download` `diff` `sync-up` `sync-down` `target` `watch`
- **:LvimRender** — `toggle` `on` `off` `split` `table`
- **:LvimReplace** — `open` `toggle` `close` `file` `word` `selection`
- **:LvimRest** — `prev` `ws` `cancel` `inspect` `save` `history` `export` `send` `replay` `scratch` `next` `options` `import` `run` `dock` `grpc` `auth` `all` `cookies` `close` `env`
- **:LvimSearchExport** — `buffer` `all` `args`
- **:LvimShell** — `aerc` `broot` `btop` `cmus` `fzf` `fzf_preview` `grep_qf` `htop` `lazydocker` `lazygit` `live_grep` `ncdu` `ncmpcpp` `neomutt` `posting` `tig` `vifm` `xplr` `yazi`
- **:LvimSnippets** — `float` `area` `bottom`
- **:LvimSpace** — `area` `bottom` `files` `float` `metrics` `open` `projects` `save` `search` `tab` `tabs` `workspaces`
- **:LvimTable** — `toggle` `on` `off` `format` `from` `to` `eval` `row-insert` `row-insert-above` `row-delete` `col-insert` `col-insert-before` `col-delete` `row-up` `row-down` `col-left` `col-right`
- **:LvimTasks** — `run` `redo` `redo-failed` `stop` `history` `clear` `toggle` `float` `area` `bottom`
- **:LvimTerm** — `toggle` `new` `next` `prev` `select` `kill` `float` `area` `bottom`
- **:LvimTest** — `attach` `clear` `debug` `failed` `file` `jump` `last` `output` `refresh` `run` `stop` `suite` `summary` `watch`
- **:LvimTex** — `build` `cite` `cites` `clean` `conceal` `continuous` `count` `doc` `errors` `files` `imaps` `info` `labels` `main` `matchparen` `output` `reload` `reverse` `selection` `stop` `stop_all` `toc` `view`
- **:LvimUndo** — `toggle` `open` `close` `project` `purge` `purge-all` `log` `log-clear` `checkpoint` `float` `area` `bottom`
- **:LvimVault** — `marks` `jumps` `macros` `mark` `jump` `macro` `save` `float` `area` `bottom`
- **:LvimWinNav** — `left` `down` `up` `right` `resize` `swap` `resize-mode` `mux-config`

## Editor commands

Defined by the configuration itself, not by a plugin.

| Command | What it does |
|---|---|
| **:CloseFloatWindows** | Close every floating window. |
| **:FocusFloatWindow** | Cycle focus to the next float. |
| **:GxOpen** | Open whatever is under the cursor with the OS handler — URL, file, path. |
| **:GxOpenDiag** | Why `gx` resolved what it did, for the thing under the cursor. |
| **:LspCodeLensRun** | Run the code lens on this line. |
| **:Messages** | The message history. |
| **:Quit** | Close LVIM IDE. |
| **:Save** | Write the buffer (the distribution's save path). |

## Health

Every plugin ships a `:checkhealth` section. The ones worth knowing:

| Check | Reports |
|---|---|
| `:checkhealth lvim-pack` | the loader's wiring, how many plugins are registered / loaded / waiting |
| `:checkhealth lvim-pkg` | the external tools the set needs, and what is installed |
| `:checkhealth lvim-lang` | the active provider, its toolchain and its tools |
| `:checkhealth lvim-lsp` | the attached servers and their capabilities |
