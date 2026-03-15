-- LSP configuration for Python
-- Uses pyright for type checking and completions, black via EFM for formatting,
-- and debugpy for DAP debugging. Strict type checking mode is enabled.
---@module "languages.base.lsp.python"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "efm",
    "pyright",
    "debugpy",
    "black",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

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

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    -- Register black as a formatter through EFM.
    -- black -q suppresses the "reformatted" status messages on stderr.
    local efm_config = {
        {
            server_name = "black",
            fPrefix = "black",
            formatCommand = "black -q -",
            formatStdin = true,
            rootMarkers = { "pyproject.toml" },
        },
    }
    lsp_manager.setup_efm(_G.LVIM.file_types.python, efm_config)

    -- DAP: debugpy adapter.
    -- global.mason_path corresponds to _G.LVIM.global.mason_path (LvimGlobal).
    -- The adapter is registered twice (duplicate block kept from original).
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
            stopOnEntry = true,   -- break at the first line so variables can be inspected early
            justMyCode = false,   -- step into third-party code / stdlib for deep debugging
            -- Prefer the active virtualenv; fall back to debugpy's own bundled Python
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
            program = "${file}",  -- always debug the active buffer
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
        filetypes = _G.LVIM.file_types.python,
        settings = {
            python = {
                analysis = {
                    -- Strict mode: report all type errors including missing type annotations.
                    -- Switch to "basic" or "off" for legacy codebases.
                    typeCheckingMode = "strict",
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    -- "workspace" analyses all files, not just those open in the editor
                    diagnosticMode = "workspace",
                },
            },
        },
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---@param client any
        ---@param bufnr  integer
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        -- Advertise codeLens capability at both textDocument and workspace levels
        -- so pyright can show reference/implementation counts and workspace code lenses.
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
    ---@param _ table
    ---@param key string
    ---@return table|nil
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
