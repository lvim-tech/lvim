# Keys

One manifest, `lua/keys/base/`, is the single source of truth for keymaps. It is split by **when and
where** a key applies, and `lua/core/keys.lua` merges `lua/keys/user/` over it and applies each
section at the right moment:

| Section | File | Applied |
|---|---|---|
| groups | `keys/base/groups.lua` | once, as the prefix labels the hint panel shows |
| global | `keys/base/global.lua` | at startup, per mode |
| lsp | `keys/base/lsp.lua` | buffer-local on `LspAttach`, guarded by the server's capability |
| filetype | `keys/base/filetype.lua` | buffer-local on `FileType` |
| plugins | `keys/base/plugins.lua` | forwarded into a plugin's own `setup(opts.keys)` |

**Add a key there, not in a plugin's config.** The documented exception is a key that drives a
plugin's live API rather than a command — lvim-winnav's `<C-h/j/k/l>` and `<C-Arrows>`, lvim-dap's
`<A-1>`…`<A-0>`, lvim-term's generated `<C-c>1`…`9` — because it needs the module in hand.

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
| `<Leader>wm` | Move window |

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
| `<Leader>rb` | Build: action chooser | `:LvimBuild` |
| `<Leader>rl` | Build: show redo target | `:LvimBuild last` |
| `<Leader>rd` | Build: redo last action | `:LvimBuild redo` |
| `<Leader>rt` | Test: nearest | `:LvimTest run` |
| `<Leader>rF` | Test: file | `:LvimTest file` |
| `<Leader>rs` | Test: suite | `:LvimTest suite` |
| `<Leader>rf` | Test: rerun failed | `:LvimTest run_failed` |
| `<Leader>rm` | Test: mark | `:LvimTest mark` |
| `<Leader>rM` | Test: run marked | `:LvimTest run_marked` |
| `<Leader>ro` | Test: output | `:LvimTest output` |
| `<Leader>rw` | Test: watch | `:LvimTest watch` |

### `<Leader>f` — Files / Remote

| Key | Action | Runs |
|---|---|---|
| `<Leader>ff` | Files: explorer | `:LvimFiles` |
| `<Leader>fx` | Files: open under cursor (OS) | `:GxOpen` |
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

### `<Leader>wm` — Move window

| Key | Action | Runs |
|---|---|---|
| `<Leader>wmh` | Move window left | `:LvimWinMove left` |
| `<Leader>wmj` | Move window down | `:LvimWinMove down` |
| `<Leader>wmk` | Move window up | `:LvimWinMove up` |
| `<Leader>wml` | Move window right | `:LvimWinMove right` |

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
| `<Leader>od` | Open: database client | `:LvimDb open` |
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
| `gpp` | Window: pick | `:LvimWinPick` |
| `<C-c>w` | Window: move mode | `:LvimWinMove` |
| `<C-c>l` | Linguistics: toggle insert language | `:LvimLinguisticsTOGGLEInsertModeLanguage` |
| `<C-c>k` | Linguistics: toggle spelling | `:LvimLinguisticsTOGGLESpelling` |
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
provider. Diagnostics deliberately live on `]d` / `[d` / `gld` rather than `d*`, which would make the
delete operator wait out `timeoutlen` on every LSP buffer.

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
| `ga` | Code action | `<lua function>` | `codeActionProvider` |
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

## Per filetype

The same key means *the language's own action*: `<Leader>rr` runs a Go file through lvim-build and a
Flutter app through lvim-lang. That is what keeps the hint panel accurate per buffer.

### `dart`

| Key | Action | Runs |
|---|---|---|
| `<Leader>rr` | Run (Flutter) | `:LvimLang run` |
| `<Leader>rR` | Hot restart | `:LvimLang restart` |
| `<Leader>rl` | Hot reload | `:LvimLang reload` |
| `<Leader>rA` | Attach | `:LvimLang attach` |
| `<C-c><C-c>f` | Run | `:LvimLang run` |
| `<C-c><C-c>A` | Attach | `:LvimLang attach` |
| `<C-c><C-c>r` | Hot reload | `:LvimLang reload` |
| `<C-c><C-c>R` | Hot restart | `:LvimLang restart` |
| `<C-c><C-c>q` | Quit | `:LvimLang quit` |
| `<C-c><C-c>D` | Detach | `:LvimLang detach` |
| `<C-c><C-c>m` | Emulators | `:LvimLang emulators` |
| `<C-c><C-c>g` | Dev log | `:LvimLang log toggle` |
| `<C-c><C-c>c` | Run config | `:LvimLang config` |
| `<C-c><C-c>t` | DevTools | `:LvimLang devtools` |
| `<C-c><C-c>i` | Inspect widget | `:LvimLang inspect` |
| `<C-c><C-c>p` | Debug paint | `:LvimLang paint` |
| `<C-c><C-c>b` | Brightness | `:LvimLang brightness` |
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

### `go`

| Key | Action | Runs |
|---|---|---|
| `<Leader>rr` | Run (go) | `:LvimBuild run` |

### `rust`

| Key | Action | Runs |
|---|---|---|
| `<Leader>rr` | Run (cargo) | `:LvimBuild run` |

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
