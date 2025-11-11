local icons = require("configs.base.ui.icons")

return {
    blink_cmp = {
        opts = function()
            local ls = require("luasnip")
            ls.config.set_config({
                enable_autosnippets = true,
                store_selection_keys = "<Tab>",
            })
            require("luasnip.loaders.from_vscode").load({
                paths = { vim.fn.stdpath("config") .. "/snippets/vscode" },
            })
            require("luasnip.loaders.from_lua").load({
                paths = { vim.fn.stdpath("config") .. "/snippets/lua" },
            })
            return {
                enabled = function()
                    local disabled = false
                    local success, node = pcall(vim.treesitter.get_node)
                    disabled = disabled or (vim.bo.buftype == "prompt")
                    disabled = disabled or (vim.bo.filetype == "typr")
                    disabled = disabled or (vim.bo.filetype == "lvim-space-search-input")
                    disabled = disabled or (vim.bo.filetype == "lvim-space-tabs-input")
                    disabled = disabled or (vim.fn.reg_recording() ~= "")
                    disabled = disabled or (vim.fn.reg_executing() ~= "")
                    disabled = disabled
                        or (
                            success
                            and node ~= nil
                            and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type())
                        )
                    disabled = disabled or vim.g.__ui_cmdline_active == true
                    disabled = disabled or vim.g.__ui_confirm_msg ~= nil
                    disabled = disabled or vim.g.__ui_list_msg ~= nil
                    return not disabled
                end,
                sources = {
                    default = { "lsp", "path", "snippets", "buffer", "dadbod", "ripgrep", "emoji" },
                    providers = {
                        lsp = {
                            name = "lsp",
                            module = "blink.cmp.sources.lsp",
                            fallbacks = { "buffer" },
                            score_offset = 90,
                        },
                        path = {
                            name = "Path",
                            module = "blink.cmp.sources.path",
                            score_offset = 25,
                            fallbacks = { "buffer" },
                            opts = {
                                trailing_slash = false,
                                label_trailing_slash = true,
                                get_cwd = function(ctx)
                                    return vim.fn.expand(("#%d:p:h"):format(ctx.bufnr))
                                end,
                                show_hidden_files_by_default = true,
                            },
                        },
                        buffer = {
                            name = "Buffer",
                            module = "blink.cmp.sources.buffer",
                            max_items = 3,
                            min_keyword_length = 3,
                            score_offset = 15,
                        },
                        snippets = {
                            name = "snippets",
                            enabled = true,
                            max_items = 8,
                            min_keyword_length = 2,
                            module = "blink.cmp.sources.snippets",
                            score_offset = 85,
                        },
                        ripgrep = {
                            module = "blink-cmp-rg",
                            name = "Ripgrep",
                            opts = {
                                prefix_min_len = 3,
                                get_command = function(_, prefix)
                                    return {
                                        "rg",
                                        "--no-config",
                                        "--json",
                                        "--word-regexp",
                                        "--ignore-case",
                                        "--",
                                        prefix .. "[\\w_-]+",
                                        vim.fs.root(0, ".git") or vim.fn.getcwd(),
                                    }
                                end,
                                get_prefix = function(context)
                                    return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or ""
                                end,
                            },
                        },
                        emoji = {
                            module = "blink-emoji",
                            name = "Emoji",
                            score_offset = 15,
                            opts = { insert = true },
                        },
                        dadbod = {
                            name = "Dadbod",
                            module = "vim_dadbod_completion.blink",
                        },
                    },
                },
                appearance = {
                    kind_icons = icons.cmp.lsp_symbols,
                },
                completion = {
                    accept = { auto_brackets = { enabled = true } },
                    trigger = {
                        show_on_insert_on_trigger_character = false,
                    },
                    menu = {
                        border = "padded",
                        draw = {
                            padding = 2,
                            gap = 1,
                            treesitter = { "lsp" },
                            columns = {
                                { "kind_icon" },
                                { "label", "label_description", gap = 1 },
                                { "kind" },
                                { "source_name" },
                            },
                            components = {
                                label = {
                                    text = require("colorful-menu").blink_components_text,
                                    highlight = require("colorful-menu").blink_components_highlight,
                                },
                                source_name = {
                                    text = function(ctx)
                                        local name = ctx.source_name
                                        if name == "lsp" then
                                            return "[" .. string.upper(name) .. "]"
                                        end
                                        return "[" .. name:sub(1, 1):upper() .. name:sub(2) .. "]"
                                    end,
                                    highlight = function(ctx)
                                        local source = ctx.source_name
                                        if source == "lsp" then
                                            return "BlinkCmpSourceLSP"
                                        elseif source == "Buffer" then
                                            return "BlinkCmpSourceBuffer"
                                        elseif source == "Path" then
                                            return "BlinkCmpSourcePath"
                                        else
                                            return "BlinkCmpSource"
                                        end
                                    end,
                                },
                            },
                        },
                        cmdline_position = function()
                            if vim.g.ui_cmdline_pos ~= nil then
                                local pos = vim.g.ui_cmdline_pos
                                return { pos[1] - 1, pos[2] }
                            end
                            local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
                            return { vim.o.lines - height - 1, 0 }
                        end,
                    },
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 10,
                        treesitter_highlighting = true,
                        window = { border = "padded" },
                    },
                    ghost_text = { enabled = true },
                },
                signature = { window = { border = "padded" } },
                keymap = {
                    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                    ["<C-e>"] = { "hide", "fallback" },
                    ["<CR>"] = { "accept", "fallback" },
                    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                    ["<Down>"] = { "select_next", "fallback" },
                    ["<Up>"] = { "select_prev", "fallback" },
                    ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
                    ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
                    ["<C-h>"] = { "scroll_documentation_down", "fallback" },
                    ["<C-l>"] = { "scroll_documentation_up", "fallback" },
                    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                },
                cmdline = {
                    completion = { menu = { auto_show = true } },
                    keymap = {
                        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                        ["<C-e>"] = { "hide", "fallback" },
                        ["<CR>"] = { "accept", "fallback" },
                        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                        ["<Down>"] = { "select_next", "fallback" },
                        ["<Up>"] = { "select_prev", "fallback" },
                        ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
                        ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
                        ["<C-h>"] = { "scroll_documentation_down", "fallback" },
                        ["<C-l>"] = { "scroll_documentation_up", "fallback" },
                    },
                    sources = function()
                        local type = vim.fn.getcmdtype()
                        if type == "/" or type == "?" then
                            return { "buffer" }
                        else
                            return { "cmdline", "path" }
                        end
                    end,
                },
            }
        end,
    },
    nvim_autopairs = {
        opts = {},
    },
    nvim_ts_autotag = {
        opts = {},
    },
    nvim_surround = {
        opts = {},
    },
}

-- vim: foldmethod=indent foldlevel=1
