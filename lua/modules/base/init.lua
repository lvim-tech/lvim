local modules = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UTILS -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

modules["nvim-lua/plenary.nvim"] = {}

modules["lewis6991/impatient.nvim"] = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require("modules.base.configs.ui")

modules["lvim-tech/lvim-colorscheme"] = {
    config = ui_config.lvim_colorscheme,
}

modules["nvim-lua/popup.nvim"] = {}

modules["MunifTanjim/nui.nvim"] = {
    config = ui_config.nui_nvim,
}

modules["goolord/alpha-nvim"] = {
    event = "VimEnter",
    config = ui_config.alpha_nvim,
}

modules["s1n7ax/nvim-window-picker"] = {
    config = ui_config.nvim_window_picker,
}

modules["nvim-neo-tree/neo-tree.nvim"] = {
    branch = "v2.x",
    requires = {
        "nvim-lua/plenary.nvim",
        "kyazdani42/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        {
            "mrbjarksen/neo-tree-diagnostics.nvim",
            module = "neo-tree.sources.diagnostics",
        },
    },
    config = ui_config.neo_tree_nvim,
}

modules["elihunter173/dirbuf.nvim"] = {
    cmd = "Dirbuf",
    config = ui_config.dirbuf_nvim,
}

modules["lvim-tech/which-key.nvim"] = {
    event = "BufWinEnter",
    branch = "buftype",
    config = ui_config.which_key_nvim,
}

local commit = nil
if vim.fn.has("nvim-0.8") == 0 then
    commit = "7b4aabc2c55d50fbd4a4923e847079d6fa9a8613"
end
modules["rebelot/heirline.nvim"] = {
    commit = commit,
    after = "lvim-colorscheme",
    config = ui_config.heirline_nvim,
}

modules["is0n/fm-nvim"] = {
    config = ui_config.fm_nvim,
}

modules["akinsho/toggleterm.nvim"] = {
    tag = "v2.*",
    cmd = {
        "TTFloat",
        "TTOne",
        "TTTwo",
        "TTThree",
    },
    config = ui_config.toggleterm_nvim,
}

modules["folke/zen-mode.nvim"] = {
    requires = {
        "folke/twilight.nvim",
        config = ui_config.twilight_nvim,
        after = "zen-mode.nvim",
    },
    cmd = "ZenMode",
    config = ui_config.zen_mode_nvim,
}

modules["nyngwang/NeoZoom.lua"] = {
    config = ui_config.neozoom_lua,
    cmd = "NeoZoomToggle",
}

modules["lukas-reineke/indent-blankline.nvim"] = {
    event = {
        "BufRead",
    },
    config = ui_config.indent_blankline_nvim,
}

modules["rcarriga/nvim-notify"] = {
    after = "lvim-colorscheme",
    config = ui_config.nvim_notify,
}

modules["lvim-tech/lvim-focus"] = {
    after = "lvim-colorscheme",
    config = ui_config.lvim_focus,
}

modules["lvim-tech/lvim-helper"] = {
    cmd = "LvimHelper",
    config = ui_config.lvim_helper,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Editor -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("modules.base.configs.editor")

modules["vim-ctrlspace/vim-ctrlspace"] = {
    cmd = "CtrlSpace",
}

modules["nvim-telescope/telescope.nvim"] = {
    requires = {
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            run = "make",
            opt = true,
        },
        {
            "nvim-telescope/telescope-media-files.nvim",
            opt = true,
        },
        {
            "nvim-telescope/telescope-file-browser.nvim",
            opt = true,
        },
        {
            "camgraff/telescope-tmux.nvim",
            opt = true,
        },
        {
            "zane-/howdoi.nvim",
            opt = true,
        },
    },
    config = editor_config.telescope_nvim,
}

modules["kevinhwang91/nvim-bqf"] = {
    ft = "qf",
    requires = {
        "junegunn/fzf",
        run = function()
            vim.fn["fzf#install"]()
        end,
    },
    config = editor_config.nvim_bqf,
}

modules["https://gitlab.com/yorickpeterse/nvim-pqf"] = {
    config = editor_config.nvim_pqf,
}

modules["nanozuki/tabby.nvim"] = {
    config = editor_config.tabby_nvim,
}

modules["booperlv/nvim-gomove"] = {
    event = {
        "BufRead",
    },
    config = editor_config.nvim_gomove,
}

modules["NTBBloodbath/rest.nvim"] = {
    ft = "http",
    config = editor_config.rest_nvim,
}

modules["michaelb/sniprun"] = {
    requires = {
        "neovim/nvim-lspconfig",
    },
    run = "bash ./install.sh",
    cmd = {
        "SnipRun",
        "SnipInfo",
        "SnipReset",
        "SnipReplMemoryClean",
        "SnipClose",
    },
    config = editor_config.sniprun,
}

modules["hkupty/iron.nvim"] = {
    config = editor_config.iron_nvim,
}

modules["CRAG666/code_runner.nvim"] = {
    requires = {
        "nvim-lua/plenary.nvim",
    },
    config = editor_config.code_runner_nvim,
}

modules["windwp/nvim-spectre"] = {
    cmd = "Spectre",
    requires = {
        "nvim-lua/popup.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = editor_config.nvim_spectre,
}

modules["numToStr/Comment.nvim"] = {
    event = {
        "CursorMoved",
    },
    config = editor_config.comment_nvim,
}

modules["ton/vim-bufsurf"] = {
    event = {
        "BufRead",
    },
}

modules["danymat/neogen"] = {
    requires = {
        "nvim-treesitter/nvim-treesitter",
    },
    event = {
        "BufRead",
    },
    config = editor_config.neogen,
}

modules["norcalli/nvim-colorizer.lua"] = {
    event = {
        "BufRead",
    },
    config = editor_config.nvim_colorize_lua,
}

modules["xiyaowong/virtcolumn.nvim"] = {
    event = {
        "BufRead",
    },
    config = editor_config.virtcolumn_nvim,
}

modules["declancm/cinnamon.nvim"] = {
    event = {
        "BufRead",
    },
    config = editor_config.cinnamon_nvim,
}

modules["phaazon/hop.nvim"] = {
    event = {
        "BufRead",
    },
    branch = "v2",
    config = editor_config.hop_nvim,
}

modules["folke/todo-comments.nvim"] = {
    requires = {
        "nvim-lua/plenary.nvim",
    },
    event = {
        "BufRead",
    },
    config = editor_config.todo_comments_nvim,
}

modules["anuvyklack/pretty-fold.nvim"] = {
    requires = {
        "anuvyklack/fold-preview.nvim",
    },
    event = {
        "BufRead",
    },
    config = editor_config.pretty_fold_nvim,
}

modules["renerocksai/calendar-vim"] = {
    cmd = { "Calendar", "CalendarH", "CalendarT", "CalendarVR" },
    config = editor_config.calendar_vim,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Version control ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local version_control_config = require("modules.base.configs.version_control")

modules["TimUntersberger/neogit"] = {
    requires = {
        "nvim-lua/plenary.nvim",
    },
    cmd = "Neogit",
    config = version_control_config.neogit,
}

modules["lewis6991/gitsigns.nvim"] = {
    requires = {
        "nvim-lua/plenary.nvim",
    },
    event = {
        "BufRead",
    },
    config = version_control_config.gitsigns_nvim,
}

modules["f-person/git-blame.nvim"] = {
    event = {
        "BufRead",
    },
    config = version_control_config.git_blame_nvim,
}

modules["sindrets/diffview.nvim"] = {
    cmd = {
        "DiffviewOpen",
        "DiffviewFileHistory",
        "DiffviewFocusFiles",
        "DiffviewToggleFiles",
        "DiffviewRefresh",
    },
}

modules["pwntester/octo.nvim"] = {
    after = "lvim-colorscheme",
    requires = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "kyazdani42/nvim-web-devicons",
    },
    config = version_control_config.octo_nvim,
}

modules["mbbill/undotree"] = {
    event = {
        "BufRead",
    },
    cmd = "UndotreeToggle",
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Languages ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require("modules.base.configs.languages")

modules["williamboman/mason.nvim"] = {
    requires = {
        "neovim/nvim-lspconfig",
    },
    config = languages_config.mason_nvim,
}

modules["jose-elias-alvarez/null-ls.nvim"] = {
    config = languages_config.null_ls_nvim,
}

modules["rmagatti/goto-preview"] = {
    event = {
        "BufRead",
    },
    config = languages_config.goto_preview,
}

modules["lewis6991/hover.nvim"] = {
    event = {
        "BufRead",
    },
    config = languages_config.hover_nvim,
}

modules["lvim-tech/fidget.nvim"] = {
    event = {
        "BufRead",
    },
    config = languages_config.fidget_nvim,
}

modules["folke/lua-dev.nvim"] = {
    ft = "lua",
}

modules["simrat39/rust-tools.nvim"] = {
    ft = "rust",
    after = "telescope.nvim",
    requires = {
        {
            "neovim/nvim-lspconfig",
        },
        {
            "nvim-lua/popup.nvim",
        },
        {
            "nvim-lua/plenary.nvim",
        },
        {
            "mfussenegger/nvim-dap",
        },
        {
            "nvim-telescope/telescope.nvim",
        },
    },
}

modules["ray-x/go.nvim"] = {
    requires = {
        "ray-x/guihua.lua",
    },
    ft = "go",
    config = languages_config.go_nvim,
}

modules["akinsho/flutter-tools.nvim"] = {
    ft = "dart",
    requires = {
        "nvim-lua/plenary.nvim",
    },
}

modules["jose-elias-alvarez/nvim-lsp-ts-utils"] = {
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    requires = {
        "neovim/nvim-lspconfig",
        "nvim-lua/plenary.nvim",
    },
}

modules["Mofiqul/trld.nvim"] = {
    event = {
        "BufRead",
    },
    config = languages_config.trld_nvim,
}

modules["kosayoda/nvim-lightbulb"] = {
    event = {
        "BufRead",
    },
    config = languages_config.nvim_lightbulb,
}

modules["nvim-treesitter/nvim-treesitter"] = {
    config = languages_config.nvim_treesitter,
}

modules["nvim-treesitter/nvim-treesitter-context"] = {
    requires = {
        "nvim-treesitter/nvim-treesitter",
    },
    after = "nvim-treesitter",
    config = languages_config.nvim_treesitter_contex,
}

modules["lvimuser/lsp-inlayhints.nvim"] = {
    requires = {
        "neovim/nvim-lspconfig",
    },
    config = languages_config.lsp_inlayhints_nvim,
}

modules["SmiteshP/nvim-navic"] = {
    requires = {
        "neovim/nvim-lspconfig",
    },
    config = languages_config.nvim_navic,
}

modules["pechorin/any-jump.vim"] = {
    event = {
        "BufRead",
    },
    config = languages_config.any_jump_nvim,
}

modules["simrat39/symbols-outline.nvim"] = {
    cmd = "SymbolsOutline",
    config = languages_config.symbols_outline_nvim,
}

modules["rcarriga/nvim-dap-ui"] = {
    event = {
        "BufRead",
    },
    requires = {
        "mfussenegger/nvim-dap",
        "jbyuki/one-small-step-for-vimkind",
    },
    config = languages_config.nvim_dap_ui,
}

modules["kristijanhusak/vim-dadbod-ui"] = {
    requires = {
        {
            "tpope/vim-dadbod",
            after = "vim-dadbod-ui",
        },
        {
            "kristijanhusak/vim-dadbod-completion",
            after = "vim-dadbod-ui",
        },
    },
    cmd = {
        "DBUIToggle",
        "DBUIAddConnection",
        "DBUI",
        "DBUIFindBuffer",
        "DBUIRenameBuffer",
    },
    config = languages_config.vim_dadbod_ui,
}

modules["vuki656/package-info.nvim"] = {
    requires = {
        "MunifTanjim/nui.nvim",
    },
    event = "BufRead package.json",
    config = languages_config.package_info_nvim,
}

modules["Saecki/crates.nvim"] = {
    requires = {
        "nvim-lua/plenary.nvim",
    },
    event = "BufRead Cargo.toml",
    config = languages_config.crates_nvim,
}

modules["akinsho/pubspec-assist.nvim"] = {
    requires = {
        "nvim-lua/plenary.nvim",
    },
    event = "BufRead pubspec.yaml",
    rocks = {
        {
            "lyaml",
            server = "http://rocks.moonscript.org",
        },
    },
    config = languages_config.pubspec_assist_nvim,
}

modules["davidgranstrom/nvim-markdown-preview"] = {
    ft = "markdown",
}

modules["lervag/vimtex"] = {
    config = languages_config.vimtex,
}

modules["dhruvasagar/vim-table-mode"] = {
    event = {
        "BufRead",
    },
}

modules["nvim-orgmode/orgmode"] = {
    config = languages_config.orgmode,
}

modules["lvim-tech/lvim-org-utils"] = {
    ft = "org",
    config = languages_config.lvim_org_utils,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Completion ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require("modules.base.configs.completion")

modules["hrsh7th/nvim-cmp"] = {
    requires = {
        "hrsh7th/cmp-nvim-lsp",
        {
            "saadparwaiz1/cmp_luasnip",
            after = "nvim-cmp",
        },
        {
            "hrsh7th/cmp-buffer",
            after = "nvim-cmp",
        },
        {
            "hrsh7th/cmp-path",
            after = "nvim-cmp",
        },
        {
            "kdheepak/cmp-latex-symbols",
            after = "nvim-cmp",
        },
    },
    event = {
        "BufRead",
        "InsertEnter",
    },
    config = completion_config.nvim_cmp,
}

modules["L3MON4D3/LuaSnip"] = {
    requires = {
        "rafamadriz/friendly-snippets",
        after = "LuaSnip",
    },
}

modules["Neevash/awesome-flutter-snippets"] = {
    ft = "dart",
}

modules["windwp/nvim-autopairs"] = {
    {
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
    },
    after = {
        "nvim-treesitter",
        "nvim-cmp",
    },
    config = completion_config.nvim_autopairs,
}

modules["windwp/nvim-ts-autotag"] = {
    requires = {
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
    },
    after = {
        "nvim-treesitter",
        "nvim-cmp",
    },
    config = completion_config.nvim_ts_autotag,
}

modules["kylechui/nvim-surround"] = {
    requires = {
        "nvim-treesitter/nvim-treesitter",
    },
    after = "nvim-treesitter",
    config = completion_config.nvim_surround,
}

return modules
