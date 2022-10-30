local funcs = require("core.funcs")
local modules = {}
local plugins_snapshot = {}

local read_json_file = funcs.read_json_file(_G.LVIM_SNAPSHOT)
if read_json_file ~= nil then
    plugins_snapshot = read_json_file
end
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UTILS -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

modules["nvim-lua/plenary.nvim"] = {
    commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
}

modules["lewis6991/impatient.nvim"] = {
    commit = funcs.get_commit("impatient.nvim", plugins_snapshot),
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require("modules.base.configs.ui")

modules["lvim-tech/lvim-colorscheme"] = {
    commit = funcs.get_commit("lvim-colorscheme", plugins_snapshot),
    config = ui_config.lvim_colorscheme,
}

modules["nvim-lua/popup.nvim"] = {
    commit = funcs.get_commit("popup.nvim", plugins_snapshot),
}

modules["MunifTanjim/nui.nvim"] = {
    commit = funcs.get_commit("nui.nvim", plugins_snapshot),
    config = ui_config.nui_nvim,
}

modules["rcarriga/nvim-notify"] = {
    commit = funcs.get_commit("nvim-notify", plugins_snapshot),
    config = ui_config.nvim_notify,
}

modules["folke/noice.nvim"] = {
    commit = funcs.get_commit("noice.nvim", plugins_snapshot),
    requires = {
        {
            "MunifTanjim/nui.nvim",
            commit = funcs.get_commit("nui.nvim", plugins_snapshot),
        },
        {
            "rcarriga/nvim-notify",
            commit = funcs.get_commit("nvim-notify", plugins_snapshot),
        },
    },
    config = ui_config.noice_nvim,
}

modules["goolord/alpha-nvim"] = {
    commit = funcs.get_commit("alpha-nvim", plugins_snapshot),
    event = "VimEnter",
    config = ui_config.alpha_nvim,
}

modules["s1n7ax/nvim-window-picker"] = {
    commit = funcs.get_commit("nvim-window-picker", plugins_snapshot),
    config = ui_config.nvim_window_picker,
}

modules["nvim-neo-tree/neo-tree.nvim"] = {
    commit = funcs.get_commit("neo-tree.nvim", plugins_snapshot),
    requires = {
        {
            "nvim-lua/plenary.nvim",
            commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
        },
        {
            "kyazdani42/nvim-web-devicons",
            commit = funcs.get_commit("nvim-web-devicons", plugins_snapshot),
        },
        {
            "MunifTanjim/nui.nvim",
            commit = funcs.get_commit("nui.nvim", plugins_snapshot),
        },
        {
            "mrbjarksen/neo-tree-diagnostics.nvim",
            commit = funcs.get_commit("neo-tree-diagnostics.nvim", plugins_snapshot),
            module = "neo-tree.sources.diagnostics",
        },
    },
    config = ui_config.neo_tree_nvim,
}

modules["elihunter173/dirbuf.nvim"] = {
    commit = funcs.get_commit("dirbuf.nvim", plugins_snapshot),
    cmd = "Dirbuf",
    config = ui_config.dirbuf_nvim,
}

modules["folke/which-key.nvim"] = {
    commit = funcs.get_commit("which-key.nvim", plugins_snapshot),
    event = "BufWinEnter",
    config = ui_config.which_key_nvim,
}

modules["rebelot/heirline.nvim"] = {
    commit = funcs.get_commit("heirline.nvim", plugins_snapshot),
    event = "VimEnter",
    requires = {
        {
            "folke/noice.nvim",
            requires = {
                {
                    "MunifTanjim/nui.nvim",
                    commit = funcs.get_commit("nui.nvim", plugins_snapshot),
                },
                {
                    "rcarriga/nvim-notify",
                    commit = funcs.get_commit("nvim-notify", plugins_snapshot),
                },
            },
            commit = funcs.get_commit("noice.nvim", plugins_snapshot),
        },
    },
    config = ui_config.heirline_nvim,
}

modules["is0n/fm-nvim"] = {
    commit = funcs.get_commit("fm-nvim", plugins_snapshot),
    config = ui_config.fm_nvim,
}

modules["akinsho/toggleterm.nvim"] = {
    commit = funcs.get_commit("toggleterm.nvim", plugins_snapshot),
    config = ui_config.toggleterm_nvim,
}

modules["folke/zen-mode.nvim"] = {
    commit = funcs.get_commit("zen-mode.nvim", plugins_snapshot),
    requires = {
        "folke/twilight.nvim",
        commit = funcs.get_commit("twilight.nvim", plugins_snapshot),
        config = ui_config.twilight_nvim,
        after = "zen-mode.nvim",
    },
    cmd = "ZenMode",
    config = ui_config.zen_mode_nvim,
}

modules["nyngwang/NeoZoom.lua"] = {
    commit = funcs.get_commit("NeoZoom.lua", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = ui_config.neozoom_lua,
}

modules["gbprod/stay-in-place.nvim"] = {
    commit = funcs.get_commit("stay-in-place.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = ui_config.stay_in_place,
}

modules["lukas-reineke/indent-blankline.nvim"] = {
    commit = funcs.get_commit("indent-blankline.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = ui_config.indent_blankline_nvim,
}

modules["lvim-tech/lvim-focus"] = {
    commit = funcs.get_commit("lvim-focus", plugins_snapshot),
    event = "VimEnter",
    config = ui_config.lvim_focus,
}

modules["lvim-tech/lvim-helper"] = {
    commit = funcs.get_commit("lvim-helper", plugins_snapshot),
    cmd = "LvimHelper",
    config = ui_config.lvim_helper,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Editor -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("modules.base.configs.editor")

modules["vim-ctrlspace/vim-ctrlspace"] = {
    commit = funcs.get_commit("vim-ctrlspace", plugins_snapshot),
    -- cmd = "CtrlSpace",
}

modules["nvim-telescope/telescope.nvim"] = {
    commit = funcs.get_commit("telescope.nvim", plugins_snapshot),
    requires = {
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            commit = funcs.get_commit("telescope-fzf-native.nvim", plugins_snapshot),
            run = "make",
            opt = true,
        },
        {
            "nvim-telescope/telescope-file-browser.nvim",
            commit = funcs.get_commit("telescope-file-browser.nvim", plugins_snapshot),
            opt = true,
        },
        {
            "camgraff/telescope-tmux.nvim",
            commit = funcs.get_commit("telescope-tmux.nvim", plugins_snapshot),
            opt = true,
        },
        {
            "zane-/howdoi.nvim",
            commit = funcs.get_commit("howdoi.nvim", plugins_snapshot),
            opt = true,
        },
    },
    config = editor_config.telescope_nvim,
}

modules["winston0410/rg.nvim"] = {
    commit = funcs.get_commit("rg.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.rg_nvim,
}

modules["kevinhwang91/nvim-hlslens"] = {
    commit = funcs.get_commit("nvim-hlslens", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.nvim_hlslens,
}

modules["kevinhwang91/nvim-bqf"] = {
    commit = funcs.get_commit("nvim-bqf", plugins_snapshot),
    ft = "qf",
    requires = {
        "junegunn/fzf",
        commit = funcs.get_commit("fzf", plugins_snapshot),
        run = function()
            vim.fn["fzf#install"]()
        end,
    },
    config = editor_config.nvim_bqf,
}

modules["https://gitlab.com/yorickpeterse/nvim-pqf"] = {
    commit = funcs.get_commit("nvim-pqf", plugins_snapshot),
    config = editor_config.nvim_pqf,
}

modules["nanozuki/tabby.nvim"] = {
    commit = funcs.get_commit("tabby.nvim", plugins_snapshot),
    config = editor_config.tabby_nvim,
}

modules["ethanholz/nvim-lastplace"] = {
    commit = funcs.get_commit("nvim-lastplace", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.nvim_lastplace,
}

modules["monaqa/dial.nvim"] = {
    commit = funcs.get_commit("dial.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.dial_nvim,
}

modules["booperlv/nvim-gomove"] = {
    commit = funcs.get_commit("nvim-gomove", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.nvim_gomove,
}

modules["RRethy/nvim-treesitter-textsubjects"] = {
    commit = funcs.get_commit("nvim-treesitter-textsubjects", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.nvim_treesitter_textsubjects,
}

modules["NTBBloodbath/rest.nvim"] = {
    commit = funcs.get_commit("rest.nvim", plugins_snapshot),
    ft = "http",
    config = editor_config.rest_nvim,
}

modules["michaelb/sniprun"] = {
    commit = funcs.get_commit("sniprun", plugins_snapshot),
    requires = {
        "neovim/nvim-lspconfig",
        commit = funcs.get_commit("nvim-lspconfig", plugins_snapshot),
    },
    run = "bash ./install.sh",
    event = {
        "BufRead",
    },
    config = editor_config.sniprun,
}

modules["CRAG666/code_runner.nvim"] = {
    commit = funcs.get_commit("code_runner.nvim", plugins_snapshot),
    requires = {
        "nvim-lua/plenary.nvim",
        commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
    },
    config = editor_config.code_runner_nvim,
}

modules["windwp/nvim-spectre"] = {
    commit = funcs.get_commit("nvim-spectre", plugins_snapshot),
    event = {
        "BufRead",
    },
    requires = {
        {
            "nvim-lua/popup.nvim",
            commit = funcs.get_commit("popup.nvim", plugins_snapshot),
        },
        {
            "nvim-lua/plenary.nvim",
            commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
        },
    },
    config = editor_config.nvim_spectre,
}

modules["numToStr/Comment.nvim"] = {
    commit = funcs.get_commit("Comment.nvim", plugins_snapshot),
    event = {
        "CursorMoved",
    },
    config = editor_config.comment_nvim,
}

modules["ton/vim-bufsurf"] = {
    commit = funcs.get_commit("vim-bufsurf", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.vim_bufsurf,
}

modules["danymat/neogen"] = {
    commit = funcs.get_commit("neogen", plugins_snapshot),
    requires = {
        "nvim-treesitter/nvim-treesitter",
        commit = funcs.get_commit("nvim-treesitter", plugins_snapshot),
    },
    event = {
        "BufRead",
    },
    config = editor_config.neogen,
}

modules["NvChad/nvim-colorizer.lua"] = {
    commit = funcs.get_commit("nvim-colorizer.lua", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.nvim_colorize_lua,
}

modules["ziontee113/color-picker.nvim"] = {
    commit = funcs.get_commit("color-picker.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.color_picker_nvim,
}

modules["lvim-tech/lvim-colorcolumn"] = {
    commit = funcs.get_commit("lvim-colorcolumn", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.lvim_colorcolumn,
}

modules["phaazon/hop.nvim"] = {
    branch = "v2",
    commit = funcs.get_commit("hop.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.hop_nvim,
}

modules["folke/todo-comments.nvim"] = {
    commit = funcs.get_commit("todo-comments.nvim", plugins_snapshot),
    requires = {
        "nvim-lua/plenary.nvim",
        commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
    },
    event = {
        "BufRead",
    },
    config = editor_config.todo_comments_nvim,
}

modules["anuvyklack/pretty-fold.nvim"] = {
    commit = funcs.get_commit("pretty-fold.nvim", plugins_snapshot),
    requires = {
        "anuvyklack/fold-preview.nvim",
        commit = funcs.get_commit("fold-preview.nvim", plugins_snapshot),
    },
    event = {
        "BufRead",
    },
    config = editor_config.pretty_fold_nvim,
}

modules["renerocksai/calendar-vim"] = {
    commit = funcs.get_commit("calendar-vim", plugins_snapshot),
    cmd = { "Calendar", "CalendarH", "CalendarT", "CalendarVR" },
    config = editor_config.calendar_vim,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Version control ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local version_control_config = require("modules.base.configs.version_control")

modules["TimUntersberger/neogit"] = {
    commit = funcs.get_commit("neogit", plugins_snapshot),
    requires = {
        "nvim-lua/plenary.nvim",
        commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
    },
    cmd = "Neogit",
    config = version_control_config.neogit,
}

modules["lewis6991/gitsigns.nvim"] = {
    commit = funcs.get_commit("gitsigns.nvim", plugins_snapshot),
    requires = {
        "nvim-lua/plenary.nvim",
        commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
    },
    event = {
        "BufRead",
    },
    config = version_control_config.gitsigns_nvim,
}

modules["f-person/git-blame.nvim"] = {
    commit = funcs.get_commit("git-blame.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = version_control_config.git_blame_nvim,
}

modules["sindrets/diffview.nvim"] = {
    commit = funcs.get_commit("diffview.nvim", plugins_snapshot),
    event = "VimEnter",
    config = version_control_config.diffview_nvim,
}

modules["pwntester/octo.nvim"] = {
    commit = funcs.get_commit("octo.nvim", plugins_snapshot),
    event = "VimEnter",
    requires = {
        {
            "nvim-lua/plenary.nvim",
            commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
        },
        {
            "nvim-telescope/telescope.nvim",
            commit = funcs.get_commit("telescope.nvim", plugins_snapshot),
        },
        {
            "kyazdani42/nvim-web-devicons",
            commit = funcs.get_commit("nvim-web-devicons", plugins_snapshot),
        },
    },
    config = version_control_config.octo_nvim,
}

modules["mbbill/undotree"] = {
    commit = funcs.get_commit("undotree", plugins_snapshot),
    event = {
        "BufRead",
    },
    cmd = "UndotreeToggle",
    config = version_control_config.undotree,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Languages ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require("modules.base.configs.languages")

modules["williamboman/mason.nvim"] = {
    commit = funcs.get_commit("mason.nvim", plugins_snapshot),
    requires = {
        "neovim/nvim-lspconfig",
        commit = funcs.get_commit("nvim-lspconfig", plugins_snapshot),
    },
    config = languages_config.mason_nvim,
}

modules["jose-elias-alvarez/null-ls.nvim"] = {
    commit = funcs.get_commit("null-ls.nvim", plugins_snapshot),
    config = languages_config.null_ls_nvim,
}

modules["smjonas/inc-rename.nvim"] = {
    commit = funcs.get_commit("inc-rename.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = languages_config.inc_rename_nvim,
}

modules["rmagatti/goto-preview"] = {
    commit = funcs.get_commit("goto-preview", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = languages_config.goto_preview,
}

modules["mfussenegger/nvim-jdtls"] = {
    commit = funcs.get_commit("nvim-jdtls", plugins_snapshot),
    ft = "java",
}

modules["folke/neodev.nvim"] = {
    commit = funcs.get_commit("neodev.nvim", plugins_snapshot),
    ft = "lua",
    config = languages_config.neodev_nvim,
}

modules["simrat39/rust-tools.nvim"] = {
    commit = funcs.get_commit("rust-tools.nvim", plugins_snapshot),
    ft = "rust",
    after = "telescope.nvim",
    requires = {
        {
            "neovim/nvim-lspconfig",
            commit = funcs.get_commit("vim-lspconfig", plugins_snapshot),
        },
        {
            "nvim-lua/popup.nvim",
            commit = funcs.get_commit("popup.nvim", plugins_snapshot),
        },
        {
            "nvim-lua/plenary.nvim",
            commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
        },
        {
            "mfussenegger/nvim-dap",
            commit = funcs.get_commit("nvim-dap", plugins_snapshot),
        },
        {
            "nvim-telescope/telescope.nvim",
            commit = funcs.get_commit("telescope.nvim", plugins_snapshot),
        },
    },
}

modules["ray-x/go.nvim"] = {
    commit = funcs.get_commit("go.nvim", plugins_snapshot),
    requires = {
        "ray-x/guihua.lua",
        commit = funcs.get_commit("guihua.lua", plugins_snapshot),
        run = "cd lua/fzy && make",
    },
    ft = "go",
    config = languages_config.go_nvim,
}

modules["akinsho/flutter-tools.nvim"] = {
    commit = funcs.get_commit("flutter-tools.nvim", plugins_snapshot),
    ft = "dart",
    requires = {
        "nvim-lua/plenary.nvim",
        commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
    },
}

modules["jose-elias-alvarez/typescript.nvim"] = {
    commit = funcs.get_commit("nvim-lsp-ts-utils", plugins_snapshot),
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    requires = {
        {
            "neovim/nvim-lspconfig",
            commit = funcs.get_commit("nvim-lspconfig", plugins_snapshot),
        },
        {
            "nvim-lua/plenary.nvim",
            commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
        },
    },
}

modules["kosayoda/nvim-lightbulb"] = {
    commit = funcs.get_commit("nvim-lightbulb", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = languages_config.nvim_lightbulb,
}

modules["nvim-treesitter/nvim-treesitter"] = {
    commit = funcs.get_commit("nvim-treesitter", plugins_snapshot),
    config = languages_config.nvim_treesitter,
}

modules["lvimuser/lsp-inlayhints.nvim"] = {
    commit = funcs.get_commit("lsp-inlayhints.nvim", plugins_snapshot),
    requires = {
        "neovim/nvim-lspconfig",
        commit = funcs.get_commit("nvim-lspconfig", plugins_snapshot),
    },
    config = languages_config.lsp_inlayhints_nvim,
}

modules["SmiteshP/nvim-navic"] = {
    commit = funcs.get_commit("nvim-navic", plugins_snapshot),
    requires = {
        "neovim/nvim-lspconfig",
        commit = funcs.get_commit("nvim-lspconfig", plugins_snapshot),
    },
    config = languages_config.nvim_navic,
}

modules["pechorin/any-jump.vim"] = {
    commit = funcs.get_commit("any-jump.vim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = languages_config.any_jump_nvim,
}

modules["simrat39/symbols-outline.nvim"] = {
    commit = funcs.get_commit("symbols-outline.nvim", plugins_snapshot),
    cmd = "SymbolsOutline",
    config = languages_config.symbols_outline_nvim,
}

modules["rcarriga/nvim-dap-ui"] = {
    commit = funcs.get_commit("nvim-dap-ui", plugins_snapshot),
    event = {
        "BufRead",
    },
    requires = {
        {
            "mfussenegger/nvim-dap",
            commit = funcs.get_commit("nvim-dap", plugins_snapshot),
        },
        {
            "mxsdev/nvim-dap-vscode-js",
            commit = funcs.get_commit("nvim-dap-vscode-js", plugins_snapshot),
            config = languages_config.nvim_dap_vscode_js,
        },
        {
            "jbyuki/one-small-step-for-vimkind",
            commit = funcs.get_commit("one-small-step-for-vimkind", plugins_snapshot),
        },
    },
    config = languages_config.nvim_dap_ui,
}

modules["kristijanhusak/vim-dadbod-ui"] = {
    commit = funcs.get_commit("vim-dadbod-ui", plugins_snapshot),
    requires = {
        {
            "tpope/vim-dadbod",
            commit = funcs.get_commit("vim-dadbod", plugins_snapshot),
            after = "vim-dadbod-ui",
        },
        {
            "kristijanhusak/vim-dadbod-completion",
            commit = funcs.get_commit("vim-dadbod-completion", plugins_snapshot),
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
    commit = funcs.get_commit("package-info.nvim", plugins_snapshot),
    requires = {
        "MunifTanjim/nui.nvim",
        commit = funcs.get_commit("nui.nvim", plugins_snapshot),
    },
    event = "BufRead package.json",
    config = languages_config.package_info_nvim,
}

modules["Saecki/crates.nvim"] = {
    commit = funcs.get_commit("crates.nvim", plugins_snapshot),
    requires = {
        "nvim-lua/plenary.nvim",
        commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
    },
    event = "BufRead Cargo.toml",
    config = languages_config.crates_nvim,
}

modules["akinsho/pubspec-assist.nvim"] = {
    commit = funcs.get_commit("pubspec-assist.nvim", plugins_snapshot),
    requires = {
        "nvim-lua/plenary.nvim",
        commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
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
    commit = funcs.get_commit("nvim-markdown-preview", plugins_snapshot),
    ft = "markdown",
    config = languages_config.nvim_markdown_preview,
}

modules["lervag/vimtex"] = {
    commit = funcs.get_commit("vimtex", plugins_snapshot),
    config = languages_config.vimtex,
}

modules["dhruvasagar/vim-table-mode"] = {
    commit = funcs.get_commit("vim-table-mode", plugins_snapshot),
    event = {
        "BufRead",
    },
}

modules["nvim-orgmode/orgmode"] = {
    commit = funcs.get_commit("orgmode", plugins_snapshot),
    config = languages_config.orgmode,
}

modules["lvim-tech/lvim-org-utils"] = {
    commit = funcs.get_commit("lvim-org-utils", plugins_snapshot),
    ft = "org",
    config = languages_config.lvim_org_utils,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Completion ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require("modules.base.configs.completion")

modules["hrsh7th/nvim-cmp"] = {
    commit = funcs.get_commit("nvim-cmp", plugins_snapshot),
    requires = {
        "hrsh7th/cmp-nvim-lsp",
        commit = funcs.get_commit("cmp-nvim-lsp", plugins_snapshot),
        {
            "saadparwaiz1/cmp_luasnip",
            commit = funcs.get_commit("cmp_luasnip", plugins_snapshot),
            after = "nvim-cmp",
        },
        {
            "hrsh7th/cmp-buffer",
            commit = funcs.get_commit("cmp-buffer", plugins_snapshot),
            after = "nvim-cmp",
        },
        {
            "hrsh7th/cmp-path",
            commit = funcs.get_commit("cmp-path", plugins_snapshot),
            after = "nvim-cmp",
        },
        {
            "kdheepak/cmp-latex-symbols",
            commit = funcs.get_commit("cmp-latex-symbols", plugins_snapshot),
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
    commit = funcs.get_commit("LuaSnip", plugins_snapshot),
    requires = {
        "rafamadriz/friendly-snippets",
        commit = funcs.get_commit("friendly-snippets", plugins_snapshot),
        after = "LuaSnip",
    },
}

modules["Neevash/awesome-flutter-snippets"] = {
    commit = funcs.get_commit("awesome-flutter-snippets", plugins_snapshot),
    ft = "dart",
}

modules["windwp/nvim-autopairs"] = {
    commit = funcs.get_commit("nvim-autopairs", plugins_snapshot),
    requires = {
        {
            "nvim-treesitter/nvim-treesitter",
            commit = funcs.get_commit("nvim-treesitter", plugins_snapshot),
        },
        {
            "hrsh7th/nvim-cmp",
            commit = funcs.get_commit("nvim-cmp", plugins_snapshot),
        },
    },
    after = {
        "nvim-treesitter",
        "nvim-cmp",
    },
    config = completion_config.nvim_autopairs,
}

modules["windwp/nvim-ts-autotag"] = {
    commit = funcs.get_commit("nvim-ts-autotag", plugins_snapshot),
    requires = {
        {
            "nvim-treesitter/nvim-treesitter",
            commit = funcs.get_commit("nvim-treesitter", plugins_snapshot),
        },
        {
            "hrsh7th/nvim-cmp",
            commit = funcs.get_commit("nvim-cmp", plugins_snapshot),
        },
    },
    after = {
        "nvim-treesitter",
        "nvim-cmp",
    },
    config = completion_config.nvim_ts_autotag,
}

modules["kylechui/nvim-surround"] = {
    commit = funcs.get_commit("nvim-surround", plugins_snapshot),
    requires = {
        "nvim-treesitter/nvim-treesitter",
        commit = funcs.get_commit("nvim-treesitter", plugins_snapshot),
    },
    after = "nvim-treesitter",
    config = completion_config.nvim_surround,
}

return modules
