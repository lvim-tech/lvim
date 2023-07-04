# LVIM BINDINGS

## Normal mode

| Key                | Action                            | Description                           |
| ------------------ | --------------------------------- | ------------------------------------- |
| `<Leader><Leader>` | `:CtrlSpace<CR>`                  | CtrlSpace                             |
| `<Leader>=`        | `:LvimFileManager<CR>`            | LvimFileManager                       |
| `<Leader>f`        | `:FzfLua files<CR>`               | Fzf search files                      |
| `<Leader>s`        | `:FzfLua live_grep<CR>`           | Fzf search in files                   |
| `<Leader>m`        | `:FzfLua marks<CR>`               | Fzf marks                             |
| `<Leader>i`        |                                   | Mini files (explorer)                 |
| `Q`                |                                   | Neocomposer toggle macro              |
| `<Leader>q`        |                                   | Neocomposer play macro                |
| `<F1>`             | `:TTOne<CR>`                      | Toggleterm one open                   |
| `<F2>`             | `:TTTwo<CR>`                      | Toggleterm two open                   |
| `<F3>`             | `:TTThree<CR>`                    | Toggleterm three open                 |
| `<F4>`             | `:TTFloat<CR>`                    | Toggleterm float open                 |
| `<F5>`             | `:UndotreeToggle<CR>`             | Undotree toggle                       |
| `<F11>`            | `:LvimHelper<CR>`                 | LvimHelper                            |
| `<C-c>h`           | `:LvimHelper<CR>`                 | LvimHelper                            |
| `<C-d>`            |                                   | Scroll down for cmp, hover, signature |
| `<C-u>`            |                                   | Scroll up for cmp, hover, signature   |
| `<C-c>N`           | `:enew<CR>`                       | Create empty buffer                   |
| `<C-c>s`           | `:w<CR>`                          | Save                                  |
| `<C-c>a`           | `:wa<CR>`                         | Save all                              |
| `<C-c>e`           | `:Quit<CR>`                       | Quit                                  |
| `<C-c>x`           | `<C-w>c`                          | Close current window                  |
| `<C-c>o`           | `<C-w>o`                          | Close other windows                   |
| `<C-c>d`           | `:bdelete<CR>`                    | Bdelete buffer                        |
| `<C-c>r`           | `:PickColor<CR>`                  | Pick color                            |
| `<C-c>=`           | `:wincmd=<CR>`                    | Win resize =                          |
| `<C-n>`            | `:BufSurfForward<CR>`             | Bnext buffer                          |
| `<C-p>`            | `:BufSurfBack<CR>`                | Bprev buffer                          |
| `<C-c>b`           | `:GitSignsToggleLineBlame<CR>`    | GitSigns toggle line blame            |
| `<C-c>z`           | `:NeoZoom<CR>`                    | Zoom toggle                           |
| `<C-c>fv`          | `:Vifm<CR>`                       | Vifm                                  |
| `<C-c>fr`          | `:Ranger<CR>`                     | Ranger                                |
| `<C-c>fg`          | `:LvimForgit<CR>`                 | LvimForgit                            |
| `<C-c>w`           | `:WinShift`                       | WinShift                              |
| `<C-h>`            | `<C-w>h`                          | Move to window left                   |
| `<C-l>`            | `<C-w>l`                          | Move to window right                  |
| `<C-j>`            | `<C-w>j`                          | Move to window down                   |
| `<C-k>`            | `<C-w>k`                          | Move to window up                     |
| `<C-Left>`         | `:vertical resize -2<CR>`         | Resize width -                        |
| `<C-Right>`        | `:vertical resize +2<CR>`         | Resize width +                        |
| `<C-Up>`           | `:resize -2<CR>`                  | Resize height -                       |
| `<C-Down>`         | `:resize +2<CR>`                  | Resize height +                       |
| `<S-x>`            | `:Neotree filesystem left<CR>`    | Neotree filesystem left               |
| `<C-c><C-f>`       | `:Neotree filesystem left<CR>`    | Neotree filesystem left               |
| `<C-c><C-b>`       | `:Neotree buffers left<CR>`       | Neotree filesystem left               |
| `<C-c><C-g>`       | `:Neotree git_status left<CR>`    | Neotree git_status left               |
| `<C-c><C-d>`       | `:Neotree diagnostics left<CR>`   | Neotree diagnostics left              |
| `<S-q>`            | `:Neotree close<CR>`              | Neotree close                         |
| `<A-e>`            | `:Neotree diagnostics<CR>`        | Neotree diagnostics bottom            |
| `<S-m>`            | `:MarkdownPreview<CR>`            | Markdown preview                      |
| `<A-,>`            | `:Telescope find_files<CR>`       | Search files with Telescope           |
| `<A-.>`            | `:Telescope live_grep<CR>`        | Search word with Telescope            |
| `<A-b>`            | `:Telescope buffers<CR>`          | Telescope buffers                     |
| `<A-/>`            | `:Telescope file_browser<CR>`     | Telescope file browser                |
| `<A-u>`            | `:AnyJump<CR>`                    | Any jump                              |
| `<A-v>`            | `:SymbolsOutline<CR>`             | Symbols outline                       |
| `<A-]>`            | `:GitSignsNextHunk<CR>`           | Git signs next hunk                   |
| `<A-[>`            | `:GitSignsPrevHunk<CR>`           | Git signs prev hunk                   |
| `<A-;>`            | `:GitSignsPreviewHunk<CR>`        | Git signs preview hunk                |
| `<A-s>`            | `:Spectre<CR>`                    | Replace in multiple files             |
| `<A-j>`            | `LvimMoveDownN`                   | Move line down                        |
| `<A-k>`            | `LvimMoveUpN`                     | Move line up                          |
| `<A-h>`            | `LvimMoveLeftN`                   | Move line left                        |
| `<A-l>`            | `LvimMoveRightN`                  | Move line right                       |
| `gw`               | `:WindowPicker<CR>`               | Window picker                         |
| `<C-c><C-l>`       | `:DAPLocal<CR>`                   | DAP local config                      |
| `]m`               | `:LvimListQuickFixMenuChoice<CR>` | Quickfix menu choice                  |
| `]d`               | `:LvimListQuickFixMenuDelete<CR>` | Quickfix menu delete                  |
| `][`               | `:copen<CR>`                      | Quickfix open                         |
| `[]`               | `:cclose<CR>`                     | Quickfix close                        |
| `]]`               | `:LvimListQuickFixNext<CR>`       | Quickfix next                         |
| `[[`               | `:LvimListQuickFixPrev<CR>`       | Quickfix prev                         |
| `dc`               | `:LspShowDiagnosticCurrent<CR>`   | Lsp show diagnostic current           |
| `dn`               | `:LspShowDiagnosticNext<CR>`      | Lsp show diagnostic next              |
| `dc`               | `:LspShowDiagnosticPrev<CR>`      | Lsp show diagnostic prev              |
| `dl`               | `:LspShowDiagnosticInLocList<CR>` | Lsp show diagnostic in loc list       |
| `gh`               | `:LspHover<CR>`                   | Lsp hover                             |
| `K`                | `:LspHover<CR>`                   | Lsp hover                             |
| `gd`               | `:LspDefinition<CR>`              | Lsp definition                        |
| `gt`               | `:LspTypeDefinition<CR>`          | Lsp type definition                   |
| `gr`               | `:LspReferences<CR>`              | Lsp references                        |
| `gi`               | `:LspImplementation<CR>`          | Lsp implementation                    |
| `ge`               | `:IncRename<CR>`                  | Inc rename                            |
| `gE`               | `:LspRename<CR>`                  | Lsp rename                            |
| `gf`               | `:LspFormat<CR>`                  | Lsp format                            |
| `ga`               | `:LspCodeAction<CR>`              | Lsp code action                       |
| `gs`               | `:LspSignatureHelp<CR>`           | Lsp signature help                    |
| `gL`               | `:LspCodeLensRefresh<CR>`         | Lsp code lens refresh                 |
| `gl`               | `:LspCodeLensRun<CR>`             | Lsp code lens run                     |
| `gpd`              | `:Glance definitions<CR>`         | Glance definitions                    |
| `gpt`              | `:Glance type_definitions<CR>`    | Glance type_definitions               |
| `gpr`              | `:Glance references<CR>`          | Glance references                     |
| `gpi`              | `:Glance implementations<CR>`     | Glance implementations                |
| `<C-c>.`           |                                   | Flash                                 |
| `<C-c>,`           |                                   | Flash treesitter                      |
| `<C-c>c`           | `:Inspect<CR>`                    | Inspect                               |
| `<C-c>u`           | `:SnipRun<CR>`                    | Snip run                              |
| `<C-c>ff`          | `:CloseFloatWindows<CR>`          | Close float qindows                   |
| `<C-c>n`           | `:tabn<CR>`                       | Tab next                              |
| `<C-c>p`           | `:tabp<CR>`                       | Tab prev                              |
| `<C-c>t`           | `:Telescope tmux sessions<CR>`    | Telescope tmux session                |
| `rr`               | `<Plug>RestNvim<CR>`              | Rest nvim                             |
| `rp`               | `<Plug>RestNvimPreview<CR>`       | Rest nvim preview                     |
| `rl`               | `<Plug>RestNvimLast<CR>`          | Rest nvim last                        |
| `dc`               | `:LspShowDiagnosticCurrent<CR>`   | Lsp show diagnostic current           |
| `dn`               | `:LspShowDiagnosticNext<CR>`      | Lsp show diagnostic next              |
| `dp`               | `:LspShowDiagnosticPrev<CR>`      | Lsp show diagnostic prev              |
| `<A-/>`            | `:TelescopeBrowser<CR>`           | Telescope browser                     |
| `<A-j>`            | `MoveDown`                        | Move line down                        |
| `<A-k>`            | `MoveUp`                          | Move line up                          |
| `<A-h>`            | `MoveLeft`                        | Move line left                        |
| `<A-l>`            | `MoveRight`                       | Move line right                       |
| `<A-1>`            | `<Cmd>DapToggleBreakpoint<CR>`    | Toggle breakpoint                     |
| `<A-2>`            | `<Cmd>DapStartContinue<CR>`       | Start / continue                      |
| `<A-3>`            | `<Cmd>DapStepInto<CR>`            | Step into                             |
| `<A-4>`            | `<Cmd>DapStepOver<CR>`            | Step over                             |
| `<A-5>`            | `<Cmd>DapStepOut<CR>`             | Step out                              |
| `<A-6>`            | `<Cmd>DapUp<CR>`                  | Up                                    |
| `<A-7>`            | `<Cmd>DapDown<CR>`                | Down                                  |
| `<A-8>`            | `<Cmd>DapUIClose<CR>`             | UI close                              |
| `<A-9>`            | `<Cmd>DapRestart<CR>`             | Restart                               |
| `<A-0>`            | `<Cmd>DapToggleRepl<CR>`          | Toggle Repl                           |
