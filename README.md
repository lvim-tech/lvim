# LVIM

![lvim-logo](https://user-images.githubusercontent.com/82431193/115121988-3bc06800-9fbe-11eb-8dab-19f624aa7b93.png)

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://github.com/lvim-tech/lvim/blob/main/LICENSE)

## About

### LVIM is a modular Neovim configuration written in LUA with full customization:

- Add or remove plugins, rewrite all plugins
- Add or remove settings, rewrite all settings
- Dynamic LSP activation
- Dynamic debugging activation - Vimspector or Dap
- By default - 63 plugins
- Loading time - 060.260

## HELP FOR LVIM

> ## **For `HELP` press `<F11>` and Navigate with `]` and `[`**

## [YouTube](https://www.youtube.com/channel/UCSV5_UXKLl1JDZbQaYWuFKQ) channel

## Screenshots

> Dashboard

![01.Dashboard.png](https://github.com/lvim-tech/lvim/blob/master/media/01.Dashboard.png)

> WhichKey

![02.WhichKey.png](https://github.com/lvim-tech/lvim/blob/master/media/02.WhichKey.png)

> CtrlSpace

![03.CtrlSpace.png](https://github.com/lvim-tech/lvim/blob/master/media/03.CtrlSpace.png)

> NvimTree

![04.NvimTree.png](https://github.com/lvim-tech/lvim/blob/master/media/04.NvimTree.png)

> Trouble

![05.Trouble.png](https://github.com/lvim-tech/lvim/blob/master/media/05.Trouble.png)

> SymbolsOutline

![06.SymbolsOutline.png](https://github.com/lvim-tech/lvim/blob/master/media/06.SymbolsOutline.png)

> AnyJump

![07.AnyJump.png](https://github.com/lvim-tech/lvim/blob/master/media/07.AnyJump.png)

> Spectre

![08.Spectre.png](https://github.com/lvim-tech/lvim/blob/master/media/08.Spectre.png)

> Snap

![10.Snap.png](https://github.com/lvim-tech/lvim/blob/master/media/10.Snap.png)

> GitSigns

![11.GitSigns.png](https://github.com/lvim-tech/lvim/blob/master/media/11.GitSigns.png)

> Fugitive

![12.Fugitive.png](https://github.com/lvim-tech/lvim/blob/master/media/12.Fugitive.png)

![13.Fugitive.png](https://github.com/lvim-tech/lvim/blob/master/media/13.Fugitive.png)

> GitBlame

![14.GitBlame.png](https://github.com/lvim-tech/lvim/blob/master/media/14.GitBlame.png)

> UndoTree

![15.UndoTree.png](https://github.com/lvim-tech/lvim/blob/master/media/15.UndoTree.png)

> Floaterm

![16.Floaterm.png](https://github.com/lvim-tech/lvim/blob/master/media/16.Floaterm.png)

> DadbodUI

![17.DadbodUI.png](https://github.com/lvim-tech/lvim/blob/master/media/17.DadbodUI.png)

> Goyo

![18.Goyo.png](https://github.com/lvim-tech/lvim/blob/master/media/18.Goyo.png)

## Requirements

### Base

- [neovim nightly(>=0.5.0)](https://github.com/neovim/neovim/wiki/Installing-Neovim)
- [pynvim](https://github.com/neovim/pynvim)
- [neovim-remote](https://github.com/mhinz/neovim-remote)
- [nodejs](https://nodejs.org/en/)
- [universal-ctags](https://github.com/universal-ctags/ctags)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fzf](https://github.com/junegunn/fzf)
- [rsync](https://github.com/WayneD/rsync)

### External apps

- [vifm](https://github.com/vifm/vifm)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [lazynpm](https://github.com/jesseduffield/lazynpm)
- [lazydocker](https://github.com/jesseduffield/lazydocker)

## Install

1. Clone repository

```bash
git clone https://github.com/lvim-tech/lvim.git ~/.config/nvim
```

2. Export path to [bin](https://github.com/lvim-tech/lvim/tree/main/bin) folder in your shell (`.bashrc`, `.zshrc` etc)

```
export PATH="$HOME/.config/nvim/bin:$PATH"
```

## Plugins

### UI

[lvim-colorscheme](https://github.com/lvim-tech/lvim-colorscheme)

[dashboard-nvim](https://github.com/glepnir/dashboard-nvim)

[galaxyline.nvim](https://github.com/lvim-tech/galaxyline.nvim) (requires [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons))

[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)

[nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) (requires [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons))

[vifm.vim](https://github.com/vifm/vifm.vim)

[goyo.vim](https://github.com/junegunn/goyo.vim) (requires [limelight.vim](https://github.com/junegunn/limelight.vim))

[vim-floaterm](https://github.com/voldikss/vim-floaterm)

[lvim-helper](https://github.com/lvim-tech/lvim-helper)

### Editor

[vim-ctrlspace](https://github.com/vim-ctrlspace/vim-ctrlspace)

[snap](https://github.com/camspiers/snap)

[nvim-spectre](https://github.com/windwp/nvim-spectre) (requires [popup.nvim](https://github.com/nvim-lua/popup.nvim) \| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim))

[suda.vim](https://github.com/lambdalisue/suda.vim)

[nvim-comment](https://github.com/terrortylor/nvim-comment)

[neoformat](https://github.com/sbdchd/neoformat)

[nvim-autopairs](https://github.com/windwp/nvim-autopairs)

[vim-bookmarks](https://github.com/MattesGroeger/vim-bookmarks)

[undotree](https://github.com/mbbill/undotree)

[vim-doge](https://github.com/kkoomen/vim-doge)

[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) (requires [plenary.nvim](https://github.com/nvim-lua/plenary.nvim))

[vim-fugitive](https://github.com/tpope/vim-fugitive)

[diffview.nvim](https://github.com/sindrets/diffview.nvim)

[git-blame.nvim](https://github.com/f-person/git-blame.nvim)

[neogit](https://github.com/TimUntersberger/neogit) (requires [plenary.nvim](https://github.com/nvim-lua/plenary.nvim))

[vim-arsync](https://github.com/kenn7/vim-arsync)

### Languages

[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

[nvim-lspinstall](https://github.com/kabouzeid/nvim-lspinstall)

[nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)

[nvim-lsp-ts-utils](https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils)

[lsp_signature.nvim](https://github.com/ray-x/lsp_signature.nvim)

[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (requires [playground](https://github.com/nvim-treesitter/playground))

[any-jump.vim](https://github.com/pechorin/any-jump.vim)

[lsp-trouble.nvim](https://github.com/folke/lsp-trouble.nvim) (requires [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons))

[symbols-outline.nvim](https://github.com/simrat39/symbols-outline.nvim)

[dependency-assist.nvim](https://github.com/akinsho/dependency-assist.nvim)

[vimspector](https://github.com/puremourning/vimspector)

[nvim-dap](https://github.com/mfussenegger/nvim-dap) (requires [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui))

### Completion

[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (requires [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) \| [cmp-vsnip](https://github.com/hrsh7th/cmp-vsnip) \| [cmp-buffer](https://github.com/hrsh7th/cmp-buffer) \| [cmp-path](https://github.com/hrsh7th/cmp-path)))

[vim-vsnip](https://github.com/hrsh7th/vim-vsnip) (requires [vim-vsnip-integ](https://github.com/hrsh7th/vim-vsnip-integ) \| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)))

[lspkind-nvim](https://github.com/onsails/lspkind-nvim)

[emmet-vim](https://github.com/mattn/emmet-vim)

### Tools

[nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)

[vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) (requires [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) \| [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion))

[nvim-whichkey-setup.lua](https://github.com/AckslD/nvim-whichkey-setup.lua) (requires [vim-which-key](https://github.com/liuchengxu/vim-which-key))

[markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)

[vim-rooter](https://github.com/airblade/vim-rooter)

## Keymaps

### Normal mode

| Key         | Action                       | Description                   |
| ----------- | ---------------------------- | ----------------------------- |
| `<F11>`     | `:LvimHelper<CR>`            | LvimHelper                    |
| `<C-space>` | `:CtrlSpace<CR>`             | CtrlSpace                     |
| `<Esc>`     | `<Esc>:noh<CR>`              | Remove highlight after search |
| `<F1>`      | `:FloatermToggle<CR>`        | Floaterm toggle               |
| `<F2>`      | `:FloatermPrev<CR>`          | Floaterm prev                 |
| `<F3>`      | `:FloatermNext<CR>`          | Floaterm next                 |
| `<F4>`      | `:FloatermNew<CR>`           | Floaterm new                  |
| `<F12>`     | `:FloatermKill<CR>`          | Floaterm kill                 |
| `<F5>`      | `:UndotreeToggle<CR>`        | UndoTree toggle               |
| `<C-n>`     | `:e %:h/filename<CR>`        | Create new file               |
| `<C-s>`     | `:w<CR>`                     | Save                          |
| `<C-a>`     | `:wa<CR>`                    | Save all                      |
| `<C-e>`     | `:qa!<CR>`                   | Close all, exit nvim          |
| `<C-x>`     | `<C-w>c`                     | Close current window          |
| `<C-o>`     | `<C-w>o`                     | Close other windows           |
| `<C-d>`     | `:bdelete<CR>`               | Bdelete                       |
| `<C-h>`     | `<C-w>h`                     | Move to window left           |
| `<C-l>`     | `<C-w>l`                     | Move to window right          |
| `<C-j>`     | `<C-w>j`                     | Move to window down           |
| `<C-k>`     | `<C-w>k`                     | Move to window up             |
| `<C-Left>`  | `:vertical resize -2<CR>`    | Resize width -                |
| `<C-Right>` | `:vertical resize +2<CR>`    | Resize width +                |
| `<C-Up>`    | `:resize -2<CR>`             | Resize height -               |
| `<C-Down>`  | `:resize +2<CR>`             | Resize height +               |
| `<S-x>`     | `:NvimTreeToggle<CR>`        | NvimTree explorer             |
| `<S-u>`     | `:Vifm<CR>`                  | Vifm explorer                 |
| `<S-l>`     | `:FloatermNew lazygit<CR>`   | Lazygit                       |
| `<S-m>`     | `:MarkdownPreviewToggle<CR>` | Markdown preview toggle       |
| `<A-j>`     | `:AnyJump<CR>`               | Any jump                      |
| `<A-v>`     | `:SymbolsOutline<CR>`        | Symbols outline               |
| `<A-[>`     | `:foldopen<CR>`              | Fold open                     |
| `<A-]>`     | `:foldclose<CR>`             | Fold close                    |
| `<A-.>`     | `:BookmarkToggle<CR>`        | Bookmark toggle               |
| `<A-,>`     | `:Neoformat<CR>`             | Format code                   |
| `<A-s>`     | `:Spectre<CR>`               | Replace in multiple files     |
| `<A-/>`     | `:CommentToggle<CR>`         | Comment toggle                |
| `<A-f>`     | `:LspFormatting<CR>`         | Lsp format code               |
| `<A-t>`     | `:LspCodeAction<CR>`         | Lsp code action               |
| `<A-g>`     | `:LspReferences<CR>`         | Lsp references                |
| `<A-d>`     | `:LspDeclaration<CR>`        | Lsp declaration               |
| `<A-p>`     | `:LspDefinition<CR>`         | Lsp definition                |
| `<A-h>`     | `:LspHover<CR>`              | Lsp hover                     |
| `<A-r>`     | `:LspRename<CR>`             | Lsp rename                    |
| `<A-n>`     | `:LspGoToNext<CR>`           | Lsp go to next                |
| `<A-p>`     | `:LspGoToPrev<CR>`           | Lsp go to prev                |
| `<A-e>`     | `:LspTroubleToggle<CR>`      | Lsp trouble toggle            |

### Visual mode

| Key     | Action                 | Description     |
| ------- | ---------------------- | --------------- |
| `<`     | `<gv`                  | Tab left        |
| `>`     | `>gv`                  | Tab right       |
| `*`     | `:<Esc>/\\%V`          | Visual search / |
| `#`     | `:<Esc>?\\%V`          | Visual search ? |
| `K`     | `:move \'<-2<CR>gv-gv` | Move up         |
| `J`     | `:move \'>+1<CR>gv-gv` | Move down       |
| `<A-j>` | `:AnyJumpVisual<CR>`   | Any jump visual |
| `<A-/>` | `:CommentToggle<CR>`   | Comment toggle  |

## Commands

### Snap

```
:Snap<name-of-command>
```

## LSP support

> **IMPORTANT:**  All external programs are in the **sdk** home folder (`~/sdk`)

### Bash

```
:LspInstall bash
```

### CPP

```
:LspInstall cpp
```

### C#

```
LspInstall csharp
```

1. Download `.NET 5.0 SDK` from this [link](https://dotnet.microsoft.com/download/dotnet/5.0)
2. Move `dotnet` folder to your home directory (`~/`)
3. Install [Mono](https://www.mono-project.com/)

Export path to `dotnet` in your shell (`.bashrc`, `.zshrc` etc)

```
export DOTNET_ROOT=$HOME/dotnet
export PATH=$PATH:$HOME/dotnet
```

### CSS

```
:LspInstall css
```

### Dart + Flutter

1. Download Flutter (includes dart) from [here](https://flutter.dev)
2. Copy folder `flutter` to `~/sdk`
3. Export paths to `flutter` and `dart` in your shell (`.bashrc`, `.zshrc` etc)

```
export PATH="$PATH:$HOME/sdk/flutter/bin"
export PATH="$PATH:$HOME/sdk/flutter/bin/cache/dart-sdk/bin"
```

Upgrade flutter and dart from command line:

```
flutter upgrade
```

### Docker

```
:LspInstall dockerfile
```

### Elixir

```
:LspInstall elixir
```

### Go

```
:LspInstall go
```

### Graphql

```
:LspInstall graphql
```

### HTML

```
:LspInstall html
```

### Java

```
:LspInstall java
```

### JavaScript

```
:LspInstall typescript
```

### JSON

```
:LspInstall jason
```

### LaTeX

```
:LspInstall latex
```

### Lua

```
:LspInstall lua
```

### PHP

```
:LspInstall php
```

### Python

```
:LspInstall python
```

### Ruby

```
:LspInstall ruby
```

Install `solargraph` with `gem`

```
gem install solargraph
```

### Rust

```
:LspInstall rust
```

Install Rust with Rustup

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Svelte

```
:LspInstall svelte
```

### VIM

```
:LspInstall vim
```

### YAML

```
:LspInstall yaml
```

## Customize plugins

### Modules (plugins)

All included plugins are in this [file](https://github.com/lvim-tech/lvim/blob/main/lua/modules/global/init.lua) by default

You can modify plugins from this [file](https://github.com/lvim-tech/lvim/blob/main/lua/modules/custom/init.lua)

### Remove an existing plugin(s)

```lua
local modules = {}

modules['kevinhwang91/rnvimr'] = false

return modules
```

### Customize the settings of existing plugin(s)

```lua
local modules = {}

modules['kevinhwang91/rnvimr'] = {
    -- Your code
}

return modules
```

### Add a plugin(s)

```lua
local modules = {}

modules['sheerun/vim-polyglot'] = {
    -- your code
}

return modules
```

> **IMPORTANT:**  After any changes run `:PackerSync` and restart nvim

## Customize settings

### Configs (settings)

All settings are in this [file](https://github.com/lvim-tech/lvim/blob/main/lua/configs/global/init.lua)

You can modify settings from this [file](https://github.com/lvim-tech/lvim/blob/main/lua/configs/custom/init.lua)

### Remove an existing setting(s)

```lua
local modules = {}

configs['events'] = false

return modules
```

### Customize an existing setting(s)

```lua
local modules = {}

configs['events'] = function()
    -- your code
end

return modules
```

### Add a setting(s)

```lua
local modules = {}

configs['any-name'] = function()
    -- your code
end

return modules
```

> **IMPORTANT:**  After any changes run `:PackerSync` and restart nvim

## Customize LSP

### Global

1. Modify `configs['events']` from this [file](https://github.com/lvim-tech/lvim/blob/main/lua/configs/custom/init.lua)

```lua
configs['events'] = function()
    funcs.augroups({
        _general_settings = {
            {
                'TextYankPost', '*',
                'lua require(\'vim.highlight\').on_yank({higroup = \'Search\', timeout = 200})'
            }, {
                'BufWinEnter', '*',
                'setlocal formatoptions-=c formatoptions-=r formatoptions-=o number relativenumber cursorcolumn cursorline '
            }, {
                'BufRead', '*',
                'setlocal formatoptions-=c formatoptions-=r formatoptions-=o number relativenumber cursorcolumn cursorline '
            }, {
                'BufNewFile', '*',
                'setlocal formatoptions-=c formatoptions-=r formatoptions-=o number relativenumber cursorcolumn cursorline '
            },
            {'BufWinEnter', '*.ex', 'set filetype=elixir'},
            {'BufWinEnter', '*.exs', 'set filetype=elixir'},
            {'BufNewFile', '*.ex', 'set filetype=elixir'},
            {'BufNewFile', '*.exs', 'set filetype=elixir'},
            {'BufWinEnter', '*.graphql', 'set filetype=graphql'}
        },
        _lsp = {
            {'FileType', '*', 'lua require("configs.custom.filetypes").init()'}
        },
        _dashboard = {
            {
                'FileType', 'dashboard',
                'setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell  nolist  nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs= '
            }, {
                'FileType', 'dashboard',
                'set showtabline=0 | autocmd BufLeave <buffer> set showtabline=2'
            }
        },
        _floaterm = {
            {
                'FileType', 'floaterm',
                'setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell  nolist  nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs= '
            }
        }
    })
end
```

2. Add your LSP settings in this [folder](https://github.com/lvim-tech/lvim/tree/main/lua/lsp/custom)

> **IMPORTANT:**  After this change run `:PackerSync` and restart nvim

### For project

1. Create folder `.lvim` in root directory of your project
2. Create in this folder file with name of current language (for example `python.lua`)
3. Add your settings in this file

Example:

```lua
local M = {}

local path_sep = package.config:sub(1, 1)

M.lsp_config = 'lsp.custom.languages.python'

M.lsp_command = ':LspStart pyright'

return M
```

> **IMPORTANT:**  After this change run `:PackerSync` and restart nvim

## Debuggers

You can use `Vimpector` or `DAP (Debug Adapter Protocol)`

### Vimspector

> **IMPORTANT:**  Before using Vimspector, you need to activate it

```
:VimspectorInit
```

> **IMPORTANT:**  Before using Vimspector, install all gadgets

```
:VimspectorInstall --all
```

You can generate `.vimspector.json` file for your current project with script from [bin](https://github.com/lvim-tech/lvim/tree/main/bin) folder

```
vsconfig
```

#### Keymaps

| Key     | Action                                  | Description         |
| ------- | --------------------------------------- | ------------------- |
| `<A-1>` | `<Plug>VimspectorToggleBreakpoint`      | Toggle breakpoint   |
| `<A-2>` | `<Plug>VimspectorContinue`              | Start / continue    |
| `<A-3>` | `<Plug>VimspectorStop`                  | Stop                |
| `<A-4>` | `<Plug>VimpectorRestart`                | Restart             |
| `<A-5>` | `<Plug>VimspectorStepOver`              | Step over           |
| `<A-6>` | `<Plug>VimspectorStepInto`              | Step into           |
| `<A-7>` | `<Plug>VimspectorStepOut`               | Step out            |
| `<A-8>` | `<Plug>VimspectorAddFunctionBreakpoint` | Function breakpoint |
| `<A-9>` | `<Plug>VimspectorRunToCursor`           | Run to cursor       |
| `<A-0>` | `:VimspectorReset<CR>`                  | Reset               |

### DAP (Debug Adapter Protocol)

> **IMPORTANT:**  Before using DAP, you need to activate it

```
:DapInit
```

#### Requirements

1. [vscode-lldb](https://github.com/vadimcn/vscode-lldb) (for `cpp` and `rust`)
2. [delve](https://github.com/go-delve/delve/) (for `go`)
3. [debugpy](https://github.com/microsoft/debugpy) (for `python`)
4. [vscode-node-debug2](https://github.com/microsoft/vscode-node-debug2) (for `javascript` and `typescript`)

> **IMPORTANT:**  vscode-node-debug2 must be installed in `sdk` folder (`~/sdk/vscode-node-debug2`)

> **IMPORTANT:** Command `:VimspectorInstall --all` will install `vscode-lldb` and `debugpy`

```
:VimspectorInstall --all
```

> **IMPORTANT:** DAP configuration for `python` use `python` from [pyenv](https://github.com/pyenv/pyenv). You need to install a `pyenv` and use a `python` from `pyenv`. Path is: `~/.pyenv/shims/python`

#### Supported languages

- cpp
- dart
- go
- java
- javascript / typescript
- python
- rust

#### Keymaps

| Key     | Action                         | Description       |
| ------- | ------------------------------ | ----------------- |
| `<A-1>` | `<Cmd>DapToggleBreakpoint<CR>` | Toggle breakpoint |
| `<A-2>` | `<Cmd>DapStart<CR>`            | Start / continue  |
| `<A-3>` | `<Cmd>DapStop<CR>`             | Stop              |
| `<A-4>` | `<Cmd>DapRestart<CR>`          | Restart           |
| `<A-5>` | `<Cmd>DapStepOver<CR>`         | Step over         |
| `<A-6>` | `<Cmd>DapStepInto<CR>`         | Step into         |
| `<A-7>` | `<Cmd>DapStepOut<CR>`          | Step out          |
| `<A-8>` | `<Cmd>DapPause<CR>`            | Pause             |
| `<A-9>` | `<Cmd>DapToggleRepl<CR>`       | Toggle repl       |
| `<A-0>` | `<Cmd>DapGetSession<CR>`       | Get session       |

## Replace in multiple files

How use:

```
:Spectre
```

\-\-\- OR \-\-\-

Use keymap `<A-s>`

## Format

> IMPORTANT: LVIM use Neoformat by default. For more info use this [link](https://github.com/sbdchd/neoformat)

> IMPORTANT: If you have installed formatters then Neoformat not need of settings

How use:

```
:Neoformat
```

\-\-\- OR \-\-\-

Use keymap `<A-,>`

## Autoformat

Just add custom function to `lua/configs/custom/init.lua`

```lua
local configs = {}
local funcs = require "core.funcs"

configs["custom_events"] = function()
    funcs.augroups({
        custom_bufs = {
            {"BufWritePre", "*.go", ":Neoformat"},
            {"BufWritePre", "*.py", ":Neoformat"},
            {"BufWritePre", "*.rs", ":Neoformat"},
            {"BufWritePre", "*.dart", ":Neoformat"},
            {"BufWritePre", "*.cpp", ":Neoformat"},
            {"BufWritePre", "*.js", ":Neoformat"},
            {"BufWritePre", "*.ts", ":Neoformat"}
        }
    })
end

return configs
```

## Sudo write

```
:SudaWrite
```
