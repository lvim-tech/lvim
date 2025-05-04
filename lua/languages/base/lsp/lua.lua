local dap = require("dap")
local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

local lsp_server_name = "lua-language-server"

lsp_installer.ensure_mason_tools({
    "efm",
    "lua-language-server",
    "stylua",
}, function()
    local efm_config = {
        {
            server_name = "stylua",
            fPrefix = "stylua",
            formatCommand = "stylua -",
            formatStdin = true,
            rootMarkers = { "stylua.toml", ".stylua.toml" },
        },
    }
    lsp_manager.setup_efm(_G.file_types.lua, efm_config)

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

    _G.lua_lsp_config = lsp_server_config
    lsp_manager.start_language_server("lua", true, lsp_server_config)

    return lsp_server_config
end)

-- vim: foldmethod=indent foldlevel=1
