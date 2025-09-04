local funcs = require("core.funcs")

local modules = {}
local plugins_snapshot = {}

local file_content = funcs.read_file(_G.LVIM_SNAPSHOT)
if file_content ~= nil then
    plugins_snapshot = file_content
end

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- DEPENDENCIES -------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local dependencies_config = require("modules.base.configs.dependencies")

modules["lvim-tech/lvim-colorscheme"] = {
    commit = funcs.get_commit("lvim-tech/lvim-colorscheme", plugins_snapshot),
    priority = 100,
    config = dependencies_config.lvim_colorscheme,
}

modules["nvim-lua/plenary.nvim"] = {
    commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
    lazy = true,
}

modules["nvim-lua/popup.nvim"] = {
    commit = funcs.get_commit("popup.nvim", plugins_snapshot),
    lazy = true,
}

modules["MunifTanjim/nui.nvim"] = {
    commit = funcs.get_commit("nui.nvim", plugins_snapshot),
    lazy = true,
    config = dependencies_config.nui_nvim,
}

modules["lvim-tech/lvim-ui-config"] = {
    commit = funcs.get_commit("lvim-ui-config", plugins_snapshot),
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    lazy = true,
}

modules["nvim-tree/nvim-web-devicons"] = {
    commit = funcs.get_commit("nvim-web-devicons", plugins_snapshot),
    config = dependencies_config.nvim_web_devicons,
    lazy = true,
}

modules["junegunn/fzf"] = {
    commit = funcs.get_commit("fzf", plugins_snapshot),
    build = function()
        vim.fn["fzf#install"]()
    end,
    lazy = true,
}

modules["nvim-treesitter/playground"] = {
    commit = funcs.get_commit("playground", plugins_snapshot),
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

modules["rafamadriz/friendly-snippets"] = {
    commit = funcs.get_commit("friendly-snippets", plugins_snapshot),
    lazy = true,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require("modules.base.configs.ui")

modules["folke/snacks.nvim"] = {
    commit = funcs.get_commit("snacks.nvim", plugins_snapshot),
    config = ui_config.snacks_nvim,
}

modules["OXY2DEV/ui.nvim"] = {
    commit = funcs.get_commit("ui.nvim", plugins_snapshot),
    config = ui_config.ui_nvim,
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

modules["nvim-mini/mini.files"] = {
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
    cmd = "MiniFiles",
    config = ui_config.mini_files,
}

modules["A7Lavinraj/fyler.nvim"] = {
    commit = funcs.get_commit("fyler.nvim", plugins_snapshot),
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        {
            "<Leader>F",
            function()
                vim.cmd("Fyler")
            end,
            desc = "Fyler",
        },
    },
    cmd = "Fyler",
    config = ui_config.fyler_nvim,
}

modules["folke/which-key.nvim"] = {
    commit = funcs.get_commit("which-key.nvim", plugins_snapshot),
    cond = function()
        return _G.LVIM_SETTINGS.keyshelper
    end,
    config = ui_config.which_key_nvim,
}

modules["nvim-mini/mini.cursorword"] = {
    commit = funcs.get_commit("mini.cursorword", plugins_snapshot),
    event = {
        "BufEnter",
    },
    config = ui_config.mini_cursorword,
}

modules["prichrd/netrw.nvim"] = {
    commit = funcs.get_commit("netrw.nvim", plugins_snapshot),
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = ui_config.netrw_nvim,
}

modules["nvim-neo-tree/neo-tree.nvim"] = {
    commit = funcs.get_commit("neo-tree.nvim", plugins_snapshot),
    cmd = "Neotree",
    keys = {
        { "<S-x>", "<cmd>Neotree toggle filesystem left<CR>", desc = "NeoTree filesystem" },
        { "<C-c><C-f>", "<cmd>Neotree toggle filesystem left<CR>", desc = "NeoTree filesystem" },
        { "<C-c><C-b>", "<cmd>Neotree toggle buffers left<CR>", desc = "NeoTree buffers" },
        { "<C-c><C-g>", "<cmd>Neotree toggle git_status left<CR>", desc = "NeoTree git" },
        { "<C-c><C-m>", "<cmd>Neotree toggle document_symbols left<CR>", desc = "NeoTree symbols" },
        { "<S-q>", "<cmd>Neotree toggle close<CR>", desc = "NeoTree close" },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = ui_config.neo_tree_nvim,
}

modules["stevearc/oil.nvim"] = {
    commit = funcs.get_commit("oil.nvim", plugins_snapshot),
    keys = {
        {
            "<Leader>I",
            function()
                vim.cmd("Oil")
            end,
            desc = "Oil",
        },
    },
    cmd = "Oil",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = ui_config.oil_nvim,
}

modules["rebelot/heirline.nvim"] = {
    commit = funcs.get_commit("heirline.nvim", plugins_snapshot),
    dependencies = {
        "tanvirtin/vgit.nvim",
        "NeogitOrg/neogit",
    },
    config = ui_config.heirline_nvim,
}

modules["lvim-tech/lvim-shell"] = {
    commit = funcs.get_commit("lvim-shell", plugins_snapshot),
    config = ui_config.lvim_shell,
}

modules["CRAG666/betterTerm.nvim"] = {
    commit = funcs.get_commit("betterTerm.nvim", plugins_snapshot),
    config = ui_config.betterTerm_nvim,
}

modules["gbprod/stay-in-place.nvim"] = {
    commit = funcs.get_commit("stay-in-place.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = ui_config.stay_in_place,
}

modules["HiPhish/rainbow-delimiters.nvim"] = {
    commit = funcs.get_commit("rainbow-delimiters.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = ui_config.rainbow_delimiters_nvim,
}

modules["lukas-reineke/indent-blankline.nvim"] = {
    commit = funcs.get_commit("indent-blankline.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = ui_config.indent_blankline_nvim,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- EDITOR -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("modules.base.configs.editor")

modules["lvim-tech/lvim-space"] = {
    dependencies = {
        "kkharji/sqlite.lua",
    },
    config = editor_config.lvim_space,
}

modules["numToStr/Navigator.nvim"] = {
    commit = funcs.get_commit("Navigator.nvim", plugins_snapshot),
    config = editor_config.navigator_nvim,
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
            "<Leader>O",
            function()
                vim.cmd("FzfLua oldfiles")
            end,
            desc = "FzfLua oldfiles",
        },
        {
            "<Leader>w",
            function()
                vim.cmd("FzfLua live_grep")
            end,
            desc = "FzfLua search",
        },
        {
            "<Leader>M",
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
        {
            "gzd",
            function()
                vim.cmd("FzfLua lsp_definitions")
            end,
            desc = "FzfLua lsp definitions",
        },
        {
            "gzD",
            function()
                vim.cmd("FzfLua lsp_declarations")
            end,
            desc = "FzfLua lsp declarations",
        },
        {
            "gzt",
            function()
                vim.cmd("FzfLua lsp_typedefs")
            end,
            desc = "FzfLua lsp type definition",
        },
        {
            "gzr",
            function()
                vim.cmd("FzfLua lsp_references")
            end,
            desc = "FzfLua lsp references",
        },
        {
            "gzi",
            function()
                vim.cmd("FzfLua lsp_implementations")
            end,
            desc = "FzfLua lsp implementations",
        },
        {
            "gzf",
            function()
                vim.cmd("FzfLua lsp_finder")
            end,
            desc = "FzfLua lsp finder",
        },
        {
            "gzw",
            function()
                vim.cmd("FzfLua lsp_document_diagnostics")
            end,
            desc = "FzfLua lsp document diagnostics",
        },
        {
            "gzW",
            function()
                vim.cmd("FzfLua lsp_workspace_diagnostics")
            end,
            desc = "FzfLua lsp workspace diagnostics",
        },
        {
            "gzs",
            function()
                vim.cmd("FzfLua lsp_document_symbols")
            end,
            desc = "FzfLua lsp document symbols",
        },
        {
            "gzS",
            function()
                vim.cmd("FzfLua lsp_workspace_symbols")
            end,
            desc = "FzfLua lsp workspace symbols",
        },
    },
    config = editor_config.fzf_lua,
}

modules["lvim-tech/lvim-linguistics"] = {
    commit = funcs.get_commit("lvim-linguistics", plugins_snapshot),
    dependencies = {
        "MunifTanjim/nui.nvim",
        "lvim-tech/lvim-ui-config",
    },
    config = editor_config.lvim_linguistics,
}

modules["mangelozzi/rgflow.nvim"] = {
    commit = funcs.get_commit("rgflow.nvim", plugins_snapshot),
    keys = {
        {
            "<Leader>rG",
            function()
                require("rgflow").open()
            end,
            desc = "Rgflow open blank",
        },
        {
            "<Leader>rg",
            function()
                require("rgflow").open_cword()
            end,
            desc = "Rgflow open cword",
        },
        {
            "<Leader>rp",
            function()
                require("rgflow").open_cword()
            end,
            desc = "Rgflow open and paste",
        },
        {
            "<Leader>ra",
            function()
                require("rgflow").open_again()
            end,
            desc = "Rgflow open again",
        },
        {
            "<Leader>rx",
            function()
                require("rgflow").abort()
            end,
            desc = "Rgflow abort",
        },
        {
            "<Leader>rc",
            function()
                require("rgflow").print_cmd()
            end,
            desc = "Rgflow print cmd",
        },
        {
            "<Leader>r?",
            function()
                require("rgflow").print_status()
            end,
            desc = "Rgflow print status",
        },
        {
            "<Leader>rg",
            function()
                require("rgflow").open_visual()
            end,
            mode = "x",
            desc = "Rgflow open visual",
        },
    },
    config = editor_config.rgflow_nvim,
}

modules["gcmt/vessel.nvim"] = {
    commit = funcs.get_commit("vessel.nvim", plugins_snapshot),
    config = editor_config.vessel_nvim,
}

modules["sahilsehwag/macrobank.nvim"] = {
    commit = funcs.get_commit("macrobank.nvim", plugins_snapshot),
    config = editor_config.macrobank_nvim,
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

modules["stevearc/quicker.nvim"] = {
    event = "FileType qf",
    config = editor_config.quicker_nvim,
}

modules["lvim-tech/lvim-qf-loc"] = {
    commit = funcs.get_commit("lvim-qf-loc", plugins_snapshot),
    dependencies = {
        "MunifTanjim/nui.nvim",
        "lvim-tech/lvim-ui-config",
    },
    config = editor_config.lvim_qf_loc,
}

modules["nanozuki/tabby.nvim"] = {
    commit = funcs.get_commit("tabby.nvim", plugins_snapshot),
    dependencies = {
        "lvim-tech/lvim-space",
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

modules["mistweaverco/kulala.nvim"] = {
    commit = funcs.get_commit("kulala.nvim", plugins_snapshot),
    ft = { "http", "rest" },
    config = editor_config.kulala_nvim,
}

modules["arjunmahishi/flow.nvim"] = {
    commit = funcs.get_commit("flow.nvim", plugins_snapshot),
    keys = {
        {
            "<Leader>lls",
            ":FlowRunSelected<CR>",
            mode = "x",
            desc = "Flow run selected",
        },
        {
            "<Leader>llf",
            ":FlowRunFile<CR>",
            desc = "Flow run file",
        },
        {
            "<Leader>lll",
            ":FlowLauncher<CR>",
            desc = "Flow launcher",
        },
    },
    config = editor_config.flow_nvim,
}

modules["coffebar/transfer.nvim"] = {
    commit = funcs.get_commit("transfer.nvim", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        {
            "<Leader>ti",
            "<cmd>TransferInit<cr>",
            desc = "Transfer Init",
        },
        {
            "<Leader>tf",
            "<cmd>DiffRemote<cr>",
            desc = "Diff Remote",
        },
        {
            "<Leader>tF",
            "<cmd>TransferDirDiff<cr>",
            desc = "Transfer Dir Diff",
        },
        {
            "<Leader>tu",
            "<cmd>TransferUpload<cr>",
            desc = "Transfer Upload",
        },
        {
            "<Leader>td",
            "<cmd>TransferDownload<cr>",
            desc = "Transfer Download",
        },
        {
            "<Leader>tr",
            "<cmd>TransferDownload<cr>",
            desc = "Transfer Download",
        },
    },
    cmd = {
        "TransferInit",
        "DiffRemote",
        "TransferUpload",
        "TransferDownload",
        "TransferDirDiff",
        "TransferRepeat",
    },
    config = editor_config.transfer_nvim,
}

modules["CRAG666/code_runner.nvim"] = {
    commit = funcs.get_commit("code_runner.nvim", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        {
            "<Leader>lcp",
            ":RunProject<CR>",
            desc = "Run project",
        },
        {
            "<Leader>lcf",
            ":RunFile<CR>",
            desc = "Run file",
        },
        {
            "<Leader>lcc",
            ":RunCode<CR>",
            desc = "Run code",
        },
    },
    config = editor_config.code_runner_nvim,
}

modules["MagicDuck/grug-far.nvim"] = {
    commit = funcs.get_commit("grug-far.nvim", plugins_snapshot),
    keys = {
        {
            "<A-s>",
            ":GrugFar<CR>",
            desc = "GrugFar",
        },
    },
    config = editor_config.grug_far,
}

modules["gabrielpoca/replacer.nvim"] = {
    commit = funcs.get_commit("replacer.nvim", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.replacer_nvim,
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

modules["brenoprata10/nvim-highlight-colors"] = {
    commit = funcs.get_commit("brenoprata10/nvim-highlight-colors", plugins_snapshot),
    event = {
        "BufRead",
    },
    config = editor_config.nvim_highlight_colors,
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
}

modules["NeogitOrg/neogit"] = {
    commit = funcs.get_commit("neogit", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
        "ibhagwan/fzf-lua",
    },
    keys = {
        { "<Leader>gn", "<Cmd>Neogit<CR>", desc = "Neogit" },
    },
    config = version_control_config.neogit,
}

modules["tanvirtin/vgit.nvim"] = {
    commit = funcs.get_commit("vgit.nvim", plugins_snapshot),
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    event = "VimEnter",
    config = version_control_config.vgit,
}

modules["sindrets/diffview.nvim"] = {
    commit = funcs.get_commit("diffview.nvim", plugins_snapshot),
    event = "BufRead",
    config = version_control_config.diffview_nvim,
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

modules["mason-org/mason.nvim"] = {
    build = ":MasonUpdate",
    commit = funcs.get_commit("mason.nvim", plugins_snapshot),
    config = languages_config.mason_nvim,
}

modules["nvim-neotest/neotest"] = {
    commit = funcs.get_commit("neotest", plugins_snapshot),
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "olimorris/neotest-phpunit",
        "rouge8/neotest-rust",
        "nvim-neotest/neotest-go",
        "nvim-neotest/neotest-python",
        "jfpedroza/neotest-elixir",
        "sidlatau/neotest-dart",
        "nvim-neotest/neotest-plenary",
    },
    config = languages_config.neotest,
}

modules["chrisgrieser/nvim-rip-substitute"] = {
    cmd = "RipSubstitute",
    keys = {
        {
            "<leader>rr",
            function()
                require("rip-substitute").sub()
            end,
            mode = { "n", "x" },
            desc = "Rip substitute",
        },
    },
    config = languages_config.nvim_rip_substitute,
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
        { "<C-c><C-v>", "<Cmd>Trouble diagnostics<CR>", desc = "Trouble" },
    },
    config = languages_config.trouble_nvim,
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

modules["akinsho/flutter-tools.nvim"] = {
    commit = funcs.get_commit("flutter-tools.nvim", plugins_snapshot),
    ft = "dart",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = languages_config.flutter_tools_nvim,
}

modules["jsongerber/nvim-px-to-rem"] = {
    commit = funcs.get_commit("nvim-px-to-rem", plugins_snapshot),
    ft = {
        "css",
        "scss",
        "less",
        "astro",
    },
    keys = {
        {
            "<Leader>pxx",
            "<cmd>PxToRemCursor<cr>",
            desc = "Px to Rem cursor",
        },
        {
            "<Leader>pxl",
            "<cmd>PxToRemLine<cr>",
            desc = "Px to Rem line",
        },
    },
    config = languages_config.nvim_px_to_rem,
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

modules["j-hui/fidget.nvim"] = {
    commit = funcs.get_commit("fidget.nvim", plugins_snapshot),
    config = languages_config.fidget_nvim,
}

modules["SmiteshP/nvim-navic"] = {
    commit = funcs.get_commit("nvim-navic", plugins_snapshot),
    config = languages_config.nvim_navic,
}

modules["SmiteshP/nvim-navbuddy"] = {
    commit = funcs.get_commit("nvim-navbuddy", plugins_snapshot),
    dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim",
    },
    config = languages_config.nvim_navbuddy,
}

modules["bassamsdata/namu.nvim"] = {
    commit = funcs.get_commit("namu.nvim", plugins_snapshot),
    keys = {
        {
            "<Leader>on",
            function()
                local namu = require("namu.namu_symbols")
                namu.show()
            end,
            desc = "Namu symbols",
        },
    },
    config = languages_config.namu_nvim,
}

modules["hedyhli/outline.nvim"] = {
    commit = funcs.get_commit("outline.nvim", plugins_snapshot),
    keys = {
        {
            "<Leader>oo",
            function()
                vim.cmd("Outline")
            end,
            desc = "Outline",
        },
    },
    config = languages_config.outline_nvim,
}

modules["mfussenegger/nvim-dap"] = {
    commit = funcs.get_commit("nvim-dap", plugins_snapshot),
    event = {
        "BufReadPre",
    },
    dependencies = {
        "igorlfs/nvim-dap-view",
        "jbyuki/one-small-step-for-vimkind",
        "mxsdev/nvim-dap-vscode-js",
    },
    config = languages_config.nvim_dap,
}

modules["lvim-tech/vim-dadbod-ui"] = {
    dependencies = {
        "tpope/vim-dadbod",
        "kristijanhusak/vim-dadbod-completion",
        "pbogut/vim-dadbod-ssh",
    },
    cmd = {
        "DBUIToggle",
        "DBUIAddConnection",
        "DBUI",
        "DBUIFindBuffer",
        "DBUIRenameBuffer",
    },
    keys = {
        {
            "<Leader>dd",
            "<cmd>DBUIToggle<cr>",
            desc = "Dadbod toggle",
        },
    },
    init = languages_config.vim_dadbod_ui,
}

modules["lvim-tech/nvim-dbee"] = {
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "Dbee",
    keys = {
        {
            "<Leader>do",
            "<cmd>Dbee open<cr>",
            desc = "Dbee open",
        },
        {
            "<Leader>dc",
            "<cmd>Dbee close<cr>",
            desc = "Dbee close",
        },
    },
    build = function()
        require("dbee").install()
    end,
    config = languages_config.nvim_dbee,
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

modules["dhruvasagar/vim-table-mode"] = {
    commit = funcs.get_commit("dhruvasagar/vim-table-mode", plugins_snapshot),
    ft = { "markdown", "text" },
}

modules["iamcco/markdown-preview.nvim"] = {
    commit = funcs.get_commit("markdown-preview.nvim", plugins_snapshot),
    build = "cd app && npm install",
    ft = { "md", "markdown" },
    config = languages_config.markdown_preview_nvim,
}

modules["OXY2DEV/markview.nvim"] = {
    commit = funcs.get_commit("markview-nvim", plugins_snapshot),
    ft = { "md", "markdown", "Avante" },
    config = languages_config.markview_nvim,
}

modules["OXY2DEV/helpview.nvim"] = {
    commit = funcs.get_commit("markview-nvim", plugins_snapshot),
    config = languages_config.helpview_nvim,
}

modules["lervag/vimtex"] = {
    commit = funcs.get_commit("vimtex", plugins_snapshot),
    config = languages_config.vimtex,
}

modules["nvim-orgmode/orgmode"] = {
    commit = funcs.get_commit("orgmode", plugins_snapshot),
    ft = "org",
    -- dependencies = { "lvim-tech/lvim-org-utils" },
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

modules["Saghen/blink.cmp"] = {
    commit = funcs.get_commit("blink.cmp", plugins_snapshot),
    dependencies = {
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
        "niuiic/blink-cmp-rg.nvim",
        "xzbdmw/colorful-menu.nvim",
        "moyiz/blink-emoji.nvim",
    },
    build = "cargo build --release",
    config = completion_config.blink_cmp,
}

modules["L3MON4D3/LuaSnip"] = {
    commit = funcs.get_commit("LuaSnip", plugins_snapshot),
    dependencies = {
        "rafamadriz/friendly-snippets",
    },
    build = "make install_jsregexp",
    config = completion_config.lua_snippets,
}

modules["windwp/nvim-autopairs"] = {
    commit = funcs.get_commit("nvim-autopairs", plugins_snapshot),
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = completion_config.nvim_autopairs,
}

modules["windwp/nvim-ts-autotag"] = {
    commit = funcs.get_commit("nvim-ts-autotag", plugins_snapshot),
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
