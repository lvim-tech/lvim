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
                    fg = nil,
                    bg = nil,
                    sp = nil,
                    override = false,
                },
                GitSignsChange = {
                    gui = nil,
                    fg = nil,
                    bg = nil,
                    sp = nil,
                    override = false,
                },
                GitSignsDelete = {
                    gui = nil,
                    fg = nil,
                    bg = nil,
                    sp = nil,
                    override = false,
                },
                GitSignsAddLn = "DiffAdd",
                GitSignsDeleteLn = "DiffDelete",
                GitWordAdd = {
                    gui = nil,
                    fg = nil,
                    bg = nil,
                    sp = nil,
                    override = false,
                },
                GitWordDelete = {
                    gui = nil,
                    fg = nil,
                    bg = nil,
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
    -- HUNK
    map("n", "<Leader>g]", function()
        vgit.hunk_down()
    end, vim.tbl_extend("force", opts, { desc = "Git hunk next" }))
    map("n", "<Leader>g[", function()
        vgit.hunk_up()
    end, vim.tbl_extend("force", opts, { desc = "Git hunk prev" }))

    -- BUFFER
    map("n", "<Leader>gb", function() end, vim.tbl_extend("force", opts, { desc = "VGit Buffer" }))
    -- Hunk
    map("n", "<Leader>gbh", function() end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Hunk" }))
    map("n", "<Leader>gbhp", function()
        vgit.buffer_hunk_preview()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Hunk Preview" }))
    map("n", "<Leader>gbhs", function()
        vgit.buffer_hunk_stage()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Hunk Stage" }))
    map("n", "<Leader>gbhr", function()
        vgit.buffer_hunk_reset()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Hunk Reset" }))
    -- History
    map("n", "<Leader>gbH", function() end, vim.tbl_extend("force", opts, { desc = "VGit Buffer History" }))
    map("n", "<Leader>gbHp", function()
        vgit.buffer_history_preview()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer History Preview" }))
    -- Diff
    map("n", "<Leader>gbd", function() end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Diff" }))
    map("n", "<Leader>gbdp", function()
        vgit.buffer_diff_preview()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Diff Preview" }))
    -- Blame
    map("n", "<Leader>gbb", function() end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Blame" }))
    map("n", "<Leader>gbbp", function()
        vgit.buffer_blame_preview()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Blame Preview" }))
    -- Conflict
    map("n", "<Leader>gbc", function() end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Conflict" }))
    map("n", "<Leader>gbcb", function()
        vgit.buffer_conflict_accept_both()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Conflict Accept Both" }))
    map("n", "<Leader>gbcc", function()
        vgit.buffer_conflict_accept_current()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Conflict Accept Current" }))
    map("n", "<Leader>gbci", function()
        vgit.buffer_conflict_accept_incoming()
    end, vim.tbl_extend("force", opts, { desc = "VGit: Buffer Conflict Accept Incoming" }))
    -- Stage
    map("n", "<Leader>gbs", function()
        vgit.buffer_stage()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Stage" }))
    -- Unstage
    map("n", "<Leader>gbu", function()
        vgit.buffer_unstage()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Unstage" }))
    -- Reset
    map("n", "<Leader>gbr", function()
        vgit.buffer_reset()
    end, vim.tbl_extend("force", opts, { desc = "VGit Buffer Reset" }))

    -- PROJECT
    map("n", "<Leader>gp", function() end, vim.tbl_extend("force", opts, { desc = "VGit Project" }))
    -- Diff
    map("n", "<Leader>gpd", function() end, vim.tbl_extend("force", opts, { desc = "VGit Project Diff" }))
    map("n", "<Leader>gpdp", function()
        vgit.project_diff_preview()
    end, vim.tbl_extend("force", opts, { desc = "VGit Project Diff Preview" }))
    -- Commit
    map("n", "<Leader>gpc", function() end, vim.tbl_extend("force", opts, { desc = "VGit Project Commit" }))
    map("n", "<Leader>gpcp", function()
        vgit.project_commit_preview()
    end, vim.tbl_extend("force", opts, { desc = "VGit Project Commit Preview" }))
    -- Stash
    map("n", "<Leader>gps", function() end, vim.tbl_extend("force", opts, { desc = "VGit Project Stash" }))
    map("n", "<Leader>gpsp", function()
        vgit.project_stash_preview()
    end, vim.tbl_extend("force", opts, { desc = "VGit Project Stash Preview" }))

    -- TOGGLE
    map("n", "<Leader>gt", function() end, vim.tbl_extend("force", opts, { desc = "VGit Toggle" }))
    map("n", "<Leader>gtd", function() end, vim.tbl_extend("force", opts, { desc = "VGit Toggle Diff" }))
    map("n", "<Leader>gtdp", function()
        vgit.toggle_diff_preference()
    end, vim.tbl_extend("force", opts, { desc = "VGit Toggle Diff Preference" }))
    map("n", "<Leader>gtl", function() end, vim.tbl_extend("force", opts, { desc = "VGit Toggle Live" }))
    map("n", "<Leader>gtlg", function()
        vgit.toggle_live_gutter()
    end, vim.tbl_extend("force", opts, { desc = "VGit Toggle Live Gutter" }))
    map("n", "<Leader>gtlb", function()
        vgit.toggle_live_blame()
    end, vim.tbl_extend("force", opts, { desc = "VGit Toggle Live Blame" }))
    map("n", "<Leader>gtt", function()
        vgit.toggle_tracing()
    end, vim.tbl_extend("force", opts, { desc = "VGit Toggle Tracing" }))
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
    time_machine.setup({
        diff_tool = "delta",
        external_diff_args = {
            delta = {
                "--side-by-side",
                "--line-numbers",
                "--navigate",
                "--file-style=omit",
                "--hunk-header-style=omit",
            },
        },
    })
end

return config
