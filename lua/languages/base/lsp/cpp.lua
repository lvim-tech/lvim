local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")
local dap_utils = require("languages.utils.dap_fn")
local dap = require("dap")

local lsp_dependencies = {
    "efm",
    "clangd",
    "cpptools",
}

local lsp_config = nil
local root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git",
}

local function switch_source_header(bufnr)
    local method_name = "textDocument/switchSourceHeader"
    local client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
    if not client then
        return vim.notify(
            ("method %s is not supported by any servers active on the current buffer"):format(method_name)
        )
    end
    local params = vim.lsp.util.make_text_document_params(bufnr)
    client.request(method_name, params, function(err, result)
        if err then
            error(tostring(err))
        end
        if not result then
            vim.notify("corresponding file cannot be determined")
            return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
    end, bufnr)
end

local function symbol_info()
    local bufnr = vim.api.nvim_get_current_buf()
    local clangd_client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
    ---@diagnostic disable-next-line: missing-parameter
    if not clangd_client or not clangd_client.supports_method("textDocument/symbolInfo") then
        return vim.notify("Clangd client not found", vim.log.levels.ERROR)
    end
    local win = vim.api.nvim_get_current_win()
    local params = vim.lsp.util.make_position_params(win, clangd_client.offset_encoding)
    clangd_client.request("textDocument/symbolInfo", params, function(err, res)
        if err or #res == 0 then
            -- Clangd always returns an error, there is not reason to parse it
            return
        end
        local container = string.format("container: %s", res[1].containerName) ---@type string
        local name = string.format("name: %s", res[1].name) ---@type string
        vim.lsp.util.open_floating_preview({ name, container }, "", {
            height = 2,
            width = math.max(string.len(name), string.len(container)),
            focusable = false,
            focus = false,
            border = "single",
            title = "Symbol Info",
        })
    end, bufnr)
end

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    local efm_config = {
        {
            server_name = "cpplint",
            lPrefix = "cpplint",
            lintCommand = "cpplint ${INPUT}",
            lintStdin = true,
            rootMarkers = { "cpplint.cfg" },
        },
    }
    lsp_manager.setup_efm(_G.file_types.cpp, efm_config)

    dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = global.mason_path .. "/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
    }
    ---@type table<string, any>
    dap.configurations = dap.configurations or {}
    dap.configurations.cpp = dap.configurations.cpp or {}
    dap.configurations.cpp = {
        {
            name = "Launch file",
            type = "cppdbg",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = true,
            setupCommands = {
                {
                    text = "-enable-pretty-printing",
                    description = "enable pretty printing",
                    ignoreFailures = false,
                },
            },
        },
        {
            name = "Attach to gdbserver :1234",
            type = "cppdbg",
            request = "attach",
            processId = dap_utils.fzf_process_picker,
            MIMode = "gdb",
            miDebuggerServerAddress = "localhost:1234",
            miDebuggerPath = "/usr/bin/gdb",
            cwd = "${workspaceFolder}",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            useExtendedRemote = true,
            setupCommands = {
                {
                    text = "-enable-pretty-printing",
                    description = "enable pretty printing",
                    ignoreFailures = false,
                },
            },
        },
    }

    lsp_config = {
        name = "cpp",
        cmd = {
            "clangd",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--background-index",
            "--suggest-missing-includes",
        },
        filetypes = _G.file_types.cpp,
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
            vim.api.nvim_buf_create_user_command(0, "LspClangdSwitchSourceHeader", function()
                switch_source_header(0)
            end, { desc = "Switch between source/header" })
            vim.api.nvim_buf_create_user_command(0, "LspClangdShowSymbolInfo", function()
                symbol_info()
            end, { desc = "Show symbol info" })
        end,
        capabilities = (function()
            local capabilities = setup_diagnostics.get_capabilities()
            capabilities.textDocument.codeLens = {
                dynamicRegistration = true,
                resolveProvider = true,
            }
            return capabilities
        end)(),
        settings = {
            clangd = {
                callHierarchy = true,
                semanticHighlighting = true,
                checkUpdates = true,
                fallbackFlags = { "-std=c++17" },
            },
        },
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
