local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

local lsp_dependencies = {
    "efm",
    "lua-language-server",
    "stylua",
}

local lsp_config = nil
local root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
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
    ---@type table<string, any>
    dap.configurations = dap.configurations or {}
    dap.configurations.lua = dap.configurations.lua or {}
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

    lsp_config = {
        name = "lua",
        cmd = { "lua-language-server" },
        filetypes = _G.file_types.lua,
        settings = {
            Lua = {
                codeLens = {
                    enable = true,
                    referencesCodeLens = {
                        enable = true,
                    },
                    implementationsCodeLens = {
                        enable = true,
                    },
                    definitionCodeLens = {
                        enable = true,
                    },
                },
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
                    library = {
                        vim.fn.expand("$VIMRUNTIME/lua"),
                        vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                        vim.fn.expand("~/.config/nvim"),
                    },
                    maxPreload = 2000,
                    preloadFileSize = 150,
                    ignoreDir = {
                        ".git",
                        "node_modules",
                        ".cache",
                    },
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
                    workspaceDelay = 3000,
                    workspaceRate = 100,
                },
                telemetry = {
                    enable = false,
                },
                completion = {
                    workspaceWord = false,
                    showWord = "Disable",
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
