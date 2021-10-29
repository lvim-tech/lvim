local config = {}

function config.neogit()
    require("neogit").setup {
        disable_signs = false,
        disable_context_highlighting = false,
        disable_commit_confirmation = false,
        signs = {
            section = {
                "",
                ""
            },
            item = {
                "",
                ""
            },
            hunk = {
                "",
                ""
            }
        },
        integrations = {
            diffview = true
        }
    }
end

function config.gitsigns()
    require("gitsigns").setup {
        signs = {
            add = {
                hl = "GitSignsAdd",
                text = "▎",
                numhl = "GitSignsAddNr",
                linehl = "GitSignsAddLn"
            },
            change = {
                hl = "GitSignsChange",
                text = "▎",
                numhl = "GitSignsChangeNr",
                linehl = "GitSignsChangeLn"
            },
            delete = {
                hl = "GitSignsDelete",
                text = "契",
                numhl = "GitSignsDeleteNr",
                linehl = "GitSignsDeleteLn"
            },
            topdelete = {
                hl = "GitSignsDelete",
                text = "契",
                numhl = "GitSignsDeleteNr",
                linehl = "GitSignsDeleteLn"
            },
            changedelete = {
                hl = "GitSignsChange",
                text = "▎",
                numhl = "GitSignsChangeNr",
                linehl = "GitSignsChangeLn"
            }
        },
        numhl = false,
        linehl = false,
        keymaps = {
            noremap = true,
            buffer = true
        },
        watch_index = {interval = 1000, follow_files = true},
        current_line_blame = false,
        current_line_blame_delay = 1000,
        current_line_blame_position = "eol",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        word_diff = false,
        use_decoration_api = true,
        use_internal_diff = true
    }
    vim.cmd("command! GitSignsPreviewHunk lua require('gitsigns').preview_hunk()")
    vim.cmd("command! GitSignsNextHunk lua require('gitsigns').next_hunk()")
    vim.cmd("command! GitSignsPrevHunk lua require('gitsigns').prev_hunk()")
    vim.cmd("command! GitSignsStageHunk lua require('gitsigns').stage_hunk()")
    vim.cmd("command! GitSignsUndoStageHunk lua require('gitsigns').undo_stage_hunk()")
    vim.cmd("command! GitSignsResetHunk lua require('gitsigns').reset_hunk()")
    vim.cmd("command! GitSignsResetBuffer lua require('gitsigns').reset_buffer()")
    vim.cmd("command! GitSignsBlameLine lua require('gitsigns').blame_line()")
end

function config.git_blame()
    vim.g.gitblame_enabled = 0
end

function config.diffview()
    local cb = require("diffview.config").diffview_callback
    require("diffview").setup {
        diff_binaries = false,
        file_panel = {width = 35, use_icons = true},
        key_bindings = {
            disable_defaults = false,
            view = {
                ["<tab>"] = cb("select_next_entry"),
                ["<s-tab>"] = cb("select_prev_entry"),
                ["<leader>e"] = cb("focus_files"),
                ["<leader>b"] = cb("toggle_files")
            },
            file_panel = {
                ["j"] = cb("next_entry"),
                ["<down>"] = cb("next_entry"),
                ["k"] = cb("prev_entry"),
                ["<up>"] = cb("prev_entry"),
                ["<cr>"] = cb("select_entry"),
                ["o"] = cb("select_entry"),
                ["<2-LeftMouse>"] = cb("select_entry"),
                ["-"] = cb("toggle_stage_entry"),
                ["S"] = cb("stage_all"),
                ["U"] = cb("unstage_all"),
                ["R"] = cb("refresh_files"),
                ["<tab>"] = cb("select_next_entry"),
                ["<s-tab>"] = cb("select_prev_entry"),
                ["<leader>e"] = cb("focus_files"),
                ["<leader>b"] = cb("toggle_files")
            }
        }
    }
end

return config
