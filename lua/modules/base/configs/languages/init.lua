local icons = require("configs.base.ui.icons")

return {
    mason = {
        opts = function()
            vim.schedule(function()
                require("languages").init()
                require("languages.utils.setup_diagnostics").init_diagnostics()
                require("languages.lsp_commands")
                require("languages.utils.code_lens").setup()
            end)
            return {
                ui = {
                    icons = icons.mason,
                },
            }
        end,
    },
    neotest = {
        cmd = {
            "NeotestRun",
            "NeotestRunCurrent",
            "NeotestRunDap",
            "NeotestStop",
            "NeotestAttach",
            "NeotestOutput",
            "NeotestOutputPanel",
            "NeotestSummary",
        },
        keys = {
            { "<leader>nr", "<cmd>NeotestRun<CR>", desc = "Neotest Run" },
            { "<leader>nc", "<cmd>NeotestRunCurrent<CR>", desc = "Neotest Run Current File" },
            { "<leader>nd", "<cmd>NeotestRunDap<CR>", desc = "Neotest Run with DAP" },
            { "<leader>ns", "<cmd>NeotestStop<CR>", desc = "Neotest Stop" },
            { "<leader>na", "<cmd>NeotestAttach<CR>", desc = "Neotest Attach" },
            { "<leader>no", "<cmd>NeotestOutput<CR>", desc = "Neotest Output" },
            { "<leader>np", "<cmd>NeotestOutputPanel<CR>", desc = "Neotest Output Panel" },
            { "<leader>nt", "<cmd>NeotestSummary<CR>", desc = "Neotest Summary Toggle" },
        },
        opts = function()
            local neotest_ns = vim.api.nvim_create_namespace("neotest")
            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message =
                            diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                        return message
                    end,
                },
            }, neotest_ns)

            vim.api.nvim_create_user_command("NeotestRun", function()
                require("neotest").run.run()
            end, {})
            vim.api.nvim_create_user_command("NeotestRunCurrent", function()
                require("neotest").run.run(vim.fn.expand("%"))
            end, {})
            vim.api.nvim_create_user_command("NeotestRunDap", function()
                require("neotest").run.run({ strategy = "dap" })
            end, {})
            vim.api.nvim_create_user_command("NeotestStop", function()
                require("neotest").run.stop()
            end, {})
            vim.api.nvim_create_user_command("NeotestAttach", function()
                require("neotest").run.attach()
            end, {})
            vim.api.nvim_create_user_command("NeotestOutput", function()
                require("neotest").output.open()
            end, {})
            vim.api.nvim_create_user_command("NeotestOutputPanel", function()
                require("neotest").output_panel.toggle()
            end, {})
            vim.api.nvim_create_user_command("NeotestSummary", function()
                require("neotest").summary.toggle()
            end, {})

            return {
                icons = {
                    running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                    passed = "󰗠",
                    running = "󰔟",
                    failed = "󰅙",
                    skipped = "󰘳",
                    unknown = "󰢖",
                    non_collapsible = "─",
                    collapsed = "─",
                    expanded = "┐",
                    child_prefix = "├",
                    final_child_prefix = "└",
                    child_indent = "│",
                    final_child_indent = " ",
                    watching = "󰓦",
                    test = "󰙨",
                    notify = "󰂚",
                },
                adapters = {
                    require("neotest-plenary"),
                    require("neotest-python")({
                        python = ".venv/bin/python",
                        runner = "pytest",
                        args = { "-q" },
                    }),
                    require("neotest-phpunit"),
                    require("neotest-rust"),
                    require("neotest-go"),
                    require("neotest-elixir"),
                    require("neotest-dart"),
                },
            }
        end,
    },
    nvim_rip_substitute = {
        cmd = { "RipSubstitute" },
        keys = {
            {
                "<leader>rr",
                function()
                    require("rip-substitute").sub()
                end,
                mode = { "n", "x" },
                desc = "Rip substitute",
            },
        },
        opts = {
            popupWin = {
                title = "Replace",
                border = "single",
                matchCountHlGroup = "Keyword",
                noMatchHlGroup = "ErrorMsg",
                hideSearchReplaceLabels = false,
                position = "bottom",
            },
            keymaps = {
                confirm = "<CR>",
                abort = "q",
                prevSubstitutionInHistory = "<Up>",
                nextSubstitutionInHistory = "<Down>",
                insertModeConfirm = "<C-CR>",
            },
            incrementalPreview = {
                matchHlGroup = "IncSearch",
                rangeBackdrop = {
                    enabled = false,
                    blend = 0,
                },
            },
        },
    },
    glance_nvim = {
        keys = {
            {
                "gpd",
                function()
                    vim.cmd("Glance definitions")
                end,
                mode = { "n" },
                desc = "Glance definitions",
            },
            {
                "gpr",
                function()
                    vim.cmd("Glance references")
                end,
                mode = { "n" },
                desc = "Glance references",
            },
            {
                "gpt",
                function()
                    vim.cmd("Glance type_definitions")
                end,
                mode = { "n" },
                desc = "Glance type definitions",
            },
            {
                "gpi",
                function()
                    vim.cmd("Glance implementations")
                end,
                mode = { "n" },
                desc = "Glance implementations",
            },
        },
        opts = {
            zindex = 20,
            border = {
                enable = true,
                top_char = " ",
                bottom_char = " ",
            },
            list = {
                width = 0.4,
            },
            theme = {
                enable = false,
            },
            indent_lines = {
                enable = true,
                icon = "▏",
            },
            hooks = {
                before_open = function(results, open, jump, _)
                    local uri = vim.uri_from_bufnr(0)
                    if #results == 1 then
                        local target_uri = results[1].uri or results[1].targetUri
                        if target_uri == uri then
                            jump(results[1])
                        else
                            open(results)
                        end
                    else
                        open(results)
                    end
                end,
            },
        },
    },
    trouble_nvim = {
        cmd = { "Trouble" },
        keys = {
            { "<C-c><C-v>", "<Cmd>Trouble diagnostics<CR>", desc = "Trouble" },
        },
        opts = {
            signs = {
                error = icons.diagnostics.error,
                warning = icons.diagnostics.warn,
                hint = icons.diagnostics.hint,
                information = icons.diagnostics.info,
                other = icons.diagnostics.other,
            },
        },
    },
    flutter_tools_nvim = {
        opts = function()
            local setup_diagnostics = require("languages.utils.setup_diagnostics")
            local navic = require("nvim-navic")
            return {
                ui = {
                    notification_style = "plugin",
                },
                closing_tags = {
                    prefix = icons.common.separator .. " ",
                    highlight = "FlutterInlineHint",
                },
                lsp = {
                    auto_attach = true,
                    on_attach = function(client, bufnr)
                        setup_diagnostics.keymaps(client, bufnr)
                        setup_diagnostics.document_highlight(client, bufnr)
                        setup_diagnostics.document_auto_format(client, bufnr)
                        setup_diagnostics.inlay_hint(client, bufnr)
                        navic.attach(client, bufnr)
                    end,
                    autostart = true,
                    capabilities = {
                        textDocument = {
                            formatting = {
                                dynamicRegistration = false,
                            },
                            codeAction = {
                                dynamicRegistration = false,
                            },
                            hover = {
                                dynamicRegistration = false,
                            },
                            rename = {
                                dynamicRegistration = false,
                            },
                            completion = {
                                dynamicRegistration = false,
                                completionItem = {
                                    snippetSupport = true,
                                    commitCharactersSupport = true,
                                    documentationFormat = { "markdown", "plaintext" },
                                    deprecatedSupport = true,
                                    preselectSupport = true,
                                    insertReplaceSupport = true,
                                    labelDetailsSupport = true,
                                    resolveSupport = {
                                        properties = { "documentation", "detail", "additionalTextEdits" },
                                    },
                                },
                                completionItemKind = {
                                    valueSet = (function()
                                        local result = {}
                                        for i = 1, 25 do
                                            table.insert(result, i)
                                        end
                                        return result
                                    end)(),
                                },
                                contextSupport = true,
                            },
                            declaration = {
                                dynamicRegistration = false,
                                linkSupport = true,
                            },
                            definition = {
                                dynamicRegistration = false,
                                linkSupport = true,
                            },
                            typeDefinition = {
                                dynamicRegistration = false,
                                linkSupport = true,
                            },
                            implementation = {
                                dynamicRegistration = false,
                                linkSupport = true,
                            },
                            references = {
                                dynamicRegistration = false,
                            },
                            documentHighlight = {
                                dynamicRegistration = false,
                            },
                            documentSymbol = {
                                dynamicRegistration = false,
                                symbolKind = {
                                    valueSet = (function()
                                        local result = {}
                                        for i = 1, 26 do
                                            table.insert(result, i)
                                        end
                                        return result
                                    end)(),
                                },
                                hierarchicalDocumentSymbolSupport = true,
                            },
                            signatureHelp = {
                                dynamicRegistration = false,
                                signatureInformation = {
                                    documentationFormat = { "markdown", "plaintext" },
                                    parameterInformation = {
                                        labelOffsetSupport = true,
                                    },
                                    activeParameterSupport = true,
                                },
                            },
                            documentFormatting = {
                                dynamicRegistration = false,
                            },
                            documentRangeFormatting = {
                                dynamicRegistration = false,
                            },
                            documentOnTypeFormatting = {
                                dynamicRegistration = false,
                            },
                            publishDiagnostics = {
                                dynamicRegistration = false,
                                relatedInformation = true,
                                tagSupport = {
                                    valueSet = { 1, 2 },
                                },
                                versionSupport = true,
                                codeDescriptionSupport = true,
                                dataSupport = true,
                            },
                            foldingRange = {
                                dynamicRegistration = false,
                                lineFoldingOnly = true,
                            },
                            selectionRange = {
                                dynamicRegistration = false,
                            },
                            callHierarchy = {
                                dynamicRegistration = false,
                            },
                            semanticTokens = {
                                dynamicRegistration = false,
                                requests = {
                                    range = true,
                                    full = {
                                        delta = true,
                                    },
                                },
                                tokenTypes = {
                                    "namespace",
                                    "type",
                                    "class",
                                    "enum",
                                    "interface",
                                    "struct",
                                    "typeParameter",
                                    "parameter",
                                    "variable",
                                    "property",
                                    "enumMember",
                                    "event",
                                    "function",
                                    "method",
                                    "macro",
                                    "keyword",
                                    "modifier",
                                    "comment",
                                    "string",
                                    "number",
                                    "regexp",
                                    "operator",
                                    "decorator",
                                },
                                tokenModifiers = {
                                    "declaration",
                                    "definition",
                                    "readonly",
                                    "static",
                                    "deprecated",
                                    "abstract",
                                    "async",
                                    "modification",
                                    "documentation",
                                    "defaultLibrary",
                                },
                                formats = { "relative" },
                                overlappingTokenSupport = false,
                                multilineTokenSupport = false,
                            },
                            linkedEditingRange = {
                                dynamicRegistration = false,
                            },
                            inlayHint = {
                                dynamicRegistration = false,
                                resolveSupport = {
                                    properties = { "tooltip", "textEdits", "label.tooltip", "label.location" },
                                },
                            },
                        },
                        window = {
                            showMessage = {
                                messageActionItem = {
                                    additionalPropertiesSupport = true,
                                },
                            },
                            showDocument = {
                                support = true,
                            },
                            workDoneProgress = true,
                        },
                        workspace = {
                            applyEdit = true,
                            workspaceEdit = {
                                documentChanges = true,
                                resourceOperations = { "create", "rename", "delete" },
                                failureHandling = "textOnlyTransactional",
                                normalizesLineEndings = true,
                                changeAnnotationSupport = {
                                    groupsOnLabel = true,
                                },
                            },
                            didChangeConfiguration = {
                                dynamicRegistration = false,
                            },
                            didChangeWatchedFiles = {
                                dynamicRegistration = false,
                                relativePatternSupport = true,
                            },
                            symbol = {
                                dynamicRegistration = false,
                                symbolKind = {
                                    valueSet = (function()
                                        local result = {}
                                        for i = 1, 26 do
                                            table.insert(result, i)
                                        end
                                        return result
                                    end)(),
                                },
                            },
                            executeCommand = {
                                dynamicRegistration = false,
                            },
                            workspaceFolders = true,
                            configuration = true,
                            semanticTokens = {
                                refreshSupport = true,
                            },
                            fileOperations = {
                                dynamicRegistration = true,
                                didCreate = true,
                                didRename = true,
                                didDelete = true,
                                willCreate = true,
                                willRename = true,
                                willDelete = true,
                            },
                            inlayHint = {
                                refreshSupport = true,
                            },
                        },
                        general = {
                            regularExpressions = {
                                engine = "oniguruma",
                                version = "2",
                            },
                            markdown = {
                                parser = "marked",
                                version = "1.1.0",
                            },
                            positionEncodings = { "utf-16" },
                        },
                    },
                    settings = {
                        dart = {
                            completeFunctionCalls = true,
                            showTodos = true,
                            analysisExcludedFolders = {},
                            updateImportsOnRename = true,
                            renameFilesWithClasses = "prompt",
                            enableSnippets = true,
                            lineLength = 80,
                        },
                    },
                },
            }
        end,
    },
    nvim_px_to_rem = {
        cmd = { "PxToRemCursor", "PxToRemLine" },
        keys = {
            {
                "<Leader>pxx",
                "<cmd>PxToRemCursor<cr>",
                desc = "Px to Rem cursor",
            },
            {
                "<Leader>pxl",
                "<cmd>PxToRemLine<cr>",
                desc = "Px to Rem line",
            },
        },
        opts = {
            root_font_size = 16,
            decimal_count = 4,
            show_virtual_text = true,
            add_cmp_source = true,
            filetypes = {
                "css",
                "scss",
                "less",
                "astro",
            },
        },
    },
    nvim_lightbulb = {
        opts = {
            sign = {
                enabled = false,
            },
            virtual_text = {
                text = " " .. icons.common.light_bulb .. " ",
                enabled = true,
            },
            autocmd = {
                enabled = true,
                updatetime = 1,
            },
            ignore = {
                ft = { "dart" },
            },
        },
    },
    nvim_treesitter = {
        opts = {
            ensure_installed = "all",
            ignore_install = {},
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "org" },
            },
            indent = {
                enable = true,
                disable = {
                    "dart",
                },
            },
            autopairs = {
                enable = true,
            },
            rainbow = {
                enable = true,
            },
            context_commentstring = {
                enable = true,
                config = {
                    javascriptreact = {
                        style_element = "{/*%s*/}",
                    },
                },
            },
            matchup = {
                enable = true,
                disable_virtual_text = true,
            },
        },
    },
    fidget_nvim = {
        opts = {
            progress = {
                display = {
                    done_style = "FidgetDone",
                    progress_style = "FidgetProgress",
                    group_style = "FidgetGroup",
                    icon_style = "FidgetIcon",
                },
            },
            notification = {
                view = {
                    icon_separator = " ",
                    group_separator = "─────",
                    group_separator_hl = "Error",
                },
                override_vim_notify = false,
                window = {
                    normal_hl = "FidgetWindow",
                    x_padding = 0,
                    y_padding = 1,
                    winblend = 0,
                    align = "top",
                },
            },
        },
    },
    nvim_navic = {
        opts = function()
            vim.g.navic_silence = true
            return {
                icons = icons.lsp,
                highlight = true,
                separator = " " .. icons.common.separator,
            }
        end,
    },
    outline = {
        cmd = { "Outline" },
        keys = {
            {
                "<Leader>lo",
                function()
                    vim.cmd("Outline")
                end,
                desc = "Outline",
            },
        },
        opts = {
            outline_window = {
                winhl = "Normal:SideBar,NormalNC:SideBarNC",
            },
            preview_window = {
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
                winhl = "Normal:SideBar,NormalNC:SideBarNC",
            },
            symbols = {
                icons = icons.outline,
            },
        },
    },
    nvim_dap = {
        cmd = {
            "LuaDapLaunch",
            "DapToggleBreakpoint",
            "DapClearBreakpoints",
            "DapRunToCursor",
            "DapContinue",
            "DapStepInto",
            "DapStepOver",
            "DapStepOut",
            "DapUp",
            "DapDown",
            "DapPause",
            "DapClose",
            "DapDisconnect",
            "DapRestart",
            "DapToggleRepl",
            "DapGetSession",
            "DapUIClose",
        },
        keys = {
            {
                "<A-1>",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Dap Toggle Breakpoint",
            },
            {
                "<A-2>",
                function()
                    local dap = require("dap")
                    local ft = vim.bo.filetype
                    if ft == "lua" then
                        if not dap.session() then
                            local ok, err = pcall(function()
                                require("osv").run_this()
                            end)
                            if not ok then
                                vim.notify("Could not start Lua debug session: " .. tostring(err), vim.log.levels.ERROR)
                            end
                        else
                            dap.continue()
                        end
                    else
                        dap.continue()
                    end
                end,
                desc = "Debug Start/Continue",
            },
            {
                "<A-3>",
                function()
                    require("dap").step_into()
                end,
                desc = "Dap Step Into",
            },
            {
                "<A-4>",
                function()
                    require("dap").step_over()
                end,
                desc = "Dap Step Over",
            },
            {
                "<A-5>",
                function()
                    require("dap").step_out()
                end,
                desc = "Dap Step Out",
            },
            {
                "<A-6>",
                function()
                    require("dap").up()
                end,
                desc = "Dap Up",
            },
            {
                "<A-7>",
                function()
                    require("dap").down()
                end,
                desc = "Dap Down",
            },
            {
                "<A-8>",
                function()
                    local dap = require("dap")
                    local dapui = require("dapui")
                    dap.close()
                    dap.disconnect()
                    dapui.close()
                end,
                desc = "Dap UI Close",
            },
            {
                "<A-9>",
                function()
                    require("dap").restart()
                end,
                desc = "Dap Restart",
            },
            {
                "<A-0>",
                function()
                    require("dap").repl.toggle()
                end,
                desc = "Dap Toggle Repl",
            },
        },
        config = function()
            local dap_status_ok, dap = pcall(require, "dap")
            if not dap_status_ok then
                return
            end
            local dap_view_status_ok, dap_view = pcall(require, "dap-view")
            if not dap_view_status_ok then
                return
            end
            vim.fn.sign_define("DapBreakpoint", {
                text = icons.dap_ui.sign.breakpoint,
                texthl = "DapBreakpoint",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapBreakpointRejected", {
                text = icons.dap_ui.sign.reject,
                texthl = "DapBreakpointRejected",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapBreakpointCondition", {
                text = icons.dap_ui.sign.condition,
                texthl = "DapBreakpointCondition",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapStopped", {
                text = icons.dap_ui.sign.stopped,
                texthl = "DapStopped",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapLogPoint", {
                text = icons.dap_ui.sign.log_point,
                texthl = "DapLogPoint",
                linehl = "",
                numhl = "",
            })
            vim.api.nvim_create_user_command("LuaDapLaunch", 'lua require"osv".run_this()', {})
            vim.api.nvim_create_user_command("DapToggleBreakpoint", 'lua require("dap").toggle_breakpoint()', {})
            vim.api.nvim_create_user_command("DapClearBreakpoints", 'lua require("dap").clear_breakpoints()', {})
            vim.api.nvim_create_user_command("DapRunToCursor", 'lua require("dap").run_to_cursor()', {})
            vim.api.nvim_create_user_command("DapContinue", 'lua require"dap".continue()', {})
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
            dap.listeners.after.event_initialized["dapui_config"] = function()
                vim.defer_fn(function()
                    dap_view.open()
                end, 200)
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dap_view.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dap_view.close()
            end
        end,
    },
    vim_dadbod_ui = {
        cmd = {
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUI",
            "DBUIFindBuffer",
            "DBUIRenameBuffer",
        },
        keys = {
            {
                "<Leader>dd",
                "<cmd>DBUIToggle<cr>",
                desc = "Dadbod toggle",
            },
        },
        init = function()
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_icons = {
                expanded = {
                    db = " 󰆼",
                    buffers = " 󰧮",
                    saved_queries = " 󰛮",
                    schemas = " 󰯂",
                    schema = " 󰙅",
                    tables = " 󰓱",
                    table = " 󰓫",
                },
                collapsed = {
                    db = " 󰆼",
                    buffers = " 󰧮",
                    saved_queries = " 󰛮",
                    schemas = " 󰯂",
                    schema = " 󰙅",
                    tables = " 󰓱",
                    table = " 󰓫",
                },
                saved_queries = " 󰛮",
                new_query = " 󰓰",
                tables = " 󰓫",
                buffers = " 󰧮",
                add_connection = "  󰆺",
                connection_ok = "",
                connection_error = "",
            }
            vim.g.db_ui_execute_on_save = 0
            vim.g.db_ui_disable_info_notifications = 1
            vim.g.db_ui_show_help = 0
            vim.g.db_ui_win_position = "left"
            vim.g.db_ui_winwidth = 35
            vim.api.nvim_set_keymap("n", "<leader>db", ":DBUIFindBuffer<CR>", {
                noremap = true,
                silent = true,
            })
            vim.api.nvim_set_keymap("n", "<leader>dr", ":DBUIRenameBuffer<CR>", {
                noremap = true,
                -- silent = true,
            })
            vim.api.nvim_set_keymap("n", "<leader>dl", ":DBUILastQueryInfo<CR>", {
                noremap = true,
                silent = true,
            })
            vim.g.db_ui_auto_execute_table_helpers = 1
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dbui",
                callback = function()
                    vim.schedule(function()
                        vim.api.nvim_set_hl(0, "dbui_connection_ok", { fg = _G.LVIM_COLORS.green })
                        vim.api.nvim_set_hl(0, "dbui_connection_error", { fg = _G.LVIM_COLORS.red })
                        vim.api.nvim_set_hl(0, "dbui_saved_query", { fg = _G.LVIM_COLORS.orange })
                    end)
                end,
                group = "LvimIDE",
            })
        end,
    },
    nvim_dbee = {
        cmd = { "Dbee" },
        keys = {
            {
                "<Leader>do",
                "<cmd>Dbee open<cr>",
                desc = "Dbee open",
            },
            {
                "<Leader>dc",
                "<cmd>Dbee close<cr>",
                desc = "Dbee close",
            },
        },
        opts = {},
    },
    package_info_nvim = {
        opts = function()
            vim.api.nvim_create_user_command("PackageInfoToggle", "lua require('package-info').toggle()", {})
            vim.api.nvim_create_user_command("PackageInfoDelete", "lua require('package-info').delete()", {})
            vim.api.nvim_create_user_command(
                "PackageInfoChangeVersion",
                "lua require('package-info').change_version()",
                {}
            )
            vim.api.nvim_create_user_command("PackageInfoInstall", "lua require('package-info').install()", {})
            return {}
        end,
    },
    crates_nvim = {
        opts = function()
            local crates_status_ok, crates = pcall(require, "crates")
            if not crates_status_ok then
                return
            end
            vim.api.nvim_create_user_command("CratesUpdate", crates.update, { desc = "Update crate dependencies" })
            vim.api.nvim_create_user_command("CratesReload", crates.reload, { desc = "Reload crates cache" })
            vim.api.nvim_create_user_command("CratesHide", crates.hide, { desc = "Hide crates UI" })
            vim.api.nvim_create_user_command("CratesToggle", crates.toggle, { desc = "Toggle crates UI" })
            vim.api.nvim_create_user_command(
                "CratesUpdateCrate",
                crates.update_crate,
                { desc = "Update a single crate" }
            )
            vim.api.nvim_create_user_command(
                "CratesUpdateCrates",
                crates.update_crates,
                { desc = "Update selected crates" }
            )
            vim.api.nvim_create_user_command(
                "CratesUpdateAllCrates",
                crates.update_all_crates,
                { desc = "Update all crates" }
            )
            vim.api.nvim_create_user_command(
                "CratesUpgradeCrate",
                crates.upgrade_crate,
                { desc = "Upgrade a single crate" }
            )
            vim.api.nvim_create_user_command(
                "CratesUpgradeCrates",
                crates.upgrade_crates,
                { desc = "Upgrade selected crates" }
            )
            vim.api.nvim_create_user_command(
                "CratesUpgradeAllCrates",
                crates.upgrade_all_crates,
                { desc = "Upgrade all crates" }
            )
            vim.api.nvim_create_user_command("CratesShowPopup", function()
                crates.show_popup()
                crates.focus_popup()
            end, { desc = "Show and focus main popup" })
            vim.api.nvim_create_user_command("CratesShowVersionsPopup", function()
                crates.show_versions_popup()
                crates.focus_popup()
            end, { desc = "Show and focus versions popup" })
            vim.api.nvim_create_user_command("CratesShowFeaturesPopup", function()
                crates.show_features_popup()
                crates.focus_popup()
            end, { desc = "Show and focus features popup" })
            vim.api.nvim_create_user_command(
                "CratesFocusPopup",
                crates.focus_popup,
                { desc = "Focus the active popup" }
            )
            vim.api.nvim_create_user_command("CratesHidePopup", crates.hide_popup, { desc = "Hide the active popup" })
            return {}
        end,
    },
    pubspec_assist_nvim = {
        opts = {
            highlights = {
                up_to_date = "PubspecDependencyUpToDate",
                outdated = "PubspecDependencyOutdated",
                unknown = "PubspecDependencyUnknown",
            },
        },
    },
    markdown_preview_nvim = {
        cmd = { "MarkdownPreview" },
        keys = {
            { "<S-m>", "<cmd>MarkdownPreview<CR>", desc = "Markdown preview" },
        },
    },
    markview_nvim = {
        opts = function()
            local markdown = require("modules.base.configs.languages.markview.markdown")
            local markdown_inline = require("modules.base.configs.languages.markview.markdown_inline")
            local html = require("modules.base.configs.languages.markview.html")
            local yaml = require("modules.base.configs.languages.markview.yaml")
            local typst = require("modules.base.configs.languages.markview.typst")
            require("markview.extras.editor").setup({
                width = { 10, 0.75 },
                height = { 3, 0.75 },
                debounce = 50,
            })
            require("markview.extras.checkboxes").setup()
            vim.keymap.set("n", "<Leader>cb", function()
                vim.cmd("Checkbox interactive")
            end, { noremap = true, silent = true, desc = "Checkbox choice" })
            return {
                preview = { enable = true },
                markdown = markdown,
                markdown_inline = markdown_inline,
                html = html,
                yaml = yaml,
                typst = typst,
            }
        end,
    },
    helpview_nvim = {
        opts = {},
    },
    vimtex = {
        config = function()
            vim.g.vimtex_mappings_prefix = "'"
            vim.g.vimtex_view_method = "zathura"
            vim.g.latex_view_general_viewer = "zathura"
            vim.g.vimtex_compiler_progname = "nvr"
            vim.g.vimtex_compiler_callback_compiling = "nvr"
            vim.g.vimtex_quickfix_open_on_warning = 0
        end,
    },
    orgmode = {
        opts = {
            emacs_config = {
                config_path = "~/.emacs.d/early-init.el",
            },
            org_agenda_files = { "~/Org/**/*" },
            org_default_notes_file = "~/Org/refile.org",
        },
    },
    lvim_org_utils = {
        opts = {},
    },
}

-- vim: foldmethod=indent foldlevel=1
