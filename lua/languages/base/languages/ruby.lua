-- Install Lsp server
-- :LspInstall solargraph

-- Install debugger
-- :DIInstall ruby_vsc
-- Do not forget to add `ruby-debug-ide` gem to your bundle or system!
-- gem install ruby-debug-ide

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
        filetypes = { "ruby" },
        on_attach = function(client, bufnr)
            table.insert(global["languages"]["ruby"]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client)
            languages_setup.document_formatting(client)
        end,
        capabilities = languages_setup.get_capabilities(),
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
    }
    languages_setup.setup_lsp("solargraph", server_setup)
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/ruby_vsc/") ~= true then
        vim.cmd("DIInstall ruby_vsc")
    end
    dap_install.config("ruby_vsc", {})
    dap.configurations.ruby = {
        {
            type = "ruby",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
        },
    }
end

return language_configs
