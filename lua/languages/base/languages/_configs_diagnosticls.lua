local global = require("core.global")
local languages_setup = require("languages.base.utils")
local nvim_lsp_util = require("lspconfig/util")
local default_debouce_time = 150
local M = {}

M.config = {
    linters_filetypes = {
        c = "cpplint",
        cpp = "cpplint",
        html = "tidy",
        lua = "luacheck",
        objc = "cpplint",
        objcpp = "cpplint",
        python = "pylint",
        sh = "shellcheck",
        vim = "vint",
    },
    linters = {
        --- html
        -- https://github.com/htacg/tidy-html5
        -- https://www.html-tidy.org
        -- INSTALL INSTRUCTION: see instruction
        tidy = {
            sourceName = "tidy",
            command = "tidy",
            args = { "-e", "-q" },
            rootPatterns = { "tidy.txt" },
            isStderr = true,
            debounce = 100,
            offsetLine = 0,
            offsetColumn = 0,
            formatLines = 1,
            formatPattern = {
                "^.*?(\\d+).*?(\\d+)\\s+-\\s+([^:]+):\\s+(.*)(\\r|\\n)*$",
                {
                    line = 1,
                    column = 2,
                    endLine = 1,
                    endColumn = 2,
                    message = 4,
                    security = 3,
                },
            },
            securities = {
                [1] = "error",
                [2] = "warning",
            },
        },
        -- c, cpp, objc, objcpp
        -- https://github.com/cpplint/cpplint
        -- INSTALL: pip3 install cpplint
        -- AUTOINSTALL !!!
        cpplint = {
            command = "cpplint",
            sourceName = "cpplint",
            args = { "%file" },
            rootPatterns = { "CPPLINT.cfg" },
            debounce = 100,
            isStderr = true,
            isStdout = false,
            offsetLine = 0,
            offsetColumn = 0,
            formatPattern = {
                "^[^:]+:(\\d+):(\\d+)?\\s+([^:]+?)\\s\\[(\\d)\\]$",
                {
                    line = 1,
                    column = 2,
                    message = 3,
                    security = 4,
                },
            },
        },
        -- lua
        -- https://github.com/mpeterv/luacheck
        -- https://luacheck.readthedocs.io/en/stable
        -- INSTALL: luarocks install luacheck
        -- AUTOINSTALL !!!
        luacheck = {
            sourceName = "luacheck",
            command = "luacheck",
            args = {
                "--formatter",
                "plain",
                "--codes",
                "--ranges",
                "--filename",
                "%filepath",
                "-",
            },
            rootPatterns = { ".luacheckrc" },
            formatPattern = {
                "^[^:]+:(\\d+):(\\d+)-(\\d+):\\s+\\((\\w)\\d+\\)\\s+(.*)$",
                {
                    line = 1,
                    column = 2,
                    endLine = 1,
                    endColumn = 3,
                    security = 4,
                    message = 5,
                },
            },
            debounce = 100,
            securities = {
                W = "warning",
                E = "error",
            },
        },
        -- python
        -- https://github.com/PyCQA/pylint
        -- https://pylint.org
        -- INSTALL: pip3 install pylint
        -- AUTOINSTALL !!!
        pylint = {
            sourceName = "pylint",
            command = "pylint",
            rootPatterns = { ".pylintrc" },
            debounce = 100,
            args = {
                "--output-format",
                "text",
                "--score",
                "no",
                "--msg-template",
                "'{line}:{column}:{category}:{msg} ({msg_id}:{symbol})'",
                "%file",
            },
            formatPattern = {
                "^(\\d+?):(\\d+?):([a-z]+?):(.*)$",
                {
                    line = 1,
                    column = 2,
                    security = 3,
                    message = 4,
                },
            },
            securities = {
                informational = "hint",
                refactor = "info",
                convention = "info",
                warning = "warning",
                error = "error",
                fatal = "error",
            },
            offsetColumn = 1,
            formatLines = 1,
        },
        -- vim
        -- https://github.com/Vimjas/vint
        -- INSTALL: pip3 install vim-vint
        -- AUTOINSTALL !!!
        vint = {
            sourceName = "vint",
            command = "vint",
            rootPatterns = { ".vintrc.yaml" },
            debounce = 100,
            args = { "--enable-neovim", "-" },
            offsetLine = 0,
            offsetColumn = 0,
            formatLines = 1,
            formatPattern = {
                "[^:]+:(\\d+):(\\d+):\\s*(.*)(\\r|\\n)*$",
                {
                    line = 1,
                    column = 2,
                    message = 3,
                },
            },
        },
        -- sh
        -- https://github.com/koalaman/shellcheck
        -- INSTALL INSTRUCTION: https://github.com/koalaman/shellcheck#installing
        -- AUTOINSTALL !!!
        shellcheck = {
            sourceName = "shellcheck",
            command = "shellcheck",
            debounce = 100,
            args = { "--format=gcc", "-" },
            offsetLine = 0,
            offsetColumn = 0,
            formatLines = 1,
            formatPattern = {
                "^[^:]+:(\\d+):(\\d+):\\s+([^:]+):\\s+(.*)$",
                {
                    line = 1,
                    column = 2,
                    message = 4,
                    security = 3,
                },
            },
            securities = {
                error = "error",
                warning = "warning",
                note = "info",
            },
        },
    },
    formatters_filetypes = {
        html = "prettier",
        json = "prettier",
        lua = "stylua",
        markdown = "prettier",
        python = "black",
        sh = "shfmt",
        vim = "prettier",
    },
    formatters = {
        -- html, json
        -- https://prettier.io
        -- INSTALL: npm install -g prettier
        -- AUTOINSTALL !!!
        prettier = {
            command = "prettier",
            args = { "--stdin-filepath", "%filepath", "--single-quote", "--tab-width=4" },
            rootPatterns = {},
            isStdout = true,
            isStderr = false,
            doesWriteToFile = false,
        },
        -- lua
        -- https://github.com/JohnnyMorganz/StyLua
        -- INSTALL: cargo install stylua
        -- AUTOINSTALL !!!
        stylua = {
            command = "stylua",
            args = { "--search-parent-directories", "--stdin-filepath", "%filepath", "--", "-" },
        },
        -- python
        -- https://github.com/hhatto/autopep8
        -- https://pypi.org/project/autopep8
        -- INSTALL: pip3 install autopep8
        -- AUTOINSTALL !!!
        black = {
            command = "black",
            args = { "--quiet", "-" },
        },
        -- sh
        -- https://github.com/mvdan/sh
        -- INSTALL: go install mvdan.cc/sh/v3/cmd/shfmt@latest
        -- AUTOINSTALL !!!
        shfmt = {
            command = "shfmt",
            args = {
                "-i",
                "2",
                "-bn",
                "-ci",
                "-sr",
            },
        },
    },
}

M.default_config = function(file_types, pid_name)
    return {
        flags = {
            debounce_text_changes = default_debouce_time,
        },
        autostart = true,
        filetypes = file_types,
        init_options = {
            filetypes = M.config.linters_filetypes,
            linters = M.config.linters,
            formatFiletypes = M.config.formatters_filetypes,
            formatters = M.config.formatters,
        },
        on_attach = function(client, bufnr)
            client.offset_encoding = "utf-16"
            table.insert(global["languages"][pid_name]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client, bufnr)
            languages_setup.document_formatting(client, bufnr)
        end,
        on_init = function(client, results)
            if results.offsetEncoding then
                client.offset_encoding = results.offsetEncoding
            end

            if client.config.settings then
                client.notify("workspace/didChangeConfiguration", {
                    settings = client.config.settings,
                })
            end
        end,
        capabilities = languages_setup.get_capabilities(),
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
    }
end

return M
