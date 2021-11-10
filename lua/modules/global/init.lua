local modules = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- SYSTEM -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

modules["nvim-lua/plenary.nvim"] = {}
modules["nvim-lua/popup.nvim"] = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require("modules.global.configs.ui")

modules["lvim-tech/lvim-colorscheme"] = {
    event = {
        "VimEnter",
        "BufRead",
        "BufNewFile"
    },
    config = ui_config.lvim_colorscheme
}

modules["glepnir/dashboard-nvim"] = {
    event = "VimEnter",
    config = ui_config.dashboard_nvim
}

modules["kyazdani42/nvim-tree.lua"] = {
    requires = "kyazdani42/nvim-web-devicons",
    cmd = "NvimTreeToggle",
    config = ui_config.nvim_tree
}

modules["folke/which-key.nvim"] = {
    event = "BufWinEnter",
    config = ui_config.which_key
}

modules["nvim-lualine/lualine.nvim"] = {
    requires = "kyazdani42/nvim-web-devicons",
    event = {
        "VimEnter",
        "BufRead",
        "BufNewFile"
    },
    config = ui_config.lualine
}

modules["voldikss/vim-floaterm"] = {
    config = ui_config.vim_floaterm
}

modules["folke/twilight.nvim"] = {
    cmd = "Twilight",
    config = ui_config.twilight
}

modules["lukas-reineke/indent-blankline.nvim"] = {
    event = {
        "VimEnter",
        "BufRead",
        "BufNewFile"
    },
    config = ui_config.indent_blankline
}

modules["lvim-tech/lvim-focus"] = {
    event = {
        "VimEnter",
        "BufRead",
        "BufNewFile"
    },
    config = ui_config.lvim_focus
}

modules["lvim-tech/lvim-helper"] = {
    cmd = "LvimHelper",
    config = ui_config.lvim_helper
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Editor -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("modules.global.configs.editor")

modules["vim-ctrlspace/vim-ctrlspace"] = {
    cmd = "CtrlSpace"
}

local commit
if 1 ~= vim.fn.has "nvim-0.5.1" then
    commit = "02a02f7bcdfb1f207de6649c00701ee1fe13a420"
else
    commit = nil
end

modules["nvim-telescope/telescope.nvim"] = {
    commit = commit,
    requires = {
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            run = "make"
        },
        {
            "nvim-telescope/telescope-media-files.nvim"
        }
    },
    cmd = "Telescope",
    config = editor_config.telescope
}

modules["windwp/nvim-spectre"] = {
    event = {
        "BufRead",
        "BufNewFile"
    },
    requires = {
        {
            "nvim-lua/popup.nvim"
        },
        {
            "nvim-lua/plenary.nvim"
        }
    },
    config = editor_config.nvim_spectre
}

modules["terrortylor/nvim-comment"] = {
    cmd = "CommentToggle",
    config = editor_config.nvim_comment
}

modules["MattesGroeger/vim-bookmarks"] = {
    cmd = "BookmarkToggle",
    config = editor_config.vim_bookmarks
}

modules["kkoomen/vim-doge"] = {
    cmd = {
        "DogeGenerate",
        "DogeCreateDocStandard"
    },
    run = ":call doge#install()",
    config = editor_config.vim_doge
}

modules["windwp/nvim-autopairs"] = {
    after = {
        "nvim-treesitter",
        "nvim-cmp"
    },
    config = editor_config.nvim_autopairs
}

modules["norcalli/nvim-colorizer.lua"] = {
    event = {
        "BufRead",
        "BufNewFile"
    },
    config = editor_config.nvim_colorize
}

modules["lambdalisue/suda.vim"] = {
    event = {
        "BufRead",
        "BufNewFile"
    },
    config = editor_config.suda
}

modules["kenn7/vim-arsync"] = {
    event = {
        "BufRead",
        "BufNewFile"
    }
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Version control ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local version_control_config = require("modules.global.configs.version_control")

modules["TimUntersberger/neogit"] = {
    requires = "nvim-lua/plenary.nvim",
    cmd = "Neogit",
    config = version_control_config.neogit
}

modules["tpope/vim-fugitive"] = {
    event = {
        "BufRead",
        "BufNewFile"
    }
}

modules["lewis6991/gitsigns.nvim"] = {
    requires = "nvim-lua/plenary.nvim",
    event = {
        "BufRead",
        "BufNewFile"
    },
    config = version_control_config.gitsigns
}

modules["f-person/git-blame.nvim"] = {
    config = version_control_config.git_blame
}

modules["sindrets/diffview.nvim"] = {
    event = {
        "BufRead",
        "BufNewFile"
    }
}

modules["mbbill/undotree"] = {
    event = {
        "BufRead",
        "BufNewFile"
    },
    cmd = "UndotreeToggle"
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Languages ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require("modules.global.configs.languages")

modules["neovim/nvim-lspconfig"] = {
    event = {
        "VimEnter",
        "BufWinEnter",
        "BufRead",
        "BufNewFile"
    },
    config = languages_config.nvim_lspconfig
}

modules["williamboman/nvim-lsp-installer"] = {
    requires = "neovim/nvim-lspconfig",
    config = languages_config.nvim_lsp_installer
}

modules["ray-x/lsp_signature.nvim"] = {}

modules["nvim-treesitter/nvim-treesitter"] = {
    requires = {
        {
            "nvim-treesitter/playground",
            after = "nvim-treesitter"
        }
    },
    event = {
        "BufRead",
        "BufNewFile"
    },
    run = ":TSUpdate",
    config = languages_config.nvim_treesitter
}

modules["pechorin/any-jump.vim"] = {
    event = {
        "BufRead",
        "BufNewFile"
    },
    config = languages_config.any_jump
}

modules["folke/lsp-trouble.nvim"] = {
    requires = "kyazdani42/nvim-web-devicons",
    config = languages_config.lsp_trouble
}

modules["simrat39/symbols-outline.nvim"] = {
    cmd = "SymbolsOutline",
    config = languages_config.symbols_outline
}

modules["rcarriga/nvim-dap-ui"] = {
    event = {
        "BufRead",
        "BufNewFile"
    },
    requires = {
        "mfussenegger/nvim-dap",
        "jbyuki/one-small-step-for-vimkind"
    },
    config = languages_config.nvim_dap_ui
}

modules["Pocco81/DAPInstall.nvim"] = {
    event = "BufWinEnter",
    config = languages_config.dapinstall
}

modules["kristijanhusak/vim-dadbod-ui"] = {
    requires = {
        {
            "tpope/vim-dadbod",
            after = "vim-dadbod-ui"
        },
        {
            "kristijanhusak/vim-dadbod-completion",
            after = "vim-dadbod-ui"
        }
    },
    cmd = {
        "DBUIToggle",
        "DBUIAddConnection",
        "DBUI",
        "DBUIFindBuffer",
        "DBUIRenameBuffer"
    },
    config = languages_config.vim_dadbod_ui
}

modules["iamcco/markdown-preview.nvim"] = {
    event = {
        "VimEnter",
        "BufReadPre"
    },
    run = "cd app && yarn install"
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Completion ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require("modules.global.configs.completion")

modules["hrsh7th/nvim-cmp"] = {
    requires = {
        {
            "hrsh7th/cmp-nvim-lsp"
        },
        {
            "hrsh7th/cmp-vsnip",
            after = "nvim-cmp"
        },
        {
            "hrsh7th/cmp-buffer",
            after = "nvim-cmp"
        },
        {
            "hrsh7th/cmp-path",
            after = "nvim-cmp"
        }
    },
    event = {
        "BufRead",
        "BufNewFile",
        "InsertEnter"
    },
    config = completion_config.nvim_cmp
}

modules["hrsh7th/vim-vsnip"] = {
    requires = {
        {
            "hrsh7th/vim-vsnip-integ",
            after = "vim-vsnip"
        },
        {
            "rafamadriz/friendly-snippets",
            after = "vim-vsnip"
        }
    },
    event = "InsertEnter"
}

modules["onsails/lspkind-nvim"] = {
    event = {
        "BufRead",
        "BufNewFile"
    },
    config = completion_config.lspkind_nvim
}

modules["mattn/emmet-vim"] = {
    event = "InsertEnter",
    config = completion_config.emmet_vim
}

return modules
