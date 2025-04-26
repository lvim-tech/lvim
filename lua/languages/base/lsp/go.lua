local dap = require("dap")
local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_utils = require("languages.utils")

local lsp_server_name = "gopls"
local debbuger_server_name = "delve"

-- EFM
local efm_server_config = {
    {
        server_name = "golangci-lint",
        lPrefix = "golint",
        lintCommand = "golangci-lint ${INPUT}",
        lintStdin = true,
        rootMarkers = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" },
    },
}

lsp_utils.setup_efm(_G.file_types.go, efm_server_config)
-- EFM

-- DAP
local debbuger_server_async = lsp_utils.is_lsp_server_installed(debbuger_server_name)

local debbuger_server_result
while not debbuger_server_result do
    debbuger_server_result = debbuger_server_async()
    vim.wait(100)
end

if debbuger_server_result then
    dap.adapters.go = function(callback)
        local handle
        local port = 38697
        handle = vim.loop.spawn("dlv", {
            args = { "dap", "-l", "127.0.0.1:" .. port },
            detached = true,
        }, function(_)
            handle:close()
        end)
        vim.defer_fn(function()
            callback({ type = "server", host = "127.0.0.1", port = port })
        end, 100)
    end
    dap.configurations.go = {
        {
            type = "go",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
        },
        {
            type = "go",
            name = "Launch test",
            request = "launch",
            mode = "test",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
        },
    }
end
-- DAP

-- LSP
local mod_cache = nil

---@param fname string
---@return string?
local function get_root(fname)
    if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
        local clients = vim.lsp.get_clients({ name = "gopls" })
        if #clients > 0 then
            return clients[#clients].config.root_dir
        end
    end
    return vim.fs.root(fname, { "go.work", "go.mod", ".git" })
end

local lsp_server_config = {
    name = "go",
    cmd = { "gopls" },
    filetypes = _G.file_types.go,
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if mod_cache then
            on_dir(get_root(fname))
            return
        end
        local cmd = { "go", "env", "GOMODCACHE" }
        vim.system(cmd, { text = true }, function(output)
            if output.code == 0 then
                if output.stdout then
                    mod_cache = vim.trim(output.stdout)
                end
                on_dir(get_root(fname))
            else
                vim.notify(("[gopls] cmd failed with code %d: %s\n%s"):format(output.code, cmd, output.stderr))
            end
        end)
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
    settings = {
        gopls = {
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
        opts = {
            inlay_hints = { enabled = true },
        },
    },
    capabilities = setup_diagnostics.get_capabilities(),
}

local lsp_server_async = lsp_utils.is_lsp_server_installed(lsp_server_name)

local lsp_server_result
while not lsp_server_result do
    lsp_server_result = lsp_server_async()
    vim.wait(100)
end

_G.go_lsp_config = lsp_server_config

if lsp_server_result then
    return lsp_server_config
else
    vim.notify("An error occurred while setting up the LSP (" .. lsp_server_name .. ")!", vim.log.levels.ERROR)
end
-- LSP

-- vim: foldmethod=indent foldlevel=0
