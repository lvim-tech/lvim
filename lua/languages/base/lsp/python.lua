local global = require("core.global")
local dap = require("dap")
local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_utils = require("languages.utils")

local lsp_server_name = "python-lsp-server"
local debbuger_server_name = "debugpy"

-- EFM
local efm_config = {
    {
        server_name = "black",
        fPrefix = "black",
        formatCommand = "black -q -",
        formatStdin = true,
        rootMarkers = { "pyproject.toml" },
    },
}

lsp_utils.setup_efm(_G.file_types.python, efm_config)
-- EFM

-- DAP
local debbuger_server_async = lsp_utils.is_lsp_server_installed(debbuger_server_name)

local debbuger_server_result
while not debbuger_server_result do
    debbuger_server_result = debbuger_server_async()
    vim.wait(100)
end

if debbuger_server_result then
    dap.adapters.python = {
        type = "executable",
        command = global.mason_path .. "/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
    }
    dap.configurations.python = {
        {
            type = "python",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            console = "integratedTerminal",
            stopOnEntry = true,
            justMyCode = false,
            pythonPath = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                end
                if vim.fn.executable(global.mason_path .. "/packages/debugpy/venv/" .. "bin/python") == 1 then
                    return global.mason_path .. "/packages/debugpy/venv/" .. "bin/python"
                else
                    return "python"
                end
            end,
            cwd = "${workspaceFolder}",
            postDebugTask = "Python: Close debugger",
        },
        {
            type = "python",
            request = "launch",
            name = "Debug Current File",
            program = "${file}",
            console = "integratedTerminal",
            stopOnEntry = true,
            justMyCode = false,
            cwd = "${workspaceFolder}",
            pythonPath = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                end
                if vim.fn.executable(global.mason_path .. "/packages/debugpy/venv/" .. "bin/python") == 1 then
                    return global.mason_path .. "/packages/debugpy/venv/" .. "bin/python"
                else
                    return "python"
                end
            end,
        },
    }
end
-- DAP

-- LSP
local lsp_server_config = {
    name = "python",
    cmd = { "pylsp" },
    filetypes = _G.file_types.python,
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        ".git",
    },
    settings = {
        pylsp = {
            plugins = {
                black = { enabled = true, line_length = 79 },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
            },
        },
    },
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

_G.python_lsp_config = lsp_server_config

if lsp_server_result then
    return lsp_server_config
else
    vim.notify("An error occurred while setting up the LSP (" .. lsp_server_name .. ")!", vim.log.levels.ERROR)
end
-- LSP

-- vim: foldmethod=indent foldlevel=0
