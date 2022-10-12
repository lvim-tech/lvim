local config = {}

function config.mason_nvim()
    vim.api.nvim_create_user_command("LspAddToWorkspaceFolder", "lua vim.lsp.buf.add_workspace_folder()", {})
    vim.api.nvim_create_user_command("LspListWorkspaceFolders", "lua vim.lsp.buf.list_workspace_folders()", {})
    vim.api.nvim_create_user_command("LspRemoveWorkspaceFolder", "lua vim.lsp.buf.remove_workspace_folder()", {})
    vim.api.nvim_create_user_command("LspWorkspaceSymbol", "lua vim.lsp.buf.workspace_symbol()", {})
    vim.api.nvim_create_user_command("LspDocumentSymbol", "lua vim.lsp.buf.document_symbol()", {})
    vim.api.nvim_create_user_command("LspCodeAction", "lua vim.lsp.buf.code_action()", {})
    vim.api.nvim_create_user_command("LspRangeCodeAction", "lua vim.api.nvim_create_user_command()", {})
    vim.api.nvim_create_user_command("LspCodeLensRefresh", "lua vim.lsp.codelens.refresh()", {})
    vim.api.nvim_create_user_command("LspCodeLensRun", "lua vim.lsp.codelens.run()", {})
    vim.api.nvim_create_user_command("LspDeclaration", "lua vim.lsp.buf.declaration()", {})
    vim.api.nvim_create_user_command("LspDefinition", "lua vim.lsp.buf.definition()", {})
    vim.api.nvim_create_user_command("LspTypeDefinition", "lua vim.lsp.buf.type_definition()", {})
    vim.api.nvim_create_user_command("LspReferences", "lua vim.lsp.buf.references()", {})
    vim.api.nvim_create_user_command("LspClearReferences", "lua vim.lsp.buf.clear_references()", {})
    vim.api.nvim_create_user_command("LspDocumentHighlight", "lua vim.lsp.buf.document_highlight()", {})
    vim.api.nvim_create_user_command("LspImplementation", "lua vim.lsp.buf.implementation()", {})
    vim.api.nvim_create_user_command("LspIncomingCalls", "lua vim.lsp.buf.incoming_calls()", {})
    vim.api.nvim_create_user_command("LspOutgoingCalls", "lua vim.lsp.buf.outgoing_calls()", {})
    vim.api.nvim_create_user_command("LspFormatting", "lua vim.lsp.buf.format {async = true}", {})
    vim.api.nvim_create_user_command("LspRename", "lua vim.lsp.buf.rename()", {})
    vim.api.nvim_create_user_command("LspSignatureHelp", "lua vim.lsp.buf.signature_help()", {})
    local mason_status_ok, mason = pcall(require, "mason")
    if not mason_status_ok then
        return
    end
    mason.setup({
        ui = {
            icons = {
                package_installed = " ",
                package_pending = " ",
                package_uninstalled = " ",
            },
        },
    })
    require("languages.base.utils").setup_diagnostic()
end

function config.null_ls_nvim()
    local null_ls_status_ok, null_ls = pcall(require, "null-ls")
    if not null_ls_status_ok then
        return
    end
    null_ls.setup({
        debug = false,
        on_attach = function(client, bufnr)
            if client.server_capabilities.documentFormattingProvider then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = "LvimIDE",
                    buffer = bufnr,
                    command = "lua vim.lsp.buf.format()",
                })
            end
        end,
    })
end

function config.goto_preview()
    local lib = require("goto-preview.lib")
    local goto_preview_status_ok, goto_preview = pcall(require, "goto-preview")
    if not goto_preview_status_ok then
        return
    end
    goto_preview.setup({
        width = 160,
        height = 25,
        border = { " ", " ", " ", " ", " ", " ", " ", " " }, -- Border characters of the floating window
        references = {
            telescope = lib.has_telescope and lib.telescope.themes.get_dropdown({
                layout_config = {
                    width = function(_, max_columns, _)
                        return math.min(max_columns, 200)
                    end,

                    height = function(_, _, max_lines)
                        return math.min(max_lines, 15)
                    end,
                },
                winblend = 8,
                border = {},
                borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
                hide_preview = false,
            }) or nil,
        },
    })
    vim.api.nvim_create_user_command(
        "LspPreviewDefinition",
        "lua require('goto-preview').goto_preview_definition()",
        {}
    )
    vim.api.nvim_create_user_command(
        "LspPreviewTypeDefinition",
        "lua require('goto-preview').goto_preview_type_definition()",
        {}
    )
    vim.api.nvim_create_user_command(
        "LspPreviewReferences",
        "lua require('goto-preview').goto_preview_references()",
        {}
    )
    vim.api.nvim_create_user_command(
        "LspPreviewImplementation",
        "lua require('goto-preview').goto_preview_implementation()",
        {}
    )
    vim.api.nvim_create_user_command("LspPreviewCloseAll", "lua require('goto-preview').close_all_win()", {})
end

function config.hover_nvim()
    local hover_status_ok, hover = pcall(require, "hover")
    if not hover_status_ok then
        return
    end
    hover.setup({
        init = function()
            require("hover.providers.lsp")
        end,
        preview_opts = {
            border = nil,
        },
        title = false,
    })
    vim.api.nvim_create_user_command("LspHover", "lua require('hover').hover()", {})
end

function config.fidget_nvim()
    local fidget_status_ok, fidget = pcall(require, "fidget")
    if not fidget_status_ok then
        return
    end
    fidget.setup({
        sources = {
            ["null-ls"] = {
                ignore = true,
            },
        },
        text = {
            spinner = "bouncing_bar", -- animation shown when tasks are ongoing
        },
        window = {
            relative = "editor", -- where to anchor, either "win" or "editor"
            blend = 0,
            border = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        command = [[silent! FidgetClose]],
    })
end

function config.go_nvim()
    local go_status_ok, go = pcall(require, "go")
    if not go_status_ok then
        return
    end
    go.setup({
        lsp_inlay_hints = {
            enable = false,
        },
    })
end

function config.trld_nvim()
    local trld_status_ok, trld = pcall(require, "trld")
    if not trld_status_ok then
        return
    end
    trld.setup({
        position = "bottom",
        highlights = {
            error = "DiagnosticError",
            warn = "DiagnosticWarn",
            info = "DiagnosticInfo",
            hint = "DiagnosticHint",
        },
    })
end

function config.nvim_lightbulb()
    local nvim_lightbulb_status_ok, nvim_lightbulb = pcall(require, "nvim-lightbulb")
    if not nvim_lightbulb_status_ok then
        return
    end
    nvim_lightbulb.setup({
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
    vim.fn.sign_define("LightBulbSign", { text = "", texthl = "LightBulb", linehl = "", numhl = "" })
end

function config.nvim_treesitter()
    local nvim_treesitter_configs_status_ok, nvim_treesitter_configs = pcall(require, "nvim-treesitter.configs")
    if not nvim_treesitter_configs_status_ok then
        return
    end
    nvim_treesitter_configs.setup({
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
            disable = { "markdown" },
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

function config.lsp_inlayhints_nvim()
    local lsp_inlayhints_status_ok, lsp_inlayhints = pcall(require, "lsp-inlayhints")
    if not lsp_inlayhints_status_ok then
        return
    end
    lsp_inlayhints.setup({
        inlay_hints = {
            highlight = "Comment",
        },
    })
    vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
    vim.api.nvim_create_autocmd("LspAttach", {
        group = "LspAttach_inlayhints",
        callback = function(args)
            if not (args.data and args.data.client_id) then
                return
            end
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            lsp_inlayhints.on_attach(client, bufnr)
        end,
    })
end

function config.nvim_navic()
    local icons = require("configs.base.ui.icons")
    local nvim_navic_status_ok, nvim_navic = pcall(require, "nvim-navic")
    if not nvim_navic_status_ok then
        return
    end
    nvim_navic.setup({
        icons = icons.lsp,
        highlight = true,
        separator = " ➤ ",
    })
    vim.g.navic_silence = true
end

function config.any_jump_nvim()
    vim.g.any_jump_disable_default_keybindings = 1
    vim.g.any_jump_list_numbers = 1
end

function config.symbols_outline_nvim()
    local icons = require("configs.base.ui.icons")
    local symbols_outline_status_ok, symbols_outline = pcall(require, "symbols-outline")
    if not symbols_outline_status_ok then
        return
    end
    symbols_outline.setup({
        symbols = icons.outline,
        highlight_hovered_item = true,
        show_guides = true,
    })
end

function config.nvim_dap_ui()
    local dapui_status_ok, dapui = pcall(require, "dapui")
    if not dapui_status_ok then
        return
    end
    local dap_status_ok, dap = pcall(require, "dap")
    if not dap_status_ok then
        return
    end
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
        layouts = {
            {
                elements = {
                    "scopes",
                    "breakpoints",
                    "stacks",
                    "watches",
                },
                size = 40,
                position = "left",
            },
            {
                elements = {
                    "repl",
                    "console",
                },
                size = 10,
                position = "bottom",
            },
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
        dapui.open({})
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
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

function config.nvim_dap_vscode_js()
    local global = require("core.global")
    local dap_vscode_js_status_ok, dap_vscode_js = pcall(require, "dap-vscode-js")
    if not dap_vscode_js_status_ok then
        return
    end
    dap_vscode_js.setup({
        node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
        debugger_path = global.mason_path .. "/bin/vscode-js-debug", -- Path to vscode-js-debug installation.
        debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
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

function config.package_info_nvim()
    local package_info_status_ok, package_info = pcall(require, "package-info")
    if not package_info_status_ok then
        return
    end
    package_info.setup({
        colors = {
            up_to_date = "#98c379",
            outdated = "#F05F4E",
        },
    })
end

function config.crates_nvim()
    local crates_status_ok, crates = pcall(require, "crates")
    if not crates_status_ok then
        return
    end
    crates.setup()
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

function config.pubspec_assist_nvim()
    local pubspec_assist_status_ok, pubspec_assist = pcall(require, "pubspec-assist")
    if not pubspec_assist_status_ok then
        return
    end
    pubspec_assist.setup({})
end

function config.vimtex()
    vim.g.vimtex_view_method = "zathura"
    vim.g.latex_view_general_viewer = "zathura"
    vim.g.vimtex_compiler_progname = "nvr"
    vim.g.vimtex_compiler_callback_compiling = "nvr"
    vim.g.vimtex_quickfix_open_on_warning = 0
end

function config.orgmode()
    local orgmode_status_ok, orgmode = pcall(require, "orgmode")
    if not orgmode_status_ok then
        return
    end
    orgmode.setup_ts_grammar()
    orgmode.setup({
        emacs_config = {
            config_path = "$HOME/.emacs.d/early-init.el",
        },
        org_agenda_files = { "$HOME/Org/**/*" },
        org_default_notes_file = "$HOME/Org/refile.org",
    })
end

function config.lvim_org_utils()
    local lvim_org_utils_status_ok, lvim_org_utils = pcall(require, "lvim-org-utils")
    if not lvim_org_utils_status_ok then
        return
    end
    lvim_org_utils.setup()
end

return config
