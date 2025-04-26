local dap = require("dap")
local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_utils = require("languages.utils")

local lsp_server_name = "lua-language-server"

-- EFM
local efm_config = {
    {
        server_name = "stylua",
        fPrefix = "stylua",
        formatCommand = "stylua -",
        formatStdin = true,
        rootMarkers = { "stylua.toml", ".stylua.toml" },
    },
}

lsp_utils.setup_efm(_G.file_types.lua, efm_config)
-- EFM

-- DAP
dap.adapters.nlua = function(callback, config)
    callback({ type = "server", host = config.host, port = config.port })
end
dap.configurations.lua = {
    {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance",
        host = function()
            local value = vim.fn.input("Host [127.0.0.1]: ")
            if value ~= "" then
                return value
            end
            return "127.0.0.1"
        end,
        port = function()
            local input = vim.fn.input("Port [8086]: ")
            if input == "" then
                return 8080
            end

            local value = tonumber(input)
            if not value then
                vim.notify("Invalid port number, using default 8086", vim.log.levels.WARN)
                return 8086
            end
            return value
        end,
    },
}
-- DAP

-- LSP
local lsp_server_config = {
    name = "lua",
    cmd = { lsp_server_name },
    filetypes = _G.file_types.lua,
    root_markers = {
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
        ".git",
    },
    settings = {
        Lua = {
            format = {
                enable = false,
            },
            hint = {
                enable = true,
                arrayIndex = "All",
                await = true,
                paramName = "All",
                paramType = true,
                semicolon = "Disable",
                setType = true,
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            runtime = {
                version = "LuaJIT",
                special = {
                    reload = "require",
                },
            },
            diagnostics = {
                globals = {
                    "vim",
                    "use",
                    "packer_plugins",
                    "NOREF_NOERR_TRUNC",
                },
            },
            telemetry = {
                enable = false,
            },
        },
    },
    on_attach = function(client, bufnr)
        setup_diagnostics.keymaps(client, bufnr)
        setup_diagnostics.document_highlight(client, bufnr)
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

_G.lua_lsp_config = lsp_server_config

if lsp_server_result then
    return lsp_server_config
else
    vim.notify("An error occurred while setting up the LSP (" .. lsp_server_name .. ")!", vim.log.levels.ERROR)
end
-- LSP

-- vim: foldmethod=indent foldlevel=0
