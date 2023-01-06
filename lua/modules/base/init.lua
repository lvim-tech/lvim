local funcs = require("core.funcs")

local ui_config = require("modules.base.configs.ui")

local modules = {}
local plugins_snapshot = {}

local file_content = funcs.read_file(_G.LVIM_SNAPSHOT)
if file_content ~= nil then
    plugins_snapshot = file_content
end

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- DEPENDENCIES -------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

modules[_G.LVIM_SETTINGS.colorschemes.theme_plugin] = {
    commit = funcs.get_commit(_G.LVIM_SETTINGS.colorschemes.theme_name, plugins_snapshot),
    priority = 100,
    config = ui_config.lvim_colorscheme,
}

modules["nvim-lua/plenary.nvim"] = {
    commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
    lazy = true,
}

modules["nvim-lua/popup.nvim"] = {
    commit = funcs.get_commit("popup.nvim", plugins_snapshot),
    lazy = true,
}

modules["rcarriga/nvim-notify"] = {
    commit = funcs.get_commit("nvim-notify", plugins_snapshot),
    lazy = true,
    config = ui_config.nvim_notify,
}

modules["MunifTanjim/nui.nvim"] = {
    commit = funcs.get_commit("nui.nvim", plugins_snapshot),
    lazy = true,
    config = ui_config.nui_nvim,
}

modules["lvim-tech/lvim-ui-config"] = {
    commit = funcs.get_commit("lvim-ui-config", plugins_snapshot),
    dependencies = {
        "rcarriga/nvim-notify",
        "MunifTanjim/nui.nvim",
    },
    lazy = true,
}

modules["nvim-tree/nvim-web-devicons"] = {
    commit = funcs.get_commit("nvim-web-devicons", plugins_snapshot),
    lazy = true,
}

modules["mrbjarksen/neo-tree-diagnostics.nvim"] = {
    commit = funcs.get_commit("neo-tree-diagnostics.nvim", plugins_snapshot),
    module = "neo-tree.sources.diagnostics",
    lazy = true,
}

modules["folke/twilight.nvim"] = {
    commit = funcs.get_commit("twilight.nvim", plugins_snapshot),
    config = ui_config.twilight_nvim,
    lazy = true,
}

modules["nvim-telescope/telescope-fzf-native.nvim"] = {
    commit = funcs.get_commit("telescope-fzf-native.nvim", plugins_snapshot),
    build = "make",
    lazy = true,
}

modules["nvim-telescope/telescope-file-browser.nvim"] = {
    commit = funcs.get_commit("telescope-file-browser.nvim", plugins_snapshot),
    lazy = true,
}

modules["camgraff/telescope-tmux.nvim"] = {
    commit = funcs.get_commit("telescope-tmux.nvim", plugins_snapshot),
    lazy = true,
}

modules["junegunn/fzf"] = {
    commit = funcs.get_commit("fzf", plugins_snapshot),
    build = function()
        vim.fn["fzf#install"]()
    end,
    lazy = true,
}

modules["neovim/nvim-lspconfig"] = {
    commit = funcs.get_commit("nvim-lspconfig", plugins_snapshot),
    lazy = true,
}

modules["anuvyklack/pretty-fold.nvim"] = {
    commit = funcs.get_commit("fold-preview.nvim", plugins_snapshot),
    lazy = true,
}

modules["olimorris/neotest-phpunit"] = {
    commit = funcs.get_commit("neotest-phpunit", plugins_snapshot),
    lazy = true,
}

modules["rouge8/neotest-rust"] = {
    commit = funcs.get_commit("neotest-rust", plugins_snapshot),
    lazy = true,
}

modules["nvim-neotest/neotest-go"] = {
    commit = funcs.get_commit("neotest-go", plugins_snapshot),
    lazy = true,
}

modules["nvim-neotest/neotest-python"] = {
    commit = funcs.get_commit("neotest-python", plugins_snapshot),
    lazy = true,
}

modules["MrcJkb/neotest-haskell"] = {
    commit = funcs.get_commit("neotest-haskell", plugins_snapshot),
    lazy = true,
}

modules["jfpedroza/neotest-elixir"] = {
    commit = funcs.get_commit("neotest-elixir", plugins_snapshot),
    lazy = true,
}

modules["sidlatau/neotest-dart"] = {
    commit = funcs.get_commit("neotest-dart", plugins_snapshot),
    lazy = true,
}

modules["ray-x/guihua.lua"] = {
    commit = funcs.get_commit("guihua.lua", plugins_snapshot),
    build = "cd lua/fzy && make",
    lazy = true,
}

modules["nvim-treesitter/playground"] = {
    commit = funcs.get_commit("playground", plugins_snapshot),
    lazy = true,
}

modules["mfussenegger/nvim-dap"] = {
    commit = funcs.get_commit("nvim-dap", plugins_snapshot),
    lazy = true,
}

modules["mxsdev/nvim-dap-vscode-js"] = {
    commit = funcs.get_commit("nvim-dap-vscode-js", plugins_snapshot),
    lazy = true,
}

modules["jbyuki/one-small-step-for-vimkind"] = {
    commit = funcs.get_commit("one-small-step-for-vimkind", plugins_snapshot),
    lazy = true,
}

modules["tpope/vim-dadbod"] = {
    commit = funcs.get_commit("vim-dadbod", plugins_snapshot),
    lazy = true,
}

modules["kristijanhusak/vim-dadbod-completion"] = {
    commit = funcs.get_commit("vim-dadbod-completion", plugins_snapshot),
    lazy = true,
}

modules["hrsh7th/cmp-nvim-lsp"] = {
    commit = funcs.get_commit("cmp-nvim-lsp", plugins_snapshot),
    lazy = true,
}

modules["saadparwaiz1/cmp_luasnip"] = {
    commit = funcs.get_commit("cmp_luasnip", plugins_snapshot),
    lazy = true,
}

modules["hrsh7th/cmp-buffer"] = {
    commit = funcs.get_commit("cmp-buffer", plugins_snapshot),
    lazy = true,
}

modules["hrsh7th/cmp-path"] = {
    commit = funcs.get_commit("cmp-path", plugins_snapshot),
    lazy = true,
}

modules["kdheepak/cmp-latex-symbols"] = {
    commit = funcs.get_commit("cmp-latex-symbols", plugins_snapshot),
    ft = "latex",
    lazy = true,
}

modules["rafamadriz/friendly-snippets"] = {
    commit = funcs.get_commit("friendly-snippets", plugins_snapshot),
    lazy = true,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

modules["folke/noice.nvim"] = {
    commit = funcs.get_commit("noice.nvim", plugins_snapshot),
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
        "hrsh7th/nvim-cmp",
    },
    cmd = "Noice",
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

modules["prichrd/netrw.nvim"] = {
    commit = funcs.get_commit("netrw.nvim", plugins_snapshot),
    config = ui_config.netrw_nvim,
}

modules["nvim-neo-tree/neo-tree.nvim"] = {
    commit = funcs.get_commit("neo-tree.nvim", plugins_snapshot),
    cmd = "Neotree",
    keys = {
        { "<S-x>", "<cmd>Neotree filesystem left toggle<cr>", desc = "NeoTree filesystem" },
        { "<C-c><C-f>", "<cmd>Neotree filesystem left toggle<cr>", desc = "NeoTree filesystem" },
        { "<C-c><C-b>", "<cmd>Neotree buffers left toggle<cr>", desc = "NeoTree buffers" },
        { "<C-c><C-g>", "<cmd>Neotree git_status left toggle<cr>", desc = "NeoTree git status" },
        { "<C-c><C-d>", "<cmd>Neotree diagnostics left toggle<cr>", desc = "NeoTree diagnostics" },
        { "<A-e>", "<cmd>Neotree diagnostics reveal bottom toggle<cr>", desc = "NeoTree diagnostics" },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        "mrbjarksen/neo-tree-diagnostics.nvim",
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
    keys = { "<space>", "d", "g", "t", "<C-c>" },
    config = ui_config.which_key_nvim,
}

modules["rebelot/heirline.nvim"] = {
    commit = funcs.get_commit("heirline.nvim", plugins_snapshot),
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
    dependencies = {
        "folke/twilight.nvim",
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
    config = ui_config.lvim_helper,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- EDITOR -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("modules.base.configs.editor")

modules["gpanders/editorconfig.nvim"] = {
    commit = funcs.get_commit("editorconfig.nvim", plugins_snapshot),
    config = editor_config.editorconfig_nvim,
}

modules["vim-ctrlspace/vim-ctrlspace"] = {
    commit = funcs.get_commit("vim-ctrlspace", plugins_snapshot),
    keys = {
        { "<space><space>", "<Cmd>CtrlSpace<CR>", desc = "CtrlSpace" },
    },
    cmd = "CtrlSpace",
}

modules["numToStr/Navigator.nvim"] = {
    commit = funcs.get_commit("Navigator.nvim", plugins_snapshot),
    config = editor_config.navigator_nvim,
}

modules["nvim-telescope/telescope.nvim"] = {
    commit = funcs.get_commit("telescope.nvim", plugins_snapshot),
    cmd = "Telescope",
    keys = {
        { "<A-,>", "<Cmd>Telescope find_files<CR>", desc = "Telescope find files" },
        { "<A-.>", "<Cmd>Telescope live_grep<CR>", desc = "Telescope live grep" },
        { "<A-/>", "<Cmd>Telescope file_browser<CR>", desc = "Telescope file browser" },
        { "<A-b>", "<Cmd>Telescope buffers<CR>", desc = "Telescope buffers" },
        { "tt", "<Cmd>Telescope tmux session<CR>", desc = "Telescope tmux session" },
    },
    dependencies = {
        "nvim-telescope/telescope-fzf-native.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        "camgraff/telescope-tmux.nvim",
    },
    config = editor_config.telescope_nvim,
}

modules["lvim-tech/lvim-linguistics"] = {
    commit = funcs.get_commit("lvim-linguistics", plugins_snapshot),
    dependencies = {
        "rcarriga/nvim-notify",
        "MunifTanjim/nui.nvim",
        "lvim-tech/lvim-ui-config",
    },
    config = editor_config.lvim_linguistics,
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
    dependencies = {
        "junegunn/fzf",
    },
    config = editor_config.nvim_bqf,
}

modules["yorickpeterse/nvim-pqf"] = {
    url = "https://gitlab.com/yorickpeterse/nvim-pqf",
    commit = funcs.get_commit("nvim-pqf", plugins_snapshot),
    config = editor_config.nvim_pqf,
}

modules["nanozuki/tabby.nvim"] = {
    commit = funcs.get_commit("tabby.nvim", plugins_snapshot),
    dependencies = {
        "vim-ctrlspace/vim-ctrlspace",
    },
    event = {
        "BufRead",
    },
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

modules["nvim-treesitter/nvim-treesitter-context"] = {
    commit = funcs.get_commit("nvim-treesitter-context", plugins_snapshot),
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = editor_config.nvim_treesitter_context,
}

modules["Dkendal/nvim-treeclimber"] = {
    commit = funcs.get_commit("nvim-treeclimber", plugins_snapshot),
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = editor_config.nvim_treeclimber,
}

modules["NTBBloodbath/rest.nvim"] = {
    commit = funcs.get_commit("rest.nvim", plugins_snapshot),
    ft = "http",
    config = editor_config.rest_nvim,
}

modules["michaelb/sniprun"] = {
    commit = funcs.get_commit("sniprun", plugins_snapshot),
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    build = "bash ./install.sh",
    event = {
        "BufRead",
    },
    config = editor_config.sniprun,
}

modules["CRAG666/code_runner.nvim"] = {
    commit = funcs.get_commit("code_runner.nvim", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = editor_config.code_runner_nvim,
}

modules["windwp/nvim-spectre"] = {
    commit = funcs.get_commit("nvim-spectre", plugins_snapshot),
    event = {
        "BufRead",
    },
    dependencies = {
        "nvim-lua/popup.nvim",
        "nvim-lua/plenary.nvim",
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
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
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
    commit = funcs.get_commit("hop.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.hop_nvim,
}

modules["folke/todo-comments.nvim"] = {
    commit = funcs.get_commit("todo-comments.nvim", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = {
        "BufRead",
    },
    config = editor_config.todo_comments_nvim,
}

modules["anuvyklack/pretty-fold.nvim"] = {
    commit = funcs.get_commit("pretty-fold.nvim", plugins_snapshot),
    dependencies = {
        "anuvyklack/fold-preview.nvim",
    },
    event = {
        "BufRead",
    },
    config = editor_config.pretty_fold_nvim,
}

modules["renerocksai/calendar-vim"] = {
    commit = funcs.get_commit("calendar-vim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.calendar_vim,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- VERSION CONTROL ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local version_control_config = require("modules.base.configs.version_control")

modules["TimUntersberger/neogit"] = {
    commit = funcs.get_commit("neogit", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    cmd = "Neogit",
    config = version_control_config.neogit,
}

modules["lewis6991/gitsigns.nvim"] = {
    commit = funcs.get_commit("gitsigns.nvim", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
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
    event = "BufRead",
    config = version_control_config.diffview_nvim,
}

modules["pwntester/octo.nvim"] = {
    commit = funcs.get_commit("octo.nvim", plugins_snapshot),
    cmd = "Octo",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    config = version_control_config.octo_nvim,
}

modules["mbbill/undotree"] = {
    commit = funcs.get_commit("undotree", plugins_snapshot),
    cmd = "UndotreeToggle",
    config = version_control_config.undotree,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Languages ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require("modules.base.configs.languages")

modules["folke/neoconf.nvim"] = {
    commit = funcs.get_commit("neoconf.nvim", plugins_snapshot),
}

modules["williamboman/mason.nvim"] = {
    commit = funcs.get_commit("mason.nvim", plugins_snapshot),
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    config = languages_config.mason_nvim,
}

modules["jose-elias-alvarez/null-ls.nvim"] = {
    commit = funcs.get_commit("null-ls.nvim", plugins_snapshot),
    config = languages_config.null_ls_nvim,
}

modules["nvim-neotest/neotest"] = {
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "olimorris/neotest-phpunit",
        "rouge8/neotest-rust",
        "nvim-neotest/neotest-go",
        "nvim-neotest/neotest-python",
        "MrcJkb/neotest-haskell",
        "jfpedroza/neotest-elixir",
        "sidlatau/neotest-dart",
    },
    config = languages_config.neotest,
}

modules["smjonas/inc-rename.nvim"] = {
    commit = funcs.get_commit("inc-rename.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = languages_config.inc_rename_nvim,
}

modules["DNLHC/glance.nvim"] = {
    commit = funcs.get_commit("glance.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = languages_config.glance_nvim,
}

modules["folke/neodev.nvim"] = {
    commit = funcs.get_commit("neodev.nvim", plugins_snapshot),
    ft = "lua",
    config = languages_config.neodev_nvim,
}

modules["mfussenegger/nvim-jdtls"] = {
    commit = funcs.get_commit("nvim-jdtls", plugins_snapshot),
    ft = "java",
}

modules["scalameta/nvim-metals"] = {
    commit = funcs.get_commit("nvim-metals", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    ft = { "scala", "sbt" },
}

modules["simrat39/rust-tools.nvim"] = {
    commit = funcs.get_commit("rust-tools.nvim", plugins_snapshot),
    ft = "rust",
    dependencies = {
        "neovim/nvim-lspconfig",
        "nvim-lua/popup.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "mfussenegger/nvim-dap",
    },
}

modules["ray-x/go.nvim"] = {
    commit = funcs.get_commit("go.nvim", plugins_snapshot),
    dependencies = {
        "ray-x/guihua.lua",
    },
    ft = "go",
    config = languages_config.go_nvim,
}

modules["akinsho/flutter-tools.nvim"] = {
    commit = funcs.get_commit("flutter-tools.nvim", plugins_snapshot),
    ft = "dart",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
}

modules["jose-elias-alvarez/typescript.nvim"] = {
    commit = funcs.get_commit("nvim-lsp-ts-utils", plugins_snapshot),
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    dependencies = {
        "neovim/nvim-lspconfig",
        "nvim-lua/plenary.nvim",
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
    dependencies = {
        "nvim-treesitter/playground",
    },
    config = languages_config.nvim_treesitter,
}

modules["lvimuser/lsp-inlayhints.nvim"] = {
    commit = funcs.get_commit("lsp-inlayhints.nvim", plugins_snapshot),
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    config = languages_config.lsp_inlayhints_nvim,
}

modules["SmiteshP/nvim-navic"] = {
    commit = funcs.get_commit("nvim-navic", plugins_snapshot),
    dependencies = {
        "neovim/nvim-lspconfig",
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
    event = {
        "BufRead",
    },
    config = languages_config.symbols_outline_nvim,
}

modules["rcarriga/nvim-dap-ui"] = {
    commit = funcs.get_commit("nvim-dap-ui", plugins_snapshot),
    event = {
        "BufRead",
    },
    dependencies = {
        "mfussenegger/nvim-dap",
        "mxsdev/nvim-dap-vscode-js",
        "jbyuki/one-small-step-for-vimkind",
    },
    config = languages_config.nvim_dap_ui,
}

modules["kristijanhusak/vim-dadbod-ui"] = {
    commit = funcs.get_commit("vim-dadbod-ui", plugins_snapshot),
    dependencies = {
        "tpope/vim-dadbod",
        "kristijanhusak/vim-dadbod-completion",
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
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    event = "BufReadPost package.json",
    config = languages_config.package_info_nvim,
}

modules["Saecki/crates.nvim"] = {
    commit = funcs.get_commit("crates.nvim", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = "BufReadPost Cargo.toml",
    config = languages_config.crates_nvim,
}

modules["akinsho/pubspec-assist.nvim"] = {
    commit = funcs.get_commit("pubspec-assist.nvim", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = "BufReadPost pubspec.yaml",
    config = languages_config.pubspec_assist_nvim,
}

modules["iamcco/markdown-preview.nvim"] = {
    commit = funcs.get_commit("markdown-preview.nvim", plugins_snapshot),
    build = "cd app && npm install",
    ft = "markdown",
    config = languages_config.markdown_preview_nvim,
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
    ft = "org",
    config = languages_config.orgmode,
}

modules["lvim-tech/lvim-org-utils"] = {
    commit = funcs.get_commit("lvim-org-utils", plugins_snapshot),
    ft = "org",
    config = languages_config.lvim_org_utils,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- COMPLETION ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require("modules.base.configs.completion")

modules["hrsh7th/nvim-cmp"] = {
    commit = funcs.get_commit("nvim-cmp", plugins_snapshot),
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "kdheepak/cmp-latex-symbols",
    },
    event = {
        "InsertEnter",
    },
    config = completion_config.nvim_cmp,
}

modules["L3MON4D3/LuaSnip"] = {
    commit = funcs.get_commit("LuaSnip", plugins_snapshot),
    dependencies = {
        "rafamadriz/friendly-snippets",
    },
}

modules["Neevash/awesome-flutter-snippets"] = {
    commit = funcs.get_commit("awesome-flutter-snippets", plugins_snapshot),
    ft = "dart",
}

modules["windwp/nvim-autopairs"] = {
    commit = funcs.get_commit("nvim-autopairs", plugins_snapshot),
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
    },
    config = completion_config.nvim_autopairs,
}

modules["windwp/nvim-ts-autotag"] = {
    commit = funcs.get_commit("nvim-ts-autotag", plugins_snapshot),
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
    },
    config = completion_config.nvim_ts_autotag,
}

modules["kylechui/nvim-surround"] = {
    commit = funcs.get_commit("nvim-surround", plugins_snapshot),
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = completion_config.nvim_surround,
}

return modules
