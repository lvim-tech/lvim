-- Install Lsp server
-- :LspInstall rust_analyzer

-- Install debugger
-- :DIInstall ccppr_lldb

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.global.utils")
local nvim_lsp = require("lspconfig")
local nvim_lsp_util = require("lspconfig/util")
local lsp_signature = require("lsp_signature")
local default_debouce_time = 150
local lsp_installer = require("nvim-lsp-installer")
local lsp_installer_servers = require("nvim-lsp-installer.servers")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    local function start_rust_analyzer()
        nvim_lsp.rust_analyzer.setup {
            cmd = {
                global.lsp_path .. "lsp_servers/rust/rust-analyzer"
            },
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"rust"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["rust"]["pid"], client.rpc.pid)
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
                lsp_signature.on_attach(languages_setup.config_lsp_signature)
                languages_setup.document_highlight(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_setup.show_line_diagnostics()
        }
    end
    local ok, rust_analyzer = lsp_installer_servers.get_server("rust_analyzer")
    if ok then
        if not rust_analyzer:is_installed() then
            rust_analyzer:install()
            lsp_installer.on_server_ready(
                function()
                    start_rust_analyzer()
                end
            )
        else
            start_rust_analyzer()
        end
    end
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/ccppr_lldb/") ~= true then
        vim.cmd("DIInstall ccppr_lldb")
    end
    dap.adapters.rust = {
        type = "executable",
        attach = {pidProperty = "pid", pidSelect = "ask"},
        command = "lldb-vscode",
        env = {LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"},
        name = "lldb"
    }
    dap.configurations.rust = {
        {
            type = "rust",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            args = {},
            cwd = "${workspaceFolder}",
            env = function()
                local variables = {}
                for k, v in pairs(vim.fn.environ()) do
                    table.insert(variables, string.format("%s=%s", k, v))
                end
                return variables
            end,
            stopOnEntry = false
        }
    }
end

return language_configs
