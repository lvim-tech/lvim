# LVIM

![lvim-logo](https://user-images.githubusercontent.com/82431193/115121988-3bc06800-9fbe-11eb-8dab-19f624aa7b93.png)

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://github.com/lvim-tech/lvim/blob/main/LICENSE)

## About

### LVIM is a modular Neovim configuration written in LUA with full customization:

- Add or remove plugins, rewrite all plugins
- Add or remove settings, rewrite all settings
- Dynamic LSP activation
- Dynamic debugging activation - Vimspector or Dap
- By default - 51 plugins
- Loading time - 044.807

> ATTENTION: Now default branch is `master`
>
> Important changes:
>
> 1. Remove [telescope](https://github.com/nvim-telescope/telescope.nvim)
> 2. Add [vim-ctrlspace](https://github.com/vim-ctrlspace/vim-ctrlspace) for organize projects. Best tutorial for `vim-ctrlspace` [here](https://atlas-vim.readthedocs.io/vim/plugged/vim-ctrlspace/README/)
> 3. Add [vim-clap](https://github.com/liuchengxu/vim-clap) for search `buffers`, `files`, `grep` and more and more and more
>
>If you want to use [telescope](https://github.com/nvim-telescope/telescope.nvim) - switch to branch `telescope`

![01.png](https://github.com/lvim-tech/lvim/blob/master/assets/01.png)

![02.png](https://github.com/lvim-tech/lvim/blob/master/assets/02.png)

![03.png](https://github.com/lvim-tech/lvim/blob/master/assets/03.png)

![04.png](https://github.com/lvim-tech/lvim/blob/master/assets/04.png)

![05.png](https://github.com/lvim-tech/lvim/blob/master/assets/05.png)

![06.png](https://github.com/lvim-tech/lvim/blob/master/assets/06.png)

## Requirements

### Base

- [neovim nightly(>=0.5.0)](https://github.com/neovim/neovim/wiki/Installing-Neovim)
- [pynvim](https://github.com/neovim/pynvim)
- [neovim-remote](https://github.com/mhinz/neovim-remote)
- [nodejs](https://nodejs.org/en/)
- [universal-ctags](https://github.com/universal-ctags/ctags)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fzf](https://github.com/junegunn/fzf)

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

### Editor

[vim-ctrlspace](https://github.com/vim-ctrlspace/vim-ctrlspace)

[vim-clap](https://github.com/liuchengxu/vim-clap)

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

[git-blame.nvim](https://github.com/f-person/git-blame.nvim)

[neogit](https://github.com/TimUntersberger/neogit) (requires [plenary.nvim](https://github.com/nvim-lua/plenary.nvim))

### Languages

[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

[nvim-lspinstall](https://github.com/kabouzeid/nvim-lspinstall)

[nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)

[nvim-lsp-ts-utils](https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils)

[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (requires [playground](https://github.com/nvim-treesitter/playground))

[any-jump.vim](https://github.com/pechorin/any-jump.vim)

[lsp-trouble.nvim](https://github.com/folke/lsp-trouble.nvim) (requires [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons))

[symbols-outline.nvim](https://github.com/simrat39/symbols-outline.nvim)

[vimspector](https://github.com/puremourning/vimspector)

[nvim-dap](https://github.com/mfussenegger/nvim-dap)

### Completion

[nvim-compe](https://github.com/hrsh7th/nvim-compe)

[vim-vsnip](https://github.com/hrsh7th/vim-vsnip)

[friendly-snippets](https://github.com/rafamadriz/friendly-snippets)

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

| Key         | Action                                          | Description                          |
| ----------- | ----------------------------------------------- | ------------------------------------ |
| `<C-space>` | `:CtrlSpace<CR>`                                | CtrlSpace                            |
| `<Esc>`     | `<Esc>:noh<CR>`                                 | Remove highlight after search        |
| `<F1>`      | `:FloatermToggle<CR>`                           | Floaterm toggle                      |
| `<F2>`      | `:FloatermPrev<CR>`                             | Floaterm prev                        |
| `<F3>`      | `:FloatermNext<CR>`                             | Floaterm next                        |
| `<F4>`      | `:FloatermNew<CR>`                              | Floaterm new                         |
| `<F12>`     | `:FloatermKill<CR>`                             | Floaterm kill                        |
| `<F5>`      | `:UndotreeToggle<CR>`                           | UndoTree toggle                      |
| `<C-n>`     | `:e %:h/filename<CR>`                           | Create new file in current directory |
| `<C-s>`     | `:w<CR>`                                        | Save                                 |
| `<C-a>`     | `:wa<CR>`                                       | Save all                             |
| `<C-e>`     | `:qa!<CR>`                                      | Close all, exit nvim                 |
| `<C-x>`     | `<C-w>c`                                        | Close current window                 |
| `<C-x>`     | `<C-w>o`                                        | Close other windows                  |
| `<C-d>`     | `:bdelete<CR>`                                  | Bdelete                              |
| `<C-h>`     | `<C-w>h`                                        | Move to window left                  |
| `<C-l>`     | `<C-w>l`                                        | Move to window right                 |
| `<C-j>`     | `<C-w>j`                                        | Move to window down                  |
| `<C-k>`     | `<C-w>k`                                        | Move to window up                    |
| `<C-Left>`  | `:vertical resize -2<CR>`                       | Resize width -                       |
| `<C-Right>` | `:vertical resize +2<CR>`                       | Resize width +                       |
| `<C-Up>`    | `:resize -2<CR>`                                | Resize height -                      |
| `<C-Down>`  | `:resize +2<CR>`                                | Resize height +                      |
| `<S-r>`     | `<C-W>v`                                        | Split right                          |
| `<S-b>`     | `<C-W>s`                                        | Split bottom                         |
| `<S-e>`     | `:NvimTreeToggle<CR>`                           | NvimTree explorer                    |
| `<S-u>`     | `:Vifm<CR>`                                     | Vifm explorer                        |
| `<S-l>`     | `:FloatermNew lazygit<CR>`                      | Lazygit                              |
| `<S-m>`     | `:MarkdownPreviewToggle<CR>`                    | Markdown preview toggle              |
| `<S-t>`     | `:FloatermNew --wintype=normal --height=10<CR>` | Floaterm bottom                      |
| `<A-j>`     | `:AnyJump<CR>`                                  | Any jump                             |
| `<A-v>`     | `:SymbolsOutline<CR>`                           | Symbols outline                      |
| `<A-[>`     | `:foldopen<CR>`                                 | Fold open                            |
| `<A-]>`     | `:foldclose<CR>`                                | Fold close                           |
| `<A-.>`     | `:BookmarkToggle<CR>`                           | Bookmark toggle                      |
| `<A-,>`     | `:Neoformat<CR>`                                | Format code                          |
| `<A-s>`     | `:Spectre<CR>`                                  | Replace in multiple files            |
| `<A-/>`     | `:CommentToggle<CR>`                            | Comment toggle                       |
| `<A-f>`     | `:LspFormatting<CR>`                            | Lsp format code                      |
| `<A-g>`     | `:LspReferences<CR>`                            | Lsp references                       |
| `<A-d>`     | `:LspDeclaration<CR>`                           | Lsp declaration                      |
| `<A-p>`     | `:LspDefinition<CR>`                            | Lsp definition                       |
| `<A-h>`     | `:LspHover<CR>`                                 | Lsp hover                            |
| `<A-r>`     | `:LspRename<CR>`                                | Lsp rename                           |
| `<A-n>`     | `:LspGoToNext<CR>`                              | Lsp go to next                       |
| `<A-p>`     | `:LspGoToPrev<CR>`                              | Lsp go to prev                       |
| `<A-e>`     | `:LspTroubleToggle<CR>`                         | Lsp trouble toggle                   |

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

### Dart

1. Download Dart from [here](https://dart.dev/tools/sdk/archive)
2. Copy folder `dart-sdk` to `~/sdk`
3. Export path to `dart-sdk` folder in your shell (`.bashrc`, `.zshrc` etc)

```
export PATH="$PATH:$HOME/sdk/dart-sdk/bin"
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

Export path to `go` in your shell (`.bashrc`, `.zshrc` etc)

```
export GOROOT=/usr/lib64/go/1.16
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin
GO111MODULE=auto
```

> **IMPORTANT:**  In your operating system, the path and version may be different

### Graphql

```
:LspInstall graphql
```

### HTML

```
:LspInstall html
```

### Java

1. Clone repository (eclipse.jdt.ls.git)

```
git clone https://github.com/eclipse/eclipse.jdt.ls.git
```

2. Install

```
cd eclipse.jdt.ls
./mvnw clean install -DskipTests
```

3. Move folder `eclipse.jdt.ls` to `~/sdk/eclipse`

\-\-\- OR \-\-\-

Install `eclipse.jdt.ls` with script from [bin](https://github.com/lvim-tech/lvim/tree/main/bin) folder

```
install_jdtls
```

Export path to `Java` in your shell (`.bashrc`, `.zshrc` etc)

```
export JAVA_HOME=/usr/lib64/jvm/java-16-openjdk
export PATH=$JAVA_HOME/bin:$PATH
```

> **IMPORTANT:**  In your operating system, the path and version may be different

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

| Key       | Action                                        | Description                   |
| --------- | --------------------------------------------- | ----------------------------- |
| `<S-F1>`  | `<Plug>VimspectorToggleBreakpoint`            | Toggle breakpoint             |
| `<S-F2>`  | `<Plug>VimspectorContinue`                    | Start / continue              |
| `<S-F3>`  | `<Plug>VimspectorStop`                        | Stop                          |
| `<S-F4>`  | `<Plug>VimpectorRestart`                      | Restart                       |
| `<S-F5>`  | `<Plug>VimspectorStepOver`                    | Step over                     |
| `<S-F6>`  | `<Plug>VimspectorStepInto`                    | Step into                     |
| `<S-F7>`  | `<Plug>VimspectorStepOut`                     | Step out                      |
| `<S-F8>`  | `<Plug>VimspectorAddFunctionBreakpoint`       | Function breakpoint           |
| `<S-F9>`  | `<Plug>VimspectorRunToCursor`                 | Run to cursor                 |
| `<S-F10>` | `<Plug>VimspectorToggleConditionalBreakpoint` | Toggle conditional breakpoint |
| `<S-F12>` | `:VimspectorReset<CR>`                        | Reset                         |

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

| Key       | Action                         | Description       |
| --------- | ------------------------------ | ----------------- |
| `<A-F1>`  | `<Cmd>DapToggleBreakpoint<CR>` | Toggle breakpoint |
| `<A-F2>`  | `<Cmd>DapStart<CR>`            | Start / continue  |
| `<A-F3>`  | `<Cmd>DapStop<CR>`             | Stop              |
| `<A-F4>`  | `<Cmd>DapRestart<CR>`          | Restart           |
| `<A-F5>`  | `<Cmd>DapStepOver<CR>`         | Step over         |
| `<A-F6>`  | `<Cmd>DapStepInto<CR>`         | Step into         |
| `<A-F7>`  | `<Cmd>DapStepOut<CR>`          | Step out          |
| `<A-F8>`  | `<Cmd>DapPause<CR>`            | Pause             |
| `<A-F9>`  | `<Cmd>DapToggleRepl<CR>`       | Toggle repl       |
| `<A-F10>` | `<Cmd>DapGetSession<CR>`       | Get session       |

### Replace in multiple files

How use:

```
:Spectre
```

\-\-\- OR \-\-\-

Use keymap `<A-s>`

## Format

> IMPORTANT: LVIM use Neoformat by default. For more info use this [link](https://github.com/sbdchd/neoformat)

How use:

```
:Neoformat
```

\-\-\- OR \-\-\-

Use keymap `<A-,>`

## Sudo write

```
:SudaWrite
```
