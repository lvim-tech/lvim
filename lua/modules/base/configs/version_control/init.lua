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

config.vgit = function()
    local vgit_status_ok, vgit = pcall(require, "vgit")
    if not vgit_status_ok then
        return
    end
    vgit.setup({
        settings = {
            live_blame = {
                enabled = false,
            },
            live_gutter = {
                enabled = false,
            },
        },
    })
    vim.keymap.set("n", "<A-]>", function()
        vgit.hunk_down()
    end, { noremap = true, silent = true, desc = "Git hunk next" })
    vim.keymap.set("n", "<A-[>", function()
        vgit.hunk_up()
    end, { noremap = true, silent = true, desc = "Git hunk prev" })
    vim.keymap.set("n", "<Leader>gp", function()
        require("vgit").buffer_hunk_preview()
    end, { noremap = true, silent = true, desc = "Git hunk preview" })
    vim.keymap.set("n", "<Leader>gP", function()
        require("vgit").buffer_history_preview()
    end, { noremap = true, silent = true, desc = "Git history preview" })
    vim.keymap.set("n", "<Leader>gd", function()
        require("vgit").buffer_diff_preview()
    end, { noremap = true, silent = true, desc = "Git buffer diff preview" })
    vim.keymap.set("n", "<Leader>gD", function()
        require("vgit").project_diff_preview()
    end, { noremap = true, silent = true, desc = "Git project diff preview" })
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
        signs_staged_enable = false,
        signs = {
            untracked = { text = " " .. icons.common.vline },
            changedelete = { text = " " .. icons.common.vline },
            topdelete = { text = " " .. icons.common.vline },
            delete = { text = " " .. icons.common.vline },
            change = { text = " " .. icons.common.vline },
            add = { text = " " .. icons.common.vline },
        },
        linehl = false,
    })
    vim.keymap.set("n", "<Leader>g]", function()
        require("gitsigns").nav_hunk("next")
    end, { noremap = true, silent = true, desc = "Git next hunk" })
    vim.keymap.set("n", "<Leader>g[", function()
        require("gitsigns").nav_hunk("prev")
    end, { noremap = true, silent = true, desc = "Git prev hunk" })
    vim.keymap.set("n", "<Leader>gth", function()
        require("gitsigns").toggle_linehl()
    end, { noremap = true, silent = true, desc = "Git toggle hl" })
    vim.keymap.set("n", "<Leader>gtb", function()
        require("gitsigns").toggle_current_line_blame()
    end, { noremap = true, silent = true, desc = "Git toggle line blame" })
    vim.keymap.set("n", "<Leader>ghs", function()
        require("gitsigns").stage_hunk()
    end, { noremap = true, silent = true, desc = "Git hunk stage" })
    vim.keymap.set("v", "<Leader>ghs", function()
        require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { noremap = true, silent = true, desc = "Git hunk stage" })
    vim.keymap.set("n", "<Leader>ghr", function()
        require("gitsigns").reset_hunk()
    end, { noremap = true, silent = true, desc = "Git hunk reset" })
    vim.keymap.set("v", "<Leader>ghr", function()
        require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { noremap = true, silent = true, desc = "Git hunk reset" })
    vim.keymap.set("n", "<Leader>gbs", function()
        require("gitsigns").stage_buffer()
    end, { noremap = true, silent = true, desc = "Git buffer stage" })
    vim.keymap.set("n", "<Leader>gbr", function()
        require("gitsigns").reset_buffer()
    end, { noremap = true, silent = true, desc = "Git buffer reset" })
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
                    end)
                end)
            end,
        },
        view = {
            ["<C-q>"] = "<Cmd>DiffviewClose<CR>",
        },
    })
    vim.keymap.set("n", "<Leader>go", function()
        vim.cmd("DiffviewFileHistory")
    end, { noremap = true, silent = true, desc = "Git diffview file history" })
    vim.keymap.set("n", "<Leader>gO", function()
        vim.cmd("DiffviewOpen")
    end, { noremap = true, silent = true, desc = "Git diffview open" })
    vim.keymap.set("n", "<C-q>", function()
        vim.cmd("DiffviewClose")
        vim.cmd("CloseFloatWindows")
    end, { noremap = true, silent = true, desc = "Git diffview close" })
end

config.lvim_forgit = function()
    local lvim_forgit_status_ok, lvim_forgit = pcall(require, "lvim-forgit")
    if not lvim_forgit_status_ok then
        return
    end
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
                .. _G.LVIM_COLORS.blue
                .. ",bg:"
                .. _G.LVIM_COLORS.bg_float
                .. ",hl:"
                .. _G.LVIM_COLORS.red
                .. ",fg+:"
                .. _G.LVIM_COLORS.blue
                .. ",bg+:"
                .. _G.LVIM_COLORS.bg_float
                .. ",hl+:"
                .. _G.LVIM_COLORS.red
                .. ",pointer:"
                .. _G.LVIM_COLORS.red
                .. ",info:"
                .. _G.LVIM_COLORS.orange
                .. ",spinner:"
                .. _G.LVIM_COLORS.orange
                .. ",header:"
                .. _G.LVIM_COLORS.red
                .. ",prompt:"
                .. _G.LVIM_COLORS.green
                .. ",marker:"
                .. _G.LVIM_COLORS.red
                .. "'",
            COLORS = "fg:"
                .. _G.LVIM_COLORS.blue
                .. ",bg:"
                .. _G.LVIM_COLORS.bg_dark
                .. ",hl:"
                .. _G.LVIM_COLORS.red
                .. ",fg+:"
                .. _G.LVIM_COLORS.blue
                .. ",bg+:"
                .. _G.LVIM_COLORS.bg_dark
                .. ",hl+:"
                .. _G.LVIM_COLORS.red
                .. ",pointer:"
                .. _G.LVIM_COLORS.red
                .. ",info:"
                .. _G.LVIM_COLORS.orange
                .. ",spinner:"
                .. _G.LVIM_COLORS.orange
                .. ",header:"
                .. _G.LVIM_COLORS.red
                .. ",prompt:"
                .. _G.LVIM_COLORS.green
                .. ",marker:"
                .. _G.LVIM_COLORS.red,
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
