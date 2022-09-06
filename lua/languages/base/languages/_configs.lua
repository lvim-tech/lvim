local global = require("core.global")
local languages_setup = require("languages.base.utils")
local nvim_lsp_util = require("lspconfig/util")
local navic = require("nvim-navic")
local lsp_inlayhints = require("lsp-inlayhints")
local default_debouce_time = 150
local M = {}

M.default_config = function(file_types, pid_name)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            table.insert(global["languages"][pid_name]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client, bufnr)
            languages_setup.document_formatting(client, bufnr)
            if vim.fn.has("nvim-0.8") == 1 then
                navic.attach(client, bufnr)
                lsp_inlayhints.on_attach(client, bufnr, true)
            end
        end,
        capabilities = languages_setup.get_capabilities(),
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
    }
end

M.without_formatting = function(file_types, pid_name)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            table.insert(global["languages"][pid_name]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client, bufnr)
            if vim.fn.has("nvim-0.8") == 1 then
                navic.attach(client, bufnr)
                lsp_inlayhints.on_attach(client, bufnr, true)
            end
        end,
        capabilities = languages_setup.get_capabilities(),
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
    }
end

M.without_winbar_config = function(file_types, pid_name)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            table.insert(global["languages"][pid_name]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client, bufnr)
            languages_setup.document_formatting(client, bufnr)
        end,
        capabilities = languages_setup.get_capabilities(),
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
    }
end

M.go = function(file_types, pid_name)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            table.insert(global["languages"][pid_name]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client, bufnr)
            languages_setup.document_formatting(client, bufnr)
            if vim.fn.has("nvim-0.8") == 1 then
                navic.attach(client, bufnr)
                lsp_inlayhints.on_attach(client, bufnr, true)
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
        },
        capabilities = languages_setup.get_capabilities(),
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
    }
end

M.lua = function(file_types, pid_name)
    local luadev = require("lua-dev").setup({
        lspconfig = {
            flags = {
                debounce_text_changes = default_debouce_time,
            },
            autostart = true,
            filetypes = file_types,
            on_attach = function(client, bufnr)
                table.insert(global["languages"][pid_name]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                languages_setup.document_highlight(client, bufnr)
                if vim.fn.has("nvim-0.8") == 1 then
                    navic.attach(client, bufnr)
                    lsp_inlayhints.on_attach(client, bufnr, true)
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
            capabilities = languages_setup.get_capabilities(),
            root_dir = function(fname)
                return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
            end,
        },
    })
    return luadev
end

M.jsts_config = function(file_types, pid_name)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            table.insert(global["languages"][pid_name]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client, bufnr)
            languages_setup.document_formatting(client, bufnr)
            if vim.fn.has("nvim-0.8") == 1 then
                navic.attach(client, bufnr)
            end
            local ts_utils = require("nvim-lsp-ts-utils")
            ts_utils.setup({
                debug = true,
            })
            ts_utils.setup_client(client)
        end,
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
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
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                },
            },
        },
        capabilities = languages_setup.get_capabilities(),
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
    }
end

M.angular_config = function(file_types, pid_name)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            table.insert(global["languages"][pid_name]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client, bufnr)
            languages_setup.document_formatting(client, bufnr)
        end,
        capabilities = languages_setup.get_capabilities(),
        root_dir = nvim_lsp_util.root_pattern("angular.json"),
    }
end

M.ember_config = function(file_types, pid_name)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        on_attach = function(client, bufnr)
            table.insert(global["languages"][pid_name]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client, bufnr)
            languages_setup.document_formatting(client, bufnr)
        end,
        capabilities = languages_setup.get_capabilities(),
        root_dir = nvim_lsp_util.root_pattern("ember-cli-build.js"),
    }
end

return M
