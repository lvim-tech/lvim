local icons = require("configs.base.ui.icons")

return {
    neogit = {
        cmd = { "Neogit" },
        keys = {
            { "<Leader>gn", "<Cmd>Neogit<CR>", desc = "Neogit" },
        },
        opts = {
            disable_signs = false,
            disable_context_highlighting = false,
            disable_commit_confirmation = false,
            integrations = {
                diffview = true,
            },
        },
    },
    mini_diff = {
        opts = function()
            vim.schedule(function()
                vim.keymap.del("n", "gh", {})
            end)
            local keys = {
                goto_first = "<Leader>{",
                goto_prev = "<Leader>[",
                goto_next = "<Leader>]",
                goto_last = "<Leader>}",
                toggle_overlay = "<Leader>gh",
            }
            local base_opts = { noremap = true, silent = true }
            local function safe_minidiff_call(fn, ...)
                local ok, mini = pcall(require, "mini.diff")
                if ok and mini and type(mini[fn]) == "function" then
                    return pcall(mini[fn], ...)
                end
                ---@diagnostic disable-next-line: undefined-field
                if type(_G.MiniDiff) == "table" and type(_G.MiniDiff[fn]) == "function" then
                    return pcall(_G.MiniDiff[fn], ...)
                end
                return nil, ("mini.diff.%s not available"):format(fn)
            end
            vim.keymap.set({ "n", "x" }, keys.goto_first, function()
                safe_minidiff_call("goto_hunk", "first")
            end, vim.tbl_extend("force", base_opts, { desc = "MiniDiff: goto first hunk" }))
            vim.keymap.set({ "n", "x" }, keys.goto_prev, function()
                safe_minidiff_call("goto_hunk", "prev")
            end, vim.tbl_extend("force", base_opts, { desc = "MiniDiff: goto previous hunk" }))
            vim.keymap.set({ "n", "x" }, keys.goto_next, function()
                safe_minidiff_call("goto_hunk", "next")
            end, vim.tbl_extend("force", base_opts, { desc = "MiniDiff: goto next hunk" }))
            vim.keymap.set({ "n", "x" }, keys.goto_last, function()
                safe_minidiff_call("goto_hunk", "last")
            end, vim.tbl_extend("force", base_opts, { desc = "MiniDiff: goto last hunk" }))
            vim.keymap.set("n", keys.toggle_overlay, function()
                safe_minidiff_call("toggle_overlay")
            end, vim.tbl_extend("force", base_opts, { desc = "MiniDiff: toggle overlay" }))
            return {
                view = {
                    style = "sign",
                    signs = {
                        add = " " .. icons.common.vline,
                        change = " " .. icons.common.vline,
                        delete = " " .. icons.common.vline,
                    },
                    priority = 199,
                },
                mappings = {
                    apply = nil,
                    reset = nil,
                    textobject = nil,
                    goto_first = nil,
                    goto_prev = nil,
                    goto_next = nil,
                    goto_last = nil,
                },
            }
        end,
    },
    vgit = {
        opts = function()
            local vgit_status_ok, vgit = pcall(require, "vgit")
            if not vgit_status_ok then
                return
            end
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
            return {
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
                        enabled = false,
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
            }
        end,
    },
    diffview_nvim = {
        cmd = {
            "DiffviewFileHistory",
            "DiffviewOpen",
            "DiffviewClose",
            "DiffviewFocusFiles",
            "DiffviewToggleFiles",
            "DiffviewLog",
            "DiffviewRefresh",
        },
        keys = {
            {
                "<Leader>go",
                "<cmd>DiffviewFileHistory<cr>",
                mode = "n",
                desc = "Git diffview file history",
            },
            {
                "<Leader>gO",
                "<cmd>DiffviewOpen<cr>",
                mode = "n",
                desc = "Git diffview open",
            },
            {
                "<C-q>",
                function()
                    vim.cmd("DiffviewClose")
                    vim.cmd("CloseFloatWindows")
                end,
                mode = "n",
                desc = "Git diffview close",
            },
        },
        opts = {},
    },
    codediff_nvim = {
        cmd = {
            "CodeDiff",
        },
        keys = {
            {
                "<Leader>gd",
                "<cmd>CodeDiff<cr>",
                mode = "n",
                desc = "Git code diff",
            },
        },
        opts = {},
    },
    time_machine_nvim = {
        cmd = {
            "TimeMachineToggle",
            "TimeMachinePurgeBuffer",
            "TimeMachinePurgeAll",
            "TimeMachineLogShow",
            "TimeMachineLogClear",
        },
        keys = {
            {
                "<leader>u",
                "",
                desc = "Time Machine",
            },
            {
                "<leader>ut",
                "<cmd>TimeMachineToggle<cr>",
                desc = "[Time Machine] Toggle Tree",
            },
            {
                "<leader>up",
                "<cmd>TimeMachinePurgeCurrent<cr>",
                desc = "[Time Machine] Purge current",
            },
            {
                "<leader>uP",
                "<cmd>TimeMachinePurgeAll<cr>",
                desc = "[Time Machine] Purge all",
            },
            {
                "<leader>ul",
                "<cmd>TimeMachineLogShow<cr>",
                desc = "[Time Machine] Show log",
            },
        },
        opts = {
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
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
