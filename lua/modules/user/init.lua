local modules = {}

modules["lvim-tech/lvim-kbrd"] = {
    config = function()
        require("lvim-kbrd").setup()
        vim.api.nvim_set_keymap("n", "<C-c>l", ":LvimKbrdToggle<CR>", {})
    end,
}

modules["nvim-treesitter/playground"] = {
    cmd = "TSPlayground",
    config = function()
        require("nvim-treesitter.configs").setup({
            playground = {
                enable = true,
                disable = {},
                updatetime = 25,
                persist_queries = false,
                keybindings = {
                    toggle_query_editor = "o",
                    toggle_hl_groups = "i",
                    toggle_injected_languages = "t",
                    toggle_anonymous_nodes = "a",
                    toggle_language_display = "I",
                    focus_language = "f",
                    unfocus_language = "F",
                    update = "R",
                    goto_node = "<cr>",
                    show_help = "?",
                },
            },
        })
    end,
}
modules["wakatime/vim-wakatime"] = {}

modules["christoomey/vim-tmux-navigator"] = {}

modules["phaazon/mind.nvim"] = {
    config = function()
        require("mind").setup()
    end,
}
modules["xarthurx/taskwarrior.vim"] = {
    event = {
        "BufRead",
    },
    config = function()
        require("mind").setup()
    end,
}

modules["nvim-telescope/telescope-symbols.nvim"] = {
    after = "telescope.nvim",
    config = function()
        vim.api.nvim_create_user_command(
            "IconPickerNerd",
            "lua require'telescope.builtin'.symbols{ sources = {'nerd'} }",
            {}
        )
        vim.api.nvim_create_user_command(
            "IconPickerLatex",
            "lua require'telescope.builtin'.symbols{ sources = {'latex'} }",
            {}
        )
        vim.api.nvim_create_user_command(
            "IconPickerMath",
            "lua require'telescope.builtin'.symbols{ sources = {'math'} }",
            {}
        )
        vim.api.nvim_create_user_command(
            "IconPickerEmoji",
            "lua require'telescope.builtin'.symbols{ sources = {'emoji'} }",
            {}
        )
        vim.api.nvim_create_user_command(
            "IconPickerGitEmoji",
            "lua require'telescope.builtin'.symbols{ sources = {'gitmoji'} }",
            {}
        )
    end,
}
modules["KenN7/vim-arsync"] = {}

modules["gennaro-tedesco/nvim-peekup"] = {
    config = function()
        vim.cmd([[
            let g:peekup_open = ''
            let g:peekup_paste_before = '<leader>P'
            let g:peekup_paste_after = '<leader>p'
        ]])
    end,
}

modules["zbirenbaum/neodim"] = {
    config = function()
        require("neodim").setup({
            alpha = 0.75,
        })
    end,
}

modules["dstein64/vim-startuptime"] = {}

-- modules["lvim-tech/lvim-projects"] = {
--     rocks = { "lunajson" },
--     config = function()
--         require("lvim-projects").setup()
--     end,
-- }
--
-- modules["jedrzejboczar/possession.nvim"] = {
--     requires = { "nvim-lua/plenary.nvim" },
--     config = function()
--         require("possession").setup()
--     end,
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Unused -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- modules["folke/noice.nvim"] = {
--     event = "VimEnter",
--     config = function()
--         require("noice").setup({
--             cmdline = {
--                 view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
--                 opts = { buf_options = { filetype = "vim" } }, -- enable syntax highlighting in the cmdline
--                 icons = {
--                     ["/"] = { icon = " ", hl_group = "DiagnosticWarn" },
--                     ["?"] = { icon = " ", hl_group = "DiagnosticWarn" },
--                     [":"] = { icon = " ", hl_group = "DiagnosticInfo", firstc = false },
--                 },
--             },
--             views = {
--                 popupmenu = {
--                     zindex = 65,
--                     position = "auto", -- when auto, then it will be positioned to the cmdline or cursor
--                     win_options = {
--                         winhighlight = {
--                             Normal = "NuiBody", -- change to NormalFloat to make it look like other floats
--                             FloatBorder = "NuiBorder", -- border highlight
--                             CursorLine = "PmenuSel", -- used for highlighting the selected item
--                             PmenuMatch = "Special", -- used to highlight the part of the item that matches the input
--                         },
--                     },
--                 },
--                 notify = {
--                     backend = "notify",
--                     level = vim.log.levels.INFO,
--                     replace = true,
--                 },
--                 split = {
--                     backend = "split",
--                     enter = false,
--                     relative = "editor",
--                     position = "bottom",
--                     size = "20%",
--                     close = {
--                         keys = { "q", "<esc>" },
--                     },
--                     win_options = {
--                         winhighlight = "Normal:NuiBody,FloatBorder:NuiBorder",
--                     },
--                 },
--                 vsplit = {
--                     backend = "split",
--                     enter = false,
--                     relative = "editor",
--                     position = "right",
--                     size = "20%",
--                     close = {
--                         keys = { "q", "<esc>" },
--                     },
--                     win_options = {
--                         winhighlight = "Normal:NuiBody,FloatBorder:NuiBorder",
--                     },
--                 },
--                 popup = {
--                     backend = "popup",
--                     close = {
--                         events = { "BufLeave" },
--                         keys = { "q", "<esc>" },
--                     },
--                     enter = true,
--                     border = { " ", " ", " ", " ", " ", " ", " ", " " },
--                     position = "50%",
--                     size = {
--                         width = "80%",
--                         height = "60%",
--                     },
--                     win_options = {
--                         winhighlight = "Normal:NuiBody,FloatBorder:NuiBorder",
--                     },
--                 },
--                 cmdline = {
--                     backend = "popup",
--                     relative = "editor",
--                     position = {
--                         row = "100%",
--                         col = 0,
--                     },
--                     size = {
--                         height = "auto",
--                         width = "100%",
--                     },
--                     border = { " ", " ", " ", " ", " ", " ", " ", " " },
--                     win_options = {
--                         winhighlight = "Normal:NuiBody,FloatBorder:NuiBorder",
--                     },
--                 },
--                 cmdline_popup = {
--                     backend = "popup",
--                     relative = "editor",
--                     focusable = false,
--                     enter = false,
--                     zindex = 60,
--                     position = {
--                         row = "50%",
--                         col = "50%",
--                     },
--                     size = {
--                         min_width = 60,
--                         width = "auto",
--                         height = "auto",
--                     },
--                     border = {
--                         style = { " ", " ", " ", " ", " ", " ", " ", " " },
--                         padding = { 0, 1, 0, 1 },
--                         text = {
--                             top = " COMMAND LINE: ",
--                         },
--                     },
--                     win_options = {
--                         winhighlight = "Normal:NuiBody,FloatBorder:NuiBorder",
--                         cursorline = false,
--                     },
--                     filter_options = {
--                         {
--                             filter = { event = "cmdline", find = "^%s*[/?]" },
--                             opts = {
--                                 border = {
--                                     text = {
--                                         top = " SEARCH: ",
--                                     },
--                                 },
--                                 win_options = {
--                                     winhighlight = "Normal:NuiBody,FloatBorder:NuiBorder",
--                                 },
--                             },
--                         },
--                     },
--                 },
--             },
--             routes = {
--                 {
--                     view = "cmdline_popup",
--                     filter = { event = "cmdline" },
--                 },
--                 {
--                     view = "cmdline_popup",
--                     filter = {
--                         any = {
--                             { event = "msg_show", kind = "confirm" },
--                             { event = "msg_show", kind = "confirm_sub" },
--                         },
--                     },
--                 },
--                 {
--                     view = "split",
--                     filter = {
--                         any = {
--                             { event = "msg_history_show" },
--                             -- { min_height = 20 },
--                         },
--                     },
--                 },
--                 -- {
--                 --     view = "virtualtext",
--                 --     filter = {
--                 --         event = "msg_show",
--                 --         kind = "search_count",
--                 --     },
--                 --     opts = { hl_group = "DiagnosticVirtualTextInfo" },
--                 -- },
--                 {
--                     filter = {
--                         any = {
--                             { event = { "msg_showmode", "msg_showcmd", "msg_ruler" } },
--                             { event = "msg_show", kind = "search_count" },
--                         },
--                     },
--                     opts = { skip = true },
--                 },
--                 {
--                     view = "notify",
--                     filter = {
--                         event = "noice",
--                         kind = { "stats", "debug" },
--                     },
--                     opts = { buf_options = { filetype = "lua" }, replace = true },
--                 },
--                 -- {
--                 --     view = "notify",
--                 --     filter = {
--                 --         any = {
--                 --             { event = "notify" },
--                 --             { error = true },
--                 --             { warning = true },
--                 --         },
--                 --     },
--                 --     opts = { title = "LVIM IDE", merge = false, replace = false },
--                 -- },
--                 {
--                     view = "notify",
--                     filter = {},
--                     opts = { title = "LVIM IDE" },
--                 },
--             },
--         })
--     end,
-- }

-- modules["m-demare/hlargs.nvim"] = {
--     config = function()
--         require("hlargs").setup()
--     end,
-- }
-- modules["miversen33/netman.nvim"] = {
--     branch = "issue-28-libuv-shenanigans",
--     config = function()
--         require("netman")
--     end,
-- }
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- HELP ---------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Disable of default Module (Plug-in) (from lua/modules/base/init.lua)

-- You can disable of any default Module (Plug-in)
-- modules["glepnir/dashboard-nvim"] = false

-- Rewrite of settings of default Module (Plug-in) (from lua/modules/base/init.lua)

-- You can rewrite of settings of any of default Module (Plug-in)
-- modules["glepnir/dashboard-nvim"] = {
--     -- your code
-- }

-- Add new Module (Plug-in)

-- You can add new Module (Plug-in)
-- modules["sheerun/vim-polyglot"] = {
--     your code
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- HELP ---------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local ui_config = require("modules.user.configs.ui")

-- modules["name_of_your/module"] = {
--     config = ui_config.name_of_your_function
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Editor -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local editor_config = require("modules.user.configs.editor")

-- modules["name_of_your/module"] = {
--     config = editor_config.name_of_your_function
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Version control ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local version_control_config = require("modules.user.configs.version_control")

-- modules["name_of_your/module"] = {
--     config = version_control_config.name_of_your_function
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Languages ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local languages_config = require("modules.user.configs.editor")

-- modules["name_of_your/module"] = {
--     config = languages_config.name_of_your_function
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Completion ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local completion_config = require("modules.user.configs.editor")

-- modules["name_of_your/module"] = {
--     config = completion_config.name_of_your_function
-- }

-- modules["VonHeikemen/fine-cmdline.nvim"] = {
--     requires = {
--         { "MunifTanjim/nui.nvim" },
--     },
--     config = function()
--         require("fine-cmdline").setup({
--             cmdline = {
--                 enable_keymaps = true,
--                 smart_history = true,
--                 prompt = ": ",
--             },
--             popup = {
--                 position = {
--                     row = "90%",
--                     col = "50%",
--                 },
--                 size = {
--                     width = "60%",
--                 },
--                 border = {
--                     style = { " ", " ", " ", " ", " ", " ", " ", " " },
--                 },
--                 win_options = {
--                     winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
--                 },
--             },
--         })
--         vim.api.nvim_set_keymap("n", ":", "<cmd>FineCmdline<CR>", { noremap = true })
--         vim.api.nvim_set_keymap("n", "?", "<cmd>FineCmdline<CR>", { noremap = true })
--         vim.api.nvim_set_keymap("n", "/", "<cmd>FineCmdline<CR>", { noremap = true })
--     end,
-- }

-- modules["levouh/tint.nvim"] = {
--     config = function()
--         require("tint").setup({
--             bg = true, -- Tint background highlights
--             amt = -40, -- Tint by value, brighten would just be 40
--             ignore = { "WinSeparator", "VertSplit", "Status.*" },
--             ignorefunc = function(winid)
--                 local buf = vim.api.nvim_win_get_buf(winid)
--                 local buftype
--                 vim.api.nvim_buf_get_option(buf, "buftype")
--
--                 if buftype == "terminal" then
--                     -- Ignore `terminal`-type buffers
--                     return true
--                 end
--
--                 -- Do not ignore this window, tint it
--                 return false
--             end,
--         })
--     end,
-- }

-- modules["chentoast/marks.nvim"] = {
--     -- cmd = "BookmarkToggle",
--     config = function()
--         require("marks").setup({
--             force_write_shada = true,
--             excluded_filetypes = { "" },
--             signs = false,
--             default_mappings = false,
--             mappings = {
--                 set = false,
--                 set_next = false,
--                 toggle = false,
--                 next = false,
--                 prev = false,
--                 preview = false,
--                 next_bookmark = false,
--                 prev_bookmark = false,
--                 delete = false,
--                 delete_line = false,
--                 delete_bookmark = false,
--                 delete_buf = false,
--             },
--             bookmark_0 = {
--                 sign = "⚑",
--             },
--             -- bookmark_1 = {
--             --     sign = "⚑",
--             -- },
--             -- bookmark_2 = {
--             --     sign = "⚑",
--             -- },
--             -- bookmark_3 = {
--             --     sign = "⚑",
--             -- },
--             -- bookmark_4 = {
--             --     sign = "⚑",
--             -- },
--             -- bookmark_5 = {
--             --     sign = "⚑",
--             -- },
--             -- bookmark_6 = {
--             --     sign = "⚑",
--             -- },
--             -- bookmark_7 = {
--             --     sign = "⚑",
--             -- },
--             -- bookmark_8 = {
--             --     sign = "⚑",
--             -- },
--         })
--     end,

-- m = {
--     name = "Marks",
--     a = { "<Plug>(Marks-set)", "Add" },
--     d = { "<Plug>(Marks-delete)", "Delete (type)" },
--     l = { "<Plug>(Marks-deleteline)", "Delete all in line" },
--     b = { "<Plug>(Marks-deletebuf)", "Delete all at buffer" },
--     t = { "<Plug>(Marks-toggle)", "Toggle" },
--     p = { "<Plug>(Marks-preview)", "Prevew" },
--     ["]"] = { "<Plug>(Marks-next)", "Next in buffer" },
--     ["["] = { "<Plug>(Marks-prev)", "Prev in buffer" },
--     s = { "<Cmd>MarksToggleSigns<CR>", "Toggle signs" },
--     o = { "<Cmd>MarksListAll<CR>", "Mark list all" },
-- },
--
--
-- { "tm", ":MarksToggleSigns<CR>" }, -- Marks toggle signs
-- { "ts", ":MarksListAll<CR>" }, -- Marks list all
-- }

-- crusj/bookmarks.nvim

return modules
