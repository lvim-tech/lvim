-- Plugin configuration for language tooling plugins.
-- Covers: Mason (LSP/tool installer), Neotest (test runner), rip-substitute,
-- Glance (LSP peek), Trouble, flutter-tools, px-to-rem, nvim-lightbulb,
-- Treesitter (+ context), Fidget, nvim-navic, Outline, nvim-dap (+dap-view),
-- vim-dadbod-ui, nvim-dbee, package-info, crates.nvim, pubspec-assist,
-- live-preview, markview, helpview, vimtex, orgmode, and lvim-org-utils.

---@module "modules.base.configs.languages"

local icons = require("configs.base.ui.icons")
local lsp_config = require("modules.base.configs.languages.lsp")
local file_types = require("modules.base.configs.languages.lsp.file_types")

return {
    -- -------------------------------------------------------------------------
    -- Mason: manages LSP servers, linters, and formatters.
    -- After Mason is ready, initialises the LVIM languages subsystem
    -- (LSP setup, diagnostics, code-lens) via a deferred vim.schedule call.
    -- -------------------------------------------------------------------------
    mason = {
        ---@return table  Mason opts table with icon configuration
        opts = function()
            return {
                ui = {
                    icons = icons.mason,
                },
            }
        end,
    },

    lvim_lsp = {
        opts = {
            file_types = file_types,
            server_config_dirs = { "modules.base.configs.languages.lsp.servers" },
            diagnostics = {
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                signs = {
                    error = icons.diagnostics.error,
                    warn = icons.diagnostics.warn,
                    hint = icons.diagnostics.hint,
                    info = icons.diagnostics.info,
                },
                show_line = lsp_config.diagnostics.show_line_diagnostics,
                goto_next = lsp_config.diagnostics.goto_next,
                goto_prev = lsp_config.diagnostics.goto_prev,
            },
            features = {
                document_highlight = true,
                auto_format = true,
                inlay_hints = true,
            },
            dap_local_fn = require("modules.base.configs.languages.lsp.dap_utils").dap_local,

            on_attach = function(client, bufnr)
                lsp_config.keymaps(client, bufnr)
            end,
        },
    },

    -- -------------------------------------------------------------------------
    -- Neotest: unified test runner with DAP integration.
    -- Registers user commands for all Neotest actions and configures adapters
    -- for Python, PHP, Rust, Go, Elixir, Dart, and Plenary.
    -- -------------------------------------------------------------------------
    neotest = {
        -- Commands exposed to the user (lazy-loading triggers)
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
        ---@return table  Neotest options (icons, adapters)
        opts = function()
            -- Create a dedicated diagnostic namespace so Neotest messages don't
            -- pollute the global diagnostic list.
            ---@type integer
            local neotest_ns = vim.api.nvim_create_namespace("neotest")
            vim.diagnostic.config({
                virtual_text = {
                    -- Collapse multi-line diagnostic messages to a single line
                    ---@param diagnostic table  vim.Diagnostic object
                    ---@return string           Single-line message
                    format = function(diagnostic)
                        local message =
                            diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                        return message
                    end,
                },
            }, neotest_ns)

            -- Register individual user commands for each Neotest action
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
                -- Braille spinner frames for the running test animation
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
                -- Language-specific test adapters; each adapter handles discovery
                -- and execution for its runtime.
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

    -- -------------------------------------------------------------------------
    -- rip-substitute: a ripgrep-powered search-and-replace UI.
    -- -------------------------------------------------------------------------
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

    -- -------------------------------------------------------------------------
    -- Glance: floating LSP peek window for definitions, references, etc.
    -- When there is exactly one result pointing at the current file, jumps
    -- directly instead of opening the Glance panel.
    -- -------------------------------------------------------------------------
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
                -- Results list takes 40% of the total popup width
                width = 0.4,
            },
            theme = {
                -- Disable Glance's built-in theme; inherit LVIM highlights
                enable = false,
            },
            indent_lines = {
                enable = true,
                icon = "▏",
            },
            hooks = {
                -- before_open: if there is a single result pointing at the current
                -- buffer, jump directly instead of opening the Glance float.
                ---@param results  table[]          LSP result list
                ---@param open     fun(results: table[])  Opens the Glance panel
                ---@param jump     fun(result: table)     Jumps to a single result
                ---@param _        any                    Unused (window handle)
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

    -- -------------------------------------------------------------------------
    -- Trouble: a diagnostics / LSP list panel.
    -- -------------------------------------------------------------------------
    trouble_nvim = {
        cmd = { "Trouble" },
        keys = {
            { "<C-c><C-v>", "<Cmd>Trouble diagnostics<CR>", desc = "Trouble" },
        },
        opts = {
            -- Map Trouble's sign names to the shared LVIM icon set
            signs = {
                error = icons.diagnostics.error,
                warning = icons.diagnostics.warn,
                hint = icons.diagnostics.hint,
                information = icons.diagnostics.info,
                other = icons.diagnostics.other,
            },
        },
    },

    -- -------------------------------------------------------------------------
    -- flutter-tools: Flutter & Dart LSP integration.
    -- Sets up a full LSP capabilities table (no dynamic registration) so the
    -- Dart analyzer receives the maximum feature set.
    -- -------------------------------------------------------------------------
    flutter_tools_nvim = {
        ---@return table  flutter-tools.nvim options
        opts = function()
            local lsp = require("modules.base.configs.languages.lsp")
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
                    -- Disable automatic pub get on save to avoid unwanted network calls
                    auto_pub_get = false,
                    ---@param client table  LSP client object
                    ---@param bufnr  integer  Buffer number the client attached to
                    on_attach = function(client, bufnr)
                        -- document_highlight / auto_format / inlay_hints are handled
                        -- by lvim-lsp features.apply_buffer_features()
                        lsp.keymaps(client, bufnr)
                        navic.attach(client, bufnr)
                    end,
                    autostart = true,
                    -- Full LSP capabilities declaration; dynamicRegistration is
                    -- disabled for all features to keep the negotiation deterministic.
                    capabilities = {
                        textDocument = {
                            formatting = { dynamicRegistration = false },
                            codeAction = { dynamicRegistration = false },
                            hover = { dynamicRegistration = false },
                            rename = { dynamicRegistration = false },
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
                                -- Advertise support for all 25 LSP completion item kinds
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
                            declaration = { dynamicRegistration = false, linkSupport = true },
                            definition = { dynamicRegistration = false, linkSupport = true },
                            typeDefinition = { dynamicRegistration = false, linkSupport = true },
                            implementation = { dynamicRegistration = false, linkSupport = true },
                            references = { dynamicRegistration = false },
                            documentHighlight = { dynamicRegistration = false },
                            documentSymbol = {
                                dynamicRegistration = false,
                                -- Advertise support for all 26 LSP symbol kinds
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
                                    parameterInformation = { labelOffsetSupport = true },
                                    activeParameterSupport = true,
                                },
                            },
                            documentFormatting = { dynamicRegistration = false },
                            documentRangeFormatting = { dynamicRegistration = false },
                            documentOnTypeFormatting = { dynamicRegistration = false },
                            publishDiagnostics = {
                                dynamicRegistration = false,
                                relatedInformation = true,
                                tagSupport = { valueSet = { 1, 2 } },
                                versionSupport = true,
                                codeDescriptionSupport = true,
                                dataSupport = true,
                            },
                            foldingRange = {
                                dynamicRegistration = false,
                                lineFoldingOnly = true,
                            },
                            selectionRange = { dynamicRegistration = false },
                            callHierarchy = { dynamicRegistration = false },
                            semanticTokens = {
                                dynamicRegistration = false,
                                requests = {
                                    range = true,
                                    full = { delta = true },
                                },
                                -- Full list of semantic token type strings the client understands
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
                            linkedEditingRange = { dynamicRegistration = false },
                            inlayHint = {
                                dynamicRegistration = false,
                                resolveSupport = {
                                    properties = { "tooltip", "textEdits", "label.tooltip", "label.location" },
                                },
                            },
                        },
                        window = {
                            showMessage = {
                                messageActionItem = { additionalPropertiesSupport = true },
                            },
                            showDocument = { support = true },
                            workDoneProgress = true,
                        },
                        workspace = {
                            applyEdit = true,
                            workspaceEdit = {
                                documentChanges = true,
                                resourceOperations = { "create", "rename", "delete" },
                                failureHandling = "textOnlyTransactional",
                                normalizesLineEndings = true,
                                changeAnnotationSupport = { groupsOnLabel = true },
                            },
                            didChangeConfiguration = { dynamicRegistration = false },
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
                            executeCommand = { dynamicRegistration = false },
                            workspaceFolders = true,
                            configuration = true,
                            semanticTokens = { refreshSupport = true },
                            fileOperations = {
                                dynamicRegistration = true,
                                didCreate = true,
                                didRename = true,
                                didDelete = true,
                                willCreate = true,
                                willRename = true,
                                willDelete = true,
                            },
                            inlayHint = { refreshSupport = true },
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
                    -- Dart language server settings
                    settings = {
                        dart = {
                            completeFunctionCalls = true,
                            showTodos = true,
                            analysisExcludedFolders = {},
                            updateImportsOnRename = true,
                            renameFilesWithClasses = "prompt",
                            enableSnippets = true,
                            lineLength = 80,
                            -- Do not run pub get automatically; triggered manually instead
                            autoRunPubGet = false,
                        },
                    },
                },
            }
        end,
    },

    -- -------------------------------------------------------------------------
    -- nvim-px-to-rem: converts CSS px values to rem units (base 16px).
    -- -------------------------------------------------------------------------
    nvim_px_to_rem = {
        cmd = { "PxToRemCursor", "PxToRemLine" },
        keys = {
            { "<Leader>pxx", "<cmd>PxToRemCursor<cr>", desc = "Px to Rem cursor" },
            { "<Leader>pxl", "<cmd>PxToRemLine<cr>", desc = "Px to Rem line" },
        },
        opts = {
            root_font_size = 16,
            decimal_count = 4,
            show_virtual_text = true,
            add_cmp_source = true,
            -- Only active in stylesheet filetypes
            filetypes = { "css", "scss", "less", "astro" },
        },
    },

    -- -------------------------------------------------------------------------
    -- nvim-lightbulb: shows a virtual-text lightbulb icon when code actions
    -- are available at the cursor position. Disabled for Dart (flutter-tools
    -- handles code actions separately for that filetype).
    -- -------------------------------------------------------------------------
    nvim_lightbulb = {
        opts = {
            sign = {
                -- Use virtual text instead of sign column to avoid layout shifts
                enabled = false,
            },
            virtual_text = {
                text = " " .. icons.common.light_bulb .. " ",
                enabled = true,
            },
            autocmd = {
                enabled = true,
                -- Update the lightbulb 1 ms after the cursor stops moving
                updatetime = 1,
            },
            ignore = {
                -- flutter-tools provides its own code-action UI for Dart
                ft = { "dart" },
            },
        },
    },

    -- -------------------------------------------------------------------------
    -- nvim-treesitter: syntax parsing, folding, and indentation.
    -- Installs tree-sitter-cli via Mason, then installs all available parsers
    -- and activates treesitter folding + indentation per filetype.
    -- -------------------------------------------------------------------------
    nvim_treesitter = {
        ---@return nil
        config = function()
            -- Ensure the tree-sitter CLI is available before installing parsers
            -- require("lvim-lsp").ensure_mason_tools({ "tree-sitter-cli" }, function()
            --     local ts = require("nvim-treesitter")
            --     ---@type string[]  All parsers available for the current nvim-treesitter version
            --     local all_parsers = ts.get_available()
            --     ts.install(all_parsers)
            --     -- Enable treesitter features per-buffer when the filetype is known
            --     vim.api.nvim_create_autocmd("FileType", {
            --         desc = "Start treesitter",
            --         group = vim.api.nvim_create_augroup("start_treesitter", { clear = true }),
            --         pattern = all_parsers,
            --         callback = function()
            --             vim.treesitter.start()
            --             -- Use treesitter-based fold expressions
            --             vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            --             -- Use nvim-treesitter indent for = operator
            --             vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            --         end,
            --     })
            -- end)
        end,
    },

    -- -------------------------------------------------------------------------
    -- nvim-treesitter-context: shows the current function / class in a sticky
    -- header at the top of the window. Disabled for markdown and org files.
    -- -------------------------------------------------------------------------
    nvim_treesitter_context = {
        opts = {
            enable = true,
            -- Show at most 3 context lines in the sticky header
            max_lines = 3,
            trim_scope = "outer",
            min_window_height = 0,
            -- Per-language node patterns that qualify as "context" scope boundaries
            patterns = {
                default = {
                    "class",
                    "function",
                    "method",
                    "for",
                    "while",
                    "if",
                    "switch",
                    "case",
                },
                tex = { "chapter", "section", "subsection", "subsubsection" },
                rust = { "impl_item", "struct", "enum" },
                scala = { "object_definition" },
                vhdl = { "process_statement", "architecture_body", "entity_declaration" },
                markdown = { "section" },
                elixir = {
                    "anonymous_function",
                    "arguments",
                    "block",
                    "do_block",
                    "list",
                    "map",
                    "tuple",
                    "quoted_content",
                },
                json = { "pair" },
                yaml = { "block_mapping_pair" },
            },
            -- Disable context for prose filetypes where it adds no value
            ---@param bufnr integer  Buffer number being evaluated
            ---@return boolean       true to enable context for this buffer
            on_attach = function(bufnr)
                if vim.bo[bufnr].filetype == "markdown" or vim.bo[bufnr].filetype == "org" then
                    return false
                end
                return true
            end,
            exact_patterns = {},
            zindex = 20,
            mode = "cursor",
            separator = nil,
        },
    },

    -- -------------------------------------------------------------------------
    -- Fidget: LSP progress notifications shown in the bottom-right corner.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- nvim-navic: breadcrumb trail showing the symbol under the cursor.
    -- Used by the winbar to display the current code context.
    -- -------------------------------------------------------------------------
    nvim_navic = {
        ---@return table  nvim-navic options
        opts = function()
            -- Suppress "server not supported" warnings for non-navic LSP clients
            vim.g.navic_silence = true
            return {
                icons = icons.lsp,
                highlight = true,
                separator = " " .. icons.common.separator,
            }
        end,
    },

    -- -------------------------------------------------------------------------
    -- Outline: symbol tree sidebar (replaces aerial / vista for navigation).
    -- -------------------------------------------------------------------------
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
                -- Invisible border to blend with the sidebar background
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
                winhl = "Normal:SideBar,NormalNC:SideBarNC",
            },
            symbols = {
                icons = icons.outline,
            },
        },
    },

    -- -------------------------------------------------------------------------
    -- nvim-dap: Debug Adapter Protocol client.
    -- Registers all DAP user commands, sets up sign column icons, wires DAP
    -- events to dap-view for the UI, and handles the Lua debugger (osv) as a
    -- special case when debugging Lua files.
    -- -------------------------------------------------------------------------
    nvim_dap = {
        -- Lazy-load commands so DAP is only initialised when first used
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
                    local dap = require("dap")
                    dap.toggle_breakpoint()
                end,
                desc = "Dap Toggle Breakpoint",
            },
            {
                "<A-2>",
                function()
                    local dap = require("dap")
                    local ft = vim.bo.filetype
                    if ft == "lua" then
                        -- For Lua files, start a new osv (one-small-step) session
                        -- if no DAP session is active; otherwise continue existing one.
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
                    local dap = require("dap")
                    dap.step_into()
                end,
                desc = "Dap Step Into",
            },
            {
                "<A-4>",
                function()
                    local dap = require("dap")
                    dap.step_over()
                end,
                desc = "Dap Step Over",
            },
            {
                "<A-5>",
                function()
                    local dap = require("dap")
                    dap.step_out()
                end,
                desc = "Dap Step Out",
            },
            {
                "<A-6>",
                function()
                    local dap = require("dap")
                    dap.up()
                end,
                desc = "Dap Up",
            },
            {
                "<A-7>",
                function()
                    local dap = require("dap")
                    dap.down()
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
                    local dap = require("dap")
                    dap.restart()
                end,
                desc = "Dap Restart",
            },
            {
                "<A-0>",
                function()
                    local dap = require("dap")
                    dap.repl.toggle()
                end,
                desc = "Dap Toggle Repl",
            },
        },
        ---@return nil
        config = function()
            local dap = require("dap")
            local dap_view = require("dap-view")

            -- Define sign column icons for DAP breakpoint states
            vim.fn.sign_define(
                "DapBreakpoint",
                { text = icons.dap_ui.sign.breakpoint, texthl = "DapBreakpoint", linehl = "", numhl = "" }
            )
            vim.fn.sign_define(
                "DapBreakpointRejected",
                { text = icons.dap_ui.sign.reject, texthl = "DapBreakpointRejected", linehl = "", numhl = "" }
            )
            vim.fn.sign_define(
                "DapBreakpointCondition",
                { text = icons.dap_ui.sign.condition, texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
            )
            vim.fn.sign_define(
                "DapStopped",
                { text = icons.dap_ui.sign.stopped, texthl = "DapStopped", linehl = "", numhl = "" }
            )
            vim.fn.sign_define(
                "DapLogPoint",
                { text = icons.dap_ui.sign.log_point, texthl = "DapLogPoint", linehl = "", numhl = "" }
            )

            -- Register user commands so they are available in the command line
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

            -- Open dap-view automatically when the debug session initialises,
            -- and close it when the session terminates or exits.
            dap.listeners.after.event_initialized["dapui_config"] = function()
                -- Small delay lets the adapter fully initialise before opening the UI
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

    -- -------------------------------------------------------------------------
    -- vim-dadbod-ui: database UI for SQL queries.
    -- Configures icons, key maps, window layout, and colour highlights that
    -- match the LVIM palette.
    -- -------------------------------------------------------------------------
    vim_dadbod_ui = {
        cmd = {
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUI",
            "DBUIFindBuffer",
            "DBUIRenameBuffer",
        },
        keys = {
            { "<Leader>dd", "<cmd>DBUIToggle<cr>", desc = "Dadbod toggle" },
        },
        ---@return nil
        init = function()
            vim.g.db_ui_use_nerd_fonts = 1
            -- Nerd-font icon set for the DBUI tree nodes
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
                connection_ok = "",
                connection_error = "",
            }
            -- Do not auto-execute queries on buffer save
            vim.g.db_ui_execute_on_save = 0
            vim.g.db_ui_disable_info_notifications = 1
            vim.g.db_ui_show_help = 0
            vim.g.db_ui_win_position = "left"
            vim.g.db_ui_winwidth = 35
            -- Additional buffer-level key maps for DBUI operations
            vim.api.nvim_set_keymap("n", "<leader>db", ":DBUIFindBuffer<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap("n", "<leader>dr", ":DBUIRenameBuffer<CR>", { noremap = true })
            vim.api.nvim_set_keymap("n", "<leader>dl", ":DBUILastQueryInfo<CR>", { noremap = true, silent = true })
            vim.g.db_ui_auto_execute_table_helpers = 1
            -- Apply LVIM palette colours to DBUI connection status highlights
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dbui",
                callback = function()
                    vim.schedule(function()
                        vim.api.nvim_set_hl(0, "dbui_connection_ok", { fg = _G.LVIM.colors.green })
                        vim.api.nvim_set_hl(0, "dbui_connection_error", { fg = _G.LVIM.colors.red })
                        vim.api.nvim_set_hl(0, "dbui_saved_query", { fg = _G.LVIM.colors.orange })
                    end)
                end,
                group = "LvimIDE",
            })
        end,
    },

    -- -------------------------------------------------------------------------
    -- nvim-dbee: alternative database client with a richer query UI.
    -- -------------------------------------------------------------------------
    nvim_dbee = {
        cmd = { "Dbee" },
        keys = {
            { "<Leader>do", "<cmd>Dbee open<cr>", desc = "Dbee open" },
            { "<Leader>dc", "<cmd>Dbee close<cr>", desc = "Dbee close" },
        },
        opts = {},
    },

    lvim_dependencies = {
        opts = {},
    },

    -- -------------------------------------------------------------------------
    -- package-info.nvim: shows npm package version info inline in package.json.
    -- Registers user commands so the UI can be triggered from the command line.
    -- -------------------------------------------------------------------------
    package_info_nvim = {
        ---@return table  Empty opts (commands registered as side-effect)
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

    -- -------------------------------------------------------------------------
    -- crates.nvim: Rust crate version info and management in Cargo.toml.
    -- Registers user commands for all crate operations and enables LSP + hover.
    -- -------------------------------------------------------------------------
    crates_nvim = {
        ---@return table|nil  crates.nvim options with LSP and completion config
        opts = function()
            local crates_status_ok, crates = pcall(require, "crates")
            if not crates_status_ok then
                return
            end

            -- Register user commands for common crate management actions
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
            -- Popup commands show the popup and immediately move focus to it
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

            return {
                lsp = {
                    enabled = true,
                    ---@param _client table   LSP client object
                    ---@param _bufnr  integer Buffer number
                    on_attach = function(_client, _bufnr)
                        -- the same on_attach function as for your other language servers
                        -- can be ommited if you're using the `LspAttach` autocmd
                    end,
                    actions = true,
                    completion = true,
                    hover = true,
                },
                completion = {
                    crates = {
                        enabled = true, -- Disabled by default
                        max_results = 8, -- The maximum number of search results to display
                        min_chars = 3, -- The minimum number of charaters to type before completions begin appearing
                    },
                },
            }
        end,
    },

    -- -------------------------------------------------------------------------
    -- pubspec-assist: adds Flutter/Dart packages from pub.dev to pubspec.yaml.
    -- Key maps are registered only when pubspec.yaml is the active buffer.
    -- -------------------------------------------------------------------------
    pubspec_assist_nvim = {
        ---@return table  pubspec-assist highlight group configuration
        opts = function()
            -- Set up buffer-local key maps only when editing pubspec.yaml
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("pubspec_keymaps", { clear = true }),
                pattern = "pubspec.yaml",
                callback = function()
                    local opts_buffer = { buffer = 0, silent = true, desc = "Pubspec: Add Package" }
                    local opts_buffer_dev = { buffer = 0, silent = true, desc = "Pubspec: Add Dev Package" }
                    local opts_buffer_pick = { buffer = 0, silent = true, desc = "Pubspec: Pick Version" }
                    vim.keymap.set("n", "<leader>pa", "<cmd>PubspecAssistAddPackage<cr>", opts_buffer)
                    vim.keymap.set("n", "<leader>pd", "<cmd>PubspecAssistAddDevPackage<cr>", opts_buffer_dev)
                    vim.keymap.set("n", "<leader>pv", "<cmd>PubspecAssistPickVersion<cr>", opts_buffer_pick)
                end,
            })
            return {
                -- Map dependency freshness states to LVIM highlight groups
                highlights = {
                    up_to_date = "PubspecDependencyUpToDate",
                    outdated = "PubspecDependencyOutdated",
                    unknown = "PubspecDependencyUnknown",
                },
            }
        end,
    },

    -- -------------------------------------------------------------------------
    -- live-preview.nvim: browser live-preview for Markdown / HTML files.
    -- -------------------------------------------------------------------------
    live_preview_nvim = {
        keys = {
            { "<leader>pp", "<cmd>LivePreview pick<CR>", desc = "LivePreview Pick" },
        },
        opts = {
            picker = "fzf-lua",
            address = "127.0.0.1",
            port = 5500,
            browser = "qutebrowser",
            -- Do not change root based on open files
            dynamic_root = false,
            sync_scroll = true,
        },
    },

    -- -------------------------------------------------------------------------
    -- markview.nvim: rich Markdown / Typst / HTML / YAML rendering inside Neovim.
    -- Loads per-format render configs from sibling modules and sets up the
    -- markview extras (editor float, interactive checkboxes).
    -- -------------------------------------------------------------------------
    markview_nvim = {
        ---@return table  markview options (preview + per-format configs)
        opts = function()
            -- Load per-format rendering tables from sibling config modules
            local markdown = require("modules.base.configs.languages.markview.markdown")
            local markdown_inline = require("modules.base.configs.languages.markview.markdown_inline")
            local html = require("modules.base.configs.languages.markview.html")
            local yaml = require("modules.base.configs.languages.markview.yaml")
            local typst = require("modules.base.configs.languages.markview.typst")

            -- Set up the split-window Markdown editor extra
            require("markview.extras.editor").setup({
                width = { 10, 0.75 },
                height = { 3, 0.75 },
                debounce = 50,
            })
            -- Enable the interactive checkbox extra
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

    -- -------------------------------------------------------------------------
    -- helpview.nvim: renders vimdoc help files with extra highlights.
    -- -------------------------------------------------------------------------
    helpview_nvim = {
        opts = {},
    },

    -- -------------------------------------------------------------------------
    -- vimtex: LaTeX integration with zathura as the PDF viewer.
    -- -------------------------------------------------------------------------
    vimtex = {
        ---@return nil
        config = function()
            vim.g.vimtex_mappings_prefix = "'"
            vim.g.vimtex_view_method = "zathura"
            vim.g.latex_view_general_viewer = "zathura"
            vim.g.vimtex_compiler_progname = "nvr"
            vim.g.vimtex_compiler_callback_compiling = "nvr"
            -- Suppress the quickfix window on compiler warnings (only show errors)
            vim.g.vimtex_quickfix_open_on_warning = 0
        end,
    },

    -- -------------------------------------------------------------------------
    -- orgmode: Org-mode integration for Neovim.
    -- -------------------------------------------------------------------------
    orgmode = {
        opts = {
            emacs_config = {
                -- Path to Emacs early-init for shared config compatibility
                config_path = "~/.emacs.d/early-init.el",
            },
            org_agenda_files = { "~/Org/**/*" },
            org_default_notes_file = "~/Org/refile.org",
        },
    },

    -- -------------------------------------------------------------------------
    -- lvim-org-utils: LVIM-specific utilities that extend orgmode integration.
    -- -------------------------------------------------------------------------
    lvim_org_utils = {
        opts = {},
    },
}

-- vim: foldmethod=indent foldlevel=1
