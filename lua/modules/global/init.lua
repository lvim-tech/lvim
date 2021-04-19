local modules = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require('modules.global.configs.ui')

modules['lvim-tech/lvim-colorscheme'] = {
    config = [[vim.cmd('colorscheme lvim')]]
}

modules['nvim-telescope/telescope.nvim'] =
    {
        config = ui_config.telescope,
        requires = {
            {'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'},
            {'nvim-telescope/telescope-fzy-native.nvim'},
            {'nvim-telescope/telescope-media-files.nvim'}
        }
    }

modules['glepnir/dashboard-nvim'] = {config = ui_config.dashboard}

modules['glepnir/galaxyline.nvim'] = {
    branch = 'main',
    config = ui_config.galaxyline,
    requires = 'kyazdani42/nvim-web-devicons'
}

modules['romgrk/barbar.nvim'] = {requires = 'kyazdani42/nvim-web-devicons'}

modules['lukas-reineke/indent-blankline.nvim'] =
    {branch = 'lua', config = ui_config.indent_blankline}

modules['kyazdani42/nvim-tree.lua'] = {
    config = ui_config.tree,
    requires = 'kyazdani42/nvim-web-devicons'
}

modules['kevinhwang91/rnvimr'] = {config = ui_config.ranger}

modules['norcalli/nvim-colorizer.lua'] = {config = ui_config.colorize}

modules['junegunn/goyo.vim'] = {
    config = ui_config.goyo,
    requires = 'junegunn/limelight.vim'
}

modules['voldikss/vim-floaterm'] = {config = ui_config.floaterm}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Editor -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require('modules.global.configs.editor')

modules['terrortylor/nvim-comment'] = {config = editor_config.comment}

modules['mhartington/formatter.nvim'] = {config = editor_config.formatter}

modules['windwp/nvim-autopairs'] = {config = editor_config.autopairs}

modules['MattesGroeger/vim-bookmarks'] = {config = editor_config.bookmarks}

modules['mbbill/undotree'] = {}

modules['kkoomen/vim-doge'] = {
    run = ':call doge#install()',
    config = editor_config.doge
}

modules['lewis6991/gitsigns.nvim'] = {
    requires = {'nvim-lua/plenary.nvim'},
    config = editor_config.gitsigns
}

modules['tpope/vim-fugitive'] = {}

modules['f-person/git-blame.nvim'] = {config = editor_config.blame}

modules['TimUntersberger/neogit'] = {config = editor_config.neogit}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Languages ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require('modules.global.configs.languages')

modules['neovim/nvim-lspconfig'] = {}

modules['kabouzeid/nvim-lspinstall'] = {}

modules['mfussenegger/nvim-jdtls'] = {}

modules['nvim-treesitter/nvim-treesitter'] =
    {
        config = languages_config.treesitter,
        requires = 'nvim-treesitter/playground',
        run = ':TSUpdate'
    }

modules['mfussenegger/nvim-dap'] = {}

modules['puremourning/vimspector'] = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Completion ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require('modules.global.configs.completion')

modules['hrsh7th/nvim-compe'] = {config = completion_config.compe}

modules['hrsh7th/vim-vsnip'] = {}

modules['rafamadriz/friendly-snippets'] = {}

modules['mattn/emmet-vim'] = {config = completion_config.emmet}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Tools --------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local tools_config = require('modules.global.configs.tools')

modules['liuchengxu/vista.vim'] = {}

modules['tpope/vim-dadbod'] = {
    config = tools_config.dadbod,
    requires = {
        'kristijanhusak/vim-dadbod-ui', 'kristijanhusak/vim-dadbod-completion'
    }
}

modules['AckslD/nvim-whichkey-setup.lua'] =
    {config = tools_config.whichkey, requires = 'liuchengxu/vim-which-key'}

modules['iamcco/markdown-preview.nvim'] = {run = 'cd app && yarn install'}

modules['airblade/vim-rooter'] = {config = tools_config.rooter}

return modules
