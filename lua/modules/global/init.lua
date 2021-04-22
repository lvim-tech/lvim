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
        cmd = 'Telescope',
        config = ui_config.telescope,
        requires = {
            {'nvim-lua/popup.nvim', opt = true},
            {'nvim-lua/plenary.nvim', opt = true},
            {'nvim-telescope/telescope-fzy-native.nvim', opt = true}
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
    {event = 'BufRead', branch = 'lua', config = ui_config.indent_blankline}

modules['kyazdani42/nvim-tree.lua'] = {
    config = ui_config.tree,
    requires = 'kyazdani42/nvim-web-devicons'
}

modules['kevinhwang91/rnvimr'] = {config = ui_config.ranger}

modules['norcalli/nvim-colorizer.lua'] = {config = ui_config.colorize}

modules['junegunn/goyo.vim'] = {
    requires = 'junegunn/limelight.vim',
    config = ui_config.goyo
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
    event = {'BufRead', 'BufNewFile'},
    config = editor_config.gitsigns,
    requires = {'nvim-lua/plenary.nvim', opt = true}
}

modules['tpope/vim-fugitive'] = {}

modules['f-person/git-blame.nvim'] = {config = editor_config.blame}

modules['TimUntersberger/neogit'] = {
    event = {'BufRead', 'BufNewFile'},
    config = editor_config.neogit,
    requires = {'nvim-lua/plenary.nvim', opt = true}
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Languages ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require('modules.global.configs.languages')

modules['neovim/nvim-lspconfig'] = {}

modules['kabouzeid/nvim-lspinstall'] = {}

modules['mfussenegger/nvim-jdtls'] = {}

modules['nvim-treesitter/nvim-treesitter'] =
    {
        event = 'BufRead',
        after = 'telescope.nvim',
        config = languages_config.treesitter,
        requires = {{'nvim-treesitter/playground', opt = true}},
        run = ':TSUpdate'
    }

modules['pechorin/any-jump.vim'] = {
    event = 'BufRead',
    config = languages_config.jump
}

modules['mfussenegger/nvim-dap'] = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Completion ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require('modules.global.configs.completion')

modules['hrsh7th/nvim-compe'] = {
    event = 'InsertEnter',
    config = completion_config.compe
}

modules['rafamadriz/friendly-snippets'] = {}
modules['hrsh7th/vim-vsnip'] = {}

modules['onsails/lspkind-nvim'] = {config = completion_config.lspkind}

modules['mattn/emmet-vim'] = {
    event = 'InsertEnter',
    config = completion_config.emmet
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Tools --------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local tools_config = require('modules.global.configs.tools')

modules['liuchengxu/vista.vim'] = {}

modules['kristijanhusak/vim-dadbod-ui'] =
    {
        cmd = {
            'DBUIToggle', 'DBUIAddConnection', 'DBUI', 'DBUIFindBuffer',
            'DBUIRenameBuffer'
        },
        config = tools_config.vim_dadbod_ui,
        requires = {
            {'tpope/vim-dadbod', opt = true},
            {'kristijanhusak/vim-dadbod-completion', opt = true}
        }
    }

modules['AckslD/nvim-whichkey-setup.lua'] =
    {requires = 'liuchengxu/vim-which-key', config = tools_config.whichkey}

modules['iamcco/markdown-preview.nvim'] = {run = 'cd app && yarn install'}

modules['airblade/vim-rooter'] = {config = tools_config.rooter}

return modules
