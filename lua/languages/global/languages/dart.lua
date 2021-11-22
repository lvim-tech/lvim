-- Install Lsp server
-- Custom install

-- Install debugger
-- :DIInstall dart

local global = require("core.global")
local funcs = require("core.funcs")
local languages_utils = require("languages.global.utils")
local nvim_lsp_util = require("lspconfig/util")
local lsp_signature = require("lsp_signature")
local default_debouce_time = 150
local dap_install = require("dap-install")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    require("flutter-tools").setup {
        ui = {
            border = "single"
        },
        debugger = {
            enabled = true
        },
        fvm = false,
        widget_guides = {
            enabled = false
        },
        closing_tags = {
            highlight = "Comment",
            prefix = "",
            enabled = true
        },
        outline = {
            open_cmd = "60vnew"
        },
        lsp = {
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"dart"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["dart"]["pid"], client.rpc.pid)
                if client.resolved_capabilities.document_formatting then
                    vim.api.nvim_exec(
                        [[
                        augroup LspAutocommands
                            autocmd! * <buffer>
                            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
                        augroup END
                        ]],
                        true
                    )
                end
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_utils.config_lsp_signature)
                languages_utils.document_highlight(client)
            end,
            capabilities = languages_utils.get_capabilities(),
            root_dir = function(fname)
                return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
            end
        }
    }
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/dart/") ~= true then
        vim.cmd("DIInstall dart")
    end
    local find_dart_sdk_root_path = function()
        if os.getenv "FLUTTER_SDK" then
            local flutter_path = os.getenv "FLUTTER_SDK"
            return flutter_path
        elseif vim.fn["executable"] "flutter" == 1 then
            local flutter_exe_path = vim.fn["resolve"](vim.fn["exepath"] "flutter")
            local flutter_path = flutter_exe_path:gsub("/bin/flutter", "")
            return flutter_path
        elseif vim.fn["executable"] "dart" == 1 then
            local dart_exe_path = vim.fn["resolve"](vim.fn["exepath"] "dart")
            local dart_path = dart_exe_path:gsub("/bin/dart", "")
            return dart_path
        else
            return ""
        end
    end
    local dart_path = find_dart_sdk_root_path()
    dap_install.config("dart", {})
    dap.configurations.dart = {
        {
            type = "dart",
            name = "Launch flutter",
            request = "launch",
            dartSdkPath = dart_path,
            flutterSdkPath = dart_path,
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}"
        }
    }
end

return language_configs
