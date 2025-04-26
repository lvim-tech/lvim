local global = require("core.global")
local dap = require("dap")
local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_utils = require("languages.utils")

local lsp_server_name = "intelephense"
local debbuger_server_name = "php-debug-adapter"

-- DAP
local debbuger_server_async = lsp_utils.is_lsp_server_installed(debbuger_server_name)

local debbuger_server_result
while not debbuger_server_result do
    debbuger_server_result = debbuger_server_async()
    vim.wait(100)
end

if debbuger_server_result then
    dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { global.mason_path .. "/packages/php-debug-adapter/extension/out/phpDebug.js" },
    }
    dap.configurations.php = {
        {
            type = "php",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${fileDirname}",
            port = function()
                local val = tonumber(vim.fn.input("Port: "))
                assert(val, "Please provide a port number")
                return val
            end,
            runtimeArgs = {
                "-dxdebug.start_with_request=yes",
            },
            env = {
                XDEBUG_MODE = "debug,develop",
                XDEBUG_CONFIG = "client_port=${port}",
            },
        },
    }
end
-- DAP

-- LSP
local lsp_server_config = {
    name = "php",
    cmd = { "intelephense", "--stdio" },
    filetypes = _G.file_types.php,
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local cwd = assert(vim.uv.cwd())
        local root = lsp_utils.root_pattern("composer.json", ".git")(fname)
        on_dir(vim.fs.relpath(cwd, root) and cwd or root)
    end,
    settings = {},
    before_init = function(init_params, config)
        if config.settings and config.settings["rust-analyzer"] then
            init_params.initializationOptions = config.settings["rust-analyzer"]
        end
    end,
    on_attach = function(client, bufnr)
        setup_diagnostics.keymaps(client, bufnr)
        setup_diagnostics.document_highlight(client, bufnr)
        setup_diagnostics.document_auto_format(client, bufnr)
        setup_diagnostics.inlay_hint(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end
    end,
    capabilities = setup_diagnostics.get_capabilities(),
}

local lsp_server_async = lsp_utils.is_lsp_server_installed(lsp_server_name)

local lsp_server_result
while not lsp_server_result do
    lsp_server_result = lsp_server_async()
    vim.wait(100)
end

_G.php_lsp_config = lsp_server_config

if lsp_server_result then
    return lsp_server_config
else
    vim.notify("An error occurred while setting up the LSP (" .. lsp_server_name .. ")!", vim.log.levels.ERROR)
end
-- LSP

-- vim: foldmethod=indent foldlevel=0
