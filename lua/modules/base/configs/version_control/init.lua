local config = {}

config.neogit = function()
    local neogit_status_ok, neogit = pcall(require, "neogit")
    if not neogit_status_ok then
        return
    end
    neogit.setup({
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

config.gitsigns_nvim = function()
    local gitsigns_status_ok, gitsigns = pcall(require, "gitsigns")
    if not gitsigns_status_ok then
        return
    end
    gitsigns.setup({
        numhl = false,
        signcolumn = true,
        signs = {
            add = {
                hl = "GitSignsAdd",
                text = "▌",
                numhl = "GitSignsAddNr",
                linehl = "GitSignsAddLn",
            },
            change = {
                hl = "GitSignsChange",
                text = "▌",
                numhl = "GitSignsChangeNr",
                linehl = "GitSignsChangeLn",
            },
            delete = {
                hl = "GitSignsDelete",
                text = "▌",
                numhl = "GitSignsDeleteNr",
                linehl = "GitSignsDeleteLn",
            },
            topdelete = {
                hl = "GitSignsTopDelete",
                text = "▌",
                numhl = "GitSignsTopDeleteNr",
                linehl = "GitSignsTopDeleteLn",
            },
            changedelete = {
                hl = "GitSignsChangeDelete",
                text = "▌",
                numhl = "GitSignsChangeDeleteNr",
                linehl = "GitSignsChangeDeleteLn",
            },
            untracked = {
                hl = "GitSignsUntracked",
                text = "▌",
                numhl = "GitSignsUntrackedNr",
                linehl = "GitSignsUntrackedLn",
            },
        },
        linehl = false,
        keymaps = {
            noremap = true,
            buffer = true,
        },
    })
    vim.api.nvim_create_user_command("GitSignsPreviewHunk", "lua require('gitsigns').preview_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsNextHunk", "lua require('gitsigns').next_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsPrevHunk", "lua require('gitsigns').prev_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsStageHunk", "lua require('gitsigns').stage_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsUndoStageHunk", "lua require('gitsigns').undo_stage_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsResetHunk", "lua require('gitsigns').reset_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsResetBuffer", "lua require('gitsigns').reset_buffer()", {})
    vim.api.nvim_create_user_command("GitSignsBlameLine", "lua require('gitsigns').blame_line()", {})
    vim.keymap.set("n", "<A-]>", function()
        vim.cmd("GitSignsNextHunk")
    end, { noremap = true, silent = true, desc = "GitSignsNextHunk" })
    vim.keymap.set("n", "<A-[>", function()
        vim.cmd("GitSignsPrevHunk")
    end, { noremap = true, silent = true, desc = "GitSignsPrevHunk" })
    vim.keymap.set("n", "<A-;>", function()
        vim.cmd("GitSignsPreviewHunk")
    end, { noremap = true, silent = true, desc = "GitSignsPreviewHunk" })
end

config.git_blame_nvim = function()
    vim.g.gitblame_message_when_not_committed = "➤ Not committed yet"
    vim.g.gitblame_date_format = "%r"
    vim.g.gitblame_message_template = "➤ <summary> ➤ <date> ➤ <author>"
    vim.g.gitblame_ignored_filetypes = {
        "help",
        "Outline",
        "git",
        "dapui_scopes",
        "dapui_breakpoints",
        "dapui_stacks",
        "dapui_watches",
        "NeogitStatus",
        "dashboard",
    }
    vim.keymap.set("n", "<C-c>b", function()
        vim.cmd("GitBlameToggle")
    end, { noremap = true, silent = true, desc = "GitBlameToggle" })
end

config.diffview_nvim = function()
    local diffview_status_ok, diffview = pcall(require, "diffview")
    if not diffview_status_ok then
        return
    end
    diffview.setup({
        hooks = {
            diff_buf_read = function(bufnr)
                vim.schedule(function()
                    vim.api.nvim_buf_call(bufnr, function()
                        vim.opt_local.wrap = false
                        vim.opt_local.list = false
                        vim.opt_local.relativenumber = false
                        vim.opt_local.cursorcolumn = false
                        vim.opt_local.colorcolumn = "0"
                        require("indent_blankline.commands").disable()
                    end)
                end)
            end,
        },
    })
end

config.lvim_forgit = function()
    local lvim_forgit_status_ok, lvim_forgit = pcall(require, "lvim-forgit")
    if not lvim_forgit_status_ok then
        return
    end
    lvim_forgit.setup()
    vim.keymap.set("n", "<C-c>ff", function()
        vim.cmd("LvimForgit")
    end, { noremap = true, silent = true, desc = "LvimForgit" })
end

config.octo_nvim = function()
    local octo_status_ok, octo = pcall(require, "octo")
    if not octo_status_ok then
        return
    end
    octo.setup()
end

config.undotree = function()
    vim.keymap.set("n", "<F5>", function()
        vim.cmd("UndotreeToggle")
    end, { noremap = true, silent = true, desc = "UndotreeToggle" })
end

return config
