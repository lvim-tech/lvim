-- Install Lsp server
-- :LspInstall tsserver

-- Install debugger
-- :DIInstall jsnode

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.base.utils")
local nvim_lsp_util = require("lspconfig/util")
local default_debouce_time = 150
local dap_install = require("dap-install")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    local server_setup = {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        on_attach = function(client, bufnr)
            table.insert(global["languages"]["jsts"]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client)
            languages_setup.document_formatting(client)
            local ts_utils = require("nvim-lsp-ts-utils")
            ts_utils.setup({
                debug = true,
            })
            ts_utils.setup_client(client)
        end,
        capabilities = languages_setup.get_capabilities(),
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
    }
    languages_setup.setup_lsp("tsserver", server_setup)
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/jsnode/") ~= true then
        vim.cmd("DIInstall jsnode")
    end
    dap_install.config("jsnode", {})
    dap.configurations.javascript = {
        {
            type = "node2",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            outFiles = { "${workspaceRoot}/dist/js/*" },
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
        },
    }
    dap.configurations.typescript = {
        {
            type = "node2",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            outFiles = { "${workspaceRoot}/dist/js/*" },
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
        },
    }
end

return language_configs
