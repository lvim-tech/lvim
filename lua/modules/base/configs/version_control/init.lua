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
            live_gutter = {
                enabled = true,
                edge_navigation = false,
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
    vim.keymap.set("n", "<Leader>g]", function()
        vgit.hunk_down()
    end, { noremap = true, silent = true, desc = "Git hunk next" })
    vim.keymap.set("n", "<Leader>g[", function()
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

config.undotree = function()
    vim.keymap.set("n", "<F5>", function()
        vim.cmd("UndotreeToggle")
    end, { noremap = true, silent = true, desc = "UndotreeToggle" })
end

return config
