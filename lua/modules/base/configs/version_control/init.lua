local funcs = require("core.funcs")
local icons = require("configs.base.ui.icons")

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
        current_line_blame_formatter = "➤ <author> ➤ <author_time:%Y-%m-%d> ➤ <summary>",
        current_line_blame_formatter_nc = "➤ Not Committed Yet",
        current_line_blame_opts = {
            delay = 10,
        },
        numhl = false,
        signcolumn = true,
        signs = {
            add = {
                hl = "GitSignsAdd",
                text = icons.common.vline,
                numhl = "GitSignsAddNr",
                linehl = "GitSignsAddLn",
            },
            change = {
                hl = "GitSignsChange",
                text = icons.common.vline,
                numhl = "GitSignsChangeNr",
                linehl = "GitSignsChangeLn",
            },
            delete = {
                hl = "GitSignsDelete",
                text = icons.common.vline,
                numhl = "GitSignsDeleteNr",
                linehl = "GitSignsDeleteLn",
            },
            topdelete = {
                hl = "GitSignsTopDelete",
                text = icons.common.vline,
                numhl = "GitSignsTopDeleteNr",
                linehl = "GitSignsTopDeleteLn",
            },
            changedelete = {
                hl = "GitSignsChangeDelete",
                text = icons.common.vline,
                numhl = "GitSignsChangeDeleteNr",
                linehl = "GitSignsChangeDeleteLn",
            },
            untracked = {
                hl = "GitSignsUntracked",
                text = icons.common.vline,
                numhl = "GitSignsUntrackedNr",
                linehl = "GitSignsUntrackedLn",
            },
        },
        linehl = false,
        _extmark_signs = true,
    })
    vim.api.nvim_create_user_command("GitSignsPreviewHunk", "lua require('gitsigns').preview_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsNextHunk", "lua require('gitsigns').next_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsPrevHunk", "lua require('gitsigns').prev_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsStageHunk", "lua require('gitsigns').stage_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsUndoStageHunk", "lua require('gitsigns').undo_stage_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsResetHunk", "lua require('gitsigns').reset_hunk()", {})
    vim.api.nvim_create_user_command("GitSignsResetBuffer", "lua require('gitsigns').reset_buffer()", {})
    vim.api.nvim_create_user_command("GitSignsBlameLine", "lua require('gitsigns').blame_line()", {})
    vim.api.nvim_create_user_command("GitSignsBlameFull", "lua require('gitsigns').blame_line(full=true)", {})
    vim.api.nvim_create_user_command("GitSignsToggleLinehl", "lua require('gitsigns').toggle_linehl()", {})
    vim.api.nvim_create_user_command(
        "GitSignsToggleLineBlame",
        "lua require('gitsigns').toggle_current_line_blame()",
        {}
    )
    vim.keymap.set("n", "<A-]>", function()
        vim.cmd("GitSignsNextHunk")
    end, { noremap = true, silent = true, desc = "GitSignsNextHunk" })
    vim.keymap.set("n", "<A-[>", function()
        vim.cmd("GitSignsPrevHunk")
    end, { noremap = true, silent = true, desc = "GitSignsPrevHunk" })
    vim.keymap.set("n", "<A-;>", function()
        vim.cmd("GitSignsPreviewHunk")
    end, { noremap = true, silent = true, desc = "GitSignsPreviewHunk" })
    vim.keymap.set("n", "<C-c>b", function()
        vim.cmd("GitSignsToggleLineBlame")
    end, { noremap = true, silent = true, desc = "GitSignsToggleLineBlame" })
    vim.keymap.set("n", "<C-c>m", function()
        vim.cmd("GitSignsBlameLine")
    end, { noremap = true, silent = true, desc = "GitSignsBlameLine" })
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
    local colors = _G.LVIM_COLORS["colors"][_G.LVIM_SETTINGS.theme]
    local bg = funcs.darken(colors.bg_01, 0.7, colors.corection)
    lvim_forgit.setup({
        ui = {
            float = {
                float_hl = "NormalFloat",
                height = _G.LVIM_SETTINGS.floatheight,
                border_hl = "FloatBorder",
            },
            split = "belowright " .. _G.LVIM_SETTINGS.floatheight .. " new",
        },
        env = {
            FORGIT_FZF_DEFAULT_OPTS = "--height='100%' --preview-window='right:50%' --reverse --color='"
                .. "fg:"
                .. colors.fg_07
                .. ",bg:"
                .. bg
                .. ",hl:"
                .. colors.red_03
                .. ",fg+:"
                .. colors.fg_07
                .. ",bg+:"
                .. bg
                .. ",hl+:"
                .. colors.red_03
                .. ",pointer:"
                .. colors.red_03
                .. ",info:"
                .. colors.orange_03
                .. ",spinner:"
                .. colors.orange_03
                .. ",header:"
                .. colors.red_03
                .. ",prompt:"
                .. colors.green_03
                .. ",marker:"
                .. colors.red_03
                .. "'",
            COLORS = "fg:"
                .. colors.fg_07
                .. ",bg:"
                .. bg
                .. ",hl:"
                .. colors.red_03
                .. ",fg+:"
                .. colors.fg_07
                .. ",bg+:"
                .. bg
                .. ",hl+:"
                .. colors.red_03
                .. ",pointer:"
                .. colors.red_03
                .. ",info:"
                .. colors.orange_03
                .. ",spinner:"
                .. colors.orange_03
                .. ",header:"
                .. colors.red_03
                .. ",prompt:"
                .. colors.green_03
                .. ",marker:"
                .. colors.red_03,
        },
    })
    vim.keymap.set("n", "<C-c>fg", function()
        vim.cmd("LvimForgit")
    end, { noremap = true, silent = true, desc = "LvimForgit" })
    vim.keymap.set("n", "<C-c>gga", function()
        vim.cmd("LvimForgitAdd")
    end, { noremap = true, silent = true, desc = "LvimForgitAdd" })
    vim.keymap.set("n", "<C-c>ggb", function()
        vim.cmd("LvimForgitBlame")
    end, { noremap = true, silent = true, desc = "LvimForgitBlame" })
    vim.keymap.set("n", "<C-c>ggd", function()
        vim.cmd("LvimForgitBranchDelete")
    end, { noremap = true, silent = true, desc = "LvimForgitBranchDelete" })
    vim.keymap.set("n", "<C-c>ggcb", function()
        vim.cmd("LvimForgitCheckoutBranch")
    end, { noremap = true, silent = true, desc = "LvimForgitCheckoutBranch" })
    vim.keymap.set("n", "<C-c>ggcc", function()
        vim.cmd("LvimForgitCheckoutCommit")
    end, { noremap = true, silent = true, desc = "LvimForgitCheckoutCommit" })
    vim.keymap.set("n", "<C-c>ggcf", function()
        vim.cmd("LvimForgitCheckoutFile")
    end, { noremap = true, silent = true, desc = "LvimForgitCheckoutFile" })
    vim.keymap.set("n", "<C-c>ggct", function()
        vim.cmd("LvimForgitCheckoutTag")
    end, { noremap = true, silent = true, desc = "LvimForgitCheckoutTag" })
    vim.keymap.set("n", "<C-c>ggp", function()
        vim.cmd("LvimForgitCherryPick")
    end, { noremap = true, silent = true, desc = "LvimForgitCherryPick" })
    vim.keymap.set("n", "<C-c>ggP", function()
        vim.cmd("LvimForgitCheckoutBranch")
    end, { noremap = true, silent = true, desc = "LvimForgitCherryPickFromBranch" })
    vim.keymap.set("n", "<C-c>ggn", function()
        vim.cmd("LvimForgitClean")
    end, { noremap = true, silent = true, desc = "LvimForgitClean" })
    vim.keymap.set("n", "<C-c>ggd", function()
        vim.cmd("LvimForgitDiff")
    end, { noremap = true, silent = true, desc = "LvimForgitDiff" })
    vim.keymap.set("n", "<C-c>ggf", function()
        vim.cmd("LvimForgitFixUp")
    end, { noremap = true, silent = true, desc = "LvimForgitFixUp" })
    vim.keymap.set("n", "<C-c>ggi", function()
        vim.cmd("LvimForgitIgnore")
    end, { noremap = true, silent = true, desc = "LvimForgitIgnore" })
    vim.keymap.set("n", "<C-c>ggl", function()
        vim.cmd("LvimForgitLog")
    end, { noremap = true, silent = true, desc = "LvimForgitLog" })
    vim.keymap.set("n", "<C-c>ggrr", function()
        vim.cmd("LvimForgitRebase")
    end, { noremap = true, silent = true, desc = "LvimForgitRebase" })
    vim.keymap.set("n", "<C-c>ggrh", function()
        vim.cmd("LvimForgitResetHead")
    end, { noremap = true, silent = true, desc = "LvimForgitResetHead" })
    vim.keymap.set("n", "<C-c>ggrc", function()
        vim.cmd("LvimForgitRevertCommit")
    end, { noremap = true, silent = true, desc = "LvimForgitRevertCommit" })
    vim.keymap.set("n", "<C-c>ggss", function()
        vim.cmd("LvimForgitStashShow")
    end, { noremap = true, silent = true, desc = "LvimForgitStashShow" })
    vim.keymap.set("n", "<C-c>ggsp", function()
        vim.cmd("LvimForgitStashPush")
    end, { noremap = true, silent = true, desc = "LvimForgitStashPush" })
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
