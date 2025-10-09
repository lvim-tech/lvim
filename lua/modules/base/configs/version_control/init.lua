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
    require("vgit").setup({
        settings = {
            hls = {
                GitCount = "Keyword",
                GitSymbol = "CursorLineNr",
                GitTitle = "Directory",
                GitSelected = "QuickfixLine",
                GitBackground = "Normal",
                GitAppBar = "StatusLine",
                GitHeader = "NormalFloat",
                GitFooter = "NormalFloat",
                GitBorder = "LineNr",
                GitLineNr = "LineNr",
                GitComment = "Comment",
                GitSignsAdd = {
                    gui = nil,
                    fg = "#d7ffaf",
                    bg = nil,
                    sp = nil,
                    override = false,
                },
                GitSignsChange = {
                    gui = nil,
                    fg = "#7AA6DA",
                    bg = nil,
                    sp = nil,
                    override = false,
                },
                GitSignsDelete = {
                    gui = nil,
                    fg = "#e95678",
                    bg = nil,
                    sp = nil,
                    override = false,
                },
                GitSignsAddLn = "DiffAdd",
                GitSignsDeleteLn = "DiffDelete",
                GitWordAdd = {
                    gui = nil,
                    fg = nil,
                    bg = "#5d7a22",
                    sp = nil,
                    override = false,
                },
                GitWordDelete = {
                    gui = nil,
                    fg = nil,
                    bg = "#960f3d",
                    sp = nil,
                    override = false,
                },
                GitConflictCurrentMark = "DiffAdd",
                GitConflictAncestorMark = "Visual",
                GitConflictIncomingMark = "DiffChange",
                GitConflictCurrent = "DiffAdd",
                GitConflictAncestor = "Visual",
                GitConflictMiddle = "Visual",
                GitConflictIncoming = "DiffChange",
            },
            live_gutter = {
                enabled = true,
                edge_navigation = true,
            },
            live_blame = {
                enabled = false,
                format = function(blame, git_config)
                    local config_author = git_config["user.name"]
                    local author = blame.author
                    if config_author == author then
                        author = "You"
                    end
                    local time = os.difftime(os.time(), blame.author_time) / (60 * 60 * 24 * 30 * 12)
                    local time_divisions = {
                        { 1, "years" },
                        { 12, "months" },
                        { 30, "days" },
                        { 24, "hours" },
                        { 60, "minutes" },
                        { 60, "seconds" },
                    }
                    local counter = 1
                    local time_division = time_divisions[counter]
                    local time_boundary = time_division[1]
                    local time_postfix = time_division[2]
                    while time < 1 and counter ~= #time_divisions do
                        time_division = time_divisions[counter]
                        time_boundary = time_division[1]
                        time_postfix = time_division[2]
                        time = time * time_boundary
                        counter = counter + 1
                    end
                    local commit_message = blame.commit_message
                    if not blame.committed then
                        author = "You"
                        commit_message = "Uncommitted changes"
                        return string.format(" %s • %s", author, commit_message)
                    end
                    local max_commit_message_length = 255
                    if #commit_message > max_commit_message_length then
                        commit_message = commit_message:sub(1, max_commit_message_length) .. "..."
                    end
                    return string.format(
                        " %s, %s • %s",
                        author,
                        string.format(
                            "%s %s ago",
                            time >= 0 and math.floor(time + 0.5) or math.ceil(time - 0.5),
                            time_postfix
                        ),
                        commit_message
                    )
                end,
            },
            signs = {
                priority = 10,
                definitions = {
                    GitSignsAdd = {
                        texthl = "GitSignsAdd",
                        numhl = nil,
                        icon = nil,
                        linehl = nil,
                        text = " ▌",
                    },
                    GitSignsDelete = {
                        texthl = "GitSignsDelete",
                        numhl = nil,
                        icon = nil,
                        linehl = nil,
                        text = " ▌",
                    },
                    GitSignsChange = {
                        texthl = "GitSignsChange",
                        numhl = nil,
                        icon = nil,
                        linehl = nil,
                        text = " ▌",
                    },
                },
            },
        },
    })
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }
    map("n", "<Leader>g]", function()
        vgit.hunk_down()
    end, vim.tbl_extend("force", opts, { desc = "Git hunk next" }))
    map("n", "<Leader>g[", function()
        vgit.hunk_up()
    end, vim.tbl_extend("force", opts, { desc = "Git hunk prev" }))

    map("n", "<Leader>gT", function()
        vgit.toggle_tracing()
    end, vim.tbl_extend("force", opts, { desc = "Toggle tracing" }))
    map("n", "<Leader>gB", function()
        vgit.toggle_live_blame()
    end, vim.tbl_extend("force", opts, { desc = "Toggle live blame" }))
    map("n", "<Leader>gG", function()
        vgit.toggle_live_gutter()
    end, vim.tbl_extend("force", opts, { desc = "Toggle live gutter" }))
    map("n", "<Leader>gD", function()
        vgit.toggle_diff_preference()
    end, vim.tbl_extend("force", opts, { desc = "Toggle diff preference" }))

    map("n", "<Leader>gR", function()
        vgit.buffer_reset()
    end, vim.tbl_extend("force", opts, { desc = "Buffer reset" }))
    map("n", "<Leader>gS", function()
        vgit.buffer_stage()
    end, vim.tbl_extend("force", opts, { desc = "Buffer stage" }))
    map("n", "<Leader>gU", function()
        vgit.buffer_unstage()
    end, vim.tbl_extend("force", opts, { desc = "Buffer unstage" }))

    map("n", "<Leader>gHr", function()
        vgit.buffer_hunk_reset()
    end, vim.tbl_extend("force", opts, { desc = "Buffer hunk reset" }))
    map("n", "<Leader>gHs", function()
        vgit.buffer_hunk_stage()
    end, vim.tbl_extend("force", opts, { desc = "Buffer hunk stage" }))
    map("n", "<Leader>gHp", function()
        vgit.buffer_hunk_preview()
    end, vim.tbl_extend("force", opts, { desc = "Buffer hunk preview" }))
    map("n", "<Leader>gDp", function()
        vgit.buffer_diff_preview()
    end, vim.tbl_extend("force", opts, { desc = "Buffer diff preview" }))
    map("n", "<Leader>gbp", function()
        vgit.buffer_blame_preview()
    end, vim.tbl_extend("force", opts, { desc = "Buffer blame preview" }))
    map("n", "<Leader>gHp", function()
        vgit.buffer_history_preview()
    end, vim.tbl_extend("force", opts, { desc = "Buffer history preview" }))

    map("n", "<Leader>gCb", function()
        vgit.buffer_conflict_accept_both()
    end, vim.tbl_extend("force", opts, { desc = "Buffer conflict accept both" }))
    map("n", "<Leader>gCc", function()
        vgit.buffer_conflict_accept_current()
    end, vim.tbl_extend("force", opts, { desc = "Buffer conflict accept current" }))
    map("n", "<Leader>gCi", function()
        vgit.buffer_conflict_accept_incoming()
    end, vim.tbl_extend("force", opts, { desc = "Buffer conflict accept incoming" }))

    map("n", "<Leader>gPd", function()
        vgit.project_diff_preview()
    end, vim.tbl_extend("force", opts, { desc = "Project diff preview" }))
    map("n", "<Leader>gPl", function()
        vgit.project_logs_preview()
    end, vim.tbl_extend("force", opts, { desc = "Project logs preview" }))
    map("n", "<Leader>gPs", function()
        vgit.project_stash_preview()
    end, vim.tbl_extend("force", opts, { desc = "Project stash preview" }))
    map("n", "<Leader>gPc", function()
        vgit.project_commit_preview()
    end, vim.tbl_extend("force", opts, { desc = "Project commit preview" }))
    map("n", "<Leader>gPm", function()
        vgit.project_commits_preview()
    end, vim.tbl_extend("force", opts, { desc = "Project commits preview" }))
    -- vim.keymap.set("n", "<Leader>gp", function()
    --     require("vgit").buffer_hunk_preview()
    -- end, { noremap = true, silent = true, desc = "Git hunk preview" })
    -- vim.keymap.set("n", "<Leader>gP", function()
    --     require("vgit").buffer_history_preview()
    -- end, { noremap = true, silent = true, desc = "Git history preview" })
    -- vim.keymap.set("n", "<Leader>gd", function()
    --     require("vgit").buffer_diff_preview()
    -- end, { noremap = true, silent = true, desc = "Git buffer diff preview" })
    -- vim.keymap.set("n", "<Leader>gD", function()
    --     require("vgit").project_diff_preview()
    -- end, { noremap = true, silent = true, desc = "Git project diff preview" })
    --
    --
    -- vim.keymap.set("n", "<Leader>gbs", function()
    --     require("vgit").buffer_reset().buffer_stage()
    -- end, { noremap = true, silent = true, desc = "Git buffer stage" })
    -- vim.keymap.set("n", "<Leader>gbr", function()
    --     require("vgit").buffer_reset().buffer_reset()
    -- end, { noremap = true, silent = true, desc = "Git buffer reset" })
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

config.time_machine = function()
    local time_machine_status_ok, time_machine = pcall(require, "time-machine")
    if not time_machine_status_ok then
        return
    end
    time_machine.setup({})
end

return config
