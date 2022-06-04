-- Install Lsp server
-- Custom install

-- Install debugger
-- :DIInstall dart

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.base.utils")
local nvim_lsp_util = require("lspconfig/util")
local default_debouce_time = 150
local dap_install = require("dap-install")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    require("flutter-tools").setup({
        ui = {
            border = "single",
        },
        debugger = {
            enabled = false,
        },
        fvm = false,
        widget_guides = {
            enabled = false,
        },
        closing_tags = {
            highlight = "Comment",
            prefix = "",
            enabled = true,
        },
        outline = {
            open_cmd = "60vnew",
        },
        lsp = {
            flags = {
                debounce_text_changes = default_debouce_time,
            },
            autostart = true,
            filetypes = { "dart" },
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["dart"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                languages_setup.document_highlight(client)
                languages_setup.document_formatting(client)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = function(fname)
                return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
            end,
        },
    })
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/dart/") ~= true then
        vim.cmd("DIInstall dart")
    end
    local find_dart_sdk_root_path = function()
        if os.getenv("FLUTTER_SDK") then
            local flutter_path = os.getenv("FLUTTER_SDK")
            return flutter_path
        elseif vim.fn["executable"]("flutter") == 1 then
            local flutter_exe_path = vim.fn["resolve"](vim.fn["exepath"]("flutter"))
            local flutter_path = flutter_exe_path:gsub("/bin/flutter", "")
            return flutter_path
        elseif vim.fn["executable"]("dart") == 1 then
            local dart_exe_path = vim.fn["resolve"](vim.fn["exepath"]("dart"))
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
            name = "Launch",
            request = "launch",
            dartSdkPath = dart_path,
            flutterSdkPath = dart_path,
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
        },
    }
end

return language_configs
