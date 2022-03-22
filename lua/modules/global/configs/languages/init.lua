local config = {}

function config.nvim_lspconfig()
    require("languages.global.utils").setup_diagnostic()
    require("languages.global.diagnosticls").init_diagnosticls()
    -- LSP buf
    vim.cmd("command! LspAddToWorkspaceFolder lua vim.lsp.buf.add_workspace_folder()")
    vim.cmd("command! LspListWorkspaceFolders lua vim.lsp.buf.list_workspace_folders()")
    vim.cmd("command! LspRemoveWorkspaceFolder lua vim.lsp.buf.remove_workspace_folder()")
    vim.cmd("command! LspWorkspaceSymbol lua vim.lsp.buf.workspace_symbol()")
    vim.cmd("command! LspDocumentSymbol lua vim.lsp.buf.document_symbol()")
    vim.cmd("command! LspReferences lua vim.lsp.buf.references()")
    vim.cmd("command! LspClearReferences lua vim.lsp.buf.clear_references()")
    vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
    vim.cmd("command! LspRangeCodeAction lua vim.lsp.buf.range_code_action()")
    vim.cmd("command! LspDeclaration lua vim.lsp.buf.declaration()")
    vim.cmd("command! LspDefinition lua vim.lsp.buf.definition()")
    vim.cmd("command! LspTypeDefinition lua vim.lsp.buf.type_definition()")
    vim.cmd("command! LspDocumentHighlight lua vim.lsp.buf.document_highlight()")
    vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
    vim.cmd("command! LspIncomingCalls lua vim.lsp.buf.incoming_calls()")
    vim.cmd("command! LspOutgoingCalls lua vim.lsp.buf.outgoing_calls()")
    vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting()")
    vim.cmd("command! LspRangeFormatting lua vim.lsp.buf.range_formatting()")
    vim.cmd("command! LspFormattingSync lua vim.lsp.buf.formatting_sync()")
    vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
    vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
    vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")
    -- LSP diagnostic
    vim.cmd("command! LspGoToNext lua require('languages.global.utils.diagnostics').goto_next()")
    vim.cmd("command! LspGoToPrev lua require('languages.global.utils.diagnostics').goto_prev()")
    -- Virtual text toggle
    vim.cmd("command! LspVirtualTextToggle lua require('languages.global.utils').toggle_virtual_text()")
end

function config.nvim_lsp_installer()
    require("nvim-lsp-installer").settings {
        ui = {
            icons = {
                server_installed = "",
                server_pending = "",
                server_uninstalled = ""
            }
        }
    }
end

function config.go()
    require("go").setup({})
end

function config.sniprun()
    require("sniprun").setup()
end

function config.nvim_treesitter()
    require("nvim-treesitter.configs").setup {
        ensure_installed = "all",
        highlight = {
            enable = true,
            disable = {"org"},
            additional_vim_regex_highlighting = {"org"}
        },
        indent = {
            enable = {
                "javascriptreact"
            }
        },
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
                show_help = "?"
            }
        },
        autopairs = {
            enable = true
        },
        autotag = {
            enable = true
        },
        rainbow = {
            enable = true
        },
        context_commentstring = {
            enable = true,
            config = {
                javascriptreact = {
                    style_element = "{/*%s*/}"
                }
            }
        }
    }
end

function config.any_jump()
    vim.g.any_jump_disable_default_keybindings = 1
    vim.g.any_jump_list_numbers = 1
end

function config.trouble()
    require("trouble").setup {
        height = 12,
        mode = "document_diagnostics",
        use_diagnostic_signs = true,
        signs = {
            error = "",
            warning = "",
            hint = "",
            information = "",
            other = ""
        }
    }
end

function config.symbols_outline()
    require("symbols-outline").setup {
        highlight_hovered_item = true,
        show_guides = true,
        preview_bg_highlight = "Float"
    }
end

function config.nvim_dap_ui()
    local dapui = require("dapui")
    local dap = require("dap")
    dapui.setup(
        {
            icons = {
                expanded = "▾",
                collapsed = "▸"
            },
            mappings = {
                expand = {
                    "<CR>",
                    "<2-LeftMouse>"
                },
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r"
            },
            sidebar = {
                elements = {
                    {
                        id = "scopes",
                        size = 0.25
                    },
                    {
                        id = "breakpoints",
                        size = 0.25
                    },
                    {
                        id = "stacks",
                        size = 0.25
                    },
                    {
                        id = "watches",
                        size = 00.25
                    }
                },
                size = 40,
                position = "left"
            },
            tray = {
                elements = {
                    "repl"
                },
                size = 10,
                position = "bottom"
            },
            floating = {
                max_height = nil,
                max_width = nil,
                mappings = {
                    close = {
                        "q",
                        "<Esc>"
                    }
                }
            },
            windows = {
                indent = 1
            }
        }
    )
    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end
    vim.fn.sign_define(
        "DapBreakpoint",
        {
            text = "",
            texthl = "",
            linehl = "",
            numhl = ""
        }
    )
    vim.fn.sign_define(
        "DapStopped",
        {
            text = "",
            texthl = "",
            linehl = "",
            numhl = ""
        }
    )
    vim.fn.sign_define(
        "DapLogPoint",
        {
            text = "▶",
            texthl = "",
            linehl = "",
            numhl = ""
        }
    )
    vim.cmd('command! DapToggleBreakpoint lua require"dap".toggle_breakpoint()')
    vim.cmd('command! DapStartContinue lua require"dap".continue()')
    vim.cmd('command! DapStepInto lua require"dap".step_into()')
    vim.cmd('command! DapStepOver lua require"dap".step_over()')
    vim.cmd('command! DapStepOut lua require"dap".step_out()')
    vim.cmd('command! DapUp lua require"dap".up()')
    vim.cmd('command! DapDown lua require"dap".down()')
    vim.cmd('command! DapPause lua require"dap".pause()')
    vim.cmd('command! DapClose lua require"dap".close()')
    vim.cmd('command! DapDisconnect lua require"dap".disconnect()')
    vim.cmd('command! DapRestart lua require"dap".restart()')
    vim.cmd('command! DapToggleRepl lua require"dap".repl.toggle()')
    vim.cmd('command! DapGetSession lua require"dap".session()')
    vim.cmd('command! DapUIClose lua require"dap".close(); require"dap".disconnect(); require"dapui".close()')
end

function config.dapinstall()
    local path_debuggers = vim.fn.stdpath("data") .. "/dapinstall/"
    require("dap-install").setup(
        {
            installation_path = path_debuggers
        }
    )
end

function config.vim_dadbod_ui()
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_win_position = "left"
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_winwidth = 35
    vim.api.nvim_set_keymap(
        "n",
        "<leader>Du",
        ":DBUIToggle<CR>",
        {
            noremap = true,
            silent = true
        }
    )
    vim.api.nvim_set_keymap(
        "n",
        "<leader>Df",
        ":DBUIFindBuffer<CR>",
        {
            noremap = true,
            silent = true
        }
    )
    vim.api.nvim_set_keymap(
        "n",
        "<leader>Dr",
        ":DBUIRenameBuffer<CR>",
        {
            noremap = true,
            silent = true
        }
    )
    vim.api.nvim_set_keymap(
        "n",
        "<leader>Dl",
        ":DBUILastQueryInfo<CR>",
        {
            noremap = true,
            silent = true
        }
    )
    vim.g.db_ui_auto_execute_table_helpers = true
end

function config.package_info()
    require("package-info").setup(
        {
            colors = {
                up_to_date = "#98c379",
                outdated = "#F05F4E"
            }
        }
    )
end

function config.crates()
    require("crates").setup()
    vim.cmd('command! CratesUpdate lua require("crates").update()')
    vim.cmd('command! CratesReload lua require("crates").reload()')
    vim.cmd('command! CratesHide lua require("crates").hide()')
    vim.cmd('command! CratesToggle lua require("crates").toggle()')
    vim.cmd('command! CratesUpdateCrate lua require("crates").update_crate()')
    vim.cmd('command! CratesUpdateCrates lua require("crates").update_crates()')
    vim.cmd('command! CratesUpdateAllCrates lua require("crates").update_all_crates()')
    vim.cmd('command! CratesUpgradeCrate lua require("crates").upgrade_crate()')
    vim.cmd('command! CratesUpgradeCrates lua require("crates").upgrade_crates()')
    vim.cmd('command! CratesUpgradeAllCrates lua require("crates").upgrade_all_crates()')
    vim.cmd('command! CratesShowPopup lua require("crates").show_popup()')
    vim.cmd('command! CratesShowVersionsPopup lua require("crates").show_versions_popup()')
    vim.cmd('command! CratesShowFeaturesPopup lua require("crates").show_features_popup()')
    vim.cmd('command! CratesFocusPopup lua require("crates").focus_popup()')
    vim.cmd('command! CratesHidePopup lua require("crates").hide_popup()')
end

function config.pubspec_assist()
    require("pubspec-assist").setup()
end

function config.vimtex()
    vim.g.vimtex_view_method = 'zathura'
    vim.g.latex_view_general_viewer = 'zathura'
    vim.g.vimtex_compiler_progname = 'nvr'
    vim.g.vimtex_compiler_callback_compiling = 'nvr'
end

function config.orgmode()
    require("orgmode").setup_ts_grammar()
    require("orgmode").setup {
        org_agenda_files = "~/Org/**/*",
        org_default_notes_file = "~/Org/notes.org"
    }
end

function config.org_bullets()
    require("org-bullets").setup {
        symbols = {"◉", "○", "✸"}
    }
end

return config
