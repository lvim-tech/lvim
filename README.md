# LVIM

![lvim-logo](https://user-images.githubusercontent.com/82431193/115121988-3bc06800-9fbe-11eb-8dab-19f624aa7b93.png)

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://github.com/lvim-tech/lvim/blob/main/LICENSE)

## About

LVIM is a modular Neovim configuration written in LUA with full customization:

- Add or remove plugins, rewrite all plugins
- Add or remove settings, rewrite all settings
- Dynamic LSP activation
- Dynamic debugging activation - Vimspector or Dap
- By default - 50 plugins
- Loading time - ~~180.513~~ 060.381 ms

![Screenshot from 2021-04-25 15-07-07](https://user-images.githubusercontent.com/82431193/115992744-f0b6de00-a5d7-11eb-8ff0-04d767812245.png)

![Screenshot from 2021-04-25 15-04-39](https://user-images.githubusercontent.com/82431193/115992725-d11fb580-a5d7-11eb-93af-b1a52d77aca8.png)

## Requirements

### Base

- [neovim nightly(>=0.5.0)](https://github.com/neovim/neovim/wiki/Installing-Neovim)
- [pynvim](https://github.com/neovim/pynvim)
- [neovim-remote](https://github.com/mhinz/neovim-remote)
- [universal-ctags](https://github.com/universal-ctags/ctags)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fzf](https://github.com/junegunn/fzf)

### External apps

- [ranger](https://github.com/ranger/ranger)
- [bpytop](https://github.com/aristocratos/bpytop)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [lazynpm](https://github.com/jesseduffield/lazynpm)
- [lazydocker](https://github.com/jesseduffield/lazydocker)

## Install

```bash
git clone https://github.com/lvim-tech/lvim.git ~/.config/nvim
```

## Plugins

- UI

[lvim-colorscheme](https://github.com/lvim-tech/lvim-colorscheme)

[dashboard-nvim](https://github.com/glepnir/dashboard-nvim)

[galaxyline.nvim](https://github.com/glepnir/galaxyline.nvim) (requires [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons))

[barbar.nvim](https://github.com/romgrk/barbar.nvim) (requires [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons))

[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)

[nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) (requires [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons))

[rnvimr](https://github.com/kevinhwang91/rnvimr)

[nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)

[goyo.vim](https://github.com/junegunn/goyo.vim) (requires [limelight.vim](https://github.com/junegunn/limelight.vim))

[vim-floaterm](https://github.com/voldikss/vim-floaterm)

- Editor

[nvim-comment](https://github.com/terrortylor/nvim-comment)

[formatter.nvim](https://github.com/mhartington/formatter.nvim)

[nvim-autopairs](https://github.com/windwp/nvim-autopairs)

[vim-bookmarks](https://github.com/MattesGroeger/vim-bookmarks)

[undotree](https://github.com/mbbill/undotree)

[vim-doge](https://github.com/kkoomen/vim-doge)

[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) (requires [plenary.nvim](https://github.com/nvim-lua/plenary.nvim))

[vim-fugitive](https://github.com/tpope/vim-fugitive)

[git-blame.nvim](https://github.com/f-person/git-blame.nvim)

[neogit](https://github.com/TimUntersberger/neogit) (requires [plenary.nvim](https://github.com/nvim-lua/plenary.nvim))

- Languages

[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (requires [popup.nvim](https://github.com/nvim-lua/popup.nvim) \| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) \| [telescope-fzy-native.nvim](https://github.com/nvim-telescope/telescope-fzy-native.nvim) \| [telescope-media-files.nvim](https://github.com/nvim-telescope/nvim-telescope/telescope-media-files.nvim))

[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

[nvim-lspinstall](https://github.com/kabouzeid/nvim-lspinstall)

[nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)

[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (requires [playground](https://github.com/nvim-treesitter/playground))

[any-jump.vim](https://github.com/pechorin/any-jump.vim)

[lsp-trouble.nvim](https://github.com/folke/lsp-trouble.nvim) (requires [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons))

[symbols-outline.nvim](https://github.com/simrat39/symbols-outline.nvim)

[vimspector](https://github.com/puremourning/vimspector)

[nvim-dap](https://github.com/mfussenegger/nvim-dap)

- Completion

[nvim-compe](https://github.com/hrsh7th/nvim-compe)

[vim-vsnip](https://github.com/hrsh7th/vim-vsnip)

[friendly-snippets](https://github.com/rafamadriz/friendly-snippets)

[lspkind-nvim](https://github.com/onsails/lspkind-nvim)

[emmet-vim](https://github.com/mattn/emmet-vim)

- Tools

[vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) (requires [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) \| [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion))

[nvim-whichkey-setup.lua](https://github.com/AckslD/nvim-whichkey-setup.lua) (requires [vim-which-key](https://github.com/liuchengxu/vim-which-key))

[markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)

[vim-rooter](https://github.com/airblade/vim-rooter)

## Keymaps

- Normal mode

| Key         | Action                                          | Description                          |
| ----------- | ----------------------------------------------- | ------------------------------------ |
| `<Esc>`     | `<Esc>:noh<CR>`                                 | Remove highlight after search        |
| `<Tab>`     | `:BufferNext<CR>`                               | Barbar - Tab navigation next         |
| `<S-Tab>`   | `:BufferNext<CR>`                               | Barbar - Tab navigation prev         |
| `<F5>`      | `:UndotreeToggle<CR>`                           | UndoTree toggle                      |
| `<C-n>`     | `:e %:h/filename<CR>`                           | Create new file in current directory |
| `<C-s>`     | `:w<CR>`                                        | Save                                 |
| `<C-a>`     | `:wa<CR>`                                       | Save all                             |
| `<C-e>`     | `:qa!<CR>`                                      | Close all, exit nvim                 |
| `<C-x>`     | `:BufferClose<CR>`                              | Close                                |
| `<C-q>`     | `:BufferClose!<CR>`                             | Close whitout saving                 |
| `<C-d>`     | `:bdelete<CR>`                                  | Bdelete                              |
| `<C-h>`     | `<C-w>h`                                        | Move to window right                 |
| `<C-l>`     | `<C-w>l`                                        | Move to window left                  |
| `<C-j>`     | `<C-w>j`                                        | Move to window down                  |
| `<C-k>`     | `<C-w>k`                                        | Move to window up                    |
| `<C-Left>`  | `:vertical resize +2<CR>`                       | Resize width +                       |
| `<C-Right>` | `:vertical resize -2<CR>`                       | Resize width -                       |
| `<C-Up>`    | `:resize +2<CR>`                                | Resize height +                      |
| `<C-Down>`  | `:resize -2<CR>`                                | Resize height -                      |
| `<S-r>`     | `<C-W>v`                                        | Split right                          |
| `<S-b>`     | `<C-W>s`                                        | Split bottom                         |
| `<S-e>`     | `:NvimTreeToggle<CR>`                           | NvimTree explorer toggle             |
| `<S-h>`     | `:RnvimrToggle<CR>`                             | Ranger explorer toggle               |
| `<S-f>`     | `:Telescope find_files<CR>`                     | File search                          |
| `<S-g>`     | `:Telescope live_grep<CR>`                      | Text search                          |
| `<S-p>`     | `:Telescope project<CR>`                        | Projects                             |
| `<S-l>`     | `:FloatermNew lazygit<CR>`                      | Lazygit                              |
| `<S-m>`     | `:MarkdownPreviewToggle<CR>`                    | Markdown preview toggle              |
| `<S-t>`     | `:FloatermNew --wintype=normal --height=10<CR>` | Floaterm bottom                      |
| `<A-j>`     | `:AnyJump<CR>`                                  | Any jump                             |
| `<A-v>`     | `:SymbolsOutline<CR>`                           | Symbols outline                      |
| `<A-[>`     | `:foldopen<CR>`                                 | Fold open                            |
| `<A-]>`     | `:foldclose<CR>`                                | Fold close                           |
| `<A-.>`     | `:BookmarkToggle<CR>`                           | Bookmark toggle                      |
| `<A-,>`     | `:Format<CR>`                                   | Format code                          |
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

- Visual mode

| Key      | Action                                                                                                 | Description     |
| -------- | ------------------------------------------------------------------------------------------------------ | --------------- |
| `<`      | `<gv`                                                                                                  | Tab left        |
| `>`      | `>gv`                                                                                                  | Tab right       |
| `*`      | `:<C-u>`<br/>`lua require("core.funcs.search").visual_selection("/")`<br/>`<br/><CR>/<C-r>=@/<CR><CR>` | Visual search / |
| `#`      | `:<C-u>`<br/>`lua require("core.funcs.search").visual_selection("?")`<br/>`<CR>?<C-r>=@/<CR><CR>`      | Visual search ? |
| `K`      | `:move \'<-2<CR>gv-gv`                                                                                 | Move up         |
| `J`      | `:move \'>+1<CR>gv-gv`                                                                                 | Move down       |
| `<A-j> ` | `:AnyJumpVisual<CR>`                                                                                   | Any jump visual |
| `<A-/>`  | `:CommentToggle<CR>`                                                                                   | Comment toggle  |

## LSP support

- cpp
- java
- rust
- go
- python
- ruby
- lua
- php
- dart
- sh
- javascript, javascriptreact, typescript, typescriptreact
- docker
- json
- latex
- yaml
- svelte
- html
- css, less, scss

```lua
:LspInstall <name-of-server>
```

## Customize plugins

- Modules (plugins)

All included plugins are in this [file](https://github.com/lvim-tech/lvim/blob/main/lua/modules/global/init.lua) by default

You can modify plugins from this [file](https://github.com/lvim-tech/lvim/blob/main/lua/modules/custom/init.lua)

- Remove an existing plugin(s)

```lua
local modules = {}

modules['kevinhwang91/rnvimr'] = false

return modules
```

- Customize the settings of existing plugin(s)

```lua
local modules = {}

modules['kevinhwang91/rnvimr'] = {
    -- Your code
}

return modules
```

- Adding plugin(s)

```lua
local modules = {}

modules['sheerun/vim-polyglot'] = {
    -- your code
}

return modules
```
