local global = require("core.global")
local rust_tools = require("rust-tools")
local languages_setup = require("languages.base.utils")
local nvim_lsp_util = require("lspconfig/util")
local navic = require("nvim-navic")
local default_debouce_time = 150
local dap = require("dap")

local language_configs = {}

local function start_server_tools()
    rust_tools.setup({
        tools = {
            inlay_hints = {
                auto = false,
            },
            hover_actions = {
                border = {
                    { "┌", "FloatBorder" },
                    { "─", "FloatBorder" },
                    { "┐", "FloatBorder" },
                    { "│", "FloatBorder" },
                    { "┘", "FloatBorder" },
                    { "─", "FloatBorder" },
                    { "└", "FloatBorder" },
                    { "│", "FloatBorder" },
                },
            },
        },
        server = {
            flags = {
                debounce_text_changes = default_debouce_time,
            },
            autostart = true,
            filetypes = { "rust" },
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["rust"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                languages_setup.document_highlight(client, bufnr)
                languages_setup.document_formatting(client, bufnr)
                navic.attach(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = function(fname)
                return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
            end,
        },
    })
end

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "rust",
        ["dap"] = { "cpptools" },
        ["rust-analyzer"] = {},
    })

    local function check_status()
        if global.install_proccess == false then
            start_server_tools()
            vim.cmd("LspStart rust_analyzer")
        else
            vim.defer_fn(function()
                check_status()
            end, 1000)
        end
    end

    check_status()
end

language_configs["dap"] = function()
    dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = global.mason_path .. "/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
    }
    dap.configurations.rust = {
        {
            name = "Launch file",
            type = "cppdbg",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = true,
        },
    }
end

return language_configs
