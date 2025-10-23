local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

local lsp_dependencies = {
    "efm",
    "pyright",
    "debugpy",
    "black",
}

local lsp_config = nil
local root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    local efm_config = {
        {
            server_name = "black",
            fPrefix = "black",
            formatCommand = "black -q -",
            formatStdin = true,
            rootMarkers = { "pyproject.toml" },
        },
    }
    lsp_manager.setup_efm(_G.file_types.python, efm_config)
    dap.adapters.python = {
        type = "executable",
        command = global.mason_path .. "/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
    }

    dap.adapters.python = {
        type = "executable",
        command = global.mason_path .. "/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
    }
    ---@type table<string, any>
    dap.configurations = dap.configurations or {}
    dap.configurations.python = dap.configurations.python or {}
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

    lsp_config = {
        name = "python",
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = _G.file_types.python,
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = "strict", -- Строг режим за откриване на грешки!
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "workspace",
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
        capabilities = (function()
            local capabilities = setup_diagnostics.get_capabilities()
            capabilities.textDocument = capabilities.textDocument or {}
            capabilities.textDocument.codeLens = {
                dynamicRegistration = true,
                resolveProvider = true,
            }
            capabilities.workspace = capabilities.workspace or {}
            capabilities.workspace.codeLens = {
                refreshSupport = true,
            }
            return capabilities
        end)(),
    }
end)

return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
