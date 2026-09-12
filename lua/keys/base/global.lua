-- keys/base/global.lua — the keymaps applied ONCE at startup, per mode.
--
-- Tuple format: { lhs, rhs, desc, opts? } (rhs = a string command / <Plug> / a Lua function).
-- A 4th element may carry per-entry options, including `mode` for a map that spans modes.
---@module "keys.base.global"

local global = {}

global.normal = {
    -- <Leader>s — Search / Navigate  (lvim-picker finders + lvim-replace + lvim-search)
    { "<Leader>sf", "<Cmd>LvimPicker files<CR>", "Search: files" },
    { "<Leader>sg", "<Cmd>LvimPicker grep<CR>", "Search: live grep" },
    { "<Leader>sb", "<Cmd>LvimPicker buffers<CR>", "Search: buffers" },
    { "<Leader>so", "<Cmd>LvimPicker oldfiles<CR>", "Search: recent files" },
    { "<Leader>sm", "<Cmd>LvimPicker marks<CR>", "Search: marks" },
    { "<Leader>sG", "<Cmd>LvimPicker git_files<CR>", "Search: git files" },
    { "<Leader>sk", "<Cmd>LvimPicker keymaps<CR>", "Search: keymaps" },
    { "<Leader>sc", "<Cmd>LvimPicker commands<CR>", "Search: commands" },
    { "<Leader>sq", "<Cmd>LvimPicker quickfix<CR>", "Search: quickfix" },
    { "<Leader>sr", "<Cmd>LvimReplace<CR>", "Search: project replace" },
    -- The last search (@/) as a list — this buffer, or every loaded one.
    { "<Leader>se", "<Cmd>LvimSearchExport<CR>", "Search: matches to quickfix" },
    { "<Leader>sE", "<Cmd>LvimSearchExport all<CR>", "Search: matches to quickfix (all buffers)" },

    -- <Leader>g — Git / Review  (lvim-git + lvim-forge)
    { "<Leader>gg", "<Cmd>LvimGit status<CR>", "Git: status" },
    { "<Leader>gd", "<Cmd>LvimGit diffview<CR>", "Git: diffview" },
    { "<Leader>gl", "<Cmd>LvimGit log<CR>", "Git: log" },
    { "<Leader>gb", "<Cmd>LvimGit toggle_blame<CR>", "Git: inline blame toggle" },
    { "<Leader>gB", "<Cmd>LvimGit blame<CR>", "Git: blame split" },
    { "<Leader>gr", "<Cmd>LvimGit refs<CR>", "Git: refs / bookmarks" },
    { "<Leader>go", "<Cmd>LvimGit oplog<CR>", "Git: op log / reflog" },
    { "<Leader>gf", "<Cmd>LvimForge dispatch<CR>", "Forge: dispatch (menu)" },
    { "<Leader>gF", "<Cmd>LvimForge topics<CR>", "Forge: topics (issues + PRs)" },
    { "<Leader>gN", "<Cmd>LvimForge notifications<CR>", "Forge: notifications" },

    -- <Leader>d — Debug  (lvim-dap + lvim-dap-view + LSP-driven start)
    { "<Leader>dc", "<Cmd>LvimDap continue<CR>", "Debug: continue / start" },
    { "<Leader>db", "<Cmd>LvimDap toggle_breakpoint<CR>", "Debug: toggle breakpoint" },
    { "<Leader>dB", "<Cmd>LvimDap clear_breakpoints<CR>", "Debug: clear breakpoints" },
    { "<Leader>dp", "<Cmd>LvimDap pause<CR>", "Debug: pause" },
    { "<Leader>dt", "<Cmd>LvimDap terminate<CR>", "Debug: terminate" },
    { "<Leader>dv", "<Cmd>LvimDapView toggle<CR>", "Debug: toggle view" },
    { "<Leader>dl", "<Cmd>LvimLsp dap<CR>", "Debug: start (LSP-driven)" },

    -- <Leader>r — Run / Test / Tasks  (lvim-tasks + lvim-build + lvim-test; ft run in keys.filetype)
    { "<Leader>rn", "<Cmd>LvimTasks run<CR>", "Tasks: run template" },
    { "<Leader>ra", "<Cmd>LvimTasks toggle<CR>", "Tasks: panel" },
    { "<Leader>rh", "<Cmd>LvimTasks history<CR>", "Tasks: history" },
    { "<Leader>rx", "<Cmd>LvimTasks stop<CR>", "Tasks: stop" },
    -- `rr` is GLOBAL because `LvimBuild run` is: it detects the project and the file and runs the
    -- recipe that fits, whatever the language. It used to be declared per filetype for rust and go
    -- alone, which left every other language without it for no reason. A language whose run is
    -- something else entirely overrides it in keys/base/filetype.lua — dart does, because there
    -- `run` means a Flutter session, not a build recipe.
    { "<Leader>rr", "<Cmd>LvimBuild run<CR>", "Run: build recipe" },
    { "<Leader>rb", "<Cmd>LvimBuild<CR>", "Build: action chooser" },
    { "<Leader>rl", "<Cmd>LvimBuild last<CR>", "Build: show redo target" },
    { "<Leader>rd", "<Cmd>LvimBuild redo<CR>", "Build: redo last action" },
    { "<Leader>rt", "<Cmd>LvimTest run<CR>", "Test: nearest" },
    { "<Leader>rF", "<Cmd>LvimTest file<CR>", "Test: file" },
    { "<Leader>rs", "<Cmd>LvimTest suite<CR>", "Test: suite" },
    -- `failed` is the subcommand's real name (`run_failed` was rejected by :LvimTest). Marking a test
    -- and running the marked set are keys INSIDE the summary panel (`m` / `R` / `M`, lvim-test's
    -- `keys.summary`) — there is no :LvimTest subcommand for them, so the two global keys that named
    -- `mark` / `run_marked` did nothing; they are replaced by one that opens the panel.
    { "<Leader>rf", "<Cmd>LvimTest failed<CR>", "Test: rerun failed" },
    { "<Leader>rS", "<Cmd>LvimTest summary<CR>", "Test: summary panel (m marks, R runs marked)" },
    { "<Leader>ro", "<Cmd>LvimTest output<CR>", "Test: output" },
    { "<Leader>rw", "<Cmd>LvimTest watch<CR>", "Test: watch" },

    -- <Leader>f — Files / Remote  (lvim-files + gx + lvim-remote + lvim-common print)
    { "<Leader>ff", "<Cmd>LvimFiles<CR>", "Files: explorer" },
    -- The print dialog (a PDF or a CUPS printer); the visual map prints only the selection.
    { "<Leader>fp", "<Cmd>LvimPrint<CR>", "Files: print (printer / PDF)" },
    -- The file panel's own chords (they were set inside the plugin's config, out of sight of
    -- this manifest, which is what `<Leader>sk` / the hint panel read).
    { "<S-x>", "<Cmd>LvimFiles toggle<CR>", "Files: toggle panel" },
    { "<C-c><C-f>", "<Cmd>LvimFiles toggle<CR>", "Files: toggle panel" },
    { "<Leader>fx", "<Cmd>GxOpen<CR>", "Files: open under cursor (OS)" },
    { "<Leader>fi", "<Cmd>LvimRemote init<CR>", "Remote: init project config" },
    { "<Leader>fu", "<Cmd>LvimRemote upload<CR>", "Remote: upload buffer" },
    { "<Leader>fd", "<Cmd>LvimRemote download<CR>", "Remote: download buffer" },
    { "<Leader>fD", "<Cmd>LvimRemote diff<CR>", "Remote: diff buffer" },
    { "<Leader>fs", "<Cmd>LvimRemote sync-up<CR>", "Remote: sync up (review)" },
    { "<Leader>fS", "<Cmd>LvimRemote sync-down<CR>", "Remote: sync down (review)" },

    -- <Leader>b — Buffers  (lvim-buf-history)
    { "<Leader>bb", "<Cmd>LvimBufHistory list<CR>", "Buffers: history list" },
    { "<Leader>bn", "<Cmd>LvimBufHistory forward<CR>", "Buffers: forward" },
    { "<Leader>bp", "<Cmd>LvimBufHistory back<CR>", "Buffers: back" },
    { "<Leader>bc", "<Cmd>LvimBufHistory clear<CR>", "Buffers: clear history" },
    { "<Leader>bd", ":enew | bdelete #<CR>", "Buffers: delete" },

    -- <Leader>w — Windows  (splits + lvim-winpick + lvim-winmove)
    { "<Leader>wv", "<Cmd>vsplit<CR>", "Window: split right" },
    { "<Leader>w-", "<Cmd>split<CR>", "Window: split below" },
    { "<Leader>wc", "<C-w>c", "Window: close" },
    { "<Leader>wo", "<C-w>o", "Window: close others" },
    { "<Leader>w=", "<Cmd>wincmd =<CR>", "Window: equalise" },
    { "<Leader>wp", "<Cmd>LvimWinPick<CR>", "Window: pick" },
    { "<Leader>ws", "<Cmd>LvimWinMove swap<CR>", "Window: swap" },
    -- The interactive MOVE MODE (the plugin's main interface: focus tint + "WIN MOVE" HUD title) — the
    -- same as <C-c>w. Not four one-shot `<Leader>wm{h,j,k,l}` moves: those bypass the mode, and they made
    -- `<Leader>wm` a strict prefix that waited out 'timeoutlen'.
    { "<Leader>wm", "<Cmd>LvimWinMove<CR>", "Window: move mode (h/j/k/l · H/J/K/L edge · s swap · q quit)" },

    -- <Leader>p — Project / Space  (lvim-space: sessions/projects/tabs)
    { "<Leader>pp", "<Cmd>LvimSpace<CR>", "Space: projects / workspaces" },
    -- No prompts here: an operation that needs a value asks for it ITSELF (lvim-space's tab ops
    -- do, through vim.ui.input), so these stay plain commands.
    { "<Leader>pt", "<Cmd>LvimSpace tab new<CR>", "Space: new tab" },
    { "<Leader>px", "<Cmd>LvimSpace tab close<CR>", "Space: close tab" },
    { "<Leader>pn", "<Cmd>LvimSpace tab next<CR>", "Space: next tab" },
    { "<Leader>pP", "<Cmd>LvimSpace tab prev<CR>", "Space: prev tab" },
    { "<Leader>pl", "<Cmd>LvimSpace tab move-next<CR>", "Space: move tab right" },
    { "<Leader>ph", "<Cmd>LvimSpace tab move-prev<CR>", "Space: move tab left" },
    { "<Leader>pj", "<Cmd>LvimSpace tab goto<CR>", "Space: jump to tab by index" },
    { "<Leader>pr", "<Cmd>LvimSpace tab rename<CR>", "Space: rename tab" },

    -- <Leader>c — Code / Edit  (lvim-comment / lvim-table / lvim-color-picker)
    { "<Leader>cc", "<Cmd>LvimComment line<CR>", "Code: comment line" },
    { "<Leader>cb", "<Cmd>LvimComment block<CR>", "Code: comment block" },
    { "<Leader>ct", "<Cmd>LvimTable toggle<CR>", "Code: table mode toggle" },
    { "<Leader>cp", "<Cmd>LvimColorPicker pick<CR>", "Code: pick colour" },
    { "<Leader>ck", "<Cmd>LvimColorPicker convert<CR>", "Code: convert colour" },

    -- <Leader>o — Open / Tools  (launch a panel / TUI)
    { "<Leader>ot", "<Cmd>LvimTerm toggle<CR>", "Open: terminal" },
    { "<Leader>os", "<Cmd>LvimShell<CR>", "Open: shell launcher" },
    -- A bare `:LvimDb` opens the workspace; `open` is not a subcommand (it raised "unknown subcommand").
    { "<Leader>od", "<Cmd>LvimDb<CR>", "Open: database client" },
    -- lvim-rest: `scratch` opens the persistent ad-hoc `.http` buffer (the natural entry point —
    -- a bare `:LvimRest` only prints engine status); `history` re-opens a past request.
    { "<Leader>oa", "<Cmd>LvimRest scratch<CR>", "Open: REST scratchpad" },
    { "<Leader>oA", "<Cmd>LvimRest history<CR>", "Open: REST history" },
    -- lvim-preview: start serves the CURRENT file and opens the browser; stop shuts the server down.
    { "<Leader>op", "<Cmd>LvimPreview start<CR>", "Open: live preview" },
    { "<Leader>oP", "<Cmd>LvimPreview stop<CR>", "Open: stop live preview" },
    { "<Leader>oi", "<Cmd>LvimImage toggle<CR>", "Open: image render toggle" },
    { "<Leader>oc", "<Cmd>LvimCalendar bottom<CR>", "Open: calendar (bottom)" },
    { "<Leader>oC", "<Cmd>LvimCalendar float<CR>", "Open: calendar (float)" },
    { "<Leader>oh", "<Cmd>LvimDashboard<CR>", "Open: dashboard" },
    { "<Leader>ov", "<Cmd>LvimVault<CR>", "Open: vault (macros/marks)" },
    { "<Leader>oI", "<Cmd>LvimIcons<CR>", "Open: icon picker" },
    -- shell TUIs (lvim-shell presets)
    { "<Leader>og", "<Cmd>LvimShell lazygit<CR>", "Open: LazyGit" },
    { "<Leader>oD", "<Cmd>LvimShell lazydocker<CR>", "Open: LazyDocker" },
    { "<Leader>oy", "<Cmd>LvimShell yazi<CR>", "Open: Yazi (files)" },
    { "<Leader>on", "<Cmd>LvimShell neomutt<CR>", "Open: Neomutt (mail)" },

    -- <Leader>u — UI / Toggles / Settings
    { "<Leader>uc", "<Cmd>LvimControlCenter lvim<CR>", "UI: control center" },
    { "<Leader>ug", "<Cmd>LvimControlCenter general<CR>", "UI: general settings" },
    { "<Leader>ua", "<Cmd>LvimControlCenter appearance<CR>", "UI: appearance settings" },
    { "<Leader>uL", "<Cmd>LvimControlCenter lsp<CR>", "UI: LSP settings" },
    { "<Leader>uC", "<Cmd>LvimControlCenter commands<CR>", "UI: commands settings" },
    { "<Leader>up", "<Cmd>LvimControlCenter projects<CR>", "UI: projects settings" },
    { "<Leader>ui", "<Cmd>LvimInstaller<CR>", "UI: installer" },
    { "<Leader>ud", "<Cmd>LvimDeps<CR>", "UI: dependencies" },
    { "<Leader>uk", "<Cmd>LvimKeyring<CR>", "UI: keyring" },
    { "<Leader>uh", "<Cmd>LvimKeysHelper<CR>", "UI: keymap cheatsheet" },
    -- lvim-undo (the whole timeline set — these were duplicated in the plugin config, where
    -- `<Leader>up` collided with "control center: projects" above and won).
    { "<Leader>uz", "<Cmd>LvimUndo toggle<CR>", "UI: undo history" },
    { "<Leader>uj", "<Cmd>LvimUndo project<CR>", "UI: undo project checkpoints" },
    { "<Leader>ue", "<Cmd>LvimUndo log<CR>", "UI: undo log" },
    { "<Leader>uU", "<Cmd>LvimUndo purge<CR>", "UI: undo purge this buffer" },
    { "<Leader>uP", "<Cmd>LvimUndo purge-all<CR>", "UI: undo purge all" },
    { "<Leader>uI", "<Cmd>LvimIndent toggle<CR>", "UI: indent guides toggle" },
    { "<Leader>ux", "<Cmd>LvimContext toggle<CR>", "UI: sticky context toggle" },
    { "<Leader>um", "<Cmd>Messages<CR>", "UI: messages" },

    -- m — VAULT (marks, jumps, macros). `marks.disable_native = true` frees `m` as a PREFIX:
    -- `mv*` opens the panel tabs; `m<verb><scope>` drives the marks from the editor
    -- (verb: a=add, d=delete-line, D=delete-all, c=change, n=annotate, g=goto; scope: m=local, M=global).
    { "mvm", "<Cmd>LvimVault marks<CR>", "Vault: marks" },
    { "mvj", "<Cmd>LvimVault jumps<CR>", "Vault: jumps" },
    { "mvc", "<Cmd>LvimVault macros<CR>", "Vault: macros" },
    { "mam", "<Cmd>LvimVault mark add-local<CR>", "Vault mark: add local" },
    { "maM", "<Cmd>LvimVault mark add-global<CR>", "Vault mark: add global" },
    { "mdm", "<Cmd>LvimVault mark delete-local<CR>", "Vault mark: delete local (line)" },
    { "mdM", "<Cmd>LvimVault mark delete-global<CR>", "Vault mark: delete global (line)" },
    { "mDm", "<Cmd>LvimVault mark delete-locals<CR>", "Vault mark: delete all local" },
    { "mDM", "<Cmd>LvimVault mark delete-globals<CR>", "Vault mark: delete all global" },
    { "mcm", "<Cmd>LvimVault mark change-local<CR>", "Vault mark: change local (line)" },
    { "mcM", "<Cmd>LvimVault mark change-global<CR>", "Vault mark: change global (line)" },
    { "mnm", "<Cmd>LvimVault mark annotate-local<CR>", "Vault mark: annotate local (line)" },
    { "mnM", "<Cmd>LvimVault mark annotate-global<CR>", "Vault mark: annotate global (line)" },
    { "mgm", "<Cmd>LvimVault mark jump-local<CR>", "Vault mark: jump to local by letter" },
    { "mgM", "<Cmd>LvimVault mark jump-global<CR>", "Vault mark: jump to global by letter" },
    { "m]", "<Cmd>LvimVault mark next<CR>", "Vault mark: next (buffer)" },
    { "m[", "<Cmd>LvimVault mark prev<CR>", "Vault mark: prev (buffer)" },

    -- Editor utility commands from lvim-common (its setup() registers them).
    { "gcd", "<Cmd>LvimComments strip<CR>", "Delete all comments" },
    { "<Leader>co", "<Cmd>LvimEval<CR>", "Code: run a command into a window" },

    -- Core editor + window/buffer chords (NOT launchers; the <C-c> muscle-memory layer).
    { "<Esc>", "<Esc>:noh<CR>", "Clear search highlight" },
    -- expr: 5j jumps 5 real lines, plain j moves by visual/wrapped lines
    { "j", "v:count == 0 ? 'gj' : 'j'", "Move down (visual-line aware)", { expr = true } },
    { "k", "v:count == 0 ? 'gk' : 'k'", "Move up (visual-line aware)", { expr = true } },
    { "<C-c>N", ":enew<CR>", "Create empty buffer" },
    { "<C-c>s", ":Save<CR>", "Save" },
    { "<C-c>a", ":wa<CR>", "Save all" },
    { "<C-c>e", ":Quit<CR>", "Close LvimIDE" },
    { "<C-c>x", "<C-w>c", "Close current window" },
    { "<C-c>o", "<C-w>o", "Close other windows" },
    { "<C-c>d", ":enew | bdelete #<CR>", "Delete buffer" },
    { "<C-c>=", ":wincmd=<CR>", "Equalise window sizes" },
    -- <C-h/j/k/l> (focus) and <C-Arrows> (resize) are NOT here: lvim-winnav owns them, because
    -- they are edge-aware (a move past the last window hands off to the multiplexer, and DOWN
    -- descends into the docked message zone first). They used to be declared here too, as raw
    -- `wincmd`/`resize`, and were overwritten the moment the plugin loaded — a manifest entry that
    -- lied about who owns the key. See modules/base/configs/ui/init.lua → lvim_winnav.
    { "<C-c>n", ":tabn<CR>", "Next tab" },
    { "<C-c>p", ":tabp<CR>", "Previous tab" },
    -- `Q` (= `<S-q>`) is deliberately left UNMAPPED — globally and in the Files group: Neovim's
    -- native multi-cursor uses it to add a cursor. The files panel used to bind it to close, which
    -- silently stole `Q` everywhere; that binding is gone. The panel still closes with its own
    -- buffer-local `q` and toggles with `<S-x>`, so no global `Q` is needed. Closing every float
    -- keeps its own chord below, which is where it was already reachable.
    -- `<C-c>q` clears all native multicursors (the `Q` pair). Neovim's built-in clear is `<C-L>`,
    -- but lvim-winnav owns `<C-l>` (seamless window nav), so the clear is relocated here — it runs
    -- the same namespace clear the `<C-L>` default does.
    { "<C-c>q", "<Cmd>call nvim_buf_clear_namespace(0, nvim_create_namespace('nvim.multicursor'), 0, -1)<Bar>redraw<CR>", "Multicursor: clear all" },
    { "<C-c>fc", ":CloseFloatWindows<CR>", "Close all floats" },
    { "<C-c>ff", ":FocusFloatWindow<CR>", "Cycle focus to next float" },
    { "<C-c>c", ":Inspect<CR>", "Inspect highlight under cursor" },
    { "<C-c>O", ":lua vim.ui.open(vim.fn.expand('%'))<CR>", "Open current file in OS handler" },
    { "<Leader>N", ":ene | startinsert<CR>", "New file in insert mode" },
    -- alternate window bindings (were in the winpick / winmove plugin configs)
    -- `gp`, not `gpp`: no other map starts with `gp`, so the two-key form fires at once. It shadows
    -- Vim's own `gp` (put, cursor after the text).
    { "gp", "<Cmd>LvimWinPick<CR>", "Window: pick" },
    { "<C-c>w", "<Cmd>LvimWinMove<CR>", "Window: move mode" },
    -- linguistics toggles (were in the plugin config)
    -- The toggles are :LvimLinguistics subcommands; the old `:LvimLinguisticsTOGGLE…` commands no longer exist.
    { "<C-c>l", "<Cmd>LvimLinguistics toggle-insert-mode<CR>", "Linguistics: toggle insert language" },
    { "<C-c>k", "<Cmd>LvimLinguistics toggle-spelling<CR>", "Linguistics: toggle spelling" },
    -- buffer history (were in the plugin config)
    { "<C-n>", "<Plug>(LvimBufHistoryForward)", "Buffer history forward" },
    { "<C-p>", "<Plug>(LvimBufHistoryBack)", "Buffer history back" },
    -- jump (flash-style, multi-mode n/x/o) (were in the plugin config)
    { "<C-c>.", "<Plug>(lvim-jump)", "Jump", { mode = { "n", "x", "o" } } },
    { "<C-c>;", "<Plug>(lvim-jump)", "Jump (search)", { mode = { "n", "x", "o" } } },
    { "<C-c>,", "<Plug>(lvim-jump-ts)", "Treesitter select", { mode = { "n", "x" } } },
}

global.visual = {
    { "<Leader>cc", "<Cmd>LvimComment line<CR>", "Code: comment selection" },
    { "<Leader>cp", "<Cmd>LvimColorPicker pick<CR>", "Code: pick colour" },
    -- Through `:`, not <Cmd>: the selection has to reach :LvimPrint as its '<,'> range.
    { "<Leader>fp", ":LvimPrint<CR>", "Files: print the selection (printer / PDF)" },
    -- Search only within the visual selection using the \%V atom
    { "*", "<Esc>/\\%V", "Search forward in selection" },
    { "#", "<Esc>?\\%V", "Search backward in selection" },
}

global.insert = {
    { "<C-j>", "<C-o>gj", "Move down by visual line" },
    { "<C-k>", "<C-o>gk", "Move up by visual line" },
}

global.terminal = {
    { "<Esc>", "<C-\\><C-n>", "Terminal: normal mode" },
}

return global
