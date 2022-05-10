-- Install Lsp server
-- :LspInstall pyright

-- Install debugger
-- :DIInstall python

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.global.utils")
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
        filetypes = { "python" },
        on_attach = function(client, bufnr)
            table.insert(global["languages"]["python"]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client)
            languages_setup.document_formatting(client)
        end,
        capabilities = languages_setup.get_capabilities(),
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
    }
    languages_setup.setup_lsp("pyright", server_setup)
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/python/") ~= true then
        vim.cmd("DIInstall python")
    end
    dap_install.config("python", {})
    dap.configurations.python = {
        {
            type = "python",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            pythonPath = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                end
                if vim.fn.executable(global.lsp_path .. "dapinstall/python/" .. "bin/python") == 1 then
                    return global.lsp_path .. "dapinstall/python/" .. "bin/python"
                else
                    return "python"
                end
            end,
        },
    }
end

return language_configs
