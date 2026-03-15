-- LSP configuration for Lua
-- Uses lua-language-server (LuaLS) with the Neovim runtime in the workspace
-- library, stylua via EFM for formatting, and the nlua DAP adapter for
-- attaching to a running Neovim instance (Osyris / one.nvim workflow).
---@module "languages.base.lsp.lua"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "efm",
    "lua-language-server",
    "stylua",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for Lua/Neovim config projects
local root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",  -- selene linter config
    "selene.yml",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    -- stylua reads from stdin (-) and writes formatted output to stdout.
    -- rootMarkers ensure EFM only activates stylua when a config file is present.
    local efm_config = {
        {
            server_name = "stylua",
            fPrefix = "stylua",
            formatCommand = "stylua -",
            formatStdin = true,
            rootMarkers = { "stylua.toml", ".stylua.toml" },
        },
    }
    lsp_manager.setup_efm(_G.LVIM.file_types.lua, efm_config)

    -- DAP: nlua connects to an already-running Neovim instance that has loaded
    -- the osv (one-small-step-for-vimkind) plugin and called require("osv").launch().
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
            -- Prompt for host at launch time so remote instances can be targeted
            host = function()
                local value = vim.fn.input("Host [127.0.0.1]: ")
                if value ~= "" then
                    return value
                end
                return "127.0.0.1"
            end,
            -- Prompt for port; default 8086 matches the osv.launch() default
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
        filetypes = _G.LVIM.file_types.lua,
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
                    -- Disable LuaLS's built-in formatter; stylua (via EFM) is used instead
                    enable = false,
                },
                hint = {
                    enable = true,
                    arrayIndex = "All",    -- show indices for all array literal items
                    await = true,          -- annotate async return values
                    paramName = "All",     -- show parameter names at every call site
                    paramType = true,
                    semicolon = "Disable", -- don't suggest adding semicolons
                    setType = true,        -- show inferred type for set operations
                },
                workspace = {
                    -- Include the Neovim runtime and LSP Lua stubs so that `vim.*` APIs
                    -- are known to LuaLS without needing a separate neodev plugin.
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
                    -- Suppress the "Do you want to configure third-party library?" dialog
                    checkThirdParty = false,
                },
                runtime = {
                    version = "LuaJIT",  -- Neovim uses LuaJIT, not standard Lua 5.x
                    special = {
                        reload = "require",  -- treat reload() as an alias for require()
                    },
                },
                diagnostics = {
                    -- Declare well-known Neovim globals to suppress "undefined global" warnings
                    globals = {
                        "vim",
                        "use",
                        "packer_plugins",
                        "NOREF_NOERR_TRUNC",
                    },
                    workspaceDelay = 3000,   -- ms before workspace-wide diagnostics run
                    workspaceRate = 100,     -- percentage of CPU budget for workspace checks
                },
                telemetry = {
                    enable = false,  -- opt out of LuaLS telemetry
                },
                completion = {
                    workspaceWord = false,   -- don't complete from raw identifier scan
                    showWord = "Disable",    -- hide word-based completion candidates
                },
            },
        },
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---@param client any
        ---@param bufnr  integer
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
