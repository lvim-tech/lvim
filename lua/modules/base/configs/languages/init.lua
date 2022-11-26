local config = {}

config.mason_nvim = function()
    vim.api.nvim_create_user_command(
        "LvimInstallLangDependencies",
        "lua require('languages.base.utils').install_all_packages()",
        {}
    )
    vim.api.nvim_create_user_command("LspHover", "lua vim.lsp.buf.hover()", {})
    vim.api.nvim_create_user_command("LspRename", "lua vim.lsp.buf.rename()", {})
    vim.api.nvim_create_user_command("LspAddToWorkspaceFolder", "lua vim.lsp.buf.add_workspace_folder()", {})
    vim.api.nvim_create_user_command("LspListWorkspaceFolders", "lua vim.lsp.buf.list_workspace_folders()", {})
    vim.api.nvim_create_user_command("LspRemoveWorkspaceFolder", "lua vim.lsp.buf.remove_workspace_folder()", {})
    vim.api.nvim_create_user_command("LspWorkspaceSymbol", "lua vim.lsp.buf.workspace_symbol()", {})
    vim.api.nvim_create_user_command("LspDocumentSymbol", "lua vim.lsp.buf.document_symbol()", {})
    vim.api.nvim_create_user_command("LspCodeAction", "lua vim.lsp.buf.code_action()", {})
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
    vim.api.nvim_create_user_command("LspFormat", "lua vim.lsp.buf.format {async = true}", {})
    vim.api.nvim_create_user_command("LspRename", "lua vim.lsp.buf.rename()", {})
    vim.api.nvim_create_user_command("LspSignatureHelp", "lua vim.lsp.buf.signature_help()", {})
    vim.api.nvim_create_user_command(
        "LspShowDiagnosticCurrent",
        "lua require('languages.base.utils.show_diagnostic').line()",
        {}
    )
    vim.api.nvim_create_user_command(
        "LspShowDiagnosticNext",
        "lua require('languages.base.utils.show_diagnostic').goto_next()",
        {}
    )
    vim.api.nvim_create_user_command(
        "LspShowDiagnosticPrev",
        "lua require('languages.base.utils.show_diagnostic').goto_prev()",
        {}
    )
    vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
    end, { noremap = true, silent = true, desc = "LspDefinition" })
    vim.keymap.set("n", "gt", function()
        vim.lsp.buf.type_definition()
    end, { noremap = true, silent = true, desc = "LspTypeDefinition" })
    vim.keymap.set("n", "gr", function()
        vim.lsp.buf.references()
    end, { noremap = true, silent = true, desc = "LspReferences" })
    vim.keymap.set("n", "gi", function()
        vim.lsp.buf.implementation()
    end, { noremap = true, silent = true, desc = "LspImplementation" })
    vim.keymap.set("n", "ge", function()
        vim.lsp.buf.rename()
    end, { noremap = true, silent = true, desc = "LspRename" })
    vim.keymap.set("n", "gf", function()
        vim.lsp.buf.format({ async = true })
    end, { noremap = true, silent = true, desc = "LspFormat" })
    vim.keymap.set("n", "ga", function()
        vim.lsp.buf.code_action()
    end, { noremap = true, silent = true, desc = "LspCodeAction" })
    vim.keymap.set("n", "gs", function()
        vim.lsp.buf.signature_help()
    end, { noremap = true, silent = true, desc = "LspSignatureHelp" })
    vim.keymap.set("n", "gL", function()
        vim.lsp.codelens.refresh()
    end, { noremap = true, silent = true, desc = "LspCodeLensRefresh" })
    vim.keymap.set("n", "gl", function()
        vim.lsp.codelens.run()
    end, { noremap = true, silent = true, desc = "LspCodeLensRun" })
    vim.keymap.set("n", "gh", function()
        vim.lsp.buf.hover()
    end, { noremap = true, silent = true, desc = "LspHover" })
    vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover()
    end, { noremap = true, silent = true, desc = "LspHover" })
    vim.keymap.set("n", "dc", function()
        vim.cmd("LspShowDiagnosticCurrent")
    end, { noremap = true, silent = true, desc = "LspShowDiagnosticCurrent" })
    vim.keymap.set("n", "dn", function()
        vim.cmd("LspShowDiagnosticNext")
    end, { noremap = true, silent = true, desc = "LspShowDiagnosticNext" })
    vim.keymap.set("n", "dp", function()
        vim.cmd("LspShowDiagnosticPrev")
    end, { noremap = true, silent = true, desc = "LspShowDiagnosticPrev" })
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

config.null_ls_nvim = function()
    local null_ls_status_ok, null_ls = pcall(require, "null-ls")
    if not null_ls_status_ok then
        return
    end
    null_ls.setup({
        debug = false,
        on_attach = function(client, bufnr)
            if client.server_capabilities.documentFormattingProvider then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    callback = function()
                        if _G.LVIM_SETTINGS.autoformat == true then
                            vim.lsp.buf.format()
                        end
                    end,
                    group = "LvimIDE",
                })
            end
        end,
    })
end

config.neotest = function()
    local neotest_status_ok, neotest = pcall(require, "neotest")
    if not neotest_status_ok then
        return
    end
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
        virtual_text = {
            format = function(diagnostic)
                local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                return message
            end,
        },
    }, neotest_ns)
    neotest.setup({
        adapters = {
            require("neotest-phpunit"),
            require("neotest-rust"),
            require("neotest-go"),
            require("neotest-python")({
                dap = { justMyCode = false },
                args = { "--log-level", "DEBUG" },
                runner = "pytest",
            }),
            require("neotest-haskell"),
            require("neotest-elixir"),
            require("neotest-dart")({
                command = "flutter",
                use_lsp = true,
            }),
        },
    })
    vim.api.nvim_create_user_command("NeotestRun", require("neotest").run.run, {})
    vim.api.nvim_create_user_command("NeotestOutput", require("neotest").output.open, {})
    vim.api.nvim_create_user_command("NeotestSummary", require("neotest").summary.toggle, {})
    vim.keymap.set("n", "<leader>nr", function()
        require("neotest").run.run()
    end, { noremap = true, desc = "NeotestRun" })
    vim.keymap.set("n", "<leader>no", function()
        require("neotest").output.open()
    end, { noremap = true, desc = "NeotestOutput" })
    vim.keymap.set("n", "<leader>ns", function()
        require("neotest").summary.toggle()
    end, { noremap = true, desc = "NeotestSummary" })
end

config.inc_rename_nvim = function()
    local inc_rename_status_ok, inc_rename = pcall(require, "inc_rename")
    if not inc_rename_status_ok then
        return
    end
    inc_rename.setup()
    vim.keymap.set("n", "gE", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
    end, { expr = true, desc = "IncRename" })
end

config.glance_nvim = function()
    local glance = require("glance")
    local actions = glance.actions
    glance.setup({
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
        mappings = {
            list = {
                ["j"] = actions.next,
                ["k"] = actions.previous,
                ["<Tab>"] = actions.next_location,
                ["<S-Tab>"] = actions.previous_location,
                ["<C-u>"] = actions.preview_scroll_win(5),
                ["<C-d>"] = actions.preview_scroll_win(-5),
                ["v"] = actions.jump_vsplit,
                ["s"] = actions.jump_split,
                ["t"] = actions.jump_tab,
                ["<CR>"] = actions.jump,
                ["o"] = actions.jump,
                ["<C-h>"] = actions.enter_win("preview"), -- Focus preview window
                ["<Esc>"] = actions.close,
                ["q"] = actions.close,
            },
            preview = {
                ["q"] = actions.close,
                ["<Tab>"] = actions.next_location,
                ["<S-Tab>"] = actions.previous_location,
                ["<C-l>"] = actions.enter_win("list"), -- Focus list window
            },
        },
        hooks = {
            before_open = function(results, open, jump, method)
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
    })
    vim.keymap.set("n", "gpd", "<Cmd>Glance definitions<CR>")
    vim.keymap.set("n", "gpr", "<Cmd>Glance references<CR>")
    vim.keymap.set("n", "gpt", "<Cmd>Glance type_definitions<CR>")
    vim.keymap.set("n", "gpi", "<Cmd>Glance implementations<CR>")
    vim.keymap.set("n", "fq", "<Cmd>CloseFloatWindows<CR>")
end

config.neodev_nvim = function()
    local neodev_status_ok, neodev = pcall(require, "neodev")
    if not neodev_status_ok then
        return
    end
    neodev.setup({
        library = {
            enabled = true,
            runtime = true,
            types = true,
            plugins = false,
        },
    })
end

config.go_nvim = function()
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

config.typescript_nvim = function()
    local typescript_status_ok, typescript = pcall(require, "typescript")
    if not typescript_status_ok then
        return
    end
    typescript.setup()
end

config.nvim_lightbulb = function()
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

config.nvim_treesitter = function()
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
        },
        autopairs = {
            enable = true,
        },
        autotag = {
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
    })
end

config.lsp_inlayhints_nvim = function()
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

config.nvim_navic = function()
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

config.any_jump_nvim = function()
    vim.g.any_jump_disable_default_keybindings = 1
    vim.g.any_jump_list_numbers = 1
    vim.keymap.set("n", "<A-u>", ":AnyJump<CR>", { noremap = true, silent = true, desc = "AnyJump" })
    vim.keymap.set("v", "<A-u>", ":AnyJumpVisual<CR>", { noremap = true, silent = true, desc = "AnyJumpVisual" })
end

config.symbols_outline_nvim = function()
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
    vim.keymap.set("n", "<A-v>", function()
        vim.cmd("SymbolsOutline")
    end, { noremap = true, silent = true, desc = "SymbolsOutline" })
end

config.nvim_dap_ui = function()
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
                    { id = "scopes", size = 0.33 },
                    { id = "breakpoints", size = 0.17 },
                    { id = "stacks", size = 0.25 },
                    { id = "watches", size = 0.25 },
                },
                size = 0.33,
                position = "right",
            },
            {
                elements = {
                    { id = "repl", size = 0.45 },
                    { id = "console", size = 0.55 },
                },
                size = 0.27,
                position = "bottom",
            },
        },
        floating = {
            max_height = 0.9,
            max_width = 0.5, -- Floats will be treated as percentage of your screen.
            border = vim.g.border_chars, -- Border style. Can be 'single', 'double' or 'rounded'
            mappings = {
                close = { "q", "<Esc>" },
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
    vim.api.nvim_create_user_command("LuaDapLaunch", 'lua require"osv".run_this()', {})
    vim.api.nvim_create_user_command("DapToggleBreakpoint", 'lua require("dap").toggle_breakpoint()', {})
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
    vim.keymap.set("n", "<A-1>", function()
        dap.toggle_breakpoint()
    end, { noremap = true, silent = true, desc = "DapToggleBreakpoint" })
    vim.keymap.set("n", "<A-2>", function()
        dap.continue()
    end, { noremap = true, silent = true, desc = "DapContinue" })
    vim.keymap.set("n", "<A-3>", function()
        dap.step_into()
    end, { noremap = true, silent = true, desc = "DapStepInto" })
    vim.keymap.set("n", "<A-4>", function()
        dap.step_over()
    end, { noremap = true, silent = true, desc = "DapStepOver" })
    vim.keymap.set("n", "<A-5>", function()
        dap.step_out()
    end, { noremap = true, silent = true, desc = "DapStepOut" })
    vim.keymap.set("n", "<A-6>", function()
        dap.up()
    end, { noremap = true, silent = true, desc = "DapUp" })
    vim.keymap.set("n", "<A-7>", function()
        dap.down()
    end, { noremap = true, silent = true, desc = "DapDown" })
    vim.keymap.set("n", "<A-8>", function()
        dap.close()
        dap.disconnect()
        dapui.close()
    end, { noremap = true, silent = true, desc = "DapUIClose" })
    vim.keymap.set("n", "<A-9>", function()
        dap.restart()
    end, { noremap = true, silent = true, desc = "DapRestart" })
    vim.keymap.set("n", "<A-0>", function()
        dap.repl.toggle()
    end, { noremap = true, silent = true, desc = "DapToggleRepl" })
end

config.nvim_dap_vscode_js = function()
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

config.vim_dadbod_ui = function()
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_win_position = "left"
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_winwidth = 35
    vim.g.db_ui_auto_execute_table_helpers = true
end

config.package_info_nvim = function()
    local package_info_status_ok, package_info = pcall(require, "package-info")
    if not package_info_status_ok then
        return
    end
    package_info.setup({
        colors = {
            up_to_date = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].green_01,
            outdated = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].red_01,
        },
    })
end

config.crates_nvim = function()
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

config.pubspec_assist_nvim = function()
    local pubspec_assist_status_ok, pubspec_assist = pcall(require, "pubspec-assist")
    if not pubspec_assist_status_ok then
        return
    end
    pubspec_assist.setup({})
end

config.markdown_preview_nvim = function()
    vim.keymap.set("n", "<S-m>", function()
        vim.cmd("MarkdownPreviewToggle")
    end, { noremap = true, silent = true, desc = "MarkdownPreviewToggle" })
end

config.vimtex = function()
    vim.g.vimtex_view_method = "zathura"
    vim.g.latex_view_general_viewer = "zathura"
    vim.g.vimtex_compiler_progname = "nvr"
    vim.g.vimtex_compiler_callback_compiling = "nvr"
    vim.g.vimtex_quickfix_open_on_warning = 0
end

config.orgmode = function()
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
    vim.keymap.set("n", "to", function()
        vim.cmd("e ~/Org/notes/notes.org")
    end, { noremap = true, silent = true, desc = "Open org notes" })
end

config.lvim_org_utils = function()
    local lvim_org_utils_status_ok, lvim_org_utils = pcall(require, "lvim-org-utils")
    if not lvim_org_utils_status_ok then
        return
    end
    lvim_org_utils.setup()
end

return config
