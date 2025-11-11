local funcs = require("core.funcs")

local modules = {}
local plugins_snapshot = {}

local file_content = funcs.read_file(_G.global.lvim_path .. "/.snapshots/" .. _G.LVIM_SNAPSHOT)
if file_content ~= nil then
    plugins_snapshot = file_content
end

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- DEPENDENCIES -------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local dependencies_config = require("modules.base.configs.dependencies")

modules["lvim-tech/lvim-colorscheme"] = {
    commit = funcs.get_commit("lvim-colorscheme", plugins_snapshot),
    priority = 100,
    opts = dependencies_config.lvim_colorscheme.opts,
}

modules["nvim-lua/plenary.nvim"] = {
    commit = funcs.get_commit("plenary.nvim", plugins_snapshot),
    lazy = true,
}

modules["nvim-lua/popup.nvim"] = {
    commit = funcs.get_commit("popup.nvim", plugins_snapshot),
    lazy = true,
}

modules["nvim-tree/nvim-web-devicons"] = {
    commit = funcs.get_commit("nvim-web-devicons", plugins_snapshot),
    lazy = true,
    opts = dependencies_config.nvim_web_devicons.opts,
}

modules["MunifTanjim/nui.nvim"] = {
    commit = funcs.get_commit("nui.nvim", plugins_snapshot),
    lazy = true,
    config = dependencies_config.nui_nvim.config,
}

modules["junegunn/fzf"] = {
    commit = funcs.get_commit("fzf", plugins_snapshot),
    build = function()
        vim.fn["fzf#install"]()
    end,
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

modules["L3MON4D3/LuaSnip"] = {
    commit = funcs.get_commit("LuaSnip", plugins_snapshot),
    build = "make install_jsregexp",
    lazy = true,
}

modules["niuiic/blink-cmp-rg.nvim"] = {
    commit = funcs.get_commit("blink-cmp-rg", plugins_snapshot),
    lazy = true,
}

modules["moyiz/blink-emoji.nvim"] = {
    commit = funcs.get_commit("blink-emoji", plugins_snapshot),
    lazy = true,
}

modules["xzbdmw/colorful-menu.nvim"] = {
    commit = funcs.get_commit("colorful-menu.nvim", plugins_snapshot),
    lazy = true,
}

modules["kkharji/sqlite.lua"] = {
    commit = funcs.get_commit("sqlite.lua", plugins_snapshot),
    lazy = false,
}

modules["nvim-neotest/nvim-nio"] = {
    commit = funcs.get_commit("nvim-nio", plugins_snapshot),
    lazy = true,
}

modules["nvim-neotest/neotest-plenary"] = {
    commit = funcs.get_commit("neotest-plenary", plugins_snapshot),
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

modules["jfpedroza/neotest-elixir"] = {
    commit = funcs.get_commit("neotest-elixir", plugins_snapshot),
    lazy = true,
}

modules["sidlatau/neotest-dart"] = {
    commit = funcs.get_commit("neotest-dart", plugins_snapshot),
    lazy = true,
}

modules["igorlfs/nvim-dap-view"] = {
    commit = funcs.get_commit("nvim-dap-view", plugins_snapshot),
    lazy = true,
}

modules["jbyuki/one-small-step-for-vimkind"] = {
    commit = funcs.get_commit("one-small-step-for-vimkind", plugins_snapshot),
    lazy = true,
}

modules["mxsdev/nvim-dap-vscode-js"] = {
    commit = funcs.get_commit("nvim-dap-vscode-js", plugins_snapshot),
    lazy = true,
}

modules["tpope/vim-dadbod"] = {
    commit = funcs.get_commit("vim-dadbod", plugins_snapshot),
}

modules["kristijanhusak/vim-dadbod-completion"] = {
    commit = funcs.get_commit("vim-dadbod-completion", plugins_snapshot),
    lazy = true,
}

modules["pbogut/vim-dadbod-ssh"] = {
    commit = funcs.get_commit("vim-dadbod-ssh", plugins_snapshot),
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require("modules.base.configs.ui")

modules["folke/snacks.nvim"] = {
    commit = funcs.get_commit("snacks.nvim", plugins_snapshot),
    opts = ui_config.snacks_nvim.opts,
}

modules["OXY2DEV/ui.nvim"] = {
    commit = funcs.get_commit("ui.nvim", plugins_snapshot),
    event = "VimEnter",
    opts = ui_config.ui_nvim.opts,
}

modules["s1n7ax/nvim-window-picker"] = {
    commit = funcs.get_commit("nvim-window-picker", plugins_snapshot),
    cmd = ui_config.nvim_window_picker.cmd,
    keys = ui_config.nvim_window_picker.keys,
    opts = ui_config.nvim_window_picker.opts,
}

modules["sindrets/winshift.nvim"] = {
    commit = funcs.get_commit("winshift.nvim", plugins_snapshot),
    cmd = ui_config.winshift_nvim.cmd,
    keys = ui_config.winshift_nvim.keys,
    opts = ui_config.winshift_nvim.opts,
}

modules["nvim-mini/mini.files"] = {
    commit = funcs.get_commit("mini.files", plugins_snapshot),
    cmd = ui_config.mini_files.cmd,
    keys = ui_config.mini_files.keys,
    opts = ui_config.mini_files.opts,
}

modules["A7Lavinraj/fyler.nvim"] = {
    commit = funcs.get_commit("fyler.nvim", plugins_snapshot),
    cmd = ui_config.fyler_nvim.cmd,
    keys = ui_config.fyler_nvim.keys,
    opts = ui_config.fyler_nvim.opts,
}

modules["folke/which-key.nvim"] = {
    commit = funcs.get_commit("which-key.nvim", plugins_snapshot),
    cond = function()
        return _G.LVIM_KEYSHELPER
    end,
    config = ui_config.which_key_nvim.config,
}

modules["prichrd/netrw.nvim"] = {
    commit = funcs.get_commit("netrw.nvim", plugins_snapshot),
    opts = ui_config.netrw_nvim.opts,
}

modules["nvim-neo-tree/neo-tree.nvim"] = {
    commit = funcs.get_commit("neo-tree.nvim", plugins_snapshot),
    cmd = ui_config.neo_tree_nvim.cmd,
    keys = ui_config.neo_tree_nvim.keys,
    opts = ui_config.neo_tree_nvim.opts,
}

modules["stevearc/oil.nvim"] = {
    commit = funcs.get_commit("oil.nvim", plugins_snapshot),
    cmd = ui_config.oil_nvim.cmd,
    keys = ui_config.oil_nvim.keys,
    opts = ui_config.oil_nvim.opts,
}

modules["rebelot/heirline.nvim"] = {
    commit = funcs.get_commit("heirline.nvim", plugins_snapshot),
    opts = ui_config.heirline_nvim.opts,
    config = ui_config.heirline_nvim.config,
}

modules["lvim-tech/lvim-shell"] = {
    commit = funcs.get_commit("lvim-shell", plugins_snapshot),
    config = ui_config.lvim_shell.config,
}

modules["CRAG666/betterTerm.nvim"] = {
    commit = funcs.get_commit("betterTerm.nvim", plugins_snapshot),
    opts = ui_config.better_term_nvim.opts,
}

modules["gbprod/stay-in-place.nvim"] = {
    commit = funcs.get_commit("stay-in-place.nvim", plugins_snapshot),
    opts = ui_config.stay_in_place_nvim.opts,
}

modules["HiPhish/rainbow-delimiters.nvim"] = {
    commit = funcs.get_commit("rainbow-delimiters.nvim", plugins_snapshot),
    config = ui_config.rainbow_delimiters_nvim.config,
}

modules["lukas-reineke/indent-blankline.nvim"] = {
    commit = funcs.get_commit("indent-blankline.nvim", plugins_snapshot),
    config = ui_config.indent_blankline_nvim.config,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- EDITOR -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("modules.base.configs.editor")

modules["lvim-tech/lvim-space"] = {
    commit = funcs.get_commit("lvim-space", plugins_snapshot),
    opts = editor_config.lvim_space.opts,
}

modules["lvim-tech/lvim-control-center"] = {
    commit = funcs.get_commit("lvim-control-center", plugins_snapshot),
    opts = editor_config.lvim_control_center.opts,
}

modules["numToStr/Navigator.nvim"] = {
    commit = funcs.get_commit("Navigator.nvim", plugins_snapshot),
    cmd = editor_config.navigator_nvim.cmd,
    keys = editor_config.navigator_nvim.keys,
    opts = editor_config.navigator_nvim.opts,
}

modules["ibhagwan/fzf-lua"] = {
    commit = funcs.get_commit("fzf-lua", plugins_snapshot),
    cmd = editor_config.fzf_lua.cmd,
    keys = editor_config.fzf_lua.keys,
    opts = editor_config.fzf_lua.opts,
}

modules["lvim-tech/lvim-linguistics"] = {
    commit = funcs.get_commit("lvim-linguistics", plugins_snapshot),
    opts = editor_config.lvim_linguistics.opts,
}

modules["mangelozzi/rgflow.nvim"] = {
    commit = funcs.get_commit("rgflow.nvim", plugins_snapshot),
    keys = editor_config.rgflow_nvim.keys,
    opts = editor_config.rgflow_nvim.opts,
}

modules["gcmt/vessel.nvim"] = {
    commit = funcs.get_commit("vessel.nvim", plugins_snapshot),
    opts = editor_config.vessel_nvim.opts,
}

modules["sahilsehwag/macrobank.nvim"] = {
    commit = funcs.get_commit("macrobank.nvim", plugins_snapshot),
    cmd = editor_config.macrobank_nvim.cmd,
    keys = editor_config.macrobank_nvim.keys,
    opts = editor_config.macrobank_nvim.opts,
}

modules["kevinhwang91/nvim-hlslens"] = {
    commit = funcs.get_commit("nvim-hlslens", plugins_snapshot),
    opts = editor_config.nvim_hlslens.opts,
}

modules["kevinhwang91/nvim-bqf"] = {
    commit = funcs.get_commit("nvim-bqf", plugins_snapshot),
    opts = editor_config.nvim_bqf.opts,
}

modules["stevearc/quicker.nvim"] = {
    commit = funcs.get_commit("quicker.nvim", plugins_snapshot),
    event = "FileType qf",
    opts = editor_config.quicker_nvim.opts,
}

modules["lvim-tech/lvim-qf-loc"] = {
    commit = funcs.get_commit("lvim-qf-loc", plugins_snapshot),
    cmd = editor_config.lvim_qf_loc.cmd,
    keys = editor_config.lvim_qf_loc.keys,
    opts = editor_config.lvim_qf_loc.opts,
}

modules["nanozuki/tabby.nvim"] = {
    commit = funcs.get_commit("tabby.nvim", plugins_snapshot),
    opts = editor_config.tabby_nvim.opts,
}

modules["monaqa/dial.nvim"] = {
    commit = funcs.get_commit("dial.nvim", plugins_snapshot),
    keys = editor_config.dial_nvim.keys,
    config = editor_config.dial_nvim.config,
}

modules["lvim-tech/lvim-move"] = {
    commit = funcs.get_commit("lvim-move", plugins_snapshot),
    opts = editor_config.lvim_move.opts,
}

modules["nvim-treesitter/nvim-treesitter-context"] = {
    commit = funcs.get_commit("nvim-treesitter-context", plugins_snapshot),
    opts = editor_config.nvim_treesitter_context.opts,
}

modules["mistweaverco/kulala.nvim"] = {
    commit = funcs.get_commit("kulala.nvim", plugins_snapshot),
    ft = { "http", "rest" },
    opts = editor_config.kulala_nvim.opts,
}

modules["arjunmahishi/flow.nvim"] = {
    commit = funcs.get_commit("flow.nvim", plugins_snapshot),
    cmd = editor_config.flow_nvim.cmd,
    keys = editor_config.flow_nvim.keys,
    opts = editor_config.flow_nvim.opts,
}

modules["coffebar/transfer.nvim"] = {
    commit = funcs.get_commit("transfer.nvim", plugins_snapshot),
    cmd = editor_config.transfer_nvim.cmd,
    keys = editor_config.transfer_nvim.keys,
    opts = editor_config.transfer_nvim.opts,
}

modules["ALameLlama/compiler.nvim"] = {
    commit = funcs.get_commit("compiler.nvim", plugins_snapshot),
    branch = "feat/add-support-for-native-nvim-selector",
    cmd = editor_config.compiler_nvim.cmd,
    keys = editor_config.compiler_nvim.keys,
    opts = editor_config.compiler_nvim.opts,
}

modules["stevearc/overseer.nvim"] = {
    commit = funcs.get_commit("overseer.nvim", plugins_snapshot),
    branch = "stevearc-rewrite",
    cmd = editor_config.overseer_nvim.cmd,
    keys = editor_config.overseer_nvim.keys,
    opts = editor_config.overseer_nvim.opts,
}

modules["MagicDuck/grug-far.nvim"] = {
    commit = funcs.get_commit("grug-far.nvim", plugins_snapshot),
    cmd = editor_config.grug_far_nvim.cmd,
    keys = editor_config.grug_far_nvim.keys,
    opts = editor_config.grug_far_nvim.opts,
}

modules["gabrielpoca/replacer.nvim"] = {
    commit = funcs.get_commit("replacer.nvim", plugins_snapshot),
    cmd = editor_config.replacer_nvim.cmd,
    keys = editor_config.replacer_nvim.keys,
    opts = editor_config.replacer_nvim.opts,
}

modules["numToStr/Comment.nvim"] = {
    commit = funcs.get_commit("Comment.nvim", plugins_snapshot),
    opts = editor_config.comment_nvim.opts,
}

modules["ton/vim-bufsurf"] = {
    commit = funcs.get_commit("vim-bufsurf", plugins_snapshot),
    cmd = editor_config.vim_bufsurf.cmd,
    keys = editor_config.vim_bufsurf.keys,
    opts = editor_config.vim_bufsurf.opts,
}

modules["danymat/neogen"] = {
    commit = funcs.get_commit("neogen", plugins_snapshot),
    cmd = editor_config.neogen.cmd,
    opts = editor_config.neogen.opts,
}

modules["uga-rosa/ccc.nvim"] = {
    commit = funcs.get_commit("uga-rosa/ccc.nvim", plugins_snapshot),
    cmd = editor_config.ccc_nvim.cmd,
    keys = editor_config.ccc_nvim.keys,
    opts = editor_config.ccc_nvim.opts,
}

modules["brenoprata10/nvim-highlight-colors"] = {
    commit = funcs.get_commit("brenoprata10/nvim-highlight-colors", plugins_snapshot),
    opts = editor_config.nvim_highlight_colors.opts,
}

modules["folke/flash.nvim"] = {
    commit = funcs.get_commit("flash.nvim", plugins_snapshot),
    keys = editor_config.flash_nvim.keys,
    opts = editor_config.flash_nvim.opts,
}

modules["folke/todo-comments.nvim"] = {
    commit = funcs.get_commit("todo-comments.nvim", plugins_snapshot),
    cmd = editor_config.todo_comments_nvim.cmd,
    opts = editor_config.todo_comments_nvim.opts,
}

modules["renerocksai/calendar-vim"] = {
    commit = funcs.get_commit("calendar-vim", plugins_snapshot),
    cmd = editor_config.calendar_vim.cmd,
    keys = editor_config.calendar_vim.keys,
    config = editor_config.calendar_vim.config,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- VERSION CONTROL ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local version_control_config = require("modules.base.configs.version_control")

modules["wintermute-cell/gitignore.nvim"] = {
    commit = funcs.get_commit("gitignore.nvim", plugins_snapshot),
}

modules["NeogitOrg/neogit"] = {
    commit = funcs.get_commit("neogit", plugins_snapshot),
    cmd = version_control_config.neogit.cmd,
    keys = version_control_config.neogit.keys,
    opts = version_control_config.neogit.opts,
}

modules["lvim-tech/mini.diff"] = {
    commit = funcs.get_commit("mini.diff", plugins_snapshot),
    opts = version_control_config.mini_diff.opts,
}

modules["tanvirtin/vgit.nvim"] = {
    commit = funcs.get_commit("vgit.nvim", plugins_snapshot),
    opts = version_control_config.vgit.opts,
}

modules["sindrets/diffview.nvim"] = {
    commit = funcs.get_commit("diffview.nvim", plugins_snapshot),
    cmd = version_control_config.diffview_nvim.cmd,
    keys = version_control_config.diffview_nvim.keys,
    opts = version_control_config.diffview_nvim.opts,
}

modules["y3owk1n/time-machine.nvim"] = {
    commit = funcs.get_commit("time-machine", plugins_snapshot),
    cmd = version_control_config.time_machine_nvim.cmd,
    keys = version_control_config.time_machine_nvim.keys,
    opts = version_control_config.time_machine_nvim.opts,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- LANGUAGES ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require("modules.base.configs.languages")

modules["mason-org/mason.nvim"] = {
    commit = funcs.get_commit("mason.nvim", plugins_snapshot),
    build = ":MasonUpdate",
    opts = languages_config.mason.opts,
}

modules["nvim-neotest/neotest"] = {
    commit = funcs.get_commit("neotest", plugins_snapshot),
    cmd = languages_config.neotest.cmd,
    keys = languages_config.neotest.keys,
    opts = languages_config.neotest.opts,
}

modules["chrisgrieser/nvim-rip-substitute"] = {
    commit = funcs.get_commit("nvim-rip-substitute", plugins_snapshot),
    cmd = languages_config.nvim_rip_substitute.cmd,
    keys = languages_config.nvim_rip_substitute.keys,
    opts = languages_config.nvim_rip_substitute.opts,
}

modules["DNLHC/glance.nvim"] = {
    commit = funcs.get_commit("glance.nvim", plugins_snapshot),
    keys = languages_config.glance_nvim.keys,
    opts = languages_config.glance_nvim.opts,
}

modules["folke/trouble.nvim"] = {
    commit = funcs.get_commit("trouble.nvim", plugins_snapshot),
    cmd = languages_config.trouble_nvim.cmd,
    keys = languages_config.trouble_nvim.keys,
    opts = languages_config.trouble_nvim.opts,
}

modules["mfussenegger/nvim-jdtls"] = {
    commit = funcs.get_commit("nvim-jdtls", plugins_snapshot),
    ft = "java",
}

modules["scalameta/nvim-metals"] = {
    commit = funcs.get_commit("nvim-metals", plugins_snapshot),
    ft = { "scala", "sbt" },
}

modules["akinsho/flutter-tools.nvim"] = {
    commit = funcs.get_commit("flutter-tools.nvim", plugins_snapshot),
    ft = "dart",
    opts = languages_config.flutter_tools_nvim.opts,
}

modules["jsongerber/nvim-px-to-rem"] = {
    commit = funcs.get_commit("nvim-px-to-rem", plugins_snapshot),
    ft = {
        "css",
        "scss",
        "less",
        "astro",
    },
    cmd = languages_config.nvim_px_to_rem.cmd,
    keys = languages_config.nvim_px_to_rem.keys,
    opts = languages_config.nvim_px_to_rem.opts,
}

modules["kosayoda/nvim-lightbulb"] = {
    commit = funcs.get_commit("nvim-lightbulb", plugins_snapshot),
    opts = languages_config.nvim_lightbulb.opts,
}

modules["nvim-treesitter/nvim-treesitter"] = {
    commit = funcs.get_commit("nvim-treesitter", plugins_snapshot),
    branch = "main",
    build = ":TSUpdate",
    opts = languages_config.nvim_treesitter.opts,
}

modules["j-hui/fidget.nvim"] = {
    commit = funcs.get_commit("fidget.nvim", plugins_snapshot),
    opts = languages_config.fidget_nvim.opts,
}

modules["SmiteshP/nvim-navic"] = {
    commit = funcs.get_commit("nvim-navic", plugins_snapshot),
    opts = languages_config.nvim_navic.opts,
}

modules["hedyhli/outline.nvim"] = {
    commit = funcs.get_commit("outline.nvim", plugins_snapshot),
    cmd = languages_config.outline.cmd,
    keys = languages_config.outline.keys,
    opts = languages_config.outline.opts,
}

modules["mfussenegger/nvim-dap"] = {
    commit = funcs.get_commit("nvim-dap", plugins_snapshot),
    cmd = languages_config.nvim_dap.cmd,
    keys = languages_config.nvim_dap.keys,
    config = languages_config.nvim_dap.config,
}

modules["lvim-tech/vim-dadbod-ui"] = {
    commit = funcs.get_commit("vim-dadbod-ui", plugins_snapshot),
    cmd = languages_config.vim_dadbod_ui.cmd,
    keys = languages_config.vim_dadbod_ui.keys,
    init = languages_config.vim_dadbod_ui.init,
}

modules["lvim-tech/nvim-dbee"] = {
    commit = funcs.get_commit("nvim-dbee", plugins_snapshot),
    build = function()
        require("dbee").install()
    end,
    cmd = languages_config.nvim_dbee.cmd,
    keys = languages_config.nvim_dbee.keys,
    opts = languages_config.nvim_dbee.opts,
}

modules["vuki656/package-info.nvim"] = {
    commit = funcs.get_commit("package-info.nvim", plugins_snapshot),
    event = "BufReadPost package.json",
    opts = languages_config.package_info_nvim.opts,
}

modules["Saecki/crates.nvim"] = {
    commit = funcs.get_commit("crates.nvim", plugins_snapshot),
    event = "BufReadPost Cargo.toml",
    opts = languages_config.crates_nvim.opts,
}

modules["akinsho/pubspec-assist.nvim"] = {
    commit = funcs.get_commit("pubspec-assist.nvim", plugins_snapshot),
    event = "BufReadPost pubspec.yaml",
    opts = languages_config.pubspec_assist_nvim.opts,
}

modules["dhruvasagar/vim-table-mode"] = {
    commit = funcs.get_commit("dhruvasagar/vim-table-mode", plugins_snapshot),
    ft = { "markdown", "text" },
}

modules["iamcco/markdown-preview.nvim"] = {
    commit = funcs.get_commit("markdown-preview.nvim", plugins_snapshot),
    build = "cd app && npm install",
    ft = { "md", "markdown" },
    cmd = languages_config.markdown_preview_nvim.cmd,
    keys = languages_config.markdown_preview_nvim.keys,
}

modules["OXY2DEV/markview.nvim"] = {
    commit = funcs.get_commit("markview-nvim", plugins_snapshot),
    ft = { "md", "markdown", "Avante" },
    opts = languages_config.markview_nvim.opts,
}

modules["OXY2DEV/helpview.nvim"] = {
    commit = funcs.get_commit("markview-nvim", plugins_snapshot),
    opts = languages_config.helpview_nvim.opts,
}

modules["lervag/vimtex"] = {
    commit = funcs.get_commit("vimtex", plugins_snapshot),
    config = languages_config.vimtex.config,
}

modules["nvim-orgmode/orgmode"] = {
    commit = funcs.get_commit("orgmode", plugins_snapshot),
    ft = "org",
    opts = languages_config.orgmode.opts,
}

-- modules["lvim-tech/lvim-org-utils"] = {
--     commit = funcs.get_commit("lvim-org-utils", plugins_snapshot),
--     opts = languages_config.lvim_org_utils.opts,
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- COMPLETION ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require("modules.base.configs.completion")

modules["Saghen/blink.cmp"] = {
    commit = funcs.get_commit("blink.cmp", plugins_snapshot),
    lazy = true,
    build = "cargo build --release",
    opts = completion_config.blink_cmp.opts,
}

modules["windwp/nvim-autopairs"] = {
    commit = funcs.get_commit("nvim-autopairs", plugins_snapshot),
    opts = completion_config.nvim_autopairs.opts,
}

modules["windwp/nvim-ts-autotag"] = {
    commit = funcs.get_commit("nvim-ts-autotag", plugins_snapshot),
    opts = completion_config.nvim_ts_autotag.opts,
}

modules["kylechui/nvim-surround"] = {
    commit = funcs.get_commit("nvim-surround", plugins_snapshot),
    opts = completion_config.nvim_surround.opts,
}

return modules
