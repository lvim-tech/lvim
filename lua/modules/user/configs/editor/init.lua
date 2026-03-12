local config = {}

config.avante_nvim = function()
    local avante_nvim_status_ok, avante_nvim = pcall(require, "avante")
    if not avante_nvim_status_ok then
        return
    end
    avante_nvim.setup({
        build = "make",
        provider = "deepseek",
        providers = {
            deepseek = {
                __inherited_from = "openai",
                api_key_name = "sk-0fa36a0208394bf9a5c5615a035300f1",
                endpoint = "https://api.deepseek.com",
                model = "deepseek-coder",
                max_tokens = 8192,
            },
        },
        -- provider = "copilot",
        -- providers = {
        --     copilot = {
        --         model = "gpt-4o",
        --     },
        -- },
    })
end

config.obsidian_nvim = function()
    local obsidian_nvim_status_ok, obsidian_nvim = pcall(require, "obsidian")
    if not obsidian_nvim_status_ok then
        return
    end
    obsidian_nvim.setup({
        legacy_commands = false,
        workspaces = {
            {
                name = "Literature",
                path = "~/obsidian/literature",
            },
            {
                name = "School",
                path = "~/obsidian/school",
            },
            {
                name = "Cli",
                path = "~/obsidian/cli",
            },
            {
                name = "Development",
                path = "~/obsidian/development",
            },
        },
        daily_notes = {
            folder = "notes",
            date_format = "%Y-%m-%d",
            alias_format = "%B %-d, %Y",
            default_tags = { "daily-notes" },
            template = nil,
        },
        checkbox = {
            order = {},
        },
        completion = {
            nvim_cmp = false,
            blink = {
                enabled = true,
                obsidian = { score_offset = 10 },
                obsidian_tags = {
                    score_offset = 10,
                    transform_items = function(_, items)
                        for _, item in ipairs(items) do
                            item.kind = 10
                        end
                        return items
                    end,
                },
            },
            min_chars = 0,
        },
    })
    vim.api.nvim_set_hl(0, "ObsidianRefText", { fg = _G.LVIM_COLORS.red })
    vim.api.nvim_set_hl(0, "ObsidianExtLinkIcon", { fg = _G.LVIM_COLORS.red })
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }
    map(
        "n",
        "<leader>md",
        "<cmd>Obsidian today<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Open today's note" })
    )
    map(
        "n",
        "<leader>my",
        "<cmd>Obsidian yesterday<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Open yesterday's note" })
    )
    map(
        "n",
        "<leader>mt",
        "<cmd>Obsidian tomorrow<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Open tomorrow's note" })
    )
    map(
        "n",
        "<leader>mD",
        "<cmd>Obsidian dailies<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Browse daily notes" })
    )
    map(
        "n",
        "<leader>mn",
        "<cmd>Obsidian new<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Create new note" })
    )
    map(
        "n",
        "<leader>mN",
        "<cmd>Obsidian newfromtemplate<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: New from template" })
    )
    map(
        "v",
        "<leader>me",
        "<cmd>Obsidian extractnote<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Extract to new note" })
    )
    map(
        "n",
        "<leader>mf",
        "<cmd>Obsidian followlink<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Follow link under cursor" })
    )
    map(
        "v",
        "<leader>ml",
        "<cmd>Obsidian link<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Link to existing note" })
    )
    map(
        "v",
        "<leader>mL",
        "<cmd>Obsidian linknew<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Link to new note" })
    )
    map(
        "n",
        "<leader>mb",
        "<cmd>Obsidian backlinks<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Show backlinks" })
    )
    map(
        "n",
        "<leader>ml",
        "<cmd>Obsidian links<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Show all links" })
    )
    map(
        "n",
        "<leader>ms",
        "<cmd>Obsidian search<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Search vault" })
    )
    map(
        "n",
        "<leader>mq",
        "<cmd>Obsidian quickswitch<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Quick switch note" })
    )
    map("n", "<leader>mo", "<cmd>Obsidian open<CR>", vim.tbl_extend("force", opts, { desc = "Obsidian: Open in app" }))
    map(
        "n",
        "<leader>mp",
        "<cmd>Obsidian pasteimg<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Paste image" })
    )
    map(
        "n",
        "<leader>mc",
        "<cmd>Obsidian togglecheckbox<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Toggle checkbox" })
    )
    map(
        "n",
        "<leader>mi",
        "<cmd>Obsidian template<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Insert template" })
    )
    map("n", "<leader>mg", "<cmd>Obsidian tags<CR>", vim.tbl_extend("force", opts, { desc = "Obsidian: Browse tags" }))
    map(
        "n",
        "<leader>m.",
        "<cmd>Obsidian toc<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Table of Contents" })
    )
    map(
        "n",
        "<leader>mw",
        "<cmd>Obsidian workspace<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Workspace" })
    )
    map(
        "n",
        "<leader>mr",
        "<cmd>Obsidian rename<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Rename note" })
    )
    map(
        "n",
        "<leader>m?",
        "<cmd>Obsidian check<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Check for issues" })
    )
    map(
        "n",
        "<leader>m!",
        "<cmd>Obsidian debug<CR>",
        vim.tbl_extend("force", opts, { desc = "Obsidian: Debug information" })
    )
    map("n", "<leader>mO", "<cmd>Obsidian<CR>", vim.tbl_extend("force", opts, { desc = "Obsidian: Generic command" }))
end

config.kitty_scrollback_nvim = function()
    local kitty_scrollback_nvim_status_ok, kitty_scrollback_nvim = pcall(require, "kitty-scrollback")
    if not kitty_scrollback_nvim_status_ok then
        return
    end
    kitty_scrollback_nvim.setup()
end

return config
