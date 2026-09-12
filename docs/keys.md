# Keys

One manifest, `lua/keys/base/`, is the single source of truth for keymaps. It is split by **when and
where** a key applies, and `lua/core/keys.lua` merges `lua/keys/user/` over it and applies each
section at the right moment:

| Section | File | Applied |
|---|---|---|
| groups | `keys/base/groups.lua` | once, as the prefix labels the hint panel shows |
| global | `keys/base/global.lua` | at startup, per mode |
| lsp | `keys/base/lsp.lua` | buffer-local on `LspAttach`, guarded by the server's capability |
| lang | `keys/base/lang.lua` | buffer-local on `FileType`, per the provider's own command list |
| filetype | `keys/base/filetype.lua` | buffer-local on `FileType` |
| plugins | `keys/base/plugins.lua` | forwarded into a plugin's own `setup(opts.keys)` |

**Add a key there, not in a plugin's config.** The documented exception is a key that drives a
plugin's live API rather than a command — lvim-winnav's `<C-h/j/k/l>` and `<C-Arrows>`, lvim-dap's
`<A-1>`…`<A-0>`, lvim-term's generated `<C-c>1`…`9` — because it needs the module in hand.

The `lang` section is the odd one out, deliberately: it is bound per PROVIDER rather than per
filetype, so a language gets exactly the keys its own provider implements — and a language written
tomorrow is covered the day its provider is, with no edit here.

Nothing here has to be memorised: press a prefix and the hint panel names what follows it,
`<Leader>uh` opens the cheatsheet, and `<Leader>sk` searches every live mapping.

`<Leader>` is `Space`.

## The groups

| Prefix | Group |
|---|---|
| `<Leader>b` | Buffers |
| `<Leader>c` | Code / Edit |
| `<Leader>d` | Debug |
| `<Leader>f` | Files / Remote |
| `<Leader>g` | Git / Review |
| `<Leader>o` | Open / Tools |
| `<Leader>p` | Project / Space |
| `<Leader>r` | Run / Test / Tasks |
| `<Leader>s` | Search / Navigate |
| `<Leader>u` | UI / Toggles / Settings |
| `<Leader>w` | Windows |

## Global — normal mode

### `<Leader>s` — Search / Navigate

| Key | Action | Runs |
|---|---|---|
| `<Leader>sf` | Search: files | `:LvimPicker files` |
| `<Leader>sg` | Search: live grep | `:LvimPicker grep` |
| `<Leader>sb` | Search: buffers | `:LvimPicker buffers` |
| `<Leader>so` | Search: recent files | `:LvimPicker oldfiles` |
| `<Leader>sm` | Search: marks | `:LvimPicker marks` |
| `<Leader>sG` | Search: git files | `:LvimPicker git_files` |
| `<Leader>sk` | Search: keymaps | `:LvimPicker keymaps` |
| `<Leader>sc` | Search: commands | `:LvimPicker commands` |
| `<Leader>sq` | Search: quickfix | `:LvimPicker quickfix` |
| `<Leader>sr` | Search: project replace | `:LvimReplace` |
| `<Leader>se` | Search: matches to quickfix | `:LvimSearchExport` |
| `<Leader>sE` | Search: matches to quickfix (all buffers) | `:LvimSearchExport all` |

### `<Leader>g` — Git / Review

| Key | Action | Runs |
|---|---|---|
| `<Leader>gg` | Git: status | `:LvimGit status` |
| `<Leader>gd` | Git: diffview | `:LvimGit diffview` |
| `<Leader>gl` | Git: log | `:LvimGit log` |
| `<Leader>gb` | Git: inline blame toggle | `:LvimGit toggle_blame` |
| `<Leader>gB` | Git: blame split | `:LvimGit blame` |
| `<Leader>gr` | Git: refs / bookmarks | `:LvimGit refs` |
| `<Leader>go` | Git: op log / reflog | `:LvimGit oplog` |
| `<Leader>gf` | Forge: dispatch (menu) | `:LvimForge dispatch` |
| `<Leader>gF` | Forge: topics (issues + PRs) | `:LvimForge topics` |
| `<Leader>gN` | Forge: notifications | `:LvimForge notifications` |

### `<Leader>d` — Debug

| Key | Action | Runs |
|---|---|---|
| `<Leader>dc` | Debug: continue / start | `:LvimDap continue` |
| `<Leader>db` | Debug: toggle breakpoint | `:LvimDap toggle_breakpoint` |
| `<Leader>dB` | Debug: clear breakpoints | `:LvimDap clear_breakpoints` |
| `<Leader>dp` | Debug: pause | `:LvimDap pause` |
| `<Leader>dt` | Debug: terminate | `:LvimDap terminate` |
| `<Leader>dv` | Debug: toggle view | `:LvimDapView toggle` |
| `<Leader>dl` | Debug: start (LSP-driven) | `:LvimLsp dap` |

### `<Leader>r` — Run / Test / Tasks

| Key | Action | Runs |
|---|---|---|
| `<Leader>rn` | Tasks: run template | `:LvimTasks run` |
| `<Leader>ra` | Tasks: panel | `:LvimTasks toggle` |
| `<Leader>rh` | Tasks: history | `:LvimTasks history` |
| `<Leader>rx` | Tasks: stop | `:LvimTasks stop` |
| `<Leader>rr` | Run: build recipe | `:LvimBuild run` |
| `<Leader>rb` | Build: action chooser | `:LvimBuild` |
| `<Leader>rl` | Build: show redo target | `:LvimBuild last` |
| `<Leader>rd` | Build: redo last action | `:LvimBuild redo` |
| `<Leader>rt` | Test: nearest | `:LvimTest run` |
| `<Leader>rF` | Test: file | `:LvimTest file` |
| `<Leader>rs` | Test: suite | `:LvimTest suite` |
| `<Leader>rf` | Test: rerun failed | `:LvimTest failed` |
| `<Leader>rS` | Test: summary panel (m marks, R runs marked) | `:LvimTest summary` |
| `<Leader>ro` | Test: output | `:LvimTest output` |
| `<Leader>rw` | Test: watch | `:LvimTest watch` |

### `<Leader>f` — Files / Remote

| Key | Action | Runs |
|---|---|---|
| `<Leader>ff` | Files: explorer | `:LvimFiles` |
| `<Leader>fx` | Files: open under cursor (OS) | `:GxOpen` |
| `<Leader>fp` | Files: print (printer / PDF) — in visual mode, the selection | `:LvimPrint` |
| `<Leader>fi` | Remote: init project config | `:LvimRemote init` |
| `<Leader>fu` | Remote: upload buffer | `:LvimRemote upload` |
| `<Leader>fd` | Remote: download buffer | `:LvimRemote download` |
| `<Leader>fD` | Remote: diff buffer | `:LvimRemote diff` |
| `<Leader>fs` | Remote: sync up (review) | `:LvimRemote sync-up` |
| `<Leader>fS` | Remote: sync down (review) | `:LvimRemote sync-down` |

### `<Leader>b` — Buffers

| Key | Action | Runs |
|---|---|---|
| `<Leader>bb` | Buffers: history list | `:LvimBufHistory list` |
| `<Leader>bn` | Buffers: forward | `:LvimBufHistory forward` |
| `<Leader>bp` | Buffers: back | `:LvimBufHistory back` |
| `<Leader>bc` | Buffers: clear history | `:LvimBufHistory clear` |
| `<Leader>bd` | Buffers: delete | `:enew \| bdelete #` |

### `<Leader>w` — Windows

| Key | Action | Runs |
|---|---|---|
| `<Leader>wv` | Window: split right | `:vsplit` |
| `<Leader>w-` | Window: split below | `:split` |
| `<Leader>wc` | Window: close | `<C-w>c` |
| `<Leader>wo` | Window: close others | `<C-w>o` |
| `<Leader>w=` | Window: equalise | `:wincmd =` |
| `<Leader>wp` | Window: pick | `:LvimWinPick` |
| `<Leader>ws` | Window: swap | `:LvimWinMove swap` |
| `<Leader>wm` | Window: move mode (h/j/k/l · H/J/K/L edge · s swap · q quit) | `:LvimWinMove` |

### `<Leader>p` — Project / Space

| Key | Action | Runs |
|---|---|---|
| `<Leader>pp` | Space: projects / workspaces | `:LvimSpace` |
| `<Leader>pt` | Space: new tab | `:LvimSpace tab new` |
| `<Leader>px` | Space: close tab | `:LvimSpace tab close` |
| `<Leader>pn` | Space: next tab | `:LvimSpace tab next` |
| `<Leader>pP` | Space: prev tab | `:LvimSpace tab prev` |
| `<Leader>pl` | Space: move tab right | `:LvimSpace tab move-next` |
| `<Leader>ph` | Space: move tab left | `:LvimSpace tab move-prev` |
| `<Leader>pj` | Space: jump to tab by index | `:LvimSpace tab goto` |
| `<Leader>pr` | Space: rename tab | `:LvimSpace tab rename` |

### `<Leader>c` — Code / Edit

| Key | Action | Runs |
|---|---|---|
| `<Leader>cc` | Code: comment line | `:LvimComment line` |
| `<Leader>cb` | Code: comment block | `:LvimComment block` |
| `<Leader>ct` | Code: table mode toggle | `:LvimTable toggle` |
| `<Leader>cp` | Code: pick colour | `:LvimColorPicker pick` |
| `<Leader>ck` | Code: convert colour | `:LvimColorPicker convert` |
| `<Leader>co` | Code: run a command into a window | `:LvimEval` |

### `<Leader>o` — Open / Tools

| Key | Action | Runs |
|---|---|---|
| `<Leader>ot` | Open: terminal | `:LvimTerm toggle` |
| `<Leader>os` | Open: shell launcher | `:LvimShell` |
| `<Leader>od` | Open: database client | `:LvimDb` |
| `<Leader>oa` | Open: REST scratchpad | `:LvimRest scratch` |
| `<Leader>oA` | Open: REST history | `:LvimRest history` |
| `<Leader>op` | Open: live preview | `:LvimPreview start` |
| `<Leader>oP` | Open: stop live preview | `:LvimPreview stop` |
| `<Leader>oi` | Open: image render toggle | `:LvimImage toggle` |
| `<Leader>oc` | Open: calendar (bottom) | `:LvimCalendar bottom` |
| `<Leader>oC` | Open: calendar (float) | `:LvimCalendar float` |
| `<Leader>oh` | Open: dashboard | `:LvimDashboard` |
| `<Leader>ov` | Open: vault (macros/marks) | `:LvimVault` |
| `<Leader>oI` | Open: icon picker | `:LvimIcons` |
| `<Leader>og` | Open: LazyGit | `:LvimShell lazygit` |
| `<Leader>oD` | Open: LazyDocker | `:LvimShell lazydocker` |
| `<Leader>oy` | Open: Yazi (files) | `:LvimShell yazi` |
| `<Leader>on` | Open: Neomutt (mail) | `:LvimShell neomutt` |

### `<Leader>u` — UI / Toggles / Settings

| Key | Action | Runs |
|---|---|---|
| `<Leader>uc` | UI: control center | `:LvimControlCenter lvim` |
| `<Leader>ug` | UI: general settings | `:LvimControlCenter general` |
| `<Leader>ua` | UI: appearance settings | `:LvimControlCenter appearance` |
| `<Leader>uL` | UI: LSP settings | `:LvimControlCenter lsp` |
| `<Leader>uC` | UI: commands settings | `:LvimControlCenter commands` |
| `<Leader>up` | UI: projects settings | `:LvimControlCenter projects` |
| `<Leader>ui` | UI: installer | `:LvimInstaller` |
| `<Leader>ud` | UI: dependencies | `:LvimDeps` |
| `<Leader>uk` | UI: keyring | `:LvimKeyring` |
| `<Leader>uh` | UI: keymap cheatsheet | `:LvimKeysHelper` |
| `<Leader>uz` | UI: undo history | `:LvimUndo toggle` |
| `<Leader>uj` | UI: undo project checkpoints | `:LvimUndo project` |
| `<Leader>ue` | UI: undo log | `:LvimUndo log` |
| `<Leader>uU` | UI: undo purge this buffer | `:LvimUndo purge` |
| `<Leader>uP` | UI: undo purge all | `:LvimUndo purge-all` |
| `<Leader>uI` | UI: indent guides toggle | `:LvimIndent toggle` |
| `<Leader>ux` | UI: sticky context toggle | `:LvimContext toggle` |
| `<Leader>um` | UI: messages | `:Messages` |

### Editor core, windows and buffers

| Key | Action | Runs |
|---|---|---|
| `<S-x>` | Files: toggle panel | `:LvimFiles toggle` |
| `<C-c><C-f>` | Files: toggle panel | `:LvimFiles toggle` |
| `<S-q>` | Files: close panel | `:LvimFiles close` |
| `gcd` | Delete all comments | `:LvimComments strip` |
| `<Esc>` | Clear search highlight | `<Esc>:noh` |
| `j` | Move down (visual-line aware) | `v:count == 0 ? 'gj' : 'j'` |
| `k` | Move up (visual-line aware) | `v:count == 0 ? 'gk' : 'k'` |
| `<C-c>N` | Create empty buffer | `:enew` |
| `<C-c>s` | Save | `:Save` |
| `<C-c>a` | Save all | `:wa` |
| `<C-c>e` | Close LvimIDE | `:Quit` |
| `<C-c>x` | Close current window | `<C-w>c` |
| `<C-c>o` | Close other windows | `<C-w>o` |
| `<C-c>d` | Delete buffer | `:enew \| bdelete #` |
| `<C-c>=` | Equalise window sizes | `:wincmd=` |
| `<C-c>n` | Next tab | `:tabn` |
| `<C-c>p` | Previous tab | `:tabp` |
| `<C-c>fc` | Close all floats | `:CloseFloatWindows` |
| `<C-c>ff` | Cycle focus to next float | `:FocusFloatWindow` |
| `<C-c>c` | Inspect highlight under cursor | `:Inspect` |
| `<C-c>O` | Open current file in OS handler | `:lua vim.ui.open(vim.fn.expand('%'))` |
| `<Leader>N` | New file in insert mode | `:ene \| startinsert` |
| `<Leader>n` / `<Leader>P` | Dock: next / previous consumer in the current layout (lvim-utils dock; `P`, not `p` — `<Leader>p` is the Space group prefix) | `:LvimDock <layout> next\|prev` |
| `<Leader>x` / `<Leader>m` | Dock: kill the visible consumer / the dock menu | `:LvimDock menu` |
| `gp` | Window: pick | `:LvimWinPick` |
| `<C-c>w` | Window: move mode | `:LvimWinMove` |
| `<C-c>l` | Linguistics: toggle insert language | `:LvimLinguistics toggle-insert-mode` |
| `<C-c>k` | Linguistics: toggle spelling | `:LvimLinguistics toggle-spelling` |
| `<C-n>` | Buffer history forward | `<Plug>(LvimBufHistoryForward)` |
| `<C-p>` | Buffer history back | `<Plug>(LvimBufHistoryBack)` |
| `<C-c>.` *(n/x/o)* | Jump | `<Plug>(lvim-jump)` |
| `<C-c>;` *(n/x/o)* | Jump (search) | `<Plug>(lvim-jump)` |
| `<C-c>,` *(n/x)* | Treesitter select | `<Plug>(lvim-jump-ts)` |

### Marks, jumps and macros (`m` as a prefix)

| Key | Action | Runs |
|---|---|---|
| `mvm` | Vault: marks | `:LvimVault marks` |
| `mvj` | Vault: jumps | `:LvimVault jumps` |
| `mvc` | Vault: macros | `:LvimVault macros` |
| `mam` | Vault mark: add local | `:LvimVault mark add-local` |
| `maM` | Vault mark: add global | `:LvimVault mark add-global` |
| `mdm` | Vault mark: delete local (line) | `:LvimVault mark delete-local` |
| `mdM` | Vault mark: delete global (line) | `:LvimVault mark delete-global` |
| `mDm` | Vault mark: delete all local | `:LvimVault mark delete-locals` |
| `mDM` | Vault mark: delete all global | `:LvimVault mark delete-globals` |
| `mcm` | Vault mark: change local (line) | `:LvimVault mark change-local` |
| `mcM` | Vault mark: change global (line) | `:LvimVault mark change-global` |
| `mnm` | Vault mark: annotate local (line) | `:LvimVault mark annotate-local` |
| `mnM` | Vault mark: annotate global (line) | `:LvimVault mark annotate-global` |
| `mgm` | Vault mark: jump to local by letter | `:LvimVault mark jump-local` |
| `mgM` | Vault mark: jump to global by letter | `:LvimVault mark jump-global` |
| `m]` | Vault mark: next (buffer) | `:LvimVault mark next` |
| `m[` | Vault mark: prev (buffer) | `:LvimVault mark prev` |

## Global — visual mode

| Key | Action | Runs |
|---|---|---|
| `<Leader>cc` | Code: comment selection | `:LvimComment line` |
| `<Leader>cp` | Code: pick colour | `:LvimColorPicker pick` |
| `*` | Search forward in selection | `<Esc>/\%V` |
| `#` | Search backward in selection | `<Esc>?\%V` |

## Global — insert mode

| Key | Action | Runs |
|---|---|---|
| `<C-j>` | Move down by visual line | `<C-o>gj` |
| `<C-k>` | Move up by visual line | `<C-o>gk` |

## Global — terminal mode

| Key | Action | Runs |
|---|---|---|
| `<Esc>` | Terminal: normal mode | `<C-\><C-n>` |

## LSP

Applied buffer-local when a server attaches, and **only where that server can answer**: each entry
names the capability it needs, so `gi` is simply not bound on a server without an implementation
provider. Diagnostics deliberately live on `]d` / `[d` / `gld` rather than `d*`, which would make
the delete operator wait out `timeoutlen` on every LSP buffer.

| Key | Action | Runs | Needs capability |
|---|---|---|---|
| `gd` | Go to definition | `:LvimLsp definition` | `definitionProvider` |
| `gD` | Go to declaration | `:LvimLsp declaration` | `declarationProvider` |
| `gt` | Go to type definition | `:LvimLsp type_definition` | `typeDefinitionProvider` |
| `gi` | Go to implementation | `:LvimLsp implementation` | `implementationProvider` |
| `gr` | Find references | `:LvimLsp references` | `referencesProvider` |
| `K` | Hover information | `:LvimLsp hover` | `hoverProvider` |
| `<C-k>` *(i)* | Signature help | `:LvimLsp signature_help` | `signatureHelpProvider` |
| `ge` | Rename symbol | `:LvimLsp rename` | `renameProvider` |
| `ga` | Code action | `<lua>` | `codeActionProvider` |
| `gf` | Format document | `:LvimLsp format` | `documentFormattingProvider` |
| `gF` *(v)* | Format selection | `:LvimLsp range_format` | `documentRangeFormattingProvider` |
| `gs` | Document symbols | `:LvimLsp document_symbol` | `documentSymbolProvider` |
| `gS` | Workspace symbols | `:LvimLsp workspace_symbol` | `workspaceSymbolProvider` |
| `gld` | Show line diagnostics | `:LvimLsp diagnostic_current` | — |
| `]d` | Next diagnostic | `:LvimLsp diagnostic_next` | — |
| `[d` | Previous diagnostic | `:LvimLsp diagnostic_prev` | — |
| `gL` | Run CodeLens | `:LspCodeLensRun` | `codeLensProvider` |
| `glc` | Incoming calls | `:LvimLsp incoming_calls` | `callHierarchyProvider` |
| `glC` | Outgoing calls | `:LvimLsp outgoing_calls` | `callHierarchyProvider` |
| `ghr` | Highlight references | `:LvimLsp document_highlight` | `documentHighlightProvider` |
| `ghc` | Clear highlights | `:LvimLsp clear_references` | `documentHighlightProvider` |
| `goa` | Add workspace folder | `:LvimLsp add_workspace_folder` | `(predicate)` |
| `gor` | Remove workspace folder | `:LvimLsp remove_workspace_folder` | `(predicate)` |
| `gol` | List workspace folders | `:LvimLsp list_workspace_folders` | `(predicate)` |
## The language layer

Nine chords, one meaning, every language: `:LvimLang <cmd>` dispatches to the provider of the
buffer you are in, so the same key runs a Go file with `go run`, a Rust one with `cargo run` and a
Python one with the interpreter its project resolves to.

A chord is bound **only where the provider really implements it** — a language without a debug
command never gets a debug key that would answer "no such command". Across the live registry:
`config` 91 providers, `run` 49, `build` 47, `test` 43, `test-func` 19, `debug` 17, `deps` 16,
`test-file` 14, `debug-test` 10.

They live on `<C-c><C-c>` rather than `<Leader>r`, because that group is the CROSS-language tooling
(tasks, build, test) and putting the language layer there would shadow it.

| Chord | Command | Action |
|---|---|---|
| `<C-c><C-c>r` | `:LvimLang run` | Run |
| `<C-c><C-c>b` | `:LvimLang build` | Build |
| `<C-c><C-c>t` | `:LvimLang test` | Test: all |
| `<C-c><C-c>f` | `:LvimLang test-func` | Test: function under the cursor |
| `<C-c><C-c>F` | `:LvimLang test-file` | Test: this file |
| `<C-c><C-c>d` | `:LvimLang debug` | Debug |
| `<C-c><C-c>D` | `:LvimLang debug-test` | Debug: the test under the cursor |
| `<C-c><C-c>p` | `:LvimLang deps` | Dependencies |
| `<C-c><C-c>c` | `:LvimLang config` | Run configuration |

## Per language

What each provider offers BEYOND the shared nine — its own tools, one chord each. The letter is
derived, never invented: the command's first letter when the shared layer has not taken it, its
uppercase next, then a consonant from the word. `r b t f F d D p c` are the shared nine and are
never reused, so nothing here can shadow "run" or "test".

Dart is the one hand-tuned section: a Flutter dev session (hot reload, restart, the device, the
inspector) has no counterpart in other languages, and its chords predate this layer.

### `ansible`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>l` | ansible-lint | `:LvimLang lint` |

### `astro`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>v` | npm run dev | `:LvimLang dev` |

### `bash`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | shellcheck <file> | `:LvimLang check` |

### `bib`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | latexmk -c | `:LvimLang clean` |

### `c`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | compile-commands | `:LvimLang compile-commands` |
| `<C-c><C-c>n` | configure | `:LvimLang configure` |
| `<C-c><C-c>s` | switch-header | `:LvimLang switch-header` |
| `<C-c><C-c>S` | symbol-info | `:LvimLang symbol-info` |

### `cmake`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | cmake -B build | `:LvimLang configure` |

### `cpp`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | compile-commands | `:LvimLang compile-commands` |
| `<C-c><C-c>n` | configure | `:LvimLang configure` |
| `<C-c><C-c>s` | switch-header | `:LvimLang switch-header` |
| `<C-c><C-c>S` | symbol-info | `:LvimLang symbol-info` |

### `cs`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | add | `:LvimLang add` |
| `<C-c><C-c>C` | dotnet clean [args] | `:LvimLang clean` |
| `<C-c><C-c>R` | dotnet remove package <package> | `:LvimLang remove` |
| `<C-c><C-c>s` | dotnet restore [args] | `:LvimLang restore` |

### `cue`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>e` | cue eval <file> | `:LvimLang eval` |
| `<C-c><C-c>v` | cue vet | `:LvimLang vet` |

### `dart`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>h` | Hot reload | `:LvimLang reload` |
| `<C-c><C-c>R` | Hot restart | `:LvimLang restart` |
| `<C-c><C-c>A` | Attach | `:LvimLang attach` |
| `<C-c><C-c>x` | Detach | `:LvimLang detach` |
| `<C-c><C-c>q` | Quit | `:LvimLang quit` |
| `<C-c><C-c>m` | Emulators | `:LvimLang emulators` |
| `<C-c><C-c>g` | Dev log | `:LvimLang log toggle` |
| `<C-c><C-c>v` | DevTools | `:LvimLang devtools` |
| `<C-c><C-c>i` | Inspect widget | `:LvimLang inspect` |
| `<C-c><C-c>y` | Debug paint | `:LvimLang paint` |
| `<C-c><C-c>B` | Brightness | `:LvimLang brightness` |
| `<C-c><C-c>P` | Target platform | `:LvimLang platform` |
| `<C-c><C-c>L` | Closing labels | `:LvimLang labels` |
| `<C-c><C-c>u` | Pub get | `:LvimLang pub get` |
| `<C-c><C-c>U` | Pub upgrade | `:LvimLang pub upgrade` |
| `<C-c><C-c>s` | Go to super | `:LvimLang super` |
| `<C-c><C-c>a` | Reanalyze | `:LvimLang reanalyze` |
| `<C-c><C-c>l` | Restart dartls | `:LvimLang lsp restart` |
| `<C-c><C-c>I` | Install SDK | `:LvimLang install` |
| `<C-c><C-c>o` | Outline | `:LvimLsp outline` |
| `<C-c><C-c>e` | Rename | `:LvimLsp rename` |

### `dune`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>e` | exec | `:LvimLang exec` |
| `<C-c><C-c>m` | dune build @fmt --auto-promote (ocamlformat) | `:LvimLang fmt` |
| `<C-c><C-c>u` | dune utop [dir] | `:LvimLang utop` |

### `eelixir`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | mix compile [args] | `:LvimLang compile` |
| `<C-c><C-c>R` | mix credo [args] | `:LvimLang credo` |
| `<C-c><C-c>m` | mix format [args] | `:LvimLang format` |
| `<C-c><C-c>i` | iex -S mix [args] | `:LvimLang iex` |

### `elixir`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | mix compile [args] | `:LvimLang compile` |
| `<C-c><C-c>R` | mix credo [args] | `:LvimLang credo` |
| `<C-c><C-c>m` | mix format [args] | `:LvimLang format` |
| `<C-c><C-c>i` | iex -S mix [args] | `:LvimLang iex` |

### `erlang`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | rebar3 compile [args] | `:LvimLang compile` |
| `<C-c><C-c>T` | rebar3 ct [args] | `:LvimLang ct` |
| `<C-c><C-c>S` | ct-suite | `:LvimLang ct-suite` |
| `<C-c><C-c>e` | rebar3 eunit [args] | `:LvimLang eunit` |
| `<C-c><C-c>m` | erlfmt --write <current file> | `:LvimLang fmt` |
| `<C-c><C-c>s` | rebar3 shell [args] (+ active run config) | `:LvimLang shell` |

### `eruby`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | bundle add <gem> [--version …] | `:LvimLang add` |
| `<C-c><C-c>R` | rake | `:LvimLang rake` |
| `<C-c><C-c>m` | bundle remove <gem…> | `:LvimLang remove` |
| `<C-c><C-c>B` | rubocop [args] | `:LvimLang rubocop` |
| `<C-c><C-c>x` | rubocop -A [args] | `:LvimLang rubocop-fix` |
| `<C-c><C-c>u` | bundle update [gem…] | `:LvimLang update` |

### `fsharp`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | add | `:LvimLang add` |
| `<C-c><C-c>C` | dotnet clean [args] | `:LvimLang clean` |
| `<C-c><C-c>m` | fantomas [paths…] | `:LvimLang format` |
| `<C-c><C-c>R` | dotnet remove package <package> | `:LvimLang remove` |
| `<C-c><C-c>s` | dotnet restore [args] | `:LvimLang restore` |

### `go`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | coverage [clear] | `:LvimLang coverage` |
| `<C-c><C-c>g` | go generate ./... [args] | `:LvimLang generate` |
| `<C-c><C-c>G` | go get <module[@version]> \| -u ./... | `:LvimLang get` |
| `<C-c><C-c>s` | gotests | `:LvimLang gotests` |
| `<C-c><C-c>S` | gotestsum | `:LvimLang gotestsum` |
| `<C-c><C-c>i` | impl <receiver…> <interface> | `:LvimLang impl` |
| `<C-c><C-c>m` | mod tidy\|download\|verify\|graph\|why | `:LvimLang mod` |
| `<C-c><C-c>T` | tags <add\|remove> [json\|xml\|…] | `:LvimLang tags` |
| `<C-c><C-c>v` | go vet ./... [args] | `:LvimLang vet` |

### `gomod`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | coverage [clear] | `:LvimLang coverage` |
| `<C-c><C-c>g` | go generate ./... [args] | `:LvimLang generate` |
| `<C-c><C-c>G` | go get <module[@version]> \| -u ./... | `:LvimLang get` |
| `<C-c><C-c>s` | gotests | `:LvimLang gotests` |
| `<C-c><C-c>S` | gotestsum | `:LvimLang gotestsum` |
| `<C-c><C-c>i` | impl <receiver…> <interface> | `:LvimLang impl` |
| `<C-c><C-c>m` | mod tidy\|download\|verify\|graph\|why | `:LvimLang mod` |
| `<C-c><C-c>T` | tags <add\|remove> [json\|xml\|…] | `:LvimLang tags` |
| `<C-c><C-c>v` | go vet ./... [args] | `:LvimLang vet` |

### `gotmpl`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | coverage [clear] | `:LvimLang coverage` |
| `<C-c><C-c>g` | go generate ./... [args] | `:LvimLang generate` |
| `<C-c><C-c>G` | go get <module[@version]> \| -u ./... | `:LvimLang get` |
| `<C-c><C-c>s` | gotests | `:LvimLang gotests` |
| `<C-c><C-c>S` | gotestsum | `:LvimLang gotestsum` |
| `<C-c><C-c>i` | impl <receiver…> <interface> | `:LvimLang impl` |
| `<C-c><C-c>m` | mod tidy\|download\|verify\|graph\|why | `:LvimLang mod` |
| `<C-c><C-c>T` | tags <add\|remove> [json\|xml\|…] | `:LvimLang tags` |
| `<C-c><C-c>v` | go vet ./... [args] | `:LvimLang vet` |

### `gowork`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | coverage [clear] | `:LvimLang coverage` |
| `<C-c><C-c>g` | go generate ./... [args] | `:LvimLang generate` |
| `<C-c><C-c>G` | go get <module[@version]> \| -u ./... | `:LvimLang get` |
| `<C-c><C-c>s` | gotests | `:LvimLang gotests` |
| `<C-c><C-c>S` | gotestsum | `:LvimLang gotestsum` |
| `<C-c><C-c>i` | impl <receiver…> <interface> | `:LvimLang impl` |
| `<C-c><C-c>m` | mod tidy\|download\|verify\|graph\|why | `:LvimLang mod` |
| `<C-c><C-c>T` | tags <add\|remove> [json\|xml\|…] | `:LvimLang tags` |
| `<C-c><C-c>v` | go vet ./... [args] | `:LvimLang vet` |

### `haskell`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | stack clean / cabal clean [args] | `:LvimLang clean` |

### `hcl`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>P` | terraform plan | `:LvimLang plan` |
| `<C-c><C-c>v` | terraform validate | `:LvimLang validate` |

### `heex`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | mix compile [args] | `:LvimLang compile` |
| `<C-c><C-c>R` | mix credo [args] | `:LvimLang credo` |
| `<C-c><C-c>m` | mix format [args] | `:LvimLang format` |
| `<C-c><C-c>i` | iex -S mix [args] | `:LvimLang iex` |

### `helm`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>l` | helm lint . | `:LvimLang lint` |
| `<C-c><C-c>T` | helm template . | `:LvimLang template` |

### `java`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>e` | extract-constant | `:LvimLang extract-constant` |
| `<C-c><C-c>E` | extract-method | `:LvimLang extract-method` |
| `<C-c><C-c>x` | extract-variable | `:LvimLang extract-variable` |
| `<C-c><C-c>o` | jdtls: remove unused + order imports | `:LvimLang organize-imports` |

### `javascript`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | add <package…> | `:LvimLang add` |
| `<C-c><C-c>C` | coverage [clear] | `:LvimLang coverage` |
| `<C-c><C-c>v` | run the `dev` script | `:LvimLang dev` |
| `<C-c><C-c>i` | install | `:LvimLang install` |
| `<C-c><C-c>R` | remove <package…> | `:LvimLang remove` |
| `<C-c><C-c>s` | script [name] | `:LvimLang script` |
| `<C-c><C-c>T` | emit .d.ts declarations (tsc --declaration) | `:LvimLang types` |
| `<C-c><C-c>u` | update [package…] | `:LvimLang update` |

### `javascriptreact`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | add <package…> | `:LvimLang add` |
| `<C-c><C-c>C` | coverage [clear] | `:LvimLang coverage` |
| `<C-c><C-c>v` | run the `dev` script | `:LvimLang dev` |
| `<C-c><C-c>i` | install | `:LvimLang install` |
| `<C-c><C-c>R` | remove <package…> | `:LvimLang remove` |
| `<C-c><C-c>s` | script [name] | `:LvimLang script` |
| `<C-c><C-c>T` | emit .d.ts declarations (tsc --declaration) | `:LvimLang types` |
| `<C-c><C-c>u` | update [package…] | `:LvimLang update` |

### `lhaskell`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | stack clean / cabal clean [args] | `:LvimLang clean` |

### `menhir`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>e` | exec | `:LvimLang exec` |
| `<C-c><C-c>m` | dune build @fmt --auto-promote (ocamlformat) | `:LvimLang fmt` |
| `<C-c><C-c>u` | dune utop [dir] | `:LvimLang utop` |

### `mysql`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>l` | sqlfluff lint <file> | `:LvimLang lint` |

### `objc`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | compile-commands | `:LvimLang compile-commands` |
| `<C-c><C-c>n` | configure | `:LvimLang configure` |
| `<C-c><C-c>s` | switch-header | `:LvimLang switch-header` |
| `<C-c><C-c>S` | symbol-info | `:LvimLang symbol-info` |

### `objcpp`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | compile-commands | `:LvimLang compile-commands` |
| `<C-c><C-c>n` | configure | `:LvimLang configure` |
| `<C-c><C-c>s` | switch-header | `:LvimLang switch-header` |
| `<C-c><C-c>S` | symbol-info | `:LvimLang symbol-info` |

### `ocaml`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>e` | exec | `:LvimLang exec` |
| `<C-c><C-c>m` | dune build @fmt --auto-promote (ocamlformat) | `:LvimLang fmt` |
| `<C-c><C-c>u` | dune utop [dir] | `:LvimLang utop` |

### `ocaml.interface`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>e` | exec | `:LvimLang exec` |
| `<C-c><C-c>m` | dune build @fmt --auto-promote (ocamlformat) | `:LvimLang fmt` |
| `<C-c><C-c>u` | dune utop [dir] | `:LvimLang utop` |

### `ocamllex`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>e` | exec | `:LvimLang exec` |
| `<C-c><C-c>m` | dune build @fmt --auto-promote (ocamlformat) | `:LvimLang fmt` |
| `<C-c><C-c>u` | dune utop [dir] | `:LvimLang utop` |

### `php`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | phpstan analyse | `:LvimLang analyse` |
| `<C-c><C-c>C` | php-cs-fixer fix | `:LvimLang cs-fix` |
| `<C-c><C-c>R` | composer remove <package> | `:LvimLang remove` |
| `<C-c><C-c>q` | require | `:LvimLang require` |
| `<C-c><C-c>s` | php -S host:port | `:LvimLang serve` |

### `plaintex`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | latexmk -c | `:LvimLang clean` |

### `plsql`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>l` | sqlfluff lint <file> | `:LvimLang lint` |

### `proto`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>g` | buf generate | `:LvimLang generate` |
| `<C-c><C-c>l` | buf lint | `:LvimLang lint` |

### `python`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | add <package…> | `:LvimLang add` |
| `<C-c><C-c>C` | python -m compileall | `:LvimLang check` |
| `<C-c><C-c>g` | coverage [clear] | `:LvimLang coverage` |
| `<C-c><C-c>R` | remove <package…> | `:LvimLang remove` |
| `<C-c><C-c>n` | python -m <module> [args] | `:LvimLang run-module` |
| `<C-c><C-c>s` | stub <import> | `:LvimLang stub` |
| `<C-c><C-c>u` | unittest | `:LvimLang unittest` |
| `<C-c><C-c>U` | update [package…] | `:LvimLang update` |
| `<C-c><C-c>v` | venv [create [name]] | `:LvimLang venv` |

### `ruby`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | bundle add <gem> [--version …] | `:LvimLang add` |
| `<C-c><C-c>R` | rake | `:LvimLang rake` |
| `<C-c><C-c>m` | bundle remove <gem…> | `:LvimLang remove` |
| `<C-c><C-c>B` | rubocop [args] | `:LvimLang rubocop` |
| `<C-c><C-c>x` | rubocop -A [args] | `:LvimLang rubocop-fix` |
| `<C-c><C-c>u` | bundle update [gem…] | `:LvimLang update` |

### `rust`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | cargo add <crate[@version]> [--features …] | `:LvimLang add` |
| `<C-c><C-c>C` | cargo check [args] | `:LvimLang check` |
| `<C-c><C-c>l` | cargo clippy [args] | `:LvimLang clippy` |
| `<C-c><C-c>e` | expand [item] | `:LvimLang expand` |
| `<C-c><C-c>m` | cargo fmt [args] | `:LvimLang fmt` |
| `<C-c><C-c>n` | cargo nextest run [args] | `:LvimLang nextest` |
| `<C-c><C-c>R` | cargo remove <crate…> | `:LvimLang remove` |
| `<C-c><C-c>u` | cargo update [crate] | `:LvimLang update` |

### `sh`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | shellcheck <file> | `:LvimLang check` |

### `sql`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>l` | sqlfluff lint <file> | `:LvimLang lint` |

### `svelte`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>v` | npm run dev | `:LvimLang dev` |

### `swift`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | swift package clean [args] | `:LvimLang clean` |
| `<C-c><C-c>m` | swiftformat [args] | `:LvimLang fmt` |
| `<C-c><C-c>u` | swift package update | `:LvimLang update` |

### `terraform`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>P` | terraform plan | `:LvimLang plan` |
| `<C-c><C-c>v` | terraform validate | `:LvimLang validate` |

### `tex`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>C` | latexmk -c | `:LvimLang clean` |

### `tf`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>P` | terraform plan | `:LvimLang plan` |
| `<C-c><C-c>v` | terraform validate | `:LvimLang validate` |

### `twig`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>l` | djlint <file> | `:LvimLang lint` |

### `typescript`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | add <package…> | `:LvimLang add` |
| `<C-c><C-c>C` | coverage [clear] | `:LvimLang coverage` |
| `<C-c><C-c>v` | run the `dev` script | `:LvimLang dev` |
| `<C-c><C-c>i` | install | `:LvimLang install` |
| `<C-c><C-c>R` | remove <package…> | `:LvimLang remove` |
| `<C-c><C-c>s` | script [name] | `:LvimLang script` |
| `<C-c><C-c>T` | emit .d.ts declarations (tsc --declaration) | `:LvimLang types` |
| `<C-c><C-c>u` | update [package…] | `:LvimLang update` |

### `typescriptreact`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>a` | add <package…> | `:LvimLang add` |
| `<C-c><C-c>C` | coverage [clear] | `:LvimLang coverage` |
| `<C-c><C-c>v` | run the `dev` script | `:LvimLang dev` |
| `<C-c><C-c>i` | install | `:LvimLang install` |
| `<C-c><C-c>R` | remove <package…> | `:LvimLang remove` |
| `<C-c><C-c>s` | script [name] | `:LvimLang script` |
| `<C-c><C-c>T` | emit .d.ts declarations (tsc --declaration) | `:LvimLang types` |
| `<C-c><C-c>u` | update [package…] | `:LvimLang update` |

### `typst`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>w` | typst watch ${file} | `:LvimLang watch` |

### `unison`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>R` | run-file [main] | `:LvimLang run-file` |
| `<C-c><C-c>T` | transcript [file.md] | `:LvimLang transcript` |

### `vue`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>v` | npm run dev | `:LvimLang dev` |

### `yaml.ansible`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>l` | ansible-lint | `:LvimLang lint` |

### `zig`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>h` | zig fetch --save <url\|path> | `:LvimLang fetch` |
| `<C-c><C-c>m` | zig fmt [path] | `:LvimLang fmt` |

### `zir`

| Chord | Action | Runs |
|---|---|---|
| `<C-c><C-c>h` | zig fetch --save <url\|path> | `:LvimLang fetch` |
| `<C-c><C-c>m` | zig fmt [path] | `:LvimLang fmt` |

## Keys a plugin owns

Three sets stay with their plugin, because they call its API directly rather than a command:

| Keys | Plugin | What they do |
|---|---|---|
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | lvim-winnav | focus that direction; at the edge it hands off to the multiplexer, and DOWN enters the message zone first |
| `<C-Up>` `<C-Down>` `<C-Left>` `<C-Right>` | lvim-winnav | resize the current window |
| `<A-1>` … `<A-0>` | lvim-dap | the debugger's stepping row |
| `<C-c>1` … `<C-c>9` | lvim-term | jump to terminal *n* (generated from the configured count) |

Every panel also has its own buffer-local keys — press `?` or `g?` inside it, or read that plugin's
`:help`.

## Overriding

```lua
-- lua/keys/user/init.lua — merged over the base manifest
return {
    global = {
        normal = {
            { "<Leader>zz", "<Cmd>LvimGit status<CR>", "Git: status" },
        },
    },
}
```

To rebind a key *inside* a plugin (its panel keys), use the `plugins` section — it is forwarded into
that plugin's own `setup(opts.keys)`:

```lua
-- lua/keys/base/plugins.lua (or the user layer)
return {
    ["lvim-files"] = { open_split = "s", open_vsplit = "v" },
}
```
