local modules = {}

modules["wakatime/vim-wakatime"] = {}

modules["xarthurx/taskwarrior.vim"] = {}

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

-- modules["tjdevries/nlua.nvim"] = {
--     requires = "neovim/nvim-lspconfig",
--     event = {
--         "BufRead",
--     },
--     config = function()
--         local languages_setup = require("languages.base.utils")
--         local nvim_lsp_util = require("lspconfig/util")
--         local default_debouce_time = 150
--         require("nlua.lsp.nvim").setup(require("lspconfig"), {
--             flags = {
--                 debounce_text_changes = default_debouce_time,
--             },
--             autostart = true,
--             filetypes = { "lua" },
--             on_attach = function(client, bufnr)
--                 vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
--                 languages_setup.document_highlight(client, bufnr)
--                 languages_setup.document_formatting(client, bufnr)
--             end,
--             capabilities = languages_setup.get_capabilities(),
--             root_dir = function(fname)
--                 return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
--             end,
--         })
--     end,
-- }

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
        vim.g.calendar_diary = "~/Org/diary/"
        vim.g.calendar_diary_path_pattern = "{YYYY}-{MM}-{DD}{EXT}"
        vim.g.calendar_monday = 1
        vim.g.calendar_weeknm = 1
    end,
}

-- modules["nvim-neorg/neorg"] = {
--     after = { "nvim-treesitter", "nvim-cmp" },
--     config = function()
--         require("nvim-treesitter.configs").setup({
--             ensure_installed = {
--                 "norg", --[[ other parsers you would wish to have ]]
--             },
--             highlight = { -- Be sure to enable highlights if you haven't!
--                 enable = true,
--             },
--         })
--         require("neorg").setup({
--             load = {
--                 ["core.keybinds"] = { -- Configure core.keybinds
--                     config = {
--                         default_keybinds = true, -- Generate the default keybinds
--                         neorg_leader = "<Leader>o",
--                     },
--                 },
--                 ["core.highlights"] = {
--                     config = {
--                         CarryoverTag = {
--                             Begin = "+TSConstant",
--                             Name = {
--                                 Word = "+TSConstant",
--                             },
--                         },
--                     },
--                 },
--                 ["core.defaults"] = {},
--                 ["core.norg.concealer"] = {
--                     config = {
--                         icons = {
--                             todo = { enabled = true },
--                             list = { enabled = true },
--                             link = { enabled = true },
--                             ordered = { enabled = true },
--                             ordered_link = { enabled = true },
--                             heading = { enabled = true },
--                             marker = { enabled = true },
--                             definition = { enabled = true },
--                             footnote = { enabled = true },
--                             delimiter = { enabled = true },
--                         },
--                     },
--                 },
--                 ["core.export"] = {},
--                 ["core.gtd.base"] = {
--                     config = {
--                         workspace = "gtd",
--                     },
--                 },
--                 ["core.gtd.ui"] = {},
--                 ["core.gtd.helpers"] = {},
--                 ["core.gtd.queries"] = {},
--                 ["core.norg.completion"] = {
--                     config = {
--                         engine = "nvim-cmp",
--                     },
--                 },
--                 ["core.integrations.nvim-cmp"] = {},
--                 ["core.presenter"] = {
--                     config = {
--                         zen_mode = "zen-mode",
--                     },
--                 },
--                 ["core.export.markdown"] = {
--                     config = {
--                         extensions = "all",
--                     },
--                 },
--                 ["core.norg.dirman"] = {
--                     config = {
--                         workspaces = {
--                             work = "~/neorg/work",
--                             home = "~/neorg/home",
--                             gtd = "~/neorg/gtd",
--                         },
--                         index = "index.norg",
--                         autochdir = true,
--                     },
--                 },
--             },
--         })
--         -- vim.api.nvim_create_autocmd("FileType", {
--         --     pattern = "norg",
--         --     callback = function()
--         --         vim.opt.foldmethod = "marker"
--         --     end,
--         -- })
--     end,
--     requires = { "nvim-lua/plenary.nvim" },
-- }

modules["nvim-orgmode/orgmode"] = {
    config = function()
        require("orgmode").setup_ts_grammar()
        require("orgmode").setup({
            emacs_config = {
                config_path = "$HOME/.emacs.d/early-init.el",
            },
            org_agenda_files = { "/home/biserstoilov/Org/**/*" },
            org_default_notes_file = "/home/biserstoilov/Org/refile.org",
        })
    end,
}

modules["lvim-tech/lvim-org-utils"] = {
    ft = "org",
    config = function()
        require("lvim-org-utils").setup()
    end,
}

modules["dhruvasagar/vim-table-mode"] = {}

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
                headline_highlights = { "OrgTSHeadline" },
                codeblock_highlight = "OrgTSBlock",
                dash_highlight = "Dash",
                dash_string = "-",
                fat_headlines = true,
            },
            rmd = {
                source_pattern_start = "^```",
                source_pattern_end = "^```$",
                dash_pattern = "^---+$",
                headline_pattern = "^#+",
                headline_signs = { "OrgTSHeadline" },
                codeblock_sign = "OrgTSBlock",
                dash_highlight = "Dash",
                dash_string = "-",
                fat_headlines = true,
            },
            vimwiki = {
                source_pattern_start = "^{{{%a+",
                source_pattern_end = "^}}}$",
                dash_pattern = "^---+$",
                headline_pattern = "^=+",
                headline_highlights = { "OrgTSHeadline" },
                codeblock_highlight = "OrgTSBlock",
                dash_highlight = "Dash",
                dash_string = "-",
                fat_headlines = true,
            },
            org = {
                source_pattern_start = "#%+[bB][eE][gG][iI][nN]_[sS][rR][cC]",
                source_pattern_end = "#%+[eE][nN][dD]_[sS][rR][cC]",
                dash_pattern = "^-----+$",
                headline_pattern = "^%*+",
                headline_highlights = { "OrgTSHeadline" },
                codeblock_highlight = "OrgTSBlock",
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
