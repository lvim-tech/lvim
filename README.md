# LVIM

![lvim-logo](https://user-images.githubusercontent.com/82431193/115121988-3bc06800-9fbe-11eb-8dab-19f624aa7b93.png)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://github.com/lvim-tech/lvim/blob/main/LICENSE)

## About
LVIM is a modular Neovim configuration written in LUA with full customization:
* Add or remove or rewrite of all nvim settings
* Add or remove plugins, rewrite settings of all plugins
* Dynamic LSP activation

## Requirements

* [neovim nightly(>=0.5.0)](https://github.com/neovim/neovim/wiki/Installing-Neovim)

* [neovim nightly(>=0.5.0)](https://github.com/neovim/neovim/wiki/Installing-Neovim)

* [pynvim](https://github.com/neovim/pynvim)

* [neovim-remote](https://github.com/mhinz/neovim-remote)

* [universal-ctags](https://github.com/universal-ctags/ctags)

* [ripgrep](https://github.com/BurntSushi/ripgrep)

* [ranger](https://github.com/ranger/ranger)

* [ueberzug](https://github.com/seebye/ueberzug)

* [bpytop](https://github.com/aristocratos/bpytop)

## Install

```bash
git clone https://github.com/lvim-tech/lvim.git ~/.config/nvim
```

## Plugins

* UI

    [lvim-colorscheme](https://github.com/lvim-tech/lvim-colorscheme)

    [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (requires [popup.nvim](https://github.com/nvim-lua/popup.nvim) | [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | [telescope-fzy-native.nvim](https://github.com/nvim-telescope/telescope-fzy-native.nvim) | [telescope-media-files.nvim](https://github.com/nvim-telescope/nvim-telescope/telescope-media-files.nvim))

    [dashboard-nvim](https://github.com/glepnir/dashboard-nvim)

    [galaxyline.nvim](https://github.com/glepnir/galaxyline.nvim)

    [barbar.nvim](https://github.com/romgrk/barbar.nvim) (requires [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons))

    [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)

    [nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua)

    [rnvimr](https://github.com/kevinhwang91/rnvimr)

    [nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)

    [goyo.vim](https://github.com/junegunn/goyo.vim)

    [limelight.vim](https://github.com/junegunn/limelight.vim)

    [vim-floaterm](https://github.com/voldikss/vim-floaterm)

* Editor

    [nvim-comment](https://github.com/terrortylor/nvim-comment)

    [formatter.nvim](https://github.com/mhartington/formatter.nvim)

    [nvim-autopairs](https://github.com/windwp/nvim-autopairs)

    [vim-bookmarks](https://github.com/MattesGroeger/vim-bookmarks)

    [undotree](https://github.com/mbbill/undotree)

    [vim-doge](https://github.com/kkoomen/vim-doge)

    [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)

    [vim-fugitive](https://github.com/tpope/vim-fugitive)

    [git-blame.nvim](https://github.com/f-person/git-blame.nvim)

    [neogit](https://github.com/TimUntersberger/neogit)

* Languages

    [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

    [nvim-lspinstall](https://github.com/kabouzeid/nvim-lspinstall)

    [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)

    [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (requires [playground](https://github.com/nvim-treesitter/playground))

    [nvim-dap](https://github.com/mfussenegger/nvim-dap)

    [vimspector](https://github.com/puremourning/vimspector)

* Completion

    [nvim-compe](https://github.com/hrsh7th/nvim-compe)

    [vim-vsnip](https://github.com/hrsh7th/vim-vsnip)

    [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)

    [emmet-vim](https://github.com/mattn/emmet-vim)

* Tools

    [vista](https://github.com/liuchengxu/vista.vim)

    [vim-dadbod](https://github.com/tpope/vim-dadbod) (requires [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) | [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion))

    [nvim-whichkey-setup.lua](https://github.com/AckslD/nvim-whichkey-setup.lua) (requires [vim-which-key](https://github.com/liuchengxu/vim-which-key))

    [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)

    [vim-rooter](https://github.com/airblade/vim-rooter)

## Keymaps

* Normal

```lua
{'<C-n>', ':e %:h/filename<CR>'}, -- Create new file in current directory
{'<C-s>', ':w<CR>'}, -- Save buffer
{'<C-a>', ':wa<CR>'}, -- Save all buffers
{'<C-q>', ':q!<CR>'}, -- Close buffer
{'<C-e>', ':qa!<CR>'}, -- Exit nvim
{'[j', '<C-o>'}, {']j', '<C-i>'}, -- Jump list
{'<C-h>', '<C-w>h'}, {'<C-l>', '<C-w>l'}, -- Smart way to move between windows horizontal
{'<C-j>', '<C-w>j'}, {'<C-k>', '<C-w>k'}, -- Smart way to move between windows vertical
{'[d', '<PageUp>'}, {']d', '<PageDown>'}, -- Page down/up
{'<Esc>', '<Esc>:noh<CR>'}, -- Remove highlight after search
{'<S-h>', '<C-W>v'}, -- Split horizontal
{'<S-b>', '<C-W>s'}, -- Split vertical
{'<C-Up>', ':resize +2<CR>'}, {'<C-Down>', ':resize -2<CR>'}, -- Resize
{'<C-Left>', ':vertical resize +2<CR>'}, {'<C-Right>', ':vertical resize -2<CR>'}, -- Resize
{'<Tab>', ':BufferNext<CR>'}, {'<S-Tab>', ':BufferPrevious<CR>'}, -- Tab navigation / Barbar
{'<C-x>', ':BufferClose<CR>'}, -- Buffer Close
{'<C-d>', ':bdelete<CR>'}, -- BDelete
{'<C-p>', ':Telescope project<CR>'}, -- Telescope project
{'<S-e>', ':NvimTreeToggle<CR>'}, -- NvimTree explorer
{'<S-r>', ':RnvimrToggle<CR>'}, -- Ranger explorer
{'<C-f>', ':Telescope find_files<CR>'}, -- File search
{'<C-r>', ':Telescope live_grep<CR>'}, -- Text search
{'<C-g>', ':FloatermNew lazygit<CR>'}, -- GIT
{'<F5>', ':UndotreeToggle<CR>'}, -- UndoTree toggle
{'<S-f>', ':Format<CR>'}, -- Format code
{'<S-t>', ':FloatermNew --wintype=normal --height=10<CR>'}, -- Terminal
{'<C-v>', ':Vista<CR>'}, -- Vista
{'<A-[>', ':foldopen<CR>'}, -- Fold open
{'<A-]>', ':foldclose<CR>'}, -- Fold close
{'<A-.>', ':BookmarkToggle<CR>'}, -- Bookmark toggle
{'<A-/>', ':CommentToggle<CR>'}, -- Comment toggle
{'<S-m>', ':MarkdownPreviewToggle<CR>'}, -- Markdown preview toggle
{'<A-f>', ':LspFormatting<CR>'}, -- Lsp Formatting
{'<A-g>', ':LspReferences<CR>'}, -- Lsp references
{'<A-d>', ':LspDeclaration<CR>'}, -- Lsp declaration
{'<A-p>', ':LspDefinition<CR>'}, -- Lsp definition
{'<A-h>', ':LspHover<CR>'}, -- Lsp hover
{'<A-r>', ':LspRename<CR>'}, -- Lsp rename
{'<A-n>', ':LspGoToNext<CR>'}, -- Lsp go to next
{'<A-p>', ':LspGoToPrev<CR>'}, -- Lsp go to prev
{'<A-t>', ':LspToggleLineDiagnostics<CR>'} -- Lsp toggle line diagnostics
```

* Visual

```lua
{'<', '<gv'}, -- Tab left
{'>', '>gv'}, -- Tab right
{'*', ':<C-u>lua require("core.funcs.search").visual_selection("/")<CR>/<C-r>=@/<CR><CR>'}, -- Visual search /
{'#', ':<C-u>lua require("core.funcs.search").visual_selection("?")<CR>?<C-r>=@/<CR><CR>'}, -- Visual search ?
{'K', ':move \'<-2<CR>gv-gv'}, -- Move up
{'J', ':move \'>+1<CR>gv-gv'}, -- Move down
{'<A-/>', ':CommentToggle<CR>'} -- Comment toggle
```

## Supported languages (LSP)

* cpp
* java
* rust
* go
* python
* ruby
* lua
* php
* dart
* sh
* javascript, javascriptreact, typescript, typescriptreact
* docker
* json
* latex
* yaml
* svelte
* html
* css, less, scss
