local modules = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require('modules.global.configs.ui')

modules['lvim-tech/lvim-colorscheme'] = {
    event = 'VimEnter',
    config = [[vim.cmd('colorscheme lvim')]]
}

modules['glepnir/dashboard-nvim'] = {
    event = 'VimEnter',
    config = ui_config.dashboard
}

-- modules['glepnir/galaxyline.nvim'] = {
--     branch = 'main',
--     config = ui_config.galaxyline,
--     requires = 'kyazdani42/nvim-web-devicons'
-- }

modules['lvim-tech/galaxyline.nvim'] = {
    event = {'VimEnter', 'BufRead', 'BufNewFile'},
    branch = 'exclude_filetypes',
    config = ui_config.galaxyline,
    requires = 'kyazdani42/nvim-web-devicons'
}

modules['lukas-reineke/indent-blankline.nvim'] = {
    event = 'BufRead',
    branch = 'lua',
    config = ui_config.indent_blankline
}

-- modules['ms-jpq/chadtree'] = {
--     branch = 'chad',
--     event = 'VimEnter',
--     cmd = {'CHADopen', 'CHADhelp', 'CHADdeps'},
--     requires = 'kyazdani42/nvim-web-devicons',
--     run = function()
--         vim.fn.system("python3 -m chadtree deps")
--         vim.cmd("CHADdeps")
--     end,
--     config = ui_config.chadtree
-- }

modules['kyazdani42/nvim-tree.lua'] = {
    cmd = 'NvimTreeToggle',
    config = ui_config.tree,
    requires = 'kyazdani42/nvim-web-devicons'
}

modules['vifm/vifm.vim'] = {cmd = 'Vifm'}

modules['junegunn/goyo.vim'] = {
    cmd = 'Goyo',
    requires = {
        {
            'junegunn/limelight.vim',
            after = 'goyo.vim',
            config = ui_config.limelight
        }
    },
    config = ui_config.goyo
}

modules['voldikss/vim-floaterm'] = {config = ui_config.floaterm}

modules['lvim-tech/lvim-helper'] = {
    cmd = 'LvimHelper',
    config = ui_config.helper
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Editor -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require('modules.global.configs.editor')

modules['vim-ctrlspace/vim-ctrlspace'] = {cmd = 'CtrlSpace'}

-- modules['liuchengxu/vim-clap'] = {
--     config = editor_config.clap,
--     run = ':Clap install-binary'
-- }

modules['camspiers/snap'] = {}

modules['windwp/nvim-spectre'] = {
    event = 'VimEnter',
    config = editor_config.spectre,
    requires = {
        {'nvim-lua/popup.nvim', opt = true},
        {'nvim-lua/plenary.nvim', opt = true}
    }
}

modules['lambdalisue/suda.vim'] = {
    event = {'BufRead', 'BufNewFile'},
    config = editor_config.suda
}

modules['terrortylor/nvim-comment'] = {
    cmd = 'CommentToggle',
    config = editor_config.comment
}

modules['sbdchd/neoformat'] = {cmd = 'Neoformat'}

modules['windwp/nvim-autopairs'] = {
    after = 'nvim-treesitter',
    config = editor_config.autopairs
}

modules['MattesGroeger/vim-bookmarks'] = {
    cmd = 'BookmarkToggle',
    config = editor_config.bookmarks
}

modules['mbbill/undotree'] = {cmd = 'UndotreeToggle'}

modules['kkoomen/vim-doge'] = {
    run = ':call doge#install()',
    config = editor_config.doge
}

modules['lewis6991/gitsigns.nvim'] = {
    event = 'BufReadPre',
    config = editor_config.gitsigns,
    requires = {'nvim-lua/plenary.nvim', opt = true}
}

modules['tpope/vim-fugitive'] = {}

modules['sindrets/diffview.nvim'] = {
    cmd = {
        'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles',
        'DiffviewFocusFiles', 'DiffviewRefresh'
    },
    config = editor_config.diffview
}

modules['f-person/git-blame.nvim'] = {config = editor_config.blame}

modules['TimUntersberger/neogit'] = {
    cmd = 'Neogit',
    config = editor_config.neogit,
    requires = {
        {'nvim-lua/plenary.nvim', opt = true},
        {'sindrets/diffview.nvim', opt = true, config = editor_config.diffview}
    }
}

modules['kenn7/vim-arsync'] = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Languages ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require('modules.global.configs.languages')

modules['neovim/nvim-lspconfig'] = {}

modules['kabouzeid/nvim-lspinstall'] = {}

modules['mfussenegger/nvim-jdtls'] = {event = 'VimEnter'}

modules['jose-elias-alvarez/nvim-lsp-ts-utils'] = {event = 'VimEnter'}

modules['nvim-treesitter/nvim-treesitter'] = {
    event = 'BufRead',
    config = languages_config.treesitter,
    requires = {{'nvim-treesitter/playground', opt = true}},
    run = ':TSUpdate'
}

modules['pechorin/any-jump.vim'] = {
    event = 'BufRead',
    config = languages_config.jump
}

modules['folke/lsp-trouble.nvim'] = {
    event = 'BufRead',
    config = languages_config.trouble,
    requires = 'kyazdani42/nvim-web-devicons'
}

modules['simrat39/symbols-outline.nvim'] = {
    event = 'BufRead',
    config = languages_config.symbols
}

modules['akinsho/dependency-assist.nvim'] = {
    event = {'VimEnter', 'BufRead', 'BufNewFile'},
    config = languages_config.dependency
}

modules['puremourning/vimspector'] = {opt = true}

modules['mfussenegger/nvim-dap'] = {opt = true}

modules['rcarriga/nvim-dap-ui'] = {opt = true}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Completion ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require('modules.global.configs.completion')

modules['hrsh7th/nvim-compe'] = {
    event = 'InsertEnter',
    config = completion_config.compe
}

modules['hrsh7th/vim-vsnip'] = {after = 'nvim-compe'}

modules['rafamadriz/friendly-snippets'] = {after = 'nvim-compe'}

modules['onsails/lspkind-nvim'] = {config = completion_config.lspkind}

modules['mattn/emmet-vim'] = {
    event = 'InsertEnter',
    config = completion_config.emmet
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Tools --------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local tools_config = require('modules.global.configs.tools')

modules['norcalli/nvim-colorizer.lua'] = {
    event = 'VimEnter',
    config = tools_config.colorize
}

modules['kristijanhusak/vim-dadbod-ui'] = {
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

modules['AckslD/nvim-whichkey-setup.lua'] = {
    event = {'VimEnter', 'BufReadPre'},
    requires = 'liuchengxu/vim-which-key',
    config = tools_config.whichkey
}

modules['iamcco/markdown-preview.nvim'] = {
    event = {'VimEnter', 'BufReadPre'},
    run = 'cd app && yarn install'
}

modules['airblade/vim-rooter'] = {config = tools_config.rooter}

-- modules['ahmedkhalf/lsp-rooter.nvim'] = {event = 'VimEnter'}

return modules
