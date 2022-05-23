local config = {}

function config.nvim_lsp_installer()
    -- LSP buf

    vim.api.nvim_create_user_command("DapToggleBreakpoint", 'lua require("dap").toggle_breakpoint()', {})

    vim.api.nvim_create_user_command("LspAddToWorkspaceFolder", "lua vim.lsp.buf.add_workspace_folder()", {})
    vim.api.nvim_create_user_command("LspListWorkspaceFolders", "lua vim.lsp.buf.list_workspace_folders()", {})
    vim.api.nvim_create_user_command("LspRemoveWorkspaceFolder", "lua vim.lsp.buf.remove_workspace_folder()", {})
    vim.api.nvim_create_user_command("LspWorkspaceSymbol", "lua vim.lsp.buf.workspace_symbol()", {})
    vim.api.nvim_create_user_command("LspDocumentSymbol", "lua vim.lsp.buf.document_symbol()", {})
    vim.api.nvim_create_user_command("LspReferences", "lua vim.lsp.buf.references()", {})
    vim.api.nvim_create_user_command("LspClearReferences", "lua vim.lsp.buf.clear_references()", {})
    vim.api.nvim_create_user_command("LspCodeAction", "lua vim.lsp.buf.code_action()", {})
    vim.api.nvim_create_user_command("LspRangeCodeAction", "lua vim.api.nvim_create_user_command()", {})
    vim.api.nvim_create_user_command("LspCodeLensRefresh", "lua vim.lsp.codelens.refresh()", {})
    vim.api.nvim_create_user_command("LspCodeLensRun", "lua vim.lsp.codelens.run()", {})
    vim.api.nvim_create_user_command("LspDeclaration", "lua vim.lsp.buf.declaration()", {})
    vim.api.nvim_create_user_command("LspDefinition", "lua vim.lsp.buf.definition()", {})
    vim.api.nvim_create_user_command("LspTypeDefinition", "lua vim.lsp.buf.type_definition()", {})
    vim.api.nvim_create_user_command("LspDocumentHighlight", "lua vim.lsp.buf.document_highlight()", {})
    vim.api.nvim_create_user_command("LspImplementation", "lua vim.lsp.buf.implementation()", {})
    vim.api.nvim_create_user_command("LspIncomingCalls", "lua vim.lsp.buf.incoming_calls()", {})
    vim.api.nvim_create_user_command("LspOutgoingCalls", "lua vim.lsp.buf.outgoing_calls()", {})
    if vim.fn.has("nvim-0.8") == 1 then
        vim.api.nvim_create_user_command("LspFormatting", "lua vim.lsp.buf.format {async = true}", {})
        -- vim.cmd("command! LspRangeFormatting lua vim.lsp.buf.range_format {async = true}")
    else
        vim.api.nvim_create_user_command("LspFormatting", "lua vim.lsp.buf.formatting()", {})
        -- vim.cmd("command! LspRangeFormatting lua vim.lsp.buf.range_formatting)")
    end
    vim.api.nvim_create_user_command("LspFormattingSync", "lua vim.lsp.buf.formatting_sync()", {})
    vim.api.nvim_create_user_command("LspHover", "lua vim.lsp.buf.hover()", {})
    vim.api.nvim_create_user_command("LspRename", "lua vim.lsp.buf.rename()", {})
    vim.api.nvim_create_user_command("LspSignatureHelp", "lua vim.lsp.buf.signature_help()", {})
    -- LSP diagnostic
    vim.api.nvim_create_user_command("LspLine", "lua require('languages.global.utils.diagnostics').line()", {})
    vim.api.nvim_create_user_command("LspGoToNext", "lua require('languages.global.utils.diagnostics').goto_next()", {})
    vim.api.nvim_create_user_command("LspGoToPrev", "lua require('languages.global.utils.diagnostics').goto_prev()", {})
    -- Virtual text toggle
    vim.api.nvim_create_user_command(
        "LspVirtualTextToggle",
        "lua require('languages.global.utils').toggle_virtual_text()",
        {}
    )
    require("nvim-lsp-installer").setup({
        ensure_installed = {
            "emmet_ls",
            "eslint",
            "stylelint_lsp",
            "angularls",
            "clojure_lsp",
            "cmake",
            "clangd",
            "omnisharp",
            "cssls",
            "serve_d",
            "elixirls",
            "elmls",
            "ember",
            "erlangls",
            "fortls",
            "gopls",
            "golangci_lint_ls",
            "graphql",
            "groovyls",
            "html",
            "jdtls",
            "jsonls",
            "tsserver",
            "julials",
            "kotlin_language_server",
            "ltex",
            "sumneko_lua",
            "grammarly",
            "perlnavigator",
            "intelephense",
            "phpactor",
            "pyright",
            "r_language_server",
            "solargraph",
            "rust_analyzer",
            "bashls",
            "sqls",
            "taplo",
            "vimls",
            "volar",
            "lemminx",
            "yamlls",
            "zls",
        },
        automatic_installation = true,
        ui = {
            icons = {
                server_installed = "",
                server_pending = "",
                server_uninstalled = "",
            },
        },
    })
    require("languages.global.utils").setup_diagnostic()
    require("languages.global.diagnosticls").init_diagnosticls()
end

function config.go()
    require("go").setup({})
end

function config.trld()
    require("trld").setup()
end

function config.popfix()
    vim.ui.input = require("core.ui.input")
    vim.ui.select = require("core.ui.select")
end

function config.nvim_lightbulb()
    require("nvim-lightbulb").setup({
        sign = {
            enabled = true,
            priority = 10,
        },
        virtual_text = {
            enabled = true,
            text = "",
            hl_mode = "combine",
        },
        autocmd = {
            enabled = true,
        },
    })
    vim.fn.sign_define("LightBulbSign", { text = " ▎", texthl = "LightBulb", linehl = "", numhl = "" })
end

function config.sniprun()
    require("sniprun").setup()
end

function config.nvim_treesitter()
    require("nvim-treesitter.configs").setup({
        ensure_installed = "all",
        playground = {
            enable = true,
            disable = {},
            updatetime = 25,
            persist_queries = false,
            keybindings = {
                toggle_query_editor = "o",
                toggle_hl_groups = "i",
                toggle_injected_languages = "t",
                toggle_anonymous_nodes = "a",
                toggle_language_display = "I",
                focus_language = "f",
                unfocus_language = "F",
                update = "R",
                goto_node = "<cr>",
                show_help = "?",
            },
        },
        highlight = {
            enable = true,
            disable = { "org" },
            additional_vim_regex_highlighting = { "org" },
        },
        indent = {
            enable = true,
            disable = { "html" },
        },
        autopairs = {
            enable = true,
            disable = { "html" },
        },
        autotag = {
            enable = true,
            disable = { "html" },
        },
        rainbow = {
            enable = true,
            disable = { "html" },
        },
        context_commentstring = {
            enable = true,
            disable = { "html" },
            config = {
                javascriptreact = {
                    style_element = "{/*%s*/}",
                },
            },
        },
    })
end

function config.nvim_gps()
    local status_ok, gps = pcall(require, "nvim-gps")
    if not status_ok then
        return
    end
    local icons = require("core.ui.icons")
    gps.setup({
        disable_icons = false,
        icons = {
            ["class-name"] = "%#WinBar#" .. icons.kind.Class .. " " .. "%*" .. "",
            ["function-name"] = "%#WinBar#" .. icons.kind.Function .. " " .. "%*" .. "",
            ["method-name"] = "%#WinBar#" .. icons.kind.Method .. " " .. "%*" .. "",
            ["container-name"] = "%#WinBar#" .. icons.type.Object .. " " .. "%*" .. "",
            ["tag-name"] = "%#WinBar#" .. icons.misc.Tag .. " " .. "%*" .. " ",
            ["mapping-name"] = "%#WinBar#" .. icons.type.Object .. " " .. "%*" .. "",
            ["sequence-name"] = "%#WinBar#" .. icons.type.Array .. " " .. "%*" .. "",
            ["null-name"] = "%#WinBar#" .. icons.kind.Field .. " " .. "%*" .. "",
            ["integer-name"] = "%#WinBar#" .. icons.type.Number .. " " .. "%*" .. "",
            ["float-name"] = "%#WinBar#" .. icons.type.Number .. " " .. "%*" .. "",
            ["string-name"] = "%#WinBar#" .. icons.type.String .. " " .. "%*" .. "",
            ["array-name"] = "%#WinBar#" .. icons.type.Array .. " " .. "%*" .. "",
            ["object-name"] = "%#WinBar#" .. icons.type.Object .. " " .. "%*" .. "",
            ["number-name"] = "%#WinBar#" .. icons.type.Number .. " " .. "%*" .. "",
            ["table-name"] = "%#WinBar#" .. icons.ui.Table .. " " .. "%*" .. "",
            ["date-name"] = "%#WinBar#" .. icons.ui.Calendar .. " " .. "%*" .. "",
            ["date-time-name"] = "%#WinBar#" .. icons.ui.Table .. " " .. "%*" .. "",
            ["inline-table-name"] = "%#WinBar#" .. icons.ui.Calendar .. " " .. "%*" .. "",
            ["time-name"] = "%#WinBar#" .. icons.misc.Watch .. " " .. "%*" .. "",
            ["module-name"] = "%#WinBar#" .. icons.kind.Module .. " " .. "%*" .. "",
        },
        separator = " " .. icons.ui.ChevronRight .. " ",
        depth = 0,
        depth_limit_indicator = "..",
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost" }, {
        callback = function()
            local filetype_exclude = {
                "ctrlspace",
                "packer",
                "undotree",
                "diff",
                "Outline",
                "NvimTree",
                "LvimHelper",
                "floaterm",
                "toggleterm",
                "Trouble",
                "dashboard",
                "vista",
                "spectre_panel",
                "DiffviewFiles",
                "flutterToolsOutline",
                "log",
                "qf",
                "dapui_scopes",
                "dapui_breakpoints",
                "dapui_stacks",
                "dapui_watches",
                "calendar",
            }
            if vim.tbl_contains(filetype_exclude, vim.bo.filetype) then
                vim.opt_local.winbar = nil
                return
            end
            --[[ local value = require("core.ui.winbar").gps_treesitter()

            if value == nil then
                value = require("core.ui.winbar").filename()
            end

            vim.opt_local.winbar = value ]]
            vim.opt_local.winbar = require("core.ui.winbar").gps_treesitter()
        end,
    })
end

function config.any_jump()
    vim.g.any_jump_disable_default_keybindings = 1
    vim.g.any_jump_list_numbers = 1
end

function config.trouble()
    require("trouble").setup({
        height = 12,
        mode = "workspace_diagnostics",
        use_diagnostic_signs = true,
        signs = {
            error = "",
            warning = "",
            hint = "",
            information = "",
            other = "",
        },
    })
end

function config.symbols_outline()
    require("symbols-outline").setup({
        highlight_hovered_item = true,
        show_guides = true,
        preview_bg_highlight = "Float",
    })
end

function config.nvim_dap_ui()
    local dapui = require("dapui")
    local dap = require("dap")
    dapui.setup({
        icons = {
            expanded = "▾",
            collapsed = "▸",
        },
        mappings = {
            expand = {
                "<CR>",
                "<2-LeftMouse>",
            },
            open = "o",
            remove = "d",
            edit = "e",
            repl = "r",
        },
        sidebar = {
            elements = {
                {
                    id = "scopes",
                    size = 0.25,
                },
                {
                    id = "breakpoints",
                    size = 0.25,
                },
                {
                    id = "stacks",
                    size = 0.25,
                },
                {
                    id = "watches",
                    size = 00.25,
                },
            },
            size = 40,
            position = "left",
        },
        tray = {
            elements = {
                "repl",
            },
            size = 10,
            position = "bottom",
        },
        floating = {
            max_height = nil,
            max_width = nil,
            mappings = {
                close = {
                    "q",
                    "<Esc>",
                },
            },
        },
        windows = {
            indent = 1,
        },
    })
    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end
    vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "",
        linehl = "",
        numhl = "",
    })
    vim.fn.sign_define("DapStopped", {
        text = "",
        texthl = "",
        linehl = "",
        numhl = "",
    })
    vim.fn.sign_define("DapLogPoint", {
        text = "▶",
        texthl = "",
        linehl = "",
        numhl = "",
    })
    vim.api.nvim_create_user_command("DapToggleBreakpoint", 'lua require("dap").toggle_breakpoint()', {})
    vim.api.nvim_create_user_command("DapStartContinue", 'lua require"dap".continue()', {})
    vim.api.nvim_create_user_command("DapStepInto", 'lua require"dap".step_into()', {})
    vim.api.nvim_create_user_command("DapStepOver", 'lua require"dap".step_over()', {})
    vim.api.nvim_create_user_command("DapStepOut", 'lua require"dap".step_out()', {})
    vim.api.nvim_create_user_command("DapUp", 'lua require"dap".up()', {})
    vim.api.nvim_create_user_command("DapDown", 'lua require"dap".down()', {})
    vim.api.nvim_create_user_command("DapPause", 'lua require"dap".pause()', {})
    vim.api.nvim_create_user_command("DapClose", 'lua require"dap".close()', {})
    vim.api.nvim_create_user_command("DapDisconnect", 'lua require"dap".disconnect()', {})
    vim.api.nvim_create_user_command("DapRestart", 'lua require"dap".restart()', {})
    vim.api.nvim_create_user_command("DapToggleRepl", 'lua require"dap".repl.toggle()', {})
    vim.api.nvim_create_user_command("DapGetSession", 'lua require"dap".session()', {})
    vim.api.nvim_create_user_command(
        "DapUIClose",
        'lua require"dap".close(); require"dap".disconnect(); require"dapui".close()',
        {}
    )
end

function config.dapinstall()
    local path_debuggers = vim.fn.stdpath("data") .. "/dapinstall/"
    require("dap-install").setup({
        installation_path = path_debuggers,
    })
end

function config.vim_dadbod_ui()
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_win_position = "left"
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_winwidth = 35
    vim.api.nvim_set_keymap("n", "<leader>Du", ":DBUIToggle<CR>", {
        noremap = true,
        silent = true,
    })
    vim.api.nvim_set_keymap("n", "<leader>Df", ":DBUIFindBuffer<CR>", {
        noremap = true,
        silent = true,
    })
    vim.api.nvim_set_keymap("n", "<leader>Dr", ":DBUIRenameBuffer<CR>", {
        noremap = true,
        silent = true,
    })
    vim.api.nvim_set_keymap("n", "<leader>Dl", ":DBUILastQueryInfo<CR>", {
        noremap = true,
        silent = true,
    })
    vim.g.db_ui_auto_execute_table_helpers = true
end

function config.package_info()
    require("package-info").setup({
        colors = {
            up_to_date = "#98c379",
            outdated = "#F05F4E",
        },
    })
end

function config.crates()
    require("crates").setup()
    vim.api.nvim_create_user_command("CratesUpdate", "lua require('crates').update()", {})
    vim.api.nvim_create_user_command("CratesReload", "lua require('crates').reload()", {})
    vim.api.nvim_create_user_command("CratesHide", "lua require('crates').hide()", {})
    vim.api.nvim_create_user_command("CratesToggle", "lua require('crates').toggle()", {})
    vim.api.nvim_create_user_command("CratesUpdateCrate", "lua require('crates').update_crate()", {})
    vim.api.nvim_create_user_command("CratesUpdateCrates", "lua require('crates').update_crates()", {})
    vim.api.nvim_create_user_command("CratesUpdateAllCrates", "lua require('crates').update_all_crates()", {})
    vim.api.nvim_create_user_command("CratesUpgradeCrate", "lua require('crates').upgrade_crate()", {})
    vim.api.nvim_create_user_command("CratesUpgradeCrates", "lua require('crates').upgrade_crates()", {})
    vim.api.nvim_create_user_command("CratesUpgradeAllCrates", "lua require('crates').upgrade_all_crates()", {})
    vim.api.nvim_create_user_command("CratesShowPopup", "lua require('crates').show_popup()", {})
    vim.api.nvim_create_user_command("CratesShowVersionsPopup", "lua require('crates').show_versions_popup()", {})
    vim.api.nvim_create_user_command("CratesShowFeaturesPopup", "lua require('crates').show_features_popup()", {})
    vim.api.nvim_create_user_command("CratesFocusPopup", "lua require('crates').focus_popup()", {})
    vim.api.nvim_create_user_command("CratesHidePopup", "lua require('crates').hide_popup()", {})
end

function config.pubspec_assist()
    require("pubspec-assist").setup()
end

function config.vimtex()
    vim.g.vimtex_view_method = "zathura"
    vim.g.latex_view_general_viewer = "zathura"
    vim.g.vimtex_compiler_progname = "nvr"
    vim.g.vimtex_compiler_callback_compiling = "nvr"
end

function config.orgmode()
    require("orgmode").setup_ts_grammar()
    require("orgmode").setup({
        org_agenda_files = "~/Org/**/*",
        org_default_notes_file = "~/Org/notes.org",
    })
end

function config.org_bullets()
    require("org-bullets").setup({
        symbols = { "◉", "○", "✸" },
    })
end

return config
