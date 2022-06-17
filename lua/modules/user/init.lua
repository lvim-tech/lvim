local modules = {}

modules["wakatime/vim-wakatime"] = {}

modules["christoomey/vim-tmux-navigator"] = {}

modules["lvim-tech/lvim-kbrd"] = {
    event = {
        "BufRead",
    },
    config = function()
        require("lvim-kbrd").setup()
        local map = require("lvim-kbrd.utils").map
        map("n", "<C-c>l", ":LvimKbrdToggle<CR>", { silent = false })
    end,
}

modules["tjdevries/nlua.nvim"] = {
    requires = "neovim/nvim-lspconfig",
    event = {
        "BufRead",
    },
    config = function()
        local languages_setup = require("languages.base.utils")
        require("nlua.lsp.nvim").setup(require("lspconfig"), {
            on_attach = function(client, bufnr)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                languages_setup.document_highlight(client, bufnr)
                languages_setup.document_formatting(client, bufnr)
            end,
        })
    end,
}

modules["smjonas/inc-rename.nvim"] = {
    cmd = "IncRename",
    config = function()
        if vim.fn.has("nvim-0.8") == 1 then
            require("inc_rename").setup()
        end
    end,
}

modules["renerocksai/calendar-vim"] = {
    cmd = { "Calendar", "CalendarH", "CalendarT", "CalendarVR" },
    config = function()
        vim.g.calendar_diary_extension = ".org"
        vim.g.calendar_diary = "~/BS/diary/"
        vim.g.calendar_diary_path_pattern = "{YYYY}-{MM}-{DD}{EXT}"
        vim.g.calendar_monday = 1
        vim.g.calendar_weeknm = 1
    end,
}

modules["nvim-orgmode/orgmode"] = {
    ft = "org",
    config = function()
        require("orgmode").setup_ts_grammar()
        require("nvim-treesitter.configs").setup({
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "org" },
            },
        })
        require("orgmode").setup({
            org_agenda_files = { "~/BS/*" },
            org_default_notes_file = "~/BS/reindex.org",
        })
    end,
}

modules["lvim-tech/org-bullets.nvim"] = {
    branch = "lvim",
    ft = "org",
    config = function()
        require("org-bullets").setup()
    end,
}

modules["lvim-tech/lvim-orglinks"] = {
    config = function()
        require("lvim-orglinks").setup()
    end,
}

-- modules["lvim-tech/lvim-projects"] = {
--     rocks = "lunajson",
--     config = function()
--         -- require("lvim-projects").setup()
--         -- local map = require("lvim-projects.utils").map
--         -- map("n", "<C-c>l", ":LvimKbrdToggle<CR>", { silent = false })
--     end,
-- }

-- modules["NTBBloodbath/rest.nvim"] = {
--     requires = { "nvim-lua/plenary.nvim" },
--     config = function()
--         require("rest-nvim").setup({})
--     end,
-- }

--[[ modules["smjonas/snippet-converter.nvim"] = {
    -- SnippetConverter uses semantic versioning. Example: use version = "1.*" to avoid breaking changes on version 1.
    -- Uncomment the next line to follow stable releases only.
    -- version = "*",
    config = function()
        local template = {
            -- name = "t1", (optionally give your template a name to refer to it in the `ConvertSnippets` command)
            sources = {
                ultisnips = {
                    -- Add snippets from (plugin) folders or individual files on your runtimepath...
                    "/home/biserstoilov/.config/nvim/vim-snippets/UltiSnips",
                    -- ...or use absolute paths on your system.
                },
                snipmate = {
                    "/home/biserstoilov/.config/nvim/vim-snippets/snippets",
                },
            },
            output = {
                -- Specify the output formats and paths
                vscode_luasnip = {
                    "/home/biserstoilov/.config/nvim/luasnip_snippets",
                },
            },
        }

        require("snippet_converter").setup({
            templates = { template },
            -- To change the default settings (see configuration section in the documentation)
            -- settings = {},
        })
    end,
} ]]

-- modules["tversteeg/registers.nvim"] = {}

--[[ modules["vimwiki/vimwiki"] = {
    branch = "dev",
    config = function()
        local home = vim.fn.expand("~/ORG")
        vim.g.vimwiki_list = {
            {
                path = home .. "/",
                template_path = home .. "/" .. "templates/",
                -- template_default = "default",
                syntax = "org",
                ext = ".org",
                -- path_html = home .. "/" .. "site_html/",
                -- custom_wiki2html = "vimwiki_markdown",
                -- template_ext = ".tpl",
            },
        }
        local colors = _G.LVIM_COLORS()
        local hl_group = "calendar"
        vim.api.nvim_set_hl(0, hl_group, { bg = colors.status_line_bg })
    end,
} ]]

--[[ modules["lukas-reineke/headlines.nvim"] = {
    config = function()
        require("headlines").setup({
            markdown = {
                source_pattern_start = "^```",
                source_pattern_end = "^```$",
                dash_pattern = "^---+$",
                headline_pattern = "^#+",
                headline_highlights = { "Headline" },
                codeblock_highlight = "CodeBlock",
                dash_highlight = "Dash",
                dash_string = "-",
                fat_headlines = true,
            },
            rmd = {
                source_pattern_start = "^```",
                source_pattern_end = "^```$",
                dash_pattern = "^---+$",
                headline_pattern = "^#+",
                headline_signs = { "Headline" },
                codeblock_sign = "CodeBlock",
                dash_highlight = "Dash",
                dash_string = "-",
                fat_headlines = true,
            },
            vimwiki = {
                source_pattern_start = "^{{{%a+",
                source_pattern_end = "^}}}$",
                dash_pattern = "^---+$",
                headline_pattern = "^=+",
                headline_highlights = { "Headline" },
                codeblock_highlight = "CodeBlock",
                dash_highlight = "Dash",
                dash_string = "-",
                fat_headlines = true,
            },
            org = {
                source_pattern_start = "#%+[bB][eE][gG][iI][nN]_[sS][rR][cC]",
                source_pattern_end = "#%+[eE][nN][dD]_[sS][rR][cC]",
                dash_pattern = "^-----+$",
                headline_pattern = "^%*+",
                headline_highlights = { "Headline" },
                codeblock_highlight = "CodeBlock",
                dash_highlight = "Dash",
                dash_string = "-",
                fat_headlines = true,
            },
        })
    end,
} ]]

--[[ modules["ranjithshegde/orgWiki.nvim"] = {
    ft = "org",
    config = function()
        require("orgWiki").setup({
            wiki_path = { "~/BS/" },
            diary_path = "~/BS/diary/",
        })
    end,
} ]]

-- modules["renerocksai/telekasten.nvim"] = {
--     requires = {
--         "renerocksai/calendar-vim",
--         after = "telekasten.nvim",
--     },
--     config = function()
--         local home = vim.fn.expand("~/Notes")
--         require("telekasten").setup({
--             home = home,
--             take_over_my_home = true,
--             auto_set_filetype = true,
--             dailies = home .. "/" .. "daily",
--             weeklies = home .. "/" .. "weekly",
--             templates = home .. "/" .. "templates",
--             image_subdir = "img",
--             extension = ".md",
--             new_note_filename = "title",
--             uuid_type = "%Y%m%d%H%M",
--             uuid_sep = "-",
--             follow_creates_nonexisting = true,
--             dailies_create_nonexisting = true,
--             weeklies_create_nonexisting = true,
--             journal_auto_open = false,
--             template_new_note = home .. "/" .. "templates/new_note.md",
--             template_new_daily = home .. "/" .. "templates/daily.md",
--             template_new_weekly = home .. "/" .. "templates/weekly.md",
--             image_link_style = "markdown",
--             sort = "filename",
--             plug_into_calendar = true,
--             calendar_opts = {
--                 weeknm = 4,
--                 calendar_monday = 1,
--                 calendar_mark = "left-fit",
--             },
--             close_after_yanking = false,
--             insert_after_inserting = true,
--             tag_notation = "#tag",
--             command_palette_theme = "ivy",
--             show_tags_theme = "ivy",
--             subdirs_in_links = true,
--             template_handling = "smart",
--             new_note_location = "smart",
--             rename_update_links = true,
--         })
--         vim.api.nvim_set_keymap("n", "tc", ":Telekasten show_calendar<CR>", { silent = true })
--     end,
-- }

return modules
