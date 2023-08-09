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

modules["lvim-tech/lvim-colorscheme"] = {
    commit = funcs.get_commit("lvim-tech/lvim-colorscheme", plugins_snapshot),
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

modules["sindrets/winshift.nvim"] = {
    commit = funcs.get_commit("winshift.nvim", plugins_snapshot),
    keys = {
        { "<C-c>w", "<Cmd>Neotree close<CR><Cmd>WinShift<CR>", desc = "WinShift" },
    },
    cmd = "WinShift",
    config = ui_config.winshift_nvim,
}

modules["echasnovski/mini.files"] = {
    commit = funcs.get_commit("mini.files", plugins_snapshot),
    keys = {
        {
            "<Leader>i",
            function()
                require("mini.files").open()
            end,
            desc = "Mini files",
        },
    },
    config = ui_config.mini_files,
}

modules["echasnovski/mini.clue"] = {
    commit = funcs.get_commit("mini.clue", plugins_snapshot),
    event = {
        "VimEnter",
    },
    config = ui_config.mini_clue,
}

modules["prichrd/netrw.nvim"] = {
    commit = funcs.get_commit("netrw.nvim", plugins_snapshot),
    config = ui_config.netrw_nvim,
}

modules["nvim-neo-tree/neo-tree.nvim"] = {
    branch = "v3.x",
    commit = funcs.get_commit("neo-tree.nvim", plugins_snapshot),
    cmd = "Neotree",
    keys = {
        { "<S-x>", "<cmd>Neotree filesystem left<CR>", desc = "NeoTree filesystem" },
        { "<C-c><C-f>", "<cmd>Neotree filesystem left<CR>", desc = "NeoTree filesystem" },
        { "<C-c><C-b>", "<cmd>Neotree buffers left<CR>", desc = "NeoTree buffers" },
        { "<C-c><C-g>", "<cmd>Neotree git_status left<CR>", desc = "NeoTree git status" },
        { "<S-q>", "<cmd>Neotree close<CR>", desc = "NeoTree close" },
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

modules["anuvyklack/hydra.nvim"] = {
    commit = funcs.get_commit("hydra.nvim", plugins_snapshot),
    config = ui_config.hydra_nvim,
}

modules["rebelot/heirline.nvim"] = {
    commit = funcs.get_commit("heirline.nvim", plugins_snapshot),
    config = ui_config.heirline_nvim,
}

modules["lvim-tech/lvim-shell"] = {
    commit = funcs.get_commit("lvim-shell", plugins_snapshot),
    config = ui_config.lvim_shell,
}

modules["lvim-tech/lvim-fm"] = {
    commit = funcs.get_commit("lvim-fm", plugins_snapshot),
    cmd = "LvimFileManager",
    keys = {
        { "<Leader>=", "<Cmd>LvimFileManager<CR>", desc = "Lvim file manager" },
    },
    dependencies = {
        "lvim-tech/lvim-shell",
    },
    config = ui_config.lvim_fm,
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

modules["lvim-tech/lvim-helper"] = {
    commit = funcs.get_commit("lvim-helper", plugins_snapshot),
    config = ui_config.lvim_helper,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- EDITOR -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("modules.base.configs.editor")

modules["vim-ctrlspace/vim-ctrlspace"] = {
    commit = funcs.get_commit("vim-ctrlspace", plugins_snapshot),
    keys = {
        { "<Leader><Leader>", "<Cmd>CtrlSpace<CR>", desc = "CtrlSpace" },
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
        { "<C-c>t", "<Cmd>Telescope tmux session<CR>", desc = "Telescope tmux session" },
    },
    dependencies = {
        "nvim-telescope/telescope-fzf-native.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        "camgraff/telescope-tmux.nvim",
    },
    config = editor_config.telescope_nvim,
}

modules["ibhagwan/fzf-lua"] = {
    commit = funcs.get_commit("fzf-lua", plugins_snapshot),
    cmd = "FzfLua",
    keys = {
        {
            "<Leader>f",
            function()
                vim.cmd("FzfLua files")
            end,
            desc = "FzfLua files",
        },
        {
            "<Leader>s",
            function()
                vim.cmd("FzfLua live_grep")
            end,
            desc = "FzfLua search",
        },
        {
            "<Leader>m",
            function()
                vim.cmd("FzfLua marks")
            end,
            desc = "FzfLua marks",
        },
        {
            "<Leader>b",
            function()
                vim.cmd("FzfLua buffers")
            end,
            desc = "FzfLua buffers",
        },
    },
    config = editor_config.fzf_lua,
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

modules["ecthelionvi/NeoComposer.nvim"] = {
    commit = funcs.get_commit("NeoComposer.nvim", plugins_snapshot),
    dependencies = { "kkharji/sqlite.lua" },
    config = editor_config.neocomposer_nvim,
}

modules["gennaro-tedesco/nvim-peekup"] = {
    commit = funcs.get_commit("nvim-peekup", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.nvim_peekup,
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
    commit = funcs.get_commit("nvim-pqf", plugins_snapshot),
    config = editor_config.nvim_pqf,
}

modules["lvim-tech/lvim-qf-loc"] = {
    commit = funcs.get_commit("lvim-qf-loc", plugins_snapshot),
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
        "lvim-tech/lvim-ui-config",
    },
    config = editor_config.lvim_qf_loc,
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

modules["lvim-tech/lvim-move"] = {
    commit = funcs.get_commit("lvim-move", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.lvim_move,
}

modules["nvim-treesitter/nvim-treesitter-context"] = {
    commit = funcs.get_commit("nvim-treesitter-context", plugins_snapshot),
    event = {
        "BufRead",
    },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = editor_config.nvim_treesitter_context,
}

modules["chrisgrieser/nvim-various-textobjs"] = {
    commit = funcs.get_commit("nvim-various-textobjs", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.nvim_various_textobjs,
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

modules["uga-rosa/ccc.nvim"] = {
    commit = funcs.get_commit("uga-rosa/ccc.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.ccc_nvim,
}

modules["folke/flash.nvim"] = {
    commit = funcs.get_commit("flash.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.flash_nvim,
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

modules["wintermute-cell/gitignore.nvim"] = {
    event = { "BufRead" },
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
}

modules["NeogitOrg/neogit"] = {
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

modules["sindrets/diffview.nvim"] = {
    commit = funcs.get_commit("diffview.nvim", plugins_snapshot),
    event = "BufRead",
    config = version_control_config.diffview_nvim,
}

modules["lvim-tech/lvim-forgit"] = {
    commit = funcs.get_commit("lvim-forgit", plugins_snapshot),
    dependencies = {
        "lvim-tech/lvim-shell",
    },
    event = "BufRead",
    config = version_control_config.lvim_forgit,
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
    keys = {
        { "<F5>", "<Cmd>UndotreeToggle<CR>", desc = "Undotree" },
    },
    cmd = "UndotreeToggle",
    config = version_control_config.undotree,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- LANGUAGES ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require("modules.base.configs.languages")

modules["folke/neoconf.nvim"] = {
    commit = funcs.get_commit("neoconf.nvim", plugins_snapshot),
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    config = languages_config.neoconf_nvim,
}

modules["williamboman/mason.nvim"] = {
    build = ":MasonUpdate",
    commit = funcs.get_commit("mason.nvim", plugins_snapshot),
    dependencies = {
        "neovim/nvim-lspconfig",
        "folke/neoconf.nvim",
    },
    config = languages_config.mason_nvim,
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

modules["folke/trouble.nvim"] = {
    commit = funcs.get_commit("trouble.nvim", plugins_snapshot),
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
        { "<C-c><C-v>", "<Cmd>TroubleToggle<CR>", desc = "Trouble" },
    },
    config = languages_config.trouble_nvim,
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
        "nvim-lua/plenary.nvim",
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
    config = languages_config.flutter_tools_nvim,
}

modules["pmizio/typescript-tools.nvim"] = {
    commit = funcs.get_commit("typescript-tools.nvim", plugins_snapshot),
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

modules["SmiteshP/nvim-navic"] = {
    commit = funcs.get_commit("nvim-navic", plugins_snapshot),
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    config = languages_config.nvim_navic,
}

modules["SmiteshP/nvim-navbuddy"] = {
    commit = funcs.get_commit("nvim-navbuddy", plugins_snapshot),
    dependencies = {
        "neovim/nvim-lspconfig",
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim",
    },
    config = languages_config.nvim_navbuddy,
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
        "BufReadPre",
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

modules["nvim-orgmode/orgmode"] = {
    commit = funcs.get_commit("orgmode", plugins_snapshot),
    ft = "org",
    dependencies = { "lvim-tech/lvim-org-utils" },
    config = languages_config.orgmode,
}

modules["lvim-tech/lvim-org-utils"] = {
    commit = funcs.get_commit("lvim-org-utils", plugins_snapshot),
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
        "hrsh7th/cmp-cmdline",
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
