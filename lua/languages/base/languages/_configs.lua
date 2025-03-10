local global = require("core.global")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local nvim_lsp_util = require("lspconfig/util")
local navic = require("nvim-navic")
local default_debouce_time = 150
local M = {}

M.default_config = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
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
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.without_formatting = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = setup_diagnostics.get_capabilities(),
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.without_winbar_config = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.astro_config = function(file_types)
    return {
        autostart = true,
        filetypes = file_types,
        init_options = {
            typescript = {
                tsdk = vim.fs.normalize(
                    "~/.local/share/nvim/mason/packages/astro-language-server/node_modules/typescript/lib"
                ),
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            -- setup_diagnostics.document_formatting(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = setup_diagnostics.get_capabilities(),
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.cpp_config = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = setup_diagnostics.get_cpp_capabilities(),
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.omnisharp_config = function(file_types)
    return {
        cmd = { "dotnet", global.mason_path .. "/packages/omnisharp/OmniSharp.dll" },
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
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
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.elixir_config = function(file_types)
    return {
        cmd = { global.mason_path .. "/bin/elixir-ls" },
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
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
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.python_config = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
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
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
        settings = {
            pylsp = {
                plugins = {
                    black = { enabled = true, line_length = 79 },
                    autopep8 = { enabled = false },
                    yapf = { enabled = false },
                },
            },
        },
    }
end

M.rust = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
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
            ["rust-analyzer"] = {
                assist = {
                    importEnforceGranularity = true,
                    importPrefix = "crate",
                },
                cargo = {
                    allFeatures = true,
                },
                checkOnSave = {
                    command = "clippy",
                },
                inlayHints = { locationLinks = false },
                diagnostics = {
                    enable = true,
                    experimental = {
                        enable = true,
                    },
                },
            },
        },
        capabilities = setup_diagnostics.get_capabilities(),
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.go = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
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
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.lua = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
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
        capabilities = setup_diagnostics.get_capabilities(),
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.groovy_config = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        cmd = { "groovy-language-server" },
        autostart = true,
        filetypes = file_types,
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
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.jsts_config = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
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
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                },
            },
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                },
            },
        },
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

M.angular_config = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = setup_diagnostics.get_capabilities(),
        root_dir = nvim_lsp_util.root_pattern("angular.json"),
    }
end

M.ember_config = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
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
        root_dir = nvim_lsp_util.root_pattern("ember-cli-build.js"),
    }
end

M.yaml_config = function(file_types)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        settings = {
            yaml = {
                keyOrdering = false,
            },
        },
        capabilities = setup_diagnostics.get_capabilities(),
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
    }
end

return M
