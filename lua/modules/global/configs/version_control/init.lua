local config = {}

function config.neogit()
    require("neogit").setup({
        disable_signs = false,
        disable_context_highlighting = false,
        disable_commit_confirmation = false,
        signs = {
            section = {
                "",
                "",
            },
            item = {
                "",
                "",
            },
            hunk = {
                "",
                "",
            },
        },
        integrations = {
            diffview = true,
        },
    })
end

function config.gitsigns()
    require("gitsigns").setup({
        signs = {
            add = {
                hl = "GitSignsAdd",
                text = "▎",
                numhl = "GitSignsAddNr",
                linehl = "GitSignsAddLn",
            },
            change = {
                hl = "GitSignsChange",
                text = "▎",
                numhl = "GitSignsChangeNr",
                linehl = "GitSignsChangeLn",
            },
            delete = {
                hl = "GitSignsDelete",
                text = "契",
                numhl = "GitSignsDeleteNr",
                linehl = "GitSignsDeleteLn",
            },
            topdelete = {
                hl = "GitSignsDelete",
                text = "契",
                numhl = "GitSignsDeleteNr",
                linehl = "GitSignsDeleteLn",
            },
            changedelete = {
                hl = "GitSignsChange",
                text = "▎",
                numhl = "GitSignsChangeNr",
                linehl = "GitSignsChangeLn",
            },
        },
        numhl = false,
        linehl = false,
        keymaps = {
            noremap = true,
            buffer = true,
        },
    })
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
    vim.g.gitblame_ignored_filetypes = {
        "help",
        "NvimTree",
        "Trouble",
        "Outline",
        "git",
        "dapui_scopes",
        "dapui_breakpoints",
        "dapui_stacks",
        "dapui_watches",
        "NeogitStatus",
        "dashboard",
    }
end

return config
