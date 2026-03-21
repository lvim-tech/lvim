-- LSP configuration for Python
-- Uses pyright for type checking and completions, black via EFM for formatting,
-- and debugpy for DAP debugging. Strict type checking mode is enabled.
---@module "modules.base.configs.languages.lsp.servers.python"
local ft = require("modules.base.configs.languages.lsp.file_types")

---@type string[]  Root-directory markers covering common Python project layouts
local root_markers = {
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
}

-- Register black as a formatter through EFM.
-- black -q suppresses the "reformatted" status messages on stderr.
local efm_config = {
    {
        server_name = "black",
        formatCommand = "black -q -",
        formatStdin = true,
        rootMarkers = { "pyproject.toml" },
    },
}

local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

local function python_path()
    local venv = os.getenv("VIRTUAL_ENV")
    if venv then
        return venv .. "/bin/python"
    end
    if vim.fn.executable(debugpy_python) == 1 then
        return debugpy_python
    end
    return "python"
end

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "python",
            cmd = { "pyright-langserver", "--stdio" },
            settings = {
                python = {
                    analysis = {
                        typeCheckingMode = "strict",
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "workspace",
                    },
                },
            },
            on_attach = function(client, bufnr)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end,
        },
    },

    efm = {
        filetypes = ft.python.filetypes,
        tools = efm_config,
    },

    dap = {
        adapters = {
            python = {
                type = "executable",
                command = debugpy_python,
                args = { "-m", "debugpy.adapter" },
            },
        },
        configurations = {
            python = {
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
                    pythonPath = python_path,
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
                    pythonPath = python_path,
                    cwd = "${workspaceFolder}",
                },
            },
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
